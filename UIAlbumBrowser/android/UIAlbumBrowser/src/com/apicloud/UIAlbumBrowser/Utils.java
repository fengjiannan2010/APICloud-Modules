/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.UIAlbumBrowser;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;

import com.apicloud.UIAlbumBrowser.MediaResource.FileInfo;
import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;

import android.text.TextUtils;


public class Utils {
	
	public static String stringToMD5(String string) {

		if (TextUtils.isEmpty(string)) {
			return null;
		}

		byte[] hash;

		try {
			hash = MessageDigest.getInstance("MD5").digest(
					string.getBytes("UTF-8"));
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
			return null;
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
			return null;
		}

		StringBuilder hex = new StringBuilder(hash.length * 2);
		for (byte b : hash) {
			if ((b & 0xFF) < 0x10)
				hex.append("0");
			hex.append(Integer.toHexString(b & 0xFF));
		}
		return hex.toString();
	}
	
    public static List<FileInfo> sortFile(List<FileInfo> list, final int order){
    	if(order == MediaResource.ORDER_DESC){
    		return descSortByTime(list);
    	} else {
    		return ascSortByTime(list);
    	}
    }
    
    private static List<FileInfo> descSortByTime(List<FileInfo> list) {
		int in, out;
		int max;
		FileInfo temp;
		for (out = 0; out < list.size(); out++) {
			max = out;
			for (in = out + 1; in < list.size(); in++) {
				if (list.get(max).modifiedTime < list.get(in).modifiedTime) {
					max = in;
				}
			}
			if (out != max) {
				temp = list.get(out);
				list.set(out, list.get(max));
				list.set(max, temp);
			}
		}
		return list;
	}
    
    //  20000 + 10000

	/**
	 * selected sort by ASC & time
	 */
	private static List<FileInfo> ascSortByTime(List<FileInfo> list) {
		int i, j;
		FileInfo temp;

		for (i = 0; i < list.size() - 1; i++) {
			for (j = i + 1; j < list.size(); j++) {
				if (list.get(j).modifiedTime < list.get(i).modifiedTime) {

					temp = list.get(i);
					list.set(i, list.get(j));
					list.set(j, temp);
					
				}
			}
		}
		return list;
	}
	
	
	public static void callback(UZModuleContext uzContext, String eventType, String groupId, String path){
		JSONObject ret = new JSONObject();
		try {
			ret.put("eventType", eventType);
			if(!TextUtils.isEmpty(groupId)){
				ret.put("groupId", groupId);
			}
			
			if(!TextUtils.isEmpty(path)){
				JSONObject target = new JSONObject();
				target.put("path", path);
				target.put("thumbPath", UIAlbumBrowser.checkOrCreateThumbImage(path, null, 300, 300));
				ret.put("target", target);
			}
			uzContext.success(ret, false);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

}
