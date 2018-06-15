/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package me.nereo.multi_image_selector.utils;

import java.io.File;
import java.lang.reflect.Method;
import java.util.ArrayList;

import android.content.ContentResolver;
import android.content.Context;
import android.content.res.Resources;
import android.database.Cursor;
import android.os.Build;
import android.provider.MediaStore;
import android.view.ViewConfiguration;
import android.widget.Toast;

public class Utils {
	
	
	public static ArrayList<FileInfo> listAllVideo(Context mContext) {

		ArrayList<FileInfo> list = new ArrayList<FileInfo>();

		String[] thumbColumns = new String[] {
				MediaStore.Video.Thumbnails.DATA,
				MediaStore.Video.Thumbnails.VIDEO_ID };

		ContentResolver testcr = mContext.getContentResolver();

		String[] projection = { 
				MediaStore.Video.Media.DATA,
				MediaStore.Video.Media.MIME_TYPE, 
				MediaStore.Video.Media.SIZE,
				MediaStore.Video.Media._ID,
				MediaStore.Video.Media.DURATION
				};
		Cursor videoCur = testcr.query(
				MediaStore.Video.Media.EXTERNAL_CONTENT_URI, projection, null,
				null, null);
		if (videoCur == null) {
			return list;
		}
		while (videoCur.moveToNext()) {

			String path = videoCur.getString(0);
			String mimeType = videoCur.getString(1);
			int size = videoCur.getInt(2);
			int imgId = videoCur.getInt(3);

			FileInfo info = new FileInfo();
			info.path = new File(path).getAbsolutePath();
			info.mimeType = mimeType;
			info.size = size;
			info.imgId = imgId;
			info.time = new File(path).lastModified();
			info.duration = videoCur.getLong(4);

			int id = videoCur.getInt(videoCur
					.getColumnIndexOrThrow(MediaStore.Video.Media._ID));
			String selection = MediaStore.Video.Thumbnails.VIDEO_ID + "=?";
			String[] selectionArgs = new String[] { id + "" };

			Cursor thumbCursor = mContext.getContentResolver().query(
					MediaStore.Video.Thumbnails.EXTERNAL_CONTENT_URI,
					thumbColumns, selection, selectionArgs, null);
			if (thumbCursor != null && thumbCursor.moveToFirst()) {
				info.thumbImgPath = thumbCursor
						.getString(videoCur
								.getColumnIndexOrThrow(MediaStore.Video.Thumbnails.DATA));
			}

			list.add(info);
		}
		return list;
	}

	
	
	 public static String time2Str(int time)
	  {
	    String timeStr = null;
	    int hour = 0;
	    int minute = 0;
	    int second = 0;
	    if (time <= 0) {
	      return "00:00";
	    }
	    minute = time / 60;
	    if (minute < 60) {
	      second = time % 60;
	      timeStr = unitFormat(minute) + ":" + unitFormat(second);
	    } else {
	      hour = minute / 60;
	      if (hour > 99)
	        return "99:59:59";
	      minute %= 60;
	      second = time - hour * 3600 - minute * 60;
	      timeStr = unitFormat(hour) + ":" + unitFormat(minute) + ":" + unitFormat(second);
	    }
	    return timeStr;
	  }
	 
	 public static String unitFormat(int i) {
		    String retStr = null;
		    if ((i >= 0) && (i < 10))
		      retStr = "0" + Integer.toString(i);
		    else
		      retStr = i + "";
		    return retStr;
	 }
	 
	 
	   public static int getNavigationBarHeight(Context context) {
	        int result = 0;
	        if (hasNavBar(context)) {
	            Resources res = context.getResources();
	            int resourceId = res.getIdentifier("navigation_bar_height", "dimen", "android");
	            if (resourceId > 0) {
	                result = res.getDimensionPixelSize(resourceId);
	            }
	        }
	        return result;
	    }

	    /**
	     * 检查是否存在虚拟按键栏
	     *
	     * @param context
	     * @return
	     */
	    public static boolean hasNavBar(Context context) {
	        Resources res = context.getResources();
	        int resourceId = res.getIdentifier("config_showNavigationBar", "bool", "android");
	        if (resourceId != 0) {
	            boolean hasNav = res.getBoolean(resourceId);
	            // check override flag
	            String sNavBarOverride = getNavBarOverride();
	            if ("1".equals(sNavBarOverride)) {
	                hasNav = false;
	            } else if ("0".equals(sNavBarOverride)) {
	                hasNav = true;
	            }
	            return hasNav;
	        } else { // fallback
	            return !ViewConfiguration.get(context).hasPermanentMenuKey();
	        }
	    }
	    
	    
	    @SuppressWarnings("rawtypes")
	    private static String getNavBarOverride() {
	        String sNavBarOverride = null;
	        if (Build.VERSION.SDK_INT >= 19) {
	            try {
					Class c = Class.forName("android.os.SystemProperties");
					@SuppressWarnings("unchecked")
					Method m = c.getDeclaredMethod("get", String.class);
	                m.setAccessible(true);
	                sNavBarOverride = (String) m.invoke(null, "qemu.hw.mainkeys");
	            } catch (Throwable e) {
	            }
	        }
	        return sNavBarOverride;
	    }
	    
	    
	    public static void showToast(Context context, String msg){
	    	Toast.makeText(context, msg, Toast.LENGTH_LONG).show();
	    }
}

 
	 

