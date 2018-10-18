/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package me.nereo.multi_image_selector;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.database.Cursor;
import android.graphics.Color;
import android.graphics.Point;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.provider.MediaStore;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.app.LoaderManager;
import android.support.v4.content.ContextCompat;
import android.support.v4.content.CursorLoader;
import android.support.v4.content.Loader;
import android.text.TextUtils;
import android.util.Log;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.GridView;
import android.widget.ListPopupWindow;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import com.apicloud.UIAlbumBrowser.UIAlbumBrowser;
import com.uzmap.pkg.uzkit.UZUtility;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import me.nereo.multi_image_selector.adapter.FolderAdapter;
import me.nereo.multi_image_selector.adapter.ImageGridAdapter;
import me.nereo.multi_image_selector.adapter.ImageGridAdapter.OnItemClickListener;
import me.nereo.multi_image_selector.bean.Folder;
import me.nereo.multi_image_selector.bean.Image;
import me.nereo.multi_image_selector.utils.FileInfo;
import me.nereo.multi_image_selector.utils.FileUtils;
import me.nereo.multi_image_selector.utils.ResUtils;
import me.nereo.multi_image_selector.utils.ScreenUtils;
import me.nereo.multi_image_selector.utils.Utils;

/**
 * Multi image selector Fragment Created by Nereo on 2015/4/7. Updated by nereo
 * on 2016/5/18.
 */
public class MultiImageSelectorFragment extends Fragment {
	
	public static String SELECTED_FORBID = "图片和视频不能同时选择";

	@Override
	public void onResume() {
		super.onResume();
		if(mImageAdapter != null){
			mImageAdapter.notifyDataSetChanged();
		}
	}

	public static final String TAG = "MultiImageSelectorFragment";

	private static final int REQUEST_STORAGE_WRITE_ACCESS_PERMISSION = 110;
	private static final int REQUEST_CAMERA = 100;

	private static final String KEY_TEMP_FILE = "key_temp_file";

	// Single choice
	public static final int MODE_SINGLE = 0;
	// Multi choice
	public static final int MODE_MULTI = 1;

	/** Max image size，int， */
	public static final String EXTRA_SELECT_COUNT = "max_select_count";
	/** Select mode，{@link #MODE_MULTI} by default */
	public static final String EXTRA_SELECT_MODE = "select_count_mode";
	/** Whether show camera，true by default */
	public static final String EXTRA_SHOW_CAMERA = "show_camera";
	/** Original data set */
	public static final String EXTRA_DEFAULT_SELECTED_LIST = "default_list";

	// loaders
	private static final int LOADER_ALL = 0;
	private static final int LOADER_CATEGORY = 1;

	// image result data set
	private ArrayList<String> resultList = new ArrayList<String>();
	// folder result data set
	private ArrayList<Folder> mResultFolder = new ArrayList<Folder>();

	private GridView mGridView;
	private Callback mCallback;

	private ImageGridAdapter mImageAdapter;
	private FolderAdapter mFolderAdapter;

	private ListPopupWindow mFolderPopupWindow;

	private TextView mCategoryText;
	private View mPopupAnchorView;

	private boolean hasFolderGened = false;

	private File mTmpFile;
	private Context mContext;
	
	
	public static List<Image> currentImages;

	@Override
	public void onAttach(Context context) {
		super.onAttach(context);
		try {
			mCallback = (Callback) getActivity();
		} catch (ClassCastException e) {
			throw new ClassCastException("The Activity must implement MultiImageSelectorFragment.Callback interface...");
		}
	}

	@Override
	public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
		int mis_fragment_multi_image_id = ResUtils.getInstance().getLayoutId(getContext(), "mis_fragment_multi_image");
		View fragmentView = inflater.inflate(mis_fragment_multi_image_id, container, false);
		fragmentView.setBackgroundColor(Color.TRANSPARENT);

