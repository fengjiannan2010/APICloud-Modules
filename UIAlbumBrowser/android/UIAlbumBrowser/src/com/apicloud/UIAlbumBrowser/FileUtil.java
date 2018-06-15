/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.UIAlbumBrowser;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import android.content.Context;
import android.text.TextUtils;

import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;

public class FileUtil {
	
	public static void copy(InputStream inputStream, File output) throws IOException {
	        OutputStream outputStream = null;
	        try {
	        	if(!output.exists()){
	        		output.createNewFile();
	        	}
	            outputStream = new FileOutputStream(output);
	            int read = 0;
	            byte[] bytes = new byte[1024];
	            while ((read = inputStream.read(bytes)) != -1) {
	                outputStream.write(bytes, 0, read);
	            }
	        } finally {
	            try {
	                if (inputStream != null) {
	                    inputStream.close();
	                }
	            } finally {
	                if (outputStream != null) {
	                    outputStream.close();
	                }
	            }
	        }
	}
	
	public static FileInfo getRealPath(Context context, UZModuleContext uzContext, String originalPath){
		if(TextUtils.isEmpty(originalPath)){
			return null;
		}
		if(originalPath.startsWith("widget")){
			String filePath = uzContext.makeRealPath(originalPath).replaceAll(".+widget", "widget");
			if(isAssertFile(context, filePath)){
				return new FileInfo(filePath, true);
			} else {
				// make a try
				filePath = uzContext.makeRealPath(originalPath).replaceAll("file://", "");
				if(new File(filePath).exists()){
					return new FileInfo(filePath, false);
				}
			}
		} else {
			String filePath = uzContext.makeRealPath(originalPath);
			if(new File(filePath).exists()){
				return new FileInfo(filePath, false);
			}
		}
		return null;
	}
	
	public static boolean isAssertFile(Context context, String path){
		try {
			context.getAssets().open(path);
			return true;
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}
	}
	
	public static class FileInfo {
		
		public FileInfo(String filePath, boolean isAssert){
			this.filePath = filePath;
			this.isAssert = isAssert;
		}
		
		public boolean isAssert;
		public String filePath;
	}

}
