/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.UIAlbumBrowser;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import android.annotation.SuppressLint;
import android.content.Context;
import android.database.Cursor;
import android.provider.MediaStore;
import android.provider.MediaStore.Images.Thumbnails;

public class MediaResource {
	
	public static final String TAG = "MediaResource";
	
	public static int ORDER_DESC = 0;
	public static int ORDER_ASC = 1;
	
	private static MediaResource mInstance;
	
	private MediaResource(){}
	
	public static MediaResource getInstance(){
		if(mInstance == null){
			mInstance = new MediaResource();
		}
		return mInstance;
	}
	
	@SuppressWarnings("unused")
	public List<FileInfo> getAllImages(Context mContext){
		List<FileInfo> list = new ArrayList<FileInfo>();
		
		HashMap<Integer, ThumbnailInfo> thumbInfos = listAllThumbnail(mContext);
        Cursor cursor = mContext.getContentResolver().query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                new String[] { MediaStore.Images.Media._ID, MediaStore.Images.Media.DISPLAY_NAME, MediaStore.Images.Media.DATE_MODIFIED, MediaStore.Images.Media.TITLE,
                        MediaStore.Images.Media.MIME_TYPE, MediaStore.Images.Media.SIZE, MediaStore.Images.Media.DATA }, null,
                new String[] {}, null);
        
        if(cursor == null){
        	return list;
        }
        while (cursor.moveToNext()) {
            String filePath = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.DATA));
//          if(!TextUtils.isEmpty(filePath) && filePath.endsWith("gif")){
//        		continue;
//        	}
//          int imageId = cursor.getInt(cursor.getColumnIndex(MediaStore.Images.Media._ID));
            long modifyTime = cursor.getLong(cursor.getColumnIndex(MediaStore.Images.Media.DATE_MODIFIED));
            long fileSize = cursor.getLong(cursor.getColumnIndex(MediaStore.Images.Media.SIZE));
            FileInfo fileInfo = new FileInfo();
            fileInfo.path = filePath;
            fileInfo.fileSize = fileSize;
            fileInfo.modifiedTime = modifyTime;
//          if(thumbInfos.get(imageId) != null){
//              fileInfo.thumbPath = thumbInfos.get(imageId).imagePath;
//            	fileInfo.modifiedTime = modifyTime;
//          }
            list.add(fileInfo);
        }
        cursor.close();
        return list;
	}
	
    public List<FileInfo> getAllVideos(Context context){
    	
        String[] thumbColumns = new String[]{
                MediaStore.Video.Thumbnails.DATA,  
                MediaStore.Video.Thumbnails.VIDEO_ID  
        };  

        String[] mediaColumns = new String[]{
                MediaStore.Video.Media.DATA,  
                MediaStore.Video.Media._ID,  
                MediaStore.Video.Media.TITLE,  
                MediaStore.Video.Media.MIME_TYPE,
                MediaStore.Video.Media.DATE_MODIFIED,
                MediaStore.Video.Media.SIZE,
                MediaStore.Video.Media.DURATION
        };
        Cursor cursor = context.getContentResolver().query(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, mediaColumns, null, null, null);  

        ArrayList<FileInfo> videoList = new ArrayList<FileInfo>();
        
        if(cursor == null){
        	return videoList;
        }

        if(cursor.moveToFirst()){
            do {
                FileInfo fileInfo = new FileInfo();
                fileInfo.path = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATA));
                fileInfo.modifiedTime = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATE_MODIFIED));
                fileInfo.fileSize = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.SIZE));
                int id = cursor.getInt(cursor.getColumnIndexOrThrow(MediaStore.Video.Media._ID));
                String selection = MediaStore.Video.Thumbnails.VIDEO_ID +"=?";  
                String[] selectionArgs = new String[]{
                        id+""
                };
                Cursor thumbCursor = context.getContentResolver().query(MediaStore.Video.Thumbnails.EXTERNAL_CONTENT_URI, thumbColumns, selection, selectionArgs, null);
                if(thumbCursor == null){
                	return videoList;
                }
                if(thumbCursor.moveToFirst()){
                    fileInfo.thumbPath = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Video.Thumbnails.DATA));
                }
                fileInfo.duration = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DURATION));
                videoList.add(fileInfo);
                
                if(thumbCursor != null){
                	thumbCursor.close();
                }
            } while(cursor.moveToNext());
        }
        cursor.close();
        return videoList;
    }
    
	@SuppressLint("UseSparseArrays")
	private HashMap<Integer, ThumbnailInfo> listAllThumbnail(Context mContext) {

		HashMap<Integer, ThumbnailInfo> allThumbnailMap = new HashMap<Integer, ThumbnailInfo>();

		String[] projection = { Thumbnails._ID, Thumbnails.IMAGE_ID,
				Thumbnails.DATA };
		Cursor cur = mContext.getContentResolver().query(
				Thumbnails.EXTERNAL_CONTENT_URI, projection, null, null, null);
		if (cur == null) {
			return allThumbnailMap;
		}
		if (cur.moveToFirst()) {
			int image_id;
			String image_path;
			int image_idColumn = cur.getColumnIndex(Thumbnails.IMAGE_ID);
			int dataColumn = cur.getColumnIndex(Thumbnails.DATA);

			do {
				image_id = cur.getInt(image_idColumn);
				image_path = cur.getString(dataColumn);

				ThumbnailInfo thumbInfo = new ThumbnailInfo();
				thumbInfo.imageId = image_id;
				thumbInfo.imagePath = image_path;
				allThumbnailMap.put(image_id, thumbInfo);

			} while (cur.moveToNext());
		}
		cur.close();
		return allThumbnailMap;
	}
	
	// FIXME: 待优化
	public List<Categary> getCategary(List<FileInfo> fileInfos){
		Set<String> treeSet = new TreeSet<String>();
		List<Categary> categarys = new ArrayList<Categary>();
		for(int i=0; i<fileInfos.size(); i++){
			FileInfo fileInfo = fileInfos.get(i);
			treeSet.add(fileInfo.path.substring(0, fileInfo.path.lastIndexOf("/")));
		}
		
		for(String c : treeSet){
			Categary categary = new Categary();
			String[] pathArr = c.split("/");
			categary.categaryId = pathArr[pathArr.length - 1];
			categary.categaryName = categary.categaryId;
			categary.categaryPath = c;
			categarys.add(categary);
		}
		
		for(Categary categary : categarys){
			for(int i=0; i<fileInfos.size(); i++){
				FileInfo curFileInfo = fileInfos.get(i);
				String tmpPath = curFileInfo.path.substring(0, curFileInfo.path.lastIndexOf("/"));
				if(categary.categaryPath.equals(tmpPath)){
					categary.paths.add(curFileInfo);
					categary.categaryId = Utils.stringToMD5(categary.categaryPath);
				}
			}
		}
		return categarys;
	}
	
	public static class Categary {
		
		public String categaryId;
		public String categaryType;
		public String categaryName;
		public String categaryPath;
		public List<FileInfo> paths = new ArrayList<FileInfo>();
		
	}	
	
	public static class ThumbnailInfo {
		public int imageId;
		public String imagePath;
	}
	
	public static class FileInfo{
		public String path;
		public String thumbPath;
		public long modifiedTime;
		public long fileSize;
		public long duration;
		
		@Override
		public boolean equals(Object o) {
			if(o == null)
				return false;
			if (((FileInfo)o).path.equals(this.path))
				return true;
			return false;
		}
	}
}