		mContext = this.getContext();
		return fragmentView;
	}

	@SuppressLint("NewApi") @Override
	public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
		super.onViewCreated(view, savedInstanceState);

		final int mode = selectMode();
		if (mode == MODE_MULTI) {
			ArrayList<String> tmp = getArguments().getStringArrayList(EXTRA_DEFAULT_SELECTED_LIST);
			if (tmp != null && tmp.size() > 0) {
				resultList = tmp;
			}
		}
		
		int grid_id = ResUtils.getInstance().getViewId(getContext(), "grid");
		mGridView = (GridView) view.findViewById(grid_id);
		
		mImageAdapter = new ImageGridAdapter(getActivity(), mGridView, showCamera(), 3);
		mImageAdapter.showSelectIndicator(mode == MODE_MULTI);

		int footer_id = ResUtils.getInstance().getViewId(getContext(), "footer");
		mPopupAnchorView = view.findViewById(footer_id);
		
		int category_btn_id = ResUtils.getInstance().getViewId(getContext(), "category_btn");

		// ==================== //
		mCategoryText = (TextView) view.findViewById(category_btn_id);
		if (UIAlbumBrowser.mUZModuleContext != null && UIAlbumBrowser.config != null) {
			mCategoryText.setTextColor(UZUtility.parseCssColor(UIAlbumBrowser.config.navRightColor));
		}
		// ==================== //

		

		if (Utils.hasNavBar(mContext)) {
			// MarginLayoutParams params =
			// (MarginLayoutParams)mPopupAnchorView.getLayoutParams();
			// params.bottomMargin = Utils.getNavigationBarHeight(mContext);
			//((Activity) mContext).getWindow().getDecorView().findViewById(android.R.id.content).setPadding(0, 0, 0, Utils.getNavigationBarHeight(mContext));
			
			RelativeLayout.LayoutParams mPopupParams = (RelativeLayout.LayoutParams)mPopupAnchorView.getLayoutParams();
			mPopupParams.height = Utils.getNavigationBarHeight(mContext) + UZUtility.dipToPix(30);
			
            RelativeLayout.LayoutParams mCategoryParams = (RelativeLayout.LayoutParams)mCategoryText.getLayoutParams();
            mCategoryParams.height = UZUtility.dipToPix(30);
            mCategoryParams.removeRule(RelativeLayout.CENTER_VERTICAL);
            mCategoryParams.topMargin = UZUtility.dipToPix(5);
            
			RelativeLayout.LayoutParams mGridParams = (RelativeLayout.LayoutParams)mGridView.getLayoutParams();
			mGridParams.bottomMargin =  UZUtility.dipToPix(30);
			
		}

		// ==================== //
		if (UIAlbumBrowser.mUZModuleContext != null && UIAlbumBrowser.config != null) {
			mPopupAnchorView.setBackgroundColor(UZUtility.parseCssColor(UIAlbumBrowser.config.navBg));
		}
		// ==================== //

		
		int mis_folder_all_id = ResUtils.getInstance().getStringId(getContext(), "mis_folder_all");
		mCategoryText.setText(mis_folder_all_id);
		mCategoryText.setOnClickListener(new View.OnClickListener() {
			@SuppressLint("NewApi")                 
			@Override
			public void onClick(View view) {

				if (mFolderPopupWindow == null) {
					createPopupFolderList();
				}

				if (mFolderPopupWindow.isShowing()) {
					mFolderPopupWindow.dismiss();
				} else {
					mFolderPopupWindow.show();
					int index = mFolderAdapter.getSelectIndex();
					index = index == 0 ? index : index - 1;
					mFolderPopupWindow.getListView().setSelection(index);
				}
			}
		});

		mGridView.setAdapter(mImageAdapter);
		
		mImageAdapter.setShowPreview(UIAlbumBrowser.config.isOpenPreview);
		// TODO: ===>
		if(UIAlbumBrowser.config.isOpenPreview){
			setOnItemClickListenerForImageAdapter(mode);
		} else {
			setOnItemClickListenerForImageGrid(mode);
		}
		// TODO: ===>
		
		
		mGridView.setOnScrollListener(new AbsListView.OnScrollListener() {
			@Override
			public void onScrollStateChanged(AbsListView view, int scrollState) {
				if (scrollState == SCROLL_STATE_FLING) {
					// Picasso.with(view.getContext()).pauseTag(TAG);
				} else {
					// Picasso.with(view.getContext()).resumeTag(TAG);
				}
			}

			@Override
			public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {

			}
			
		});
		mFolderAdapter = new FolderAdapter(getActivity());
	}
	
	
	
	public void setOnItemClickListenerForImageAdapter(final int mode){
			mImageAdapter.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(GridView gridView, int position) {
				if (mImageAdapter.isShowCamera()) {
					if (position == 0) {
						showCameraAction();
					} else {
						Image image = (Image) gridView.getAdapter().getItem(position);
						selectImageFromGrid(image, mode);
					}
				} else {
					Image image = (Image) gridView.getAdapter().getItem(position);
					selectImageFromGrid(image, mode);
				}
			}
			
			@Override
			public void gotoPreview(int position) {
				Intent intent = new Intent(getContext(), MultiImageSelectorPreviewActivity.class);
				currentImages = mImageAdapter.getData();
				
				if(mImageAdapter.isShowCamera()){
					position = position - 1;
				}
				
				if(currentImages.get(position).isVideo){
					return;
				}
				intent.putExtra("position", position);
				intent.putExtra("maxCount", UIAlbumBrowser.config.max);
				intent.putExtra("isShowCamera", mImageAdapter.isShowCamera());
				((Activity)getContext()).startActivityForResult(intent, 2);
			}

			@Override
			public void onCameraClick() {
				if (mImageAdapter.isShowCamera()) {
					showCameraAction();
				}
			}
		});
	}
	
	
	public void setOnItemClickListenerForImageGrid(final int mode){
		mGridView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
		@Override
		public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
			
			Log.i("debug", "Grid Item Click");
			
			if (mImageAdapter.isShowCamera()) {
				if (i == 0) {
					showCameraAction();
				} else {
					Image image = (Image) adapterView.getAdapter().getItem(i);
					selectImageFromGrid(image, mode);
				}
			} else {
				Image image = (Image) adapterView.getAdapter().getItem(i);
				selectImageFromGrid(image, mode);
			}
		}
		});
		
		mImageAdapter.setOnItemClickListener(new OnItemClickListener() {
			
			@Override
			public void onItemClick(GridView gridView, int position) {
				Log.i("debug", "Grid Item Click");
			}
			
			@Override
			public void onCameraClick() {
				if (mImageAdapter.isShowCamera()) {
						showCameraAction();
				}
			}
			
			@Override
			public void gotoPreview(int position) {}
		});
	}

	/**
	 * Create popup ListView
	 */
	@SuppressLint("NewApi")
	private void createPopupFolderList() {
		Point point = ScreenUtils.getScreenSize(getActivity());
		int width = point.x;
		int height = (int) (point.y * (4.5f / 8.0f));
		mFolderPopupWindow = new ListPopupWindow(getActivity());
		mFolderPopupWindow.setBackgroundDrawable(new ColorDrawable(Color.WHITE));
		mFolderPopupWindow.setAdapter(mFolderAdapter);
		mFolderPopupWindow.setContentWidth(width);
		mFolderPopupWindow.setWidth(width);
		mFolderPopupWindow.setHeight(height);
		mFolderPopupWindow.setAnchorView(mPopupAnchorView);
		mFolderPopupWindow.setModal(true);
		mFolderPopupWindow.setOnItemClickListener(new AdapterView.OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {

				mFolderAdapter.setSelectIndex(i);

				final int index = i;
				@SuppressWarnings("rawtypes")
				final AdapterView v = adapterView;

				new Handler().postDelayed(new Runnable() {
					@Override
					public void run() {
						mFolderPopupWindow.dismiss();

						if (index == 0) {
							getActivity().getSupportLoaderManager().restartLoader(LOADER_ALL, null, mLoaderCallback);
							int mis_folder_all = ResUtils.getInstance().getStringId(getContext(), "mis_folder_all");
							mCategoryText.setText(mis_folder_all);
							if (showCamera()) {
								mImageAdapter.setShowCamera(true);
							} else {
								mImageAdapter.setShowCamera(false);
							}
						} else {
							Folder folder = (Folder) v.getAdapter().getItem(index);
							if (null != folder) {
								mImageAdapter.setData(folder.images);
								mCategoryText.setText(folder.name);
								if (resultList != null && resultList.size() > 0) {
									mImageAdapter.setDefaultSelected(resultList);
								}
							}
							mImageAdapter.setShowCamera(false);
						}

						mGridView.smoothScrollToPosition(0);
					}
				}, 100);

			}
		});
	}

	@Override
	public void onSaveInstanceState(Bundle outState) {
		super.onSaveInstanceState(outState);
		outState.putSerializable(KEY_TEMP_FILE, mTmpFile);
	}

	@Override
	public void onViewStateRestored(@Nullable Bundle savedInstanceState) {
		super.onViewStateRestored(savedInstanceState);
		if (savedInstanceState != null) {
			mTmpFile = (File) savedInstanceState.getSerializable(KEY_TEMP_FILE);
		}
	}

	@Override
	public void onActivityCreated(@Nullable Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState);
		getActivity().getSupportLoaderManager().initLoader(LOADER_ALL, null, mLoaderCallback);
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (requestCode == REQUEST_CAMERA) {
			if (resultCode == Activity.RESULT_OK) {
				if (mTmpFile != null) {
					if (mCallback != null) {
						// mCallback.onCameraShot(mTmpFile,
						// loadMediaCallback(resultCode, data));
						// mCallback.onCameraShot(mTmpFile, "content://"+
						// getContext().getPackageName()+ "." +
						// mTmpFile.getAbsolutePath());
						mCallback.onCameraShot(mTmpFile, mTmpFile.getAbsolutePath());
					}
				}
			} else {
				// delete tmp file
				while (mTmpFile != null && mTmpFile.exists()) {
					boolean success = mTmpFile.delete();
					if (success) {
						mTmpFile = null;
					}
				}
			}
		}
	}

	protected String loadMediaCallback(int resultCode, Intent result) {
		String realPath = "";

		if (Activity.RESULT_OK != resultCode) {
			// do nothing
		} else {
			if (null != result) {
				realPath = result.getDataString();
				if (!TextUtils.isEmpty(realPath)) {
					realPath = UIAlbumBrowser.mUZModuleContext.makeRealPath(realPath);
				}
				realPath = !TextUtils.isEmpty(realPath) ? realPath : mTmpFile.getAbsolutePath();
			} else {
				realPath = mTmpFile.getAbsolutePath();
			}
		}
		return realPath;
	}

	@SuppressLint("NewApi")
	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		if (mFolderPopupWindow != null) {
			if (mFolderPopupWindow.isShowing()) {
				mFolderPopupWindow.dismiss();
			}
		}
		super.onConfigurationChanged(newConfig);
	}

	/**
	 * Open camera
	 */
	private void showCameraAction() {
		if (ContextCompat.checkSelfPermission(getContext(), Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
			int mis_permission_rationale_write_storage_id = ResUtils.getInstance().getStringId(getContext(), "mis_permission_rationale_write_storage");
			requestPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE, getString(mis_permission_rationale_write_storage_id), REQUEST_STORAGE_WRITE_ACCESS_PERMISSION);
		} else {
			Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
			if (intent.resolveActivity(getActivity().getPackageManager()) != null) {
				try {
					mTmpFile = FileUtils.createTmpFile(getActivity());
				} catch (IOException e) {
					e.printStackTrace();
				}
				if (mTmpFile != null && mTmpFile.exists()) {
					intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(mTmpFile));
					intent.setFlags(Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT);
					startActivityForResult(intent, REQUEST_CAMERA);
				} else {
					int mis_error_image_not_exist_id = ResUtils.getInstance().getStringId(getContext(), "mis_error_image_not_exist");
					Toast.makeText(getActivity(), mis_error_image_not_exist_id, Toast.LENGTH_SHORT).show();
				}
			} else {
				int mis_msg_no_camera_id = ResUtils.getInstance().getStringId(getContext(), "mis_msg_no_camera");
				Toast.makeText(getActivity(), mis_msg_no_camera_id, Toast.LENGTH_SHORT).show();
			}
		}
	}

	private void requestPermission(final String permission, String rationale, final int requestCode) {
		if (shouldShowRequestPermissionRationale(permission)) {
			int mis_permission_dialog_title_id = ResUtils.getInstance().getStringId(getContext(), "mis_permission_dialog_title");
			int mis_permission_dialog_ok_id = ResUtils.getInstance().getStringId(getContext(), "mis_permission_dialog_ok");
			int mis_permission_dialog_cancel_id = ResUtils.getInstance().getStringId(getContext(), "mis_permission_dialog_cancel");
			new AlertDialog.Builder(getContext()).setTitle(mis_permission_dialog_title_id).setMessage(rationale).setPositiveButton(mis_permission_dialog_ok_id, new DialogInterface.OnClickListener() {
				@Override
				public void onClick(DialogInterface dialog, int which) {
					requestPermissions(new String[] { permission }, requestCode);
				}
			}).setNegativeButton(mis_permission_dialog_cancel_id, null).create().show();
		} else {
			requestPermissions(new String[] { permission }, requestCode);
		}
	}
	
	
	@Override
	public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
		if (requestCode == REQUEST_STORAGE_WRITE_ACCESS_PERMISSION) {
			if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
				showCameraAction();
			}
		} else {
			super.onRequestPermissionsResult(requestCode, permissions, grantResults);
		}
	}
	
	public boolean isVideo(String resPath){
		if(TextUtils.isEmpty(resPath)){
			return false;
		}
		if(resPath.endsWith("jpg") 
				|| resPath.endsWith("png")
				|| resPath.endsWith("jpeg")){
			return false;
		}
		return true;
	}

	/**
	 * notify callback
	 * 
	 * @param image
	 *            image data
	 */
	private void selectImageFromGrid(Image image, int mode) {
		
		
		if(resultList.size() > 0 && !UIAlbumBrowser.config.selectedAll){
			if(image.isVideo && !isVideo(resultList.get(0))){
				Utils.showToast(getContext(), SELECTED_FORBID);
				return;
			}
			if(!image.isVideo && isVideo(resultList.get(0))){
				Utils.showToast(getContext(), SELECTED_FORBID);
				return;
			}
		}
		
		if (image != null) {
			if (mode == MODE_MULTI) {
				if (resultList.contains(image.path)) {
					resultList.remove(image.path);
					if (mCallback != null) {
						mCallback.onImageUnselected(image.path);
					}
				} else {
					
					if(resultList.size() > 0 && !UIAlbumBrowser.config.selectedAll && isVideo(resultList.get(0))){
						Utils.showToast(getContext(), "只能选一个视频");
						return;
					}
					
					if (selectImageCount() == resultList.size()) {
						int mis_msg_amount_limit_id = ResUtils.getInstance().getStringId(getContext(), "mis_msg_amount_limit");
						Toast.makeText(getActivity(), mis_msg_amount_limit_id, Toast.LENGTH_SHORT).show();
						return;
					}
					
					resultList.add(image.path);
					if (mCallback != null) {
						mCallback.onImageSelected(image);
					}
				}
				mImageAdapter.select(image, UIAlbumBrowser.config.max);
			} else if (mode == MODE_SINGLE) {
				if (mCallback != null) {
					mCallback.onSingleImageSelected(image.path);
				}
			}
		}
	}

	@SuppressWarnings("unused")
	private LoaderManager.LoaderCallbacks<Cursor> mLoaderCallback = new LoaderManager.LoaderCallbacks<Cursor>() {

		private final String[] IMAGE_PROJECTION = { MediaStore.Images.Media.DATA, MediaStore.Images.Media.DISPLAY_NAME, MediaStore.Images.Media.DATE_ADDED, MediaStore.Images.Media.MIME_TYPE, MediaStore.Images.Media.SIZE, MediaStore.Images.Media._ID };

		private final String[] VIDEO_PROJECTION = { MediaStore.Video.Media.DATA, MediaStore.Video.Media.DISPLAY_NAME, MediaStore.Video.Media.DATE_ADDED, MediaStore.Video.Media.MIME_TYPE, MediaStore.Video.Media.SIZE, MediaStore.Video.Media._ID };

		@Override
		public Loader<Cursor> onCreateLoader(int id, Bundle args) {
			CursorLoader cursorLoader = null;
			if (id == LOADER_ALL) {
				cursorLoader = new CursorLoader(getActivity(), MediaStore.Images.Media.EXTERNAL_CONTENT_URI, IMAGE_PROJECTION, IMAGE_PROJECTION[4] + ">0 AND " + IMAGE_PROJECTION[3] + "=? OR " + IMAGE_PROJECTION[3] + "=? ", new String[] { "image/jpeg", "image/png"}, IMAGE_PROJECTION[2] + " DESC");
			} else if (id == LOADER_CATEGORY) {
				cursorLoader = new CursorLoader(getActivity(), MediaStore.Images.Media.EXTERNAL_CONTENT_URI, IMAGE_PROJECTION, IMAGE_PROJECTION[4] + ">0 AND " + IMAGE_PROJECTION[0] + " like '%" + args.getString("path") + "%'", null, IMAGE_PROJECTION[2] + " DESC");
			}
			return cursorLoader;
		}

		private boolean fileExist(String path) {
			if (!TextUtils.isEmpty(path)) {
				return new File(path).exists();
			}
			return false;
		}

		@Override
		public void onLoadFinished(Loader<Cursor> loader, Cursor data) {
			if (data != null) {
				// ===== +++++ =====
				
				List<Image> videoPaths = new ArrayList<Image>();
				if (UIAlbumBrowser.config.isOpen && ("all".equals(UIAlbumBrowser.config.type)
						                            ||"video".equals(UIAlbumBrowser.config.type))) {
					List<FileInfo> fileInfos = Utils.listAllVideo(mContext);
					for (FileInfo fileInfo : fileInfos) {
						Image videoImg = new Image(fileInfo.path, "", fileInfo.time / 1000);
						videoImg.isVideo = true;
						videoImg.duration = fileInfo.duration;

						if (!hasFolderGened) {
							// get all folder data
							File folderFile = new File(videoImg.path).getParentFile();
							if (folderFile != null && folderFile.exists()) {
								String fp = folderFile.getAbsolutePath();
								Folder f = getFolderByPath(fp);
								if (f == null) {
									Folder folder = new Folder();
									folder.name = folderFile.getName();
									folder.path = fp;
									folder.cover = videoImg;
									List<Image> imageList = new ArrayList<Image>();
									imageList.add(videoImg);
									folder.images = imageList;
									mResultFolder.add(folder);
								} else {
									f.images.add(videoImg);
								}
							}
						}
						videoPaths.add(videoImg);
					}
				}
				// ===== +++++ =====

				List<Image> images = new ArrayList<Image>();
				if (data.getCount() > 0) {
					images.addAll(videoPaths);
					data.moveToFirst();
					do {
						
						if("video".equals(UIAlbumBrowser.config.type)){
							break;
						}
						String path = data.getString(data.getColumnIndexOrThrow(IMAGE_PROJECTION[0]));
						String name = data.getString(data.getColumnIndexOrThrow(IMAGE_PROJECTION[1]));
						long dateTime = data.getLong(data.getColumnIndexOrThrow(IMAGE_PROJECTION[2]));

						if (!fileExist(path)) {
							continue;
						}
						Image image = null;
						if (!TextUtils.isEmpty(name)) {
							image = new Image(path, name, dateTime);
							images.add(image);
						}

						if (!hasFolderGened) {
							// get all folder data
							File folderFile = new File(path).getParentFile();
							if (folderFile != null && folderFile.exists()) {
								String fp = folderFile.getAbsolutePath();
								Folder f = getFolderByPath(fp);
								if (f == null) {
									Folder folder = new Folder();
									folder.name = folderFile.getName();
									folder.path = fp;
									folder.cover = image;
									List<Image> imageList = new ArrayList<Image>();
									imageList.add(image);
									folder.images = imageList;
									mResultFolder.add(folder);
								} else {
									if(image != null){
										f.images.add(image);
									}
								}
							}
						}
					} while (data.moveToNext());

					for (int i = 0; i < mResultFolder.size(); i++) {
						Folder folder = mResultFolder.get(i);
						Collections.sort(folder.images, new ImageSorter());
					}
					
					Collections.sort(images, new ImageSorter());
					mImageAdapter.setData(images);
					if (resultList != null && resultList.size() > 0) {
						mImageAdapter.setDefaultSelected(resultList);
					}
					if (!hasFolderGened) {
						mFolderAdapter.setData(mResultFolder);
						hasFolderGened = true;
					}
				}
			}
		}

		@Override
		public void onLoaderReset(Loader<Cursor> loader) {
			
		}
	};

	private class ImageSorter implements Comparator<Image> {
		@Override
		public int compare(Image arg0, Image arg1) {
			if (arg0 == null || arg1 == null) {
				return 0;
			}
			return arg1.time.compareTo(arg0.time);
		}
	}

	private Folder getFolderByPath(String path) {
		if (mResultFolder != null) {
			for (Folder folder : mResultFolder) {
				if (TextUtils.equals(folder.path, path)) {
					return folder;
				}
			}
		}
		return null;
	}

	private boolean showCamera() {
		return getArguments() == null || getArguments().getBoolean(EXTRA_SHOW_CAMERA, true);
	}

	private int selectMode() {
		return getArguments() == null ? MODE_MULTI : getArguments().getInt(EXTRA_SELECT_MODE);
	}

	private int selectImageCount() {
		return getArguments() == null ? 9 : getArguments().getInt(EXTRA_SELECT_COUNT);
	}

	/**
	 * Callback for host activity
	 */
	public interface Callback {
		void onSingleImageSelected(String path);

		void onImageSelected(Image path);

		void onImageUnselected(String path);

		void onCameraShot(File imageFile, String realPath);
	}
}
