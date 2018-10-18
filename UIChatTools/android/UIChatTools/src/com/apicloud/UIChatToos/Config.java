/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.UIChatToos;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.text.TextUtils;

import com.apicloud.UIChatToos.common.BasicEmotion;
import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;
import com.uzmap.pkg.uzkit.UZUtility;

public class Config {
	
	private UZModuleContext uzContext;
	
	public ArrayList<String> emotionsPathArray = new ArrayList<String>();
	
	public String chatBoxPlaceHolder;
	public boolean autoFocus = false;
	public int maxRows = 6;
	
	public String styleBgColor = "#D1D1D1";
	public int styleMargin = UZUtility.dipToPix(10);
	public String styleMaskBg = "rgba(0,0,0,0.5)";
	
	public boolean hasMask = true;
	
	
	/** tools setting **/
	
	public int toolBarHeight = UZUtility.dipToPix(44);
	public int toolsIconSize = UZUtility.dipToPix(30);
	
	public String recorderNomal;
	public String recorderSelected;
	public boolean hasRecorder = false;
	
	public String imageNormal;
	public String imageSelected;
	public boolean hasImage = false;
	
	public String videoNormal;
	public String videoSelected;
	public boolean hasVideo = false;
	
	public String packetNormal;
	public String packetSelected;
	public boolean hasPacket = false;
	
	public String faceNormal;
	public String faceSelected;
	public boolean hasFace = false;
	
	public String appendNormal;
	public String appendSelected;
	public boolean hasAppend = false;
	
	
	public boolean useFacePath = false;
	public boolean isShowAddImg = true;
	
	public Config(UZModuleContext uzContext){
		
		this.uzContext = uzContext;
		
		useFacePath = uzContext.optBoolean("useFacePath");
		isShowAddImg = uzContext.optBoolean("isShowAddImg", true);
		
		JSONArray emoticonsArray = uzContext.optJSONArray("emotions");
		if(emoticonsArray != null){
			for(int i=0; i<emoticonsArray.length(); i++){
				emotionsPathArray.add(emoticonsArray.optString(i));
			}
		}
		
		JSONObject chatBoxObj = uzContext.optJSONObject("chatBox");
		if(chatBoxObj != null){
			chatBoxPlaceHolder = chatBoxObj.optString("placeholder");
			autoFocus = chatBoxObj.optBoolean("autoFocus");
			maxRows = chatBoxObj.optInt("maxRows", 6);
		}
		
		JSONObject stylesObj = uzContext.optJSONObject("styles");
		if(stylesObj != null){
			styleBgColor = stylesObj.optString("bgColor");
			styleMargin = UZUtility.dipToPix(stylesObj.optInt("margin"));
			
			JSONObject maskObj = stylesObj.optJSONObject("mask");
			if(maskObj != null){
				styleMaskBg = maskObj.optString("bgColor");
				hasMask = true;
			} else {
				styleMaskBg = "rgba(0,0,0,0)";
				hasMask = false;
			}
		}
		
		JSONObject toolsObj = uzContext.optJSONObject("tools");
		if(toolsObj != null){
			toolBarHeight = UZUtility.dipToPix(toolsObj.optInt("h", 44));
			toolsIconSize = UZUtility.dipToPix(toolsObj.optInt("iconSize", 30));
			
			JSONObject recorderObj = toolsObj.optJSONObject("recorder");
			if(recorderObj != null){
				hasRecorder = true;
				recorderNomal = recorderObj.optString("normal");
				recorderSelected = recorderObj.optString("selected");
			}
			
			JSONObject imageObj = toolsObj.optJSONObject("image");
			if(imageObj != null){
				hasImage = true;
				imageNormal = imageObj.optString("normal");
				imageSelected = imageObj.optString("selected");
			}
			
			JSONObject videoObj = toolsObj.optJSONObject("video");
			if(videoObj != null){
				hasVideo = true;
				videoNormal = videoObj.optString("normal");
				videoSelected = videoObj.optString("selected");
			}
			
			JSONObject packetObj = toolsObj.optJSONObject("packet");
			if(packetObj != null){
				hasPacket = true;
				packetNormal = packetObj.optString("normal");
				packetSelected = packetObj.optString("selected");
			}
			
			JSONObject faceObj = toolsObj.optJSONObject("face");
			if(faceObj != null){
				hasFace = true;
				faceNormal = faceObj.optString("normal");
				faceSelected = faceObj.optString("selected");
			}
			
			JSONObject appendObj = toolsObj.optJSONObject("append");
			if(appendObj != null){
				hasAppend = true;
				appendNormal = appendObj.optString("normal");
				appendSelected = appendObj.optString("selected");
			}
		}
		
	}
	
