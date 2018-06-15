/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.UIAlbumBrowser;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import me.nereo.multi_image_selector.MultiImageSelector;
import me.nereo.multi_image_selector.MultiImageSelectorActivity;
import me.nereo.multi_image_selector.adapter.ImageGroupAdapter;
import me.nereo.multi_image_selector.utils.ScreenUtils;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.content.res.AssetFileDescriptor;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.media.MediaMetadataRetriever;
import android.media.ThumbnailUtils;
import android.os.Build;
import android.provider.MediaStore.Images;
import android.support.v4.app.ActivityCompat;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.GridView;
import android.widget.RelativeLayout;

import com.apicloud.UIAlbumBrowser.MediaResource.Categary;
import com.apicloud.UIAlbumBrowser.MediaResource.FileInfo;
import com.uzmap.pkg.uzcore.UZWebView;
import com.uzmap.pkg.uzcore.uzmodule.UZModule;
import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;
import com.uzmap.pkg.uzkit.UZUtility;

public class UIAlbumBrowser extends UZModule{
	
	public static final String TAG = "UIAlbumBrowser";
	
	public static final int TYPE_ALL = 0x001;
	public static final int TYPE_IMAGE = 0x002;
	public static final int TYPE_VIDEO = 0x003;
	
	
	public static final String EVENT_TYPE_CAMERA = "camera";
	public static final String EVENT_TYPE_SELECT = "select";
	public static final String EVENT_TYPE_CANCEL = "cancel";
	public static final String EVENT_TYPE_SHOW = "show";
	public static final String EVENT_TYPE_CHANGE = "change";

	private List<FileInfo> mFileList;
	private int count = 9;
	private int start = 0;
	
	private Categary mCurrentCategary = null;
	private int mGroupStart;
	private int mGroupCount;
	
	private static String mCacheDir;

	public UIAlbumBrowser(UZWebView webView) {
		super(webView);
		mCacheDir = context().getExternalCacheDir().getAbsolutePath() + "/";
	}
	
	public void scan(int type, int sort) {
		switch (type) {
		case TYPE_ALL:
			mFileList = MediaResource.getInstance().getAllImages(context());
			List<FileInfo> allVideos = MediaResource.getInstance()
					.getAllVideos(context());
			mFileList.addAll(allVideos);
			break;
		case TYPE_IMAGE:
			mFileList = MediaResource.getInstance().getAllImages(context());
			break;
		case TYPE_VIDEO:
			mFileList = MediaResource.getInstance().getAllVideos(context());
			break;
		}
		
		start = 0;
		mFileList = Utils.sortFile(mFileList, sort);
	}

	public List<FileInfo> fetch() {
		
		if(mFileList == null){
			return null;
		}
		List<FileInfo> result = null;
		if (start >= mFileList.size()) {
			return null;
		}
		if (mFileList != null) {
			int curCount = start + count;
			if ( curCount < mFileList.size()) {
				result = mFileList.subList(start, start + count);
				start += count;
			} else if (curCount >= mFileList.size()) {
				result = mFileList.subList(start, mFileList.size());
				start = mFileList.size();
			}
		}
		return result;
	}

	private List<Categary> mCategarys;

	public void scanGroup(int type) {
		List<FileInfo> fileList = null;
		switch (type) {
		case TYPE_ALL:
			fileList = MediaResource.getInstance().getAllImages(context());
			fileList.addAll(MediaResource.getInstance().getAllVideos(context()));
			break;
		case TYPE_IMAGE:
			fileList = MediaResource.getInstance().getAllImages(context());
			break;
		case TYPE_VIDEO:
			fileList = MediaResource.getInstance().getAllVideos(context());
			break;
		}
		mCategarys = MediaResource.getInstance().getCategary(fileList);
	}

	public void scanByGroupId(String groupId, int orderType) {
		if (mCategarys == null) {
			return;
		}
		mGroupStart = 0;
		for (int i = 0; i < mCategarys.size(); i++) {
			Categary categary = mCategarys.get(i);
			if (categary.categaryId.equals(groupId)) {
				mCurrentCategary = categary;
			}
		}
		if(mCurrentCategary == null){
			return;
		}
		mCurrentCategary.paths = Utils.sortFile(mCurrentCategary.paths, orderType);
		
		
		for(int i=0; i<mCurrentCategary.paths.size(); i++){
			Log.i("debug", "time : " + mCurrentCategary.paths.get(i).modifiedTime);
		}
	}

