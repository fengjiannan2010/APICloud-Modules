/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.UIAlbumBrowser;

import org.json.JSONObject;

import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;

public class Config {
	
	public int max = 9;
	public String bg = "#FFFFFF";
	
	public String markIcon;
	public String markPosition = "bottom_left";
	public int markSize = 20;
	
	public String navBg = "#eee";
	public String navTitleColor = "#fff";
	public int navTitleSize = 18;
	public String navleftTextColor = "#fff";
	public int navLeftTextSize = 16;
	
	public String navRightColor = "#fff";
	public int navRightSize = 16;
	
	public String cameraImgPath;
	
	public boolean isOpenPreview = true;
	
	public boolean selectedAll = false;
	
	public Config(UZModuleContext uzContext){
		max = uzContext.optInt("max", 9);
		type = uzContext.optString("type");
		
		JSONObject stylesObj = uzContext.optJSONObject("styles");
		if(stylesObj != null){
			bg = stylesObj.optString("bg", "#FFFFFF");
			cameraImgPath = stylesObj.optString("cameraImg");
			JSONObject markObj = stylesObj.optJSONObject("mark");
			if(markObj != null){
				markIcon = markObj.optString("icon");
				markPosition = markObj.optString("position", "bottom_left");
				markSize = markObj.optInt("size", 20);
			}
			
			JSONObject naviObj = stylesObj.optJSONObject("nav");
			if(naviObj != null){
				navBg = naviObj.optString("bg", "#eee");
				navTitleColor = naviObj.optString("titleColor", "rgba(0,0,0,0.6)");
				navTitleSize = naviObj.optInt("titleSize", 18);
				navleftTextColor = naviObj.optString("cancelColor", "#FFF");
				navLeftTextSize = naviObj.optInt("cancelSize", 18);
				navRightColor = naviObj.optString("nextStepColor", "#FFF");
				navRightSize = naviObj.optInt("nextStepSize", 16);
			}
		}
	}
	
	public boolean isOpen = false;
	public String type = "image";
	
	public void parseOpenParams(UZModuleContext uzContext){
		this.max = uzContext.optInt("max", 9);
		
		isOpenPreview = uzContext.optBoolean("isOpenPreview", true);
		
		selectedAll = uzContext.optBoolean("selectedAll", true);
		
		JSONObject stylesObj = uzContext.optJSONObject("styles");
		if(stylesObj != null){
			bg = stylesObj.optString("bg", "#FFFFFF");
			
			JSONObject markObj = stylesObj.optJSONObject("mark");
			if(markObj != null){
				markIcon = markObj.optString("icon");
				markPosition = markObj.optString("position", "bottom_left");
				markSize = markObj.optInt("size", 20);
			}
			
			JSONObject navObj = stylesObj.optJSONObject("nav");
			if(navObj != null){
				navBg = navObj.optString("bg", "rgba(0,0,0,0.6)");
				navTitleColor = navObj.optString("titleColor", "#fff");
				navTitleSize = navObj.optInt("titleSize", 18);
				navleftTextColor = navObj.optString("cancelColor", "#fff");
				navLeftTextSize = navObj.optInt("cancelSize", 16);
				navRightColor = navObj.optString("finishColor", "#fff");
				navRightSize = navObj.optInt("finishSize", 16);
			}
		}
	}
	
}