	public ArrayList<BasicEmotion> parseBasicEmotion(){
		
		ArrayList<BasicEmotion> faces = new ArrayList<BasicEmotion>();
		
		if(uzContext == null){
			return faces;
		}
		if(emotionsPathArray.size() > 0){
			String basicEmotionPath = emotionsPathArray.get(0);
			
			int index = basicEmotionPath.lastIndexOf("/") + 1;
			final String emtionSrcFile = basicEmotionPath.substring(index);
			String realPath = uzContext.makeRealPath(basicEmotionPath + '/' + emtionSrcFile + ".json");
			
			try {
				InputStream inputStream = UZUtility.guessInputStream(realPath);
				String basicJson = readFile(inputStream);
				
				JSONArray basicJsonArray = new JSONArray(basicJson);
				if(basicJsonArray != null){
					for(int i=0; i<basicJsonArray.length(); i++){
						JSONObject basicEmotionObj = basicJsonArray.optJSONObject(i);
						
						BasicEmotion basicEmotion = new BasicEmotion();
						basicEmotion.label = basicEmotionObj.optString("label");
						
						ArrayList<FaceItem> faceItems = new ArrayList<FaceItem>();
						JSONArray faceItemArray = basicEmotionObj.optJSONArray("emotions");
						if(faceItemArray == null){
							return faces;
						}
						for(int j=0; j<faceItemArray.length(); j++){
							JSONObject faceObj = faceItemArray.optJSONObject(j);
							FaceItem faceItem = new FaceItem();
							faceItem.faceText = faceObj.optString("text");
							faceItem.faceDir = emtionSrcFile;
							String facePath = basicEmotionPath + "/" + faceObj.optString("name") + ".png";
							faceItem.facePath = uzContext.makeRealPath(facePath);
							faceItems.add(faceItem);
						}
						basicEmotion.faceItems = faceItems;
						faces.add(basicEmotion);
					}
				}
				return faces;
			} catch (JSONException e) {
				e.printStackTrace();
			} catch (IOException e){
				e.printStackTrace();
			}
		}
		return null;
	}
	
	
	public ArrayList<ArrayList<FaceItem>> parseAllAppendEmotions(){
		
		ArrayList<ArrayList<FaceItem>> appendFaces = new ArrayList<ArrayList<FaceItem>>();
		
		if(uzContext == null){
			return appendFaces;
		}
		if(emotionsPathArray.size() > 0){
			for(int i=1 ;i<emotionsPathArray.size(); i++){
				String emotionPath = emotionsPathArray.get(i);
				
				int index = emotionPath.lastIndexOf("/") + 1;
				final String emtionSrcFile = emotionPath.substring(index);
				String emotionRealPath = uzContext.makeRealPath(emotionPath + '/' + emtionSrcFile + ".json");
				
				ArrayList<FaceItem> items = new ArrayList<FaceItem>();
				try {
					InputStream inputStream = UZUtility.guessInputStream(emotionRealPath);
					String emotionJson = readFile(inputStream);
					JSONArray emotionArray = null;
					if(!TextUtils.isEmpty(emotionJson)){
						emotionArray = new JSONArray(emotionJson);
					}
					if(emotionArray != null){
						for(int j=0; j<emotionArray.length(); j++){
							JSONObject faceItemObj = emotionArray.optJSONObject(j);
							FaceItem faceItem = new FaceItem();
							String facePath = emotionPath + "/" + faceItemObj.optString("name") + ".png";
							faceItem.facePath = uzContext.makeRealPath(facePath);
							faceItem.faceText = faceItemObj.optString("text");
							faceItem.faceDir = emtionSrcFile;
							items.add(faceItem);
						}
					}
					appendFaces.add(items);
				} catch (IOException e) {
					e.printStackTrace();
				} catch (JSONException e){
					e.printStackTrace();
				}
			}
		}
		return appendFaces;
	}
	
	public String readFile(InputStream input){
		if(input == null){
			return null;
		}
		BufferedReader reader = null;
		try {
			reader = new BufferedReader(new InputStreamReader(input, "utf-8"));
		} catch (UnsupportedEncodingException e1) {
			e1.printStackTrace();
		}
		StringBuilder sb = new StringBuilder();
		String readLine = null;
		try {
			while((readLine = reader.readLine()) != null){
				sb.append(readLine);
			}
			reader.close();
			return sb.toString();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}
}
