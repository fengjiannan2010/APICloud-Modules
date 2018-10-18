package com.apicloud.UIAlbumBrowser;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.content.res.AssetFileDescriptor;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import android.graphics.drawable.BitmapDrawable;
import android.media.MediaMetadataRetriever;
import android.media.ThumbnailUtils;
import android.os.Build;

import android.os.Bundle;
import android.support.v4.app.ActivityCompat;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;

import android.widget.GridView;
import android.widget.RelativeLayout;

import android.widget.Toast;

import com.apicloud.UIAlbumBrowser.MediaResource.FileInfo;
import com.uzmap.pkg.uzcore.UZWebView;
import com.uzmap.pkg.uzcore.uzmodule.UZModule;
import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;
import com.uzmap.pkg.uzkit.UZUtility;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import me.nereo.multi_image_selector.MultiImageSelector;
import me.nereo.multi_image_selector.MultiImageSelectorActivity;
import me.nereo.multi_image_selector.adapter.ImageAlbumAdapter;
import me.nereo.multi_image_selector.adapter.ImageGroupAdapter;
import me.nereo.multi_image_selector.utils.ScreenUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class UIAlbumBrowser extends UZModule {
	public static final String TAG = "UIAlbumBrowser";
	public static final int TYPE_ALL = 1;
	public static final int TYPE_IMAGE = 2;
	public static final int TYPE_VIDEO = 3;
	public static final String EVENT_TYPE_CAMERA = "camera";
	public static final String EVENT_TYPE_SELECT = "select";
	public static final String EVENT_TYPE_CANCEL = "cancel";
	public static final String EVENT_TYPE_SHOW = "show";
	public static final String EVENT_TYPE_CHANGE = "change";
	public static final String EVENT_TYPE_MAX = "max";
	private List<MediaResource.FileInfo> mFileList;
	private int count = 9;
	private int start = 0;
	private MediaResource.Categary mCurrentCategary = null;
	private int mGroupStart;
	private int mGroupCount;
	private static String mCacheDir;
	private GridView mGridView;
	private GridView mGridAlbumView;
	private ImageGroupAdapter groupAdapter;
	private ImageAlbumAdapter imageAlbumAdapter;
	private String mCurrentGroupId;
	private UZModuleContext cbContext;
	private UZModuleContext openAlbumcbContext;
	private String videoPath;
	private String videogroupId;
	private List<MediaResource.Categary> mCategarys;
	private boolean flag_group_is_fetching = false;
	public static String COMPRESS_CACHE_PATH;
	protected static final int REQUEST_STORAGE_READ_ACCESS_PERMISSION = 101;
	public static UZModuleContext mUZModuleContext;
	public static Config config;
	private MediaFile mediaFile;
	// 有传入groupId时记录下id
	String defaultGroupId = "";
	String defaultGroupName = "";
	private Map<List<FileInfo>, MediaResource.Categary> categaryTemp =new HashMap<>();
	// 所有图片路径的集合;
	private List<FileInfo> allPath = new ArrayList<>();

	public UIAlbumBrowser(UZWebView webView) {
		super(webView);
		mCacheDir = context().getExternalCacheDir().getAbsolutePath() + "/";
	}

	public void scan(int type, int sort) {
		switch (type) {
		case 1:
			this.mFileList = MediaResource.getInstance()
					.getAllImages(context());
			List<MediaResource.FileInfo> allVideos = MediaResource
					.getInstance().getAllVideos(context());
			this.mFileList.addAll(allVideos);
			break;
		case 2:
			this.mFileList = MediaResource.getInstance()
					.getAllImages(context());
			break;
		case 3:
			this.mFileList = MediaResource.getInstance()
					.getAllVideos(context());
		}
		this.start = 0;
		this.mFileList = Utils.sortFile(this.mFileList, sort);
	}

	public List<MediaResource.FileInfo> fetch() {
		if (this.mFileList == null) {
			return null;
		}
		List<MediaResource.FileInfo> result = null;
		if (this.start >= this.mFileList.size()) {
			return null;
		}
		if (this.mFileList != null) {
			int curCount = this.start + this.count;
			if (curCount < this.mFileList.size()) {
				result = this.mFileList.subList(this.start, this.start
						+ this.count);
				this.start += this.count;
			} else if (curCount >= this.mFileList.size()) {
				result = this.mFileList.subList(this.start,
						this.mFileList.size());
				this.start = this.mFileList.size();
			}
		}
		return result;
	}

	public void createEmptyCallback(UZModuleContext uzContext) {
		JSONObject ret = new JSONObject();
		try {
			ret.put("total", 0);
			ret.put("list", new JSONArray());
			uzContext.success(ret, false);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	public void scanGroup(int type) {
		List<MediaResource.FileInfo> fileList = null;
		switch (type) {
		case 1:
			fileList = MediaResource.getInstance().getAllImages(context());
			fileList.addAll(MediaResource.getInstance().getAllVideos(context()));
			break;
		case 2:
			fileList = MediaResource.getInstance().getAllImages(context());
			break;
		case 3:
			fileList = MediaResource.getInstance().getAllVideos(context());
		}
		// 获取到组的分类
		mCategarys = MediaResource.getInstance().getCategary(fileList);
	}

	public void scanByGroupId(String groupId, int orderType) {
		if (mCategarys == null) {
			return;
		}
		mGroupStart = 0;
		for (int i = 0; i < this.mCategarys.size(); i++) {
			MediaResource.Categary categary = (MediaResource.Categary) this.mCategarys
					.get(i);
			if (categary.categaryId.equals(groupId)) {
				mCurrentCategary = categary;
			}
		}
		if (mCurrentCategary == null) {
			return;
		}
		defaultGroupId = mCurrentCategary.categaryId;
		defaultGroupName = mCurrentCategary.categaryName;
		mCurrentCategary.paths = Utils.sortFile(mCurrentCategary.paths,
				orderType);
		allPath = Utils.sortFile(mCurrentCategary.paths, orderType);
	}

	public List<MediaResource.FileInfo> fetchGroup() {
		if (this.mCurrentCategary == null) {
			return null;
		}
		List<MediaResource.FileInfo> result = null;

		List<MediaResource.FileInfo> groupFiles = this.mCurrentCategary.paths;
		if (groupFiles == null) {
			return null;
		}
		if (this.mGroupStart >= groupFiles.size()) {
			return null;
		}
		int curCount = this.mGroupStart + this.mGroupCount;
		if (curCount < groupFiles.size()) {
			result = groupFiles.subList(this.mGroupStart, this.mGroupStart
					+ this.mGroupCount);
			this.mGroupStart += this.mGroupCount;
		} else if (curCount >= groupFiles.size()) {
			result = groupFiles.subList(this.mGroupStart, groupFiles.size());
			this.mGroupStart = groupFiles.size();
		}
		return result;
	}

	public void jsmethod_open(UZModuleContext uzContext) {
		config = new Config(uzContext);
		config.parseOpenParams(uzContext);

		config.isOpen = true;
		mUZModuleContext = uzContext;
		pickImage(config.max, true);
	}

	private int mThumbWidth = 100;
	private int mThumbHeight = 100;
	private UZModuleContext scanModuleContext;

	public void jsmethod_scan(final UZModuleContext uzContext) {
		this.scanModuleContext = uzContext;
		new Thread(new Runnable() {
			public void run() {
				String type = uzContext.optString("type");
				int mediaType = 1;
				if ("video".equals(type)) {
					mediaType = 3;
				} else if ("image".equals(type)) {
					mediaType = 2;
				} else {
					mediaType = 1;
				}
				String order = "desc";
				int orderType = MediaResource.ORDER_DESC;
				JSONObject sortObj = uzContext.optJSONObject("sort");
				if (sortObj != null) {
					order = sortObj.optString("order");
				}
				if ("asc".equals(order)) {
					orderType = MediaResource.ORDER_ASC;
				} else {
					orderType = MediaResource.ORDER_DESC;
				}
				JSONObject thumbnailObj = uzContext.optJSONObject("thumbnail");
				if (thumbnailObj != null) {
					UIAlbumBrowser.this.mThumbWidth = thumbnailObj.optInt("w");
					UIAlbumBrowser.this.mThumbHeight = thumbnailObj.optInt("h");
				}
				UIAlbumBrowser.this.scan(mediaType, orderType);
				UIAlbumBrowser.this.count = uzContext.optInt("count");
				if (UIAlbumBrowser.this.count == 0) {
					UIAlbumBrowser.this.count = (UIAlbumBrowser.this.mFileList
							.size() - 1);
				}
				List<MediaResource.FileInfo> allFileInfos = UIAlbumBrowser.this
						.fetch();
				if (allFileInfos == null) {
					UIAlbumBrowser.this.createEmptyCallback(uzContext);
				} else {
					UIAlbumBrowser.this.callback(uzContext,
							UIAlbumBrowser.this.mFileList.size(), allFileInfos);
				}
			}
		})

		.start();
	}

	private boolean flag_is_fetching = false;

	public void jsmethod_fetch(final UZModuleContext uzContext) {
		if (this.flag_is_fetching) {
			return;
		}
		new Thread(new Runnable() {
			public void run() {
				UIAlbumBrowser.this.flag_is_fetching = true;
				List<MediaResource.FileInfo> fileInfos = UIAlbumBrowser.this
						.fetch();
				UIAlbumBrowser.this.callbackForFetch(uzContext, fileInfos);
				UIAlbumBrowser.this.flag_is_fetching = false;
			}
		})

		.start();
	}

	public void callbackForFetch(UZModuleContext uzContext,
			List<MediaResource.FileInfo> result) {
		callback(uzContext, -1, result);
	}

	public void callback(UZModuleContext uzContext, int total,
			List<MediaResource.FileInfo> result) {
		if (result == null) {
			return;
		}
		JSONArray resultList = new JSONArray();
		JSONObject ret = new JSONObject();
		try {
			for (MediaResource.FileInfo info : result) {
				JSONObject item = new JSONObject();
				item.put("path", info.path);
				if (new File(info.path).exists()) {
					item.put(
							"thumbPath",
							checkOrCreateThumbImage(info.path, info.thumbPath,
									this.mThumbWidth, this.mThumbHeight));

					int pathLen = info.path.length();
					String suffix = info.path.substring(
							info.path.lastIndexOf(".") + 1, pathLen);
					item.put("suffix", suffix);
					item.put("size", info.fileSize);

					item.put("time", new File(info.path).lastModified());
					String lowerSuffix = suffix
							.toLowerCase(Locale.getDefault());
					item.put(
							"mediaType",
							(lowerSuffix.endsWith("png"))
									|| (lowerSuffix.endsWith("jpg"))
									|| (lowerSuffix.endsWith("jpeg")) ? "Image"
									: "Video");
					if ("Video".equals(item.get("mediaType"))) {
						item.put("duration", info.duration);
					}
					resultList.put(item);
					if (total >= 0) {
						ret.put("total", total);
					}
				}
			}
			ret.put("list", resultList);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		uzContext.success(ret, false);
	}

	public static String checkOrCreateThumbImage(String oriPath,
			String thumbPath, int thumbW, int thumbH) {
		Log.i("debug", "thumbW: " + thumbW + " thumbH : " + thumbH);

		String generatedPath = generalPath(oriPath);
		if ((!TextUtils.isEmpty(oriPath)) && (oriPath.endsWith(".mp4"))) {
			if (new File(generatedPath).exists()) {
				return generatedPath;
			}
			Bitmap bmp = ThumbnailUtils.createVideoThumbnail(oriPath, 3);
			if (bmp != null) {
				saveBmp(generatedPath, bmp);
			}
			return generatedPath;
		}
		if (new File(generatedPath).exists()) {
			return generatedPath;
		}
		Bitmap bmp = BitmapFactory.decodeFile(oriPath);
		if (bmp != null) {
			int minW = Math.min(bmp.getWidth(), thumbW);
			int minH = Math.min(bmp.getHeight(), thumbH);
			bmp = ThumbnailUtils.extractThumbnail(bmp, minW, minH);
			saveBmp(generatedPath, bmp);
		}
		return generatedPath;
	}

	public static String generalPath(String originalPath) {
		return mCacheDir + Utils.stringToMD5(originalPath) + ".jpg";
	}

	public static void saveBmp(String path, Bitmap bitmap) {
		File imagePath = new File(path);
		FileOutputStream outStream = null;
		try {
			outStream = new FileOutputStream(imagePath);
			bitmap.compress(Bitmap.CompressFormat.JPEG, 80, outStream);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
		if (outStream != null) {
			try {
				outStream.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	private int mGroupThumbWidth = 100;
	private int mGroupThumbHeight = 100;

	public void jsmethod_scanGroups(final UZModuleContext uzContext) {
		new Thread(new Runnable() {
			public void run() {
				String type = uzContext.optString("type");

				int mediaType = 1;
				if ("video".equals(type)) {
					mediaType = 3;
				} else if ("image".equals(type)) {
					mediaType = 2;
				} else {
					mediaType = 1;
				}
				JSONObject thumbnailObj = uzContext.optJSONObject("thumbnail");
				if (thumbnailObj != null) {
					UIAlbumBrowser.this.mGroupThumbWidth = thumbnailObj
							.optInt("w");
					UIAlbumBrowser.this.mGroupThumbHeight = thumbnailObj
							.optInt("h");
				}
				UIAlbumBrowser.this.scanGroup(mediaType);
				UIAlbumBrowser.this.callbackForGroup(uzContext, mCategarys);
			}
		})

		.start();
	}

	public void callbackForGroup(UZModuleContext uzContext,
			List<MediaResource.Categary> categrays) {
		JSONArray groups = new JSONArray();
		JSONObject ret = new JSONObject();
		for (MediaResource.Categary categary : categrays) {
			JSONObject item = new JSONObject();
			try {
				item.put(
						"thumbPath",
						checkOrCreateThumbImage(
								((MediaResource.FileInfo) categary.paths.get(0)).path,
								((MediaResource.FileInfo) categary.paths.get(0)).thumbPath,
								mGroupThumbWidth, this.mGroupThumbHeight));
				item.put("groupName", categary.categaryName);
				Log.e("groupId", categary.categaryId);
				item.put("groupId", categary.categaryId);
				item.put("groupType", "image");
				item.put("imgCount", categary.paths.size());
				groups.put(item);

				ret.put("total", categrays.size());
				ret.put("list", groups);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		uzContext.success(ret, false);
	}

	public void jsmethod_scanByGroupId(final UZModuleContext uzContext) {
		new Thread(new Runnable() {
			public void run() {
				String groupId = uzContext.optString("groupId");
				UIAlbumBrowser.this.mGroupCount = uzContext.optInt("count");

				String order = "desc";
				int orderType = MediaResource.ORDER_DESC;
				JSONObject sortObj = uzContext.optJSONObject("sort");
				if (sortObj != null) {
					order = sortObj.optString("order");
				}
				if ("asc".equals(order)) {
					orderType = MediaResource.ORDER_ASC;
				} else {
					orderType = MediaResource.ORDER_DESC;
				}
				UIAlbumBrowser.this.scanByGroupId(groupId, orderType);
				if ((UIAlbumBrowser.this.mGroupCount == 0)
						&& (UIAlbumBrowser.this.mCurrentCategary != null)) {
					UIAlbumBrowser.this.mGroupCount = UIAlbumBrowser.this.mCurrentCategary.paths
							.size();
				}
				List<MediaResource.FileInfo> fileInfos = UIAlbumBrowser.this
						.fetchGroup();
				if (UIAlbumBrowser.this.mCurrentCategary != null) {
					UIAlbumBrowser.this.callback(uzContext,
							UIAlbumBrowser.this.mCurrentCategary.paths.size(),
							fileInfos);
				}
			}
		})

		.start();
	}



	public void jsmethod_fetchGroup(final UZModuleContext uzContext) {
		if (this.flag_group_is_fetching) {
			return;
		}
		new Thread(new Runnable() {
			public void run() {
				UIAlbumBrowser.this.flag_group_is_fetching = true;
				List<MediaResource.FileInfo> fileInfos = UIAlbumBrowser.this
						.fetchGroup();
				UIAlbumBrowser.this.callbackForFetch(uzContext, fileInfos);
				UIAlbumBrowser.this.flag_group_is_fetching = false;
			}
		})

		.start();
	}

	public void jsmethod_transPath(UZModuleContext uzContext) {
		String path = uzContext.optString("path");
		String quality = uzContext.optString("quality");
		float scale = (float) uzContext.optDouble("scale", 1.0D);

		Bitmap bmp = null;
		String result = null;
		bmp = BitmapFactory.decodeFile(path);
		if (bmp == null) {
			callbackForTransPath(uzContext, path);
			return;
		}
		bmp = scaleBmp(bmp, scale);
		result = compressImage(bmp, path, quality);
		callbackForTransPath(uzContext, result);
	}

	public void callbackForTransPath(UZModuleContext uzContext, String path) {
		JSONObject ret = new JSONObject();
		try {
			ret.put("path", path);
			uzContext.success(ret, false);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	public Bitmap scaleBmp(Bitmap bmp, float scale) {
		if (bmp == null) {
			return null;
		}
		return Bitmap.createScaledBitmap(bmp, (int) (bmp.getWidth() * scale),
				(int) (bmp.getHeight() * scale), false);
	}

	public String compressImage(Bitmap bmp, String path, String quality) {
		if (bmp == null) {
			return null;
		}
		String result = null;
		if (TextUtils.isEmpty(COMPRESS_CACHE_PATH)) {
			COMPRESS_CACHE_PATH = context().getExternalCacheDir()
					.getAbsolutePath() + "/compressCache";
			File cacheFile = new File(COMPRESS_CACHE_PATH);
			if (!cacheFile.exists()) {
				cacheFile.mkdirs();
			}
		}
		try {
			result = COMPRESS_CACHE_PATH
					+ "/"
					+ Utils.stringToMD5(new StringBuilder(String.valueOf(path))
							.append(quality).toString()) + ".jpg";
			File resultFile = new File(result);
			if (resultFile.exists()) {
				return result;
			}
			bmp.compress(Bitmap.CompressFormat.JPEG, getQuality(quality),
					new FileOutputStream(result));
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			return null;
		}
		return result;
	}

	public int getQuality(String quality) {
		int qualValue = 60;
		switch (quality) {
		case "highest":
			qualValue = 100;
			break;
		case "medium":
			qualValue = 60;
			break;
		case "low":
			qualValue = 30;
			break;
		default:
			qualValue = 60;
			break;
		}
		return qualValue;
	}

	@SuppressLint({ "NewApi" })
	public void jsmethod_getVideoDuration(UZModuleContext uzContext) {
		String path = uzContext.optString("path");
		if (TextUtils.isEmpty(path)) {
			return;
		}
		FileUtil.FileInfo fileInfo = FileUtil.getRealPath(context(), uzContext,
				path);
		if (fileInfo == null) {
			return;
		}
		MediaMetadataRetriever retriever = new MediaMetadataRetriever();
		if (fileInfo.isAssert) {
			try {
				AssetFileDescriptor assetFd = context().getAssets().openFd(
						fileInfo.filePath);
				retriever.setDataSource(assetFd.getFileDescriptor(),
						assetFd.getStartOffset(), assetFd.getLength());
			} catch (IOException e) {
				e.printStackTrace();
			}
		} else {
			retriever.setDataSource(path);
		}
		String duration = retriever.extractMetadata(9);
		JSONObject ret = new JSONObject();
		try {
			ret.put("duration", duration);
			uzContext.success(ret, false);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	public void jsmethod_closePicker(UZModuleContext uzContext) {
		MultiImageSelectorActivity.closeSelector();
	}

	public void jsmethod_imagePicker(UZModuleContext uzContext) {
		config = new Config(uzContext);
		config.isOpen = false;
		mUZModuleContext = uzContext;
		
		boolean showCamera = uzContext.optBoolean("showCamera", true);		
		pickImage(config.max, false, showCamera);
	}

	class GroupParams {
		public int x;
		public int y;
		public int w;
		public int h;
		public String fixedOn;
		public boolean fixed;
		public String groupId;
		public JSONArray selectedPaths;

		public GroupParams(UZModuleContext uzContext) {
			this.w = ScreenUtils.getScreenSize(UIAlbumBrowser.this.context()).x;
			this.h = this.w;
			JSONObject rect = uzContext.optJSONObject("rect");
			if (rect != null) {
				this.x = rect.optInt("x");
				this.y = rect.optInt("y");
				this.w = rect.optInt("w", this.w);
				this.h = rect.optInt("h", this.w);
			}
			this.groupId = uzContext.optString("groupId");

			this.selectedPaths = uzContext.optJSONArray("selectedPaths");

			this.fixedOn = uzContext.optString("fixedOn");
			this.fixed = uzContext.optBoolean("fixed", true);
		}
	}

	@SuppressLint({ "InlinedApi" })
	private void pickImage(int maxNum, boolean isOpen) {
		if ((Build.VERSION.SDK_INT < 16)
				||

				(ActivityCompat.checkSelfPermission(context(),
						"android.permission.READ_EXTERNAL_STORAGE") == 0)) {
			MultiImageSelector selector = MultiImageSelector.create(context());
			if (isOpen) {
				selector.showCamera(false);
			} else {
				selector.showCamera(true);
			}
			selector.count(maxNum);
			selector.isOpen(isOpen);
			selector.setImmersive(inImmerseState());
			selector.multi();
			selector.start((Activity) context(), 2);
		}
	}
	
	
	@SuppressLint({ "InlinedApi" })
	private void pickImage(int maxNum, boolean isOpen, boolean isShowCamera) {
		if ((Build.VERSION.SDK_INT < 16)
				||(ActivityCompat.checkSelfPermission(context(),
						"android.permission.READ_EXTERNAL_STORAGE") == 0)) {
			MultiImageSelector selector = MultiImageSelector.create(context());
			
			selector.showCamera(isShowCamera);
			selector.count(maxNum);
			selector.isOpen(isOpen);
			selector.setImmersive(inImmerseState());
			selector.multi();
			selector.start((Activity) context(), 2);
		}
	}

	public void jsmethod_openGroup(UZModuleContext uzContext) {
		this.cbContext = uzContext;

		GroupParams groupParams = new GroupParams(uzContext);
		this.mGridView = new GridView(context());

		this.mGridView.setBackgroundColor(-1);
		this.mGridView.setNumColumns(4);

		int spacing = UZUtility.dipToPix(3);
		this.mGridView.setHorizontalSpacing(spacing);
		this.mGridView.setVerticalSpacing(spacing);

		this.mGridView.setPadding(spacing, spacing, spacing, spacing);

		String defaultGroupId = "";
		String defaultGroupName = "";
		if (!TextUtils.isEmpty(groupParams.groupId)) {
			scanByGroupId(groupParams.groupId, MediaResource.ORDER_DESC);
		} else {
			scanGroup(2);
			if (mCategarys != null) {
				int maxLength = 0;
				for (MediaResource.Categary categary : this.mCategarys) {
					int tempSize = categary.paths.size();
					if (tempSize > maxLength) {
						maxLength = tempSize;
						defaultGroupId = categary.categaryId;
						defaultGroupName = categary.categaryName;
					}
				}
				scanByGroupId(defaultGroupId, MediaResource.ORDER_DESC);
			}
		}
		RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(
				groupParams.w, groupParams.h);
		layoutParams.leftMargin = groupParams.x;
		layoutParams.topMargin = groupParams.y;

		this.groupAdapter = new ImageGroupAdapter(context(),
				UZUtility.dipToPix(groupParams.w));
		this.mGridView.setAdapter(this.groupAdapter);

		this.mCurrentGroupId = groupParams.groupId;

		setOnItemClickListener(uzContext, this.mCurrentGroupId);
		this.groupAdapter.setPaths(mCurrentCategary.paths);

		JSONArray selectedPaths = uzContext.optJSONArray("selectedPaths");
		Object selectedFileInfos = new ArrayList();
		if (selectedPaths != null) {
			for (int i = 0; i < selectedPaths.length(); i++) {
				MediaResource.FileInfo fileInfo = new MediaResource.FileInfo();
				fileInfo.path = selectedPaths.optString(i);
				((ArrayList) selectedFileInfos).add(fileInfo);
				this.groupAdapter.setSelectedPaths((List) selectedFileInfos);
			}
		}
		insertViewToCurWindow(this.mGridView, layoutParams,
				groupParams.fixedOn, groupParams.fixed);
		Utils.callbackForOpenGroup(uzContext, "show", defaultGroupName, null,
				null);
	}

	public void setOnItemClickListener(final UZModuleContext uzContext,
			final String groupId) {
		this.mGridView
				.setOnItemClickListener(new AdapterView.OnItemClickListener() {
					public void onItemClick(AdapterView<?> arg0, View arg1,
							int arg2, long arg3) {
						if (arg2 == 0) {
							Utils.callback(uzContext, "camera", null, null);
						} else {
							UIAlbumBrowser.this.groupAdapter.addSelectedPath(
									UIAlbumBrowser.this.groupAdapter
											.getItem(arg2), uzContext, groupId);
						}
					}
				});
	}

	public void jsmethod_closeGroup(UZModuleContext uzContext) {
		removeViewFromCurWindow(this.mGridView);
		this.mGridView = null;
	}

	public void jsmethod_changeGroup(UZModuleContext uzContext) {
		String groupId = uzContext.optString("groupId");
		scanByGroupId(groupId, MediaResource.ORDER_DESC);
		this.groupAdapter.setPaths(mCurrentCategary.paths);
		this.groupAdapter.notifyDataSetChanged();
		Utils.callback(this.cbContext, "change", groupId, null);
	}

	/****
	 * 打开相册;
	 * 
	 * @param uzContext
	 */


	public void jsmethod_openAlbum(UZModuleContext uzContext) {
		mediaFile = new MediaFile();
		openAlbumcbContext = uzContext;
		AlbumParams albumParams = new AlbumParams(uzContext);
		mGridAlbumView = new GridView(context());
		mGridAlbumView.setBackgroundColor(-1);
		mGridAlbumView.setNumColumns(albumParams.column);
		int spacing = UZUtility.dipToPix(albumParams.interval);
		mGridAlbumView.setHorizontalSpacing(spacing);
		mGridAlbumView.setVerticalSpacing(spacing);
		mGridAlbumView.setPadding(spacing, spacing, spacing, spacing);
		// 没有传入组id
		int Type = 1;
		switch (albumParams.type) {
		case "all":
			Type = 1;
			break;
		case "image":
			Type = 2;
			break;
		case "video":
			Type = 3;
			break;
		}
		// 扫描组类型;
		scanGroup(Type);
		if (!TextUtils.isEmpty(albumParams.groupId)) {
			scanByGroupId(albumParams.groupId, MediaResource.ORDER_DESC);
		} else {
			//没有传入组id, 遍历所有数据
			getCategaryPaths(mCategarys);

		}
		BitmapDrawable normal = createDrawable(albumParams.normal, null);
		BitmapDrawable active = createDrawable(albumParams.active, null);
		RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(
				albumParams.w, albumParams.h);
		layoutParams.leftMargin = albumParams.x;
		layoutParams.topMargin = albumParams.y;

		imageAlbumAdapter = new ImageAlbumAdapter(context(),
				UZUtility.dipToPix(albumParams.w), albumParams.max, normal,
				active, albumParams.iconSize, albumParams.column);
		mGridAlbumView.setAdapter(imageAlbumAdapter);

		mCurrentGroupId = albumParams.groupId;
		if (TextUtils.isEmpty(mCurrentGroupId)) {
			mCurrentGroupId = "";
		}

		setOnItemAlbumClickListener(uzContext, mCurrentGroupId, allPath,
				albumParams.max, albumParams);
		imageAlbumAdapter.setPaths(allPath);
		// imageAlbumAdapter.setPaths(mCurrentCategary.paths);
		JSONArray selectedPaths = uzContext.optJSONArray("selectedPaths");
		Object selectedFileInfos = new ArrayList();
		if (selectedPaths != null) {
			for (int i = 0; i < selectedPaths.length(); i++) {
				MediaResource.FileInfo fileInfo = new MediaResource.FileInfo();
				fileInfo.path = selectedPaths.optString(i);
				((ArrayList) selectedFileInfos).add(fileInfo);
				imageAlbumAdapter.setSelectedPaths((List) selectedFileInfos);
			}
		}
		insertViewToCurWindow(this.mGridAlbumView, layoutParams,
				albumParams.fixedOn, albumParams.fixed);
		Utils.callbackForOpenGroup(uzContext, "show", defaultGroupName, null,
				null);
	}

	/***
	 * 关闭相册;
	 * 
	 * @param uzContext
	 */
	public void jsmethod_closeAlbum(UZModuleContext uzContext) {
		if (this.mGridAlbumView != null) {
			removeViewFromCurWindow(this.mGridAlbumView);
			this.mGridView = null;
		}
	}

	/****
	 * 条目的点击事件;
	 * 
	 * @param uzContext
	 * @param groupId
	 * @param paths
	 * @param max
	 * @param albumParams
	 */
	public void setOnItemAlbumClickListener(final UZModuleContext uzContext,
			final String groupId, final List<MediaResource.FileInfo> paths,
			int max, final AlbumParams albumParams) {
		this.mGridAlbumView
				.setOnItemClickListener(new AdapterView.OnItemClickListener() {
					private String path;

					public void onItemClick(AdapterView<?> arg0, View arg1,
							int arg2, long arg3) {
						MediaResource.FileInfo fileInfo = (MediaResource.FileInfo) paths
								.get(arg2);
						path = fileInfo.path;
						String SS = MediaFile.getMimeTypeForFile(this.path);

						boolean contains = SS.contains("video");
						if (contains) {
							if (UIAlbumBrowser.this.imageAlbumAdapter.selectedPaths
									.size() > 0) {
								Toast.makeText(UIAlbumBrowser.this.mContext,
										"不能同时选择视频和图片", 0).show();
								return;
							}
							videoPath = path;
							videogroupId = groupId;
							if (albumParams.videoPreview) {
								Intent intent = new Intent(
										UIAlbumBrowser.this.mContext,
										videoActivity.class);
								intent.putExtra("path", this.path);
								UIAlbumBrowser.this.startActivityForResult(
										intent, 101);
							} else {
								Utils.AlbumCallback(
										UIAlbumBrowser.this.openAlbumcbContext,
										"select",
										UIAlbumBrowser.this.videogroupId,
										UIAlbumBrowser.this.videoPath, "video");
							}
							return;
						}
						imageAlbumAdapter.addSelectedPath(
								UIAlbumBrowser.this.imageAlbumAdapter
										.getItem(arg2), uzContext, groupId);
					}
				});
	}

	/****
	 * 获取视频点击完成的回调数据;
	 */
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		if ((resultCode == 102) && (requestCode == 101)) {
			Bundle bundle = data.getExtras();

			boolean boolean1 = bundle.getBoolean("boolean");
			if (boolean1) {
				Utils.AlbumCallback(this.openAlbumcbContext, "select",
						this.videogroupId, this.videoPath, "video");
			}
		}
		super.onActivityResult(requestCode, resultCode, data);
	}

	/***
	 * 获取传入数据的类;
	 * 
	 * @author apicloud0820
	 * 
	 */
	class AlbumParams {
		public int x;
		public int y;
		public int w;
		public int h;
		public String fixedOn;
		public boolean fixed;
		public String groupId;
		public JSONArray selectedPaths;
		public int max;
		public String type;
		public int column;
		public int interval;
		public String normal;
		public String active;
		public int iconSize;
		public boolean videoPreview;

		public AlbumParams(UZModuleContext uzContext) {
			this.w = ScreenUtils.getScreenSize(UIAlbumBrowser.this.context()).x;
			this.h = this.w;
			JSONObject rect = uzContext.optJSONObject("rect");
			if (rect != null) {
				this.x = rect.optInt("x");
				this.y = rect.optInt("y");
				this.w = rect.optInt("w", this.w);
				this.h = rect.optInt("h", this.w);
			}
			this.videoPreview = uzContext.optBoolean("videoPreview", true);

			this.groupId = uzContext.optString("groupId");

			this.max = uzContext.optInt("max", 9);

			this.type = uzContext.optString("type", "all");

			this.fixedOn = uzContext.optString("fixedOn");
			this.fixed = uzContext.optBoolean("fixed", true);

			JSONObject stylesObj = uzContext.optJSONObject("styles");
			if (stylesObj != null) {
				this.column = stylesObj.optInt("column", 3);

				this.interval = stylesObj.optInt("interval", 5);
				JSONObject selectorObj = stylesObj.optJSONObject("selector");
				if (selectorObj != null) {
					this.normal = selectorObj.optString("normal");
					this.active = selectorObj.optString("active");
					this.iconSize = selectorObj.optInt("size", 20);
				} else {
					this.normal = "";
					this.active = "";
					this.iconSize = 20;
				}
			} else {
				this.column = 3;
				this.interval = 5;
				this.normal = "";
				this.active = "";
				this.iconSize = 20;
			}
		}
	}

	private BitmapDrawable createDrawable(String imgPath,
			BitmapDrawable defaultValue) {
		String realPath = makeRealPath(imgPath);
		Bitmap bitmap = getBitmap(realPath);
		if (bitmap != null) {
			return new BitmapDrawable(this.mContext.getResources(), bitmap);
		}
		return defaultValue;
	}

	/***
	 * 传入路径拿图片;
	 * 
	 * @param path
	 * @return
	 */
	public Bitmap getBitmap(String path) {
		Bitmap bitmap = null;
		InputStream input = null;
		try {
			input = UZUtility.guessInputStream(path);
			bitmap = BitmapFactory.decodeStream(input);
		} catch (IOException e) {
			e.printStackTrace();
		}
		if (input != null) {
			try {
				input.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return bitmap;
	}

	/***
	 * 获取所有图片的路径集合;
	 * 
	 * @param uzContext
	 * @param categrays
	 */
	public void getCategaryPaths(List<MediaResource.Categary> categrays) {
		allPath.clear();
		categaryTemp.clear();
		for (MediaResource.Categary categary : categrays) {
			allPath.addAll(categary.paths);
		}
	}

}
