/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package me.nereo.multi_image_selector.adapter;

import java.util.ArrayList;
import java.util.List;

import me.nereo.multi_image_selector.utils.ResUtils;

import com.apicloud.UIAlbumBrowser.MediaResource.FileInfo;
import com.apicloud.UIAlbumBrowser.UIAlbumBrowser;
import com.apicloud.UIAlbumBrowser.Utils;
import com.bumptech.glide.Glide;
import com.uzmap.pkg.uzcore.UZResourcesIDFinder;
import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;

public class ImageGroupAdapter extends BaseAdapter{
	
	private Context context;
	private List<FileInfo> paths = new ArrayList<FileInfo>();
	
	private List<FileInfo> selectedPaths = new ArrayList<FileInfo>(); 
	private int width;
	
	
	public void setSelectedPaths(List<FileInfo> selectedFileInfos){
		this.selectedPaths = selectedFileInfos;
		notifyDataSetChanged();
	}
	
	
	public void addSelectedPath(FileInfo fileInfo, UZModuleContext cbContext, String groupId){
		if(!selectedPaths.contains(fileInfo)){
			selectedPaths.add(fileInfo);
			
			Log.i("debug", "path: " + fileInfo.path);
			Utils.callback(cbContext, UIAlbumBrowser.EVENT_TYPE_SELECT, groupId, fileInfo.path);
		} else {
			selectedPaths.remove(fileInfo);
			Utils.callback(cbContext, UIAlbumBrowser.EVENT_TYPE_CANCEL, groupId, fileInfo.path);
		}
		notifyDataSetChanged();
	}
	
	public ImageGroupAdapter(Context context, int width){
		this.context = context;
		this.width = width;
	}

	@Override
	public int getCount() {
		return paths.size() + 1;
	}

	@Override
	public FileInfo getItem(int arg0) {
		if(arg0 == 0){
			return null;
		}
		return paths.get(arg0 - 1);
	}

	@Override
	public long getItemId(int arg0) {
		return arg0;
	}
	
	public void setPaths(List<FileInfo> paths){
		this.paths = paths;
		notifyDataSetChanged();
	}

	@Override
	public View getView(int arg0, View arg1, ViewGroup arg2) {
		
		if(arg0 == 0){
			int group_image_layout_id = UZResourcesIDFinder.getResLayoutID("mis_group_image_layout");
			arg1 = View.inflate(context, group_image_layout_id, null);
			
			int showImageId = UZResourcesIDFinder.getResIdID("image");
			ImageView showImage = (ImageView)arg1.findViewById(showImageId);
			
			int camera_image_id = UZResourcesIDFinder.getResDrawableID("mis_group_camera_icon");
			showImage.setImageResource(camera_image_id);
			
			int coverImageId = UZResourcesIDFinder.getResIdID("coverImage");
			ImageView coverImage = (ImageView)arg1.findViewById(coverImageId);
			coverImage.setVisibility(View.GONE);
			
			return arg1;
		}
		
		if(arg1 == null){
			int group_image_layout_id = UZResourcesIDFinder.getResLayoutID("mis_group_image_layout");
			arg1 = View.inflate(context, group_image_layout_id, null);
		}
		
		int showImageId = UZResourcesIDFinder.getResIdID("image");
		ImageView showImage = (ImageView)arg1.findViewById(showImageId);
		
		int coverImageId = UZResourcesIDFinder.getResIdID("coverImage");
		ImageView coverImage = (ImageView)arg1.findViewById(coverImageId);
		
		if(selectedPaths.contains(paths.get(arg0 - 1))){
			coverImage.setVisibility(View.VISIBLE);
		} else {
			coverImage.setVisibility(View.GONE);
		}
		
		int mis_default_error_id = ResUtils.getInstance().getDrawableId(context, "mis_default_error");
		int perWidth = width / 4;
		
		Glide.with(context)
		  .load(paths.get(arg0 - 1).path)
		  .placeholder(mis_default_error_id)
		  .override(perWidth, perWidth)
		  .error(mis_default_error_id)
		  .centerCrop()
		  .into(showImage);
		
		return arg1;
	}

}