	public List<FileInfo> fetchGroup() {
		if (mCurrentCategary == null) {
			return null;
		}
		List<FileInfo> result = null;

		List<FileInfo> groupFiles = mCurrentCategary.paths;
		if(groupFiles == null){
			return null;
		}
		if (mGroupStart >= groupFiles.size()) {
			return null;
		}
		
		int curCount = mGroupStart + mGroupCount;
		
		if ( curCount < groupFiles.size()) {
			result = groupFiles.subList(mGroupStart, mGroupStart + mGroupCount);
			mGroupStart += mGroupCount;
		} else if (curCount >= groupFiles.size()) {
			result = groupFiles.subList(mGroupStart, groupFiles.size());
			mGroupStart = groupFiles.size();
		}
		return result;
	}

	public void jsmethod_open(UZModuleContext uzContext){
		
		config = new Config(uzContext);
		config.parseOpenParams(uzContext);
		
		config.isOpen = true;
    	mUZModuleContext = uzContext;
    	pickImage(config.max, true);
	}
	
	private int mThumbWidth = 100;
	private int mThumbHeight = 100;
	
	public void jsmethod_scan(final UZModuleContext uzContext){
		new Thread(new Runnable(){
			@Override
			public void run() {
				String type = uzContext.optString("type");
				int mediaType = TYPE_ALL;
				if("video".equals(type)){
					mediaType = TYPE_VIDEO;
				} else if("image".equals(type)){
					mediaType = TYPE_IMAGE;
				} else {
					mediaType = TYPE_ALL;
				}
				
				String order = "desc";
				int orderType = MediaResource.ORDER_DESC;
				JSONObject sortObj = uzContext.optJSONObject("sort");
				if(sortObj != null){
					order = sortObj.optString("order");
				}
				if("asc".equals(order)){
					orderType = MediaResource.ORDER_ASC;
				} else {
					orderType = MediaResource.ORDER_DESC;
				}
				
				JSONObject thumbnailObj = uzContext.optJSONObject("thumbnail");

				if(thumbnailObj != null){
					mThumbWidth = thumbnailObj.optInt("w");
					mThumbHeight = thumbnailObj.optInt("h");
				}
				scan(mediaType, orderType);
				count = uzContext.optInt("count");
				if(count == 0){
					count = mFileList.size() - 1;
				}
				List<FileInfo> allFileInfos = fetch();
				callback(uzContext, mFileList.size(), allFileInfos);
			}
		}).start();
	}
	
	private boolean flag_is_fetching = false;
	
	public void jsmethod_fetch(final UZModuleContext uzContext){
		if(flag_is_fetching){ // 直到fetch完成后才能再次fetch, 避免错序乱序
			return;
		}
		new Thread(new Runnable(){
			@Override
			public void run() {
				flag_is_fetching = true;
				List<FileInfo> fileInfos = fetch();
				callbackForFetch(uzContext, fileInfos);
				flag_is_fetching = false;
			}
		}).start();
	}
	
	// private SimpleDateFormat mFormatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
	// private Date mModifiedDate = new Date();
	
	
	public void callbackForFetch(UZModuleContext uzContext, List<FileInfo> result){
		callback(uzContext, -1, result);
	}
	
