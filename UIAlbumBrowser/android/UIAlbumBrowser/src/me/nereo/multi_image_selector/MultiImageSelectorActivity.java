/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package me.nereo.multi_image_selector;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.ThumbnailUtils;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.provider.MediaStore.Images.Thumbnails;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.text.TextUtils;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.apicloud.UIAlbumBrowser.BitmapToolkit;
import com.apicloud.UIAlbumBrowser.Config;
import com.apicloud.UIAlbumBrowser.UIAlbumBrowser;
import com.uzmap.pkg.uzcore.UZResourcesIDFinder;
import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;
import com.uzmap.pkg.uzkit.UZUtility;

import me.nereo.multi_image_selector.adapter.ImageGridAdapter;
import me.nereo.multi_image_selector.bean.Image;
import me.nereo.multi_image_selector.utils.ResUtils;

/**
 * Multi image selector Created by Nereo on 2015/4/7. Updated by nereo on
 * 2016/1/19. Updated by nereo on 2016/5/18.
 */

public class MultiImageSelectorActivity extends FragmentActivity implements MultiImageSelectorFragment.Callback {

	private static String CACHE_PATH;
	private static Context mContext;

	// Single choice
	public static final int MODE_SINGLE = 0;
	// Multi choice
	public static final int MODE_MULTI = 1;

	/** Max image size，int，{@link #DEFAULT_IMAGE_SIZE} by default */
	public static final String EXTRA_SELECT_COUNT = "max_select_count";
	/** Select mode，{@link #MODE_MULTI} by default */
	public static final String EXTRA_SELECT_MODE = "select_count_mode";
	/** Whether show camera，true by default */
	public static final String EXTRA_SHOW_CAMERA = "show_camera";
	/** Result data set，ArrayList&lt;String&gt; */
	public static final String EXTRA_RESULT = "select_result";
	/** Original data set */
	public static final String EXTRA_DEFAULT_SELECTED_LIST = "default_list";
	// Default image size
	private static final int DEFAULT_IMAGE_SIZE = 9;

	private ArrayList<String> resultList = new ArrayList<String>();
	private Button mSubmitButton;
	private int mDefaultCount = DEFAULT_IMAGE_SIZE;

	@Override
	protected void onResume() {
		super.onResume();
		
		updateResultList();
	}

	private boolean isOpen = false;

	@SuppressLint("NewApi")
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		// int MIS_NO_ACTIONBAR_id = ResUtils.getInstance().getStyleId(this,
		// "MIS_NO_ACTIONBAR");
		// setTheme(MIS_NO_ACTIONBAR_id);

		mContext = this;

		CACHE_PATH = this.getExternalCacheDir() + "/" + "UIAlbumBrowser" + "/";
		File cacheFile = new File(CACHE_PATH);
		if (!cacheFile.exists()) {
			cacheFile.mkdirs();
		}

		int mis_activity_default_id = ResUtils.getInstance().getLayoutId(this, "mis_activity_default");

		setContentView(mis_activity_default_id);

		final Intent intent = getIntent();
		mDefaultCount = intent.getIntExtra(EXTRA_SELECT_COUNT, DEFAULT_IMAGE_SIZE);
		final int mode = intent.getIntExtra(EXTRA_SELECT_MODE, MODE_MULTI);
		final boolean isShow = intent.getBooleanExtra(EXTRA_SHOW_CAMERA, true);
		if (mode == MODE_MULTI && intent.hasExtra(EXTRA_DEFAULT_SELECTED_LIST)) {
			resultList = intent.getStringArrayListExtra(EXTRA_DEFAULT_SELECTED_LIST);
		}

		isOpen = intent.getBooleanExtra("isOpen", false);

		int commit_id = ResUtils.getInstance().getViewId(this, "commit");
		mSubmitButton = (Button) findViewById(commit_id);
		if (mode == MODE_MULTI) {
			updateDoneText(resultList);
			mSubmitButton.setVisibility(View.GONE);
			mSubmitButton.setOnClickListener(new View.OnClickListener() {
				@Override
				public void onClick(View view) {
					if (resultList != null && resultList.size() > 0) {
						// Notify success
						Intent data = new Intent();
						data.putStringArrayListExtra(EXTRA_RESULT, resultList);
						setResult(RESULT_OK, data);
					} else {
						setResult(RESULT_CANCELED);
					}
					finish();
				}
			});
		} else {
			mSubmitButton.setVisibility(View.GONE);
		}

		boolean isInme = intent.getBooleanExtra("immersive", false);