	public void callback(UZModuleContext uzContext, int total, List<FileInfo> result){
		if(result == null){
			return;
		}
		JSONArray resultList = new JSONArray();
		JSONObject ret = new JSONObject();
		for(FileInfo info : result){
			JSONObject item = new JSONObject();
			try {
				item.put("path", info.path);
				item.put("thumbPath", checkOrCreateThumbImage(info.path, info.thumbPath, mThumbWidth, mThumbHeight));
				
				int pathLen = info.path.length();
				String suffix = info.path.substring(pathLen - 3, pathLen);
				item.put("suffix", suffix);
				item.put("size", info.fileSize);
				// mModifiedDate.setTime(info.modifiedTime);
				item.put("time", new File(info.path).lastModified() + "");
				
				item.put("mediaType", suffix.endsWith("png") || suffix.endsWith("jpg") ? "Image" : "Video");
			    if("Video".equals(item.get("mediaType"))){
			    	item.put("duration", info.duration);
			    }
				resultList.put(item);
				
				if(total >= 0){
					ret.put("total", total);
				}
				ret.put("list", resultList);
				
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		uzContext.success(ret, false);
	}
	
	public static String checkOrCreateThumbImage(String oriPath, String thumbPath, int thumbW, int thumbH){
		
		Log.i("debug", "thumbW: " + thumbW + " thumbH : " +  thumbH);
		
		String generatedPath = generalPath(oriPath);
		if(!TextUtils.isEmpty(oriPath) && oriPath.endsWith(".mp4") ){
			if(new File(generatedPath).exists()){
				return generatedPath;
			} else {
				Bitmap bmp = ThumbnailUtils.createVideoThumbnail(oriPath, Images.Thumbnails.MICRO_KIND);
				if(bmp != null){
					saveBmp(generatedPath, bmp);
				}
				return generatedPath;
			}
		}
		
//		if(TextUtils.isEmpty(thumbPath) && new File(generatedPath).exists()){
//			return generatedPath;
//		} else if(!TextUtils.isEmpty(thumbPath) && new File(thumbPath).exists()){
//			return thumbPath;
//		} else if(!TextUtils.isEmpty(thumbPath) && !new File(thumbPath).exists() && new File(generatedPath).exists()){
//			return generatedPath;
//		} else {
//			Bitmap bmp = BitmapFactory.decodeFile(oriPath);
//			if(bmp != null){
//				int minW = Math.min(bmp.getWidth(), thumbW);
//				int minH = Math.min(bmp.getHeight(), thumbH);
//				bmp = ThumbnailUtils.extractThumbnail(bmp, minW, minH);
//				saveBmp(generatedPath, bmp);
//			}
//			return generatedPath;
//		}
		
		// bad way
		if(new File(generatedPath).exists()){
			return generatedPath;
		} else {
			Bitmap bmp = BitmapFactory.decodeFile(oriPath);
			if(bmp != null){
				int minW = Math.min(bmp.getWidth(), thumbW);
				int minH = Math.min(bmp.getHeight(), thumbH);
				bmp = ThumbnailUtils.extractThumbnail(bmp, minW, minH);
				saveBmp(generatedPath, bmp);
			}
			return generatedPath;
		}
	}
	
	public static String generalPath(String originalPath){
		return mCacheDir + Utils.stringToMD5(originalPath) + ".jpg";
	}
	
	public static void saveBmp(String path, Bitmap bitmap){
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
	
	public void jsmethod_scanGroups(final UZModuleContext uzContext){
		
		new Thread(new Runnable(){
			@Override
			public void run() {
				String type = uzContext.optString("type");
				
				int mediaType = TYPE_ALL;
				if("video".equals(type)){
					mediaType = TYPE_VIDEO;
				} else if("image".equals(type)){
					mediaType = TYPE_IMAGE;
				} else {
					mediaType = TYPE_ALL;
				}
				
				JSONObject thumbnailObj = uzContext.optJSONObject("thumbnail");

				if(thumbnailObj != null){
					mGroupThumbWidth = thumbnailObj.optInt("w");
					mGroupThumbHeight = thumbnailObj.optInt("h");
				}
				
				scanGroup(mediaType);
				callbackForGroup(uzContext, mCategarys);
			}
		}).start();
	}
	
	public void callbackForGroup(UZModuleContext uzContext, List<Categary> categrays){
		JSONArray groups = new JSONArray();
		JSONObject ret = new JSONObject();
		for(Categary categary : categrays){
			JSONObject item = new JSONObject();
			try {
				item.put("thumbPath", checkOrCreateThumbImage(categary.paths.get(0).path, categary.paths.get(0).thumbPath, mGroupThumbWidth, mGroupThumbHeight));
				item.put("groupName", categary.categaryName);
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
	
	public void jsmethod_scanByGroupId(final UZModuleContext uzContext){
		
		new Thread(new Runnable(){
			@Override
			public void run() {
				String groupId = uzContext.optString("groupId");
				mGroupCount = uzContext.optInt("count");
				
				String order = "desc";
				int orderType = MediaResource.ORDER_DESC;
				JSONObject sortObj = uzContext.optJSONObject("sort");
				if(sortObj != null){
					order = sortObj.optString("order");
				}
				if("asc".equals(order)){
					orderType = MediaResource.ORDER_ASC;
				} else {
					orderType = MediaResource.ORDER_DESC;
				}
				
				scanByGroupId(groupId, orderType);
				if(mGroupCount == 0 && mCurrentCategary != null){
					mGroupCount = mCurrentCategary.paths.size();
				}
				List<FileInfo> fileInfos = fetchGroup();
				if(mCurrentCategary != null){
					callback(uzContext, mCurrentCategary.paths.size(), fileInfos);
				}
			}
		}).start();
	}
	
	
	private boolean flag_group_is_fetching = false;
	
	public void jsmethod_fetchGroup(final UZModuleContext uzContext){
		if(flag_group_is_fetching){
			return;
		}
		new Thread(new Runnable(){
			@Override
			public void run() {
				flag_group_is_fetching = true;
				List<FileInfo> fileInfos = fetchGroup();
				callbackForFetch(uzContext, fileInfos);
				flag_group_is_fetching = false;
			}
		}).start();
		
	}
	
	public void jsmethod_transPath(UZModuleContext uzContext){
		String path = uzContext.optString("path");
		String quality = uzContext.optString("quality");
		float scale = (float)uzContext.optDouble("scale", 1.0f);
		
		Bitmap bmp = BitmapFactory.decodeFile(path);
		bmp = scaleBmp(bmp, scale);
		String result = compressImage(bmp, path, quality);
		JSONObject ret = new JSONObject();
		try {
			ret.put("path", result);
			uzContext.success(ret, false);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}
	
	
	public Bitmap scaleBmp(Bitmap bmp, float scale){   
		if(bmp == null){
			return null;
		}
		return Bitmap.createScaledBitmap(bmp, (int)((float)bmp.getWidth() * scale), (int)((float)bmp.getHeight() * scale), false);
	}
	
	
	public static String COMPRESS_CACHE_PATH;
	
	public String compressImage(Bitmap bmp, String path, String quality){
		if(bmp == null){
			return null;
		}
		String result = null;
		if(TextUtils.isEmpty(COMPRESS_CACHE_PATH)){
			COMPRESS_CACHE_PATH = context().getExternalCacheDir().getAbsolutePath()+"/compressCache" ;
			File cacheFile = new File(COMPRESS_CACHE_PATH);
			if(!cacheFile.exists()){
				cacheFile.mkdirs();
			}
		}
		try {
			result = COMPRESS_CACHE_PATH + "/" + Utils.stringToMD5(path + quality) + ".jpg";
			File resultFile = new File(result);
			if(resultFile.exists()){
				return result;
			}
			bmp.compress(CompressFormat.JPEG, getQuality(quality), new FileOutputStream(result));
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			return null;
		}
		return result;
	}
	
	public int getQuality(String quality){
		int qualValue = 60;
		switch(quality){
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
	
	
	
	@SuppressLint("NewApi") 
	public void jsmethod_getVideoDuration(UZModuleContext uzContext){
		
		String path = uzContext.optString("path");
		if(TextUtils.isEmpty(path)){
			return;
		}
		
		FileUtil.FileInfo fileInfo = FileUtil.getRealPath(context(), uzContext, path);
		if(fileInfo == null){
			return;
		}
		
		MediaMetadataRetriever retriever = new MediaMetadataRetriever();
		if(fileInfo.isAssert){
			AssetFileDescriptor assetFd;
			try {
				assetFd = context().getAssets().openFd(fileInfo.filePath);
				retriever.setDataSource(assetFd.getFileDescriptor(), assetFd.getStartOffset(), assetFd.getLength());
			} catch (IOException e) {
				e.printStackTrace();
			}
		} else {
			retriever.setDataSource(path);
		}
		String duration = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
		JSONObject ret = new JSONObject();
		try {
			ret.put("duration", duration);
			uzContext.success(ret, false);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}
	
	public void jsmethod_closePicker(UZModuleContext uzContext){
		MultiImageSelectorActivity.closeSelector();
	}
	
	protected static final int REQUEST_STORAGE_READ_ACCESS_PERMISSION = 101;
	
	 @SuppressLint("InlinedApi") 
	 private void pickImage(int maxNum, boolean isOpen) {
//		    int mis_permission_rationale = ResUtils.getInstance().getStringId(context(), "mis_permission_rationale");
	        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN // Permission was added in API Level 16
	                && ActivityCompat.checkSelfPermission(context(), Manifest.permission.READ_EXTERNAL_STORAGE)
	                != PackageManager.PERMISSION_GRANTED) {
	        	
//	            context().requestPermission(Manifest.permission.READ_EXTERNAL_STORAGE,
//	                    context().getResources().getString(mis_permission_rationale),
//	                    REQUEST_STORAGE_READ_ACCESS_PERMISSION);
	        } else {
	            @SuppressWarnings("deprecation")
				MultiImageSelector selector = MultiImageSelector.create(context());
	            if(isOpen){
	            	selector.showCamera(false);
	            } else {
	            	selector.showCamera(true);
	            }
	            selector.count(maxNum);
	            selector.isOpen(isOpen);
	            selector.setImmersive(this.inImmerseState());
	            selector.multi();
	            selector.start((Activity)context(), 2);
	        }
	    }
	 
	    public static UZModuleContext mUZModuleContext;
	    public static Config config;
	    
	    public void jsmethod_imagePicker(UZModuleContext uzContext){
	    	config = new Config(uzContext);
	    	config.isOpen = false;
	    	mUZModuleContext = uzContext;
	    	pickImage(config.max, false);
	    }
	    
	    class GroupParams{
	    	public int x;
	    	public int y;
	    	public int w;
	    	public int h;
	    	public String fixedOn;
	    	public boolean fixed;
	    	public String groupId;
	    	public JSONArray selectedPaths;
	    	
	    	public GroupParams(UZModuleContext uzContext){
	    		
	    		w = ScreenUtils.getScreenSize(context()).x;
	    		h = w;
	    		JSONObject rect = uzContext.optJSONObject("rect");
	    		if(rect != null){
	    			x = rect.optInt("x");
		    		y = rect.optInt("y");
		    		w = rect.optInt("w", w);
		    		h = rect.optInt("h", w);
	    		}
	    		groupId = uzContext.optString("groupId");
	    		selectedPaths = uzContext.optJSONArray("selectedPaths");
	    		fixedOn = uzContext.optString("fixedOn");
	    		fixed = uzContext.optBoolean("fixed", true);
	    	}
	    }
	    
	    
	    private GridView mGridView;
	    private ImageGroupAdapter groupAdapter;
	    private String mCurrentGroupId;
	    private UZModuleContext cbContext;
	    
	    public void jsmethod_openGroup(final UZModuleContext uzContext){
	    	
	    	this.cbContext = uzContext;
	    	
	    	GroupParams groupParams = new GroupParams(uzContext);
	    	mGridView = new GridView(context());
	    	
	    	mGridView.setBackgroundColor(0xFFFFFFFF);
	    	
	    	mGridView.setNumColumns(4);
	    	
	    	int spacing = UZUtility.dipToPix(3);
	    	mGridView.setHorizontalSpacing(spacing);
	    	mGridView.setVerticalSpacing(spacing);
	    	
	    	mGridView.setPadding(spacing, spacing, spacing, spacing);
	    	
	    	scanByGroupId(groupParams.groupId, MediaResource.ORDER_DESC);
	    	
	    	RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(groupParams.w, groupParams.h);
	    	layoutParams.leftMargin = groupParams.x;
	    	layoutParams.topMargin = groupParams.y;
	    	
	    	groupAdapter = new ImageGroupAdapter(context(), UZUtility.dipToPix(groupParams.w));
	    	mGridView.setAdapter(groupAdapter);
	    	
	    	mCurrentGroupId = groupParams.groupId;
	    	
	    	setOnItemClickListener(uzContext, mCurrentGroupId);
	    	
	    	groupAdapter.setPaths(mCurrentCategary.paths);
	    	
	    	
	    	JSONArray selectedPaths = uzContext.optJSONArray("selectedPaths");
	    	ArrayList<FileInfo> selectedFileInfos = new ArrayList<FileInfo>();
	    	if(selectedPaths != null){
	    		for(int i=0; i<selectedPaths.length(); i++){
	    			FileInfo fileInfo = new FileInfo();
	    			fileInfo.path = selectedPaths.optString(i);
	    			selectedFileInfos.add(fileInfo);
	    			groupAdapter.setSelectedPaths(selectedFileInfos);
	    		}
	    	}
	    	
	    	insertViewToCurWindow(mGridView, layoutParams, groupParams.fixedOn, groupParams.fixed);
	    	Utils.callback(uzContext, UIAlbumBrowser.EVENT_TYPE_SHOW, null, null);
	    }
	    
	    public void setOnItemClickListener(final UZModuleContext uzContext, final String groupId){
	    	mGridView.setOnItemClickListener(new OnItemClickListener() {
				@Override
				public void onItemClick(AdapterView<?> arg0, View arg1,
						int arg2, long arg3) {
					if(arg2 == 0){
						Utils.callback(uzContext, EVENT_TYPE_CAMERA, null, null);
					} else {
						groupAdapter.addSelectedPath(groupAdapter.getItem(arg2), uzContext, groupId);
					}
				}
			});
	    }
	    
	    public void jsmethod_closeGroup(UZModuleContext uzContext){
	    	removeViewFromCurWindow(mGridView);
	    	mGridView = null;
	    }
	    
	    public void jsmethod_changeGroup(UZModuleContext uzContext){
	    	String groupId = uzContext.optString("groupId");
	    	scanByGroupId(groupId, MediaResource.ORDER_DESC);
	    	groupAdapter.setPaths(mCurrentCategary.paths);
	    	groupAdapter.notifyDataSetChanged();
	    	Utils.callback(cbContext, EVENT_TYPE_CHANGE, groupId, null);
	    }
}