		// ==========================
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && isInme) {
			// 透明状态栏
			getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
			// 透明导航栏
			getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
		}
		// ===========================

		if (savedInstanceState == null) {
			Bundle bundle = new Bundle();
			bundle.putInt(MultiImageSelectorFragment.EXTRA_SELECT_COUNT, mDefaultCount);
			bundle.putInt(MultiImageSelectorFragment.EXTRA_SELECT_MODE, mode);
			bundle.putBoolean(MultiImageSelectorFragment.EXTRA_SHOW_CAMERA, isShow);
			bundle.putStringArrayList(MultiImageSelectorFragment.EXTRA_DEFAULT_SELECTED_LIST, resultList);

			int image_grid_id = ResUtils.getInstance().getViewId(this, "image_grid");
			getSupportFragmentManager().beginTransaction().add(image_grid_id, Fragment.instantiate(this, MultiImageSelectorFragment.class.getName(), bundle)).commit();
		}

		if (UIAlbumBrowser.config != null && UIAlbumBrowser.mUZModuleContext != null) {
			int naviBarId = UZResourcesIDFinder.getResIdID("toolbar");
			configNaviBar(UIAlbumBrowser.mUZModuleContext, UIAlbumBrowser.config, this.findViewById(naviBarId));
			// bg
			
			if (isInme) {
				int statusBarId = ResUtils.getInstance().getViewId(this, "statusBar");
				findViewById(statusBarId).setVisibility(View.VISIBLE);
				findViewById(statusBarId).setBackgroundColor(UZUtility.parseCssColor(UIAlbumBrowser.config.navBg));
			}
		}
	}

	public View getContentView() {
		return this.findViewById(android.R.id.content);
	}

	public static void closeSelector() {
		if (mContext != null) {
			Activity a = (Activity) mContext;
			a.finish();
		}
	}
	
	private boolean isFinish = false;

	public void configNaviBar(final UZModuleContext uzContext, Config config, View naviBar) {
		naviBar.setBackgroundColor(UZUtility.parseCssColor(config.navBg));

		int cancelTextId = UZResourcesIDFinder.getResIdID("cancelText");
		TextView cancelText = (TextView) this.findViewById(cancelTextId);
		cancelText.setTextColor(UZUtility.parseCssColor(config.navleftTextColor));
		cancelText.setTextSize(config.navLeftTextSize);

		int finishTextId = UZResourcesIDFinder.getResIdID("nextStepText");
		TextView finishText = (TextView) this.findViewById(finishTextId);
		finishText.setTextColor(UZUtility.parseCssColor(config.navRightColor));
		finishText.setTextSize(config.navRightSize);

		// add eventListener
		cancelText.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				finish();
				callback(uzContext, "cancel", "", null);
			}
		});
		
		finishText.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				if(isFinish){
					return;
				}
				isFinish = true;
				
				Log.i("debug", "finished text");
				new ImageHandlerTask().execute();
			}
		});

		if (isOpen) {
			cancelText.setText("取消");
			finishText.setText("完成");
			
			cancelText.setTextColor(UZUtility.parseCssColor(config.navleftTextColor));
			finishText.setTextColor(UZUtility.parseCssColor(config.navRightColor));
			
			cancelText.setTextSize(config.navLeftTextSize);
			finishText.setTextSize(config.navRightSize);
			
			
			int navTitleId = UZResourcesIDFinder.getResIdID("navTitle");
			TextView navTitle = (TextView) this.findViewById(navTitleId);
			navTitle.setText("相册");
			navTitle.setTextSize(config.navTitleSize);
			navTitle.setTextColor(UZUtility.parseCssColor(config.navTitleColor));
			
		}
		
	}

	public void callback(UZModuleContext uzContext, String eventType, String originalPath, JSONArray paths) {
		JSONObject ret = new JSONObject();
		try {
			ret.put("eventType", eventType);
			if (!TextUtils.isEmpty(originalPath)) {
				ret.put("originalPath", originalPath);
			}

			if (paths != null) {
				ret.put("list", paths);
			}
			uzContext.success(ret, false);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	@SuppressLint("NewApi")
	public class ImageHandlerTask extends AsyncTask<Void, Integer, Integer> {

		@Override
		protected void onPreExecute() {

		}

		@Override
		protected void onPostExecute(Integer result) {

		}

		@Override
		protected Integer doInBackground(Void... params) {

			JSONArray paths = new JSONArray();
			for (int i = 0; i < resultList.size(); i++) {
				JSONObject item = new JSONObject();

				try {
					item.put("path", resultList.get(i));
					File realFile = new File(resultList.get(i));
					
					String suffixStr = null;
					if (!TextUtils.isEmpty(resultList.get(i))) {
						suffixStr = resultList.get(i).substring(resultList.get(i).lastIndexOf('.') + 1, resultList.get(i).length());
						item.put("suffix", suffixStr);
					}
					
					String cacheDir = MultiImageSelectorActivity.this.getExternalCacheDir().getAbsolutePath();
					
					if (!"jpg".equals(suffixStr) && !"png".equals(suffixStr) && !"jpeg".equals(suffixStr)) {
						item.put("videoPath", resultList.get(i));
						Bitmap bmp = ThumbnailUtils.createVideoThumbnail(resultList.get(i), Thumbnails.MINI_KIND);
						
						String savePath = null;
						if(!TextUtils.isEmpty(realFile.getName())){
							String fileName = realFile.getName().substring(0, realFile.getName().lastIndexOf("."));
							savePath = cacheDir + "/" + fileName + ".jpg";
						}
						
						Log.i("Debug", "savePath : " + savePath);
						if(!new File(savePath).exists()){
							try {
								if(bmp != null){
									bmp.compress(Bitmap.CompressFormat.JPEG, 80, new FileOutputStream(savePath));
								}
							} catch (FileNotFoundException e) {
								e.printStackTrace();
							}
						}
						item.put("thumbPath", savePath);
					} else {
						Bitmap bmp = ThumbnailUtils.extractThumbnail(BitmapFactory.decodeFile(resultList.get(i)), 300, 300);
						int degree = BitmapToolkit.readPictureDegree(resultList.get(i));
						bmp = BitmapToolkit.rotaingImageView(degree, bmp);
						
						String savePath = cacheDir + "/" + realFile.getName();
						if(!new File(savePath).exists()){
							try {
								bmp.compress(Bitmap.CompressFormat.JPEG, 80, new FileOutputStream(savePath));
								BitmapToolkit.setPictureDegreeZero(savePath, degree);
							} catch (FileNotFoundException e) {
								e.printStackTrace();
							}
						}
						item.put("thumbPath", savePath);
					}
					item.put("size", realFile.length());
					item.put("time", realFile.lastModified());

				} catch (JSONException e) {
					e.printStackTrace();
				}
				paths.put(item);
			}

			if (isOpen) {
				callback(UIAlbumBrowser.mUZModuleContext, "confirm", null, paths);
				finish();
				return null;
			}

			callback(UIAlbumBrowser.mUZModuleContext, "nextStep", null, paths);
			return null;
		}
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case android.R.id.home:
			setResult(RESULT_CANCELED);
			finish();
			return true;
		}
		return super.onOptionsItemSelected(item);
	}

	/**
	 * Update done button by select image data
	 * 
	 * @param resultList
	 *            selected image data
	 */
	private void updateDoneText(ArrayList<String> resultList) {
		int size = 0;
		if (resultList == null || resultList.size() <= 0) {
			int mis_action_done_id = ResUtils.getInstance().getStringId(this, "mis_action_done");
			mSubmitButton.setText(mis_action_done_id);
			mSubmitButton.setEnabled(false);
		} else {
			size = resultList.size();
			mSubmitButton.setEnabled(true);
		}
		int mis_action_button_string_id = ResUtils.getInstance().getStringId(this, "mis_action_button_string");
		int mis_action_done_id = ResUtils.getInstance().getStringId(this, "mis_action_done");
		mSubmitButton.setText(getString(mis_action_button_string_id, getString(mis_action_done_id), size, mDefaultCount));
	}

	@Override
	public void onSingleImageSelected(String path) {
		Intent data = new Intent();
		resultList.add(path);
		data.putStringArrayListExtra(EXTRA_RESULT, resultList);
		setResult(RESULT_OK, data);
		finish();
	}

	@Override
	public void onImageSelected(Image image) {
		if (!resultList.contains(image.path)) {
//			if(resultList.size() > 0 && !UIAlbumBrowser.config.selectedAll){
//				if(isVideo(resultList.get(0)) && image.isVideo){
//					resultList.add(image.path);
//				} else {
//					resultList.add(image.path);
//				}
//			} else {
				resultList.add(image.path);
//			}
		}
		updateDoneText(resultList);
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

	@Override
	public void onImageUnselected(String path) {
		if (resultList.contains(path)) {
			resultList.remove(path);
		}
		updateDoneText(resultList);
	}
	
	public void updateResultList(){
		for(int i=0; i<ImageGridAdapter.mSelectedImages.size(); i++){
			if(!resultList.contains(ImageGridAdapter.mSelectedImages.get(i).path)){
				resultList.add(ImageGridAdapter.mSelectedImages.get(i).path);
			}
		}
	}

	@Override
	public void onCameraShot(File imageFile, final String realPath) {
		if (imageFile != null) {
			// notify system the image has change
			sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.fromFile(imageFile)));
			Intent data = new Intent();

			resultList.add(imageFile.getAbsolutePath());
			data.putStringArrayListExtra(EXTRA_RESULT, resultList);
			setResult(RESULT_OK, data);

			new Handler().postDelayed(new Runnable() {
				@Override
				public void run() {
					callback(UIAlbumBrowser.mUZModuleContext, "", realPath, null);
					finish();
				}
			}, 500);
		}
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		mContext = null;
		if(MultiImageSelectorFragment.currentImages != null){
			MultiImageSelectorFragment.currentImages.clear();
		}
		ImageGridAdapter.mSelectedImages.clear();
		
	}
}
