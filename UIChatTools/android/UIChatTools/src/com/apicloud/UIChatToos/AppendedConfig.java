/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.UIChatToos;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONObject;

import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;
import com.uzmap.pkg.uzkit.UZUtility;

public class AppendedConfig {
	
	public int row = 2;
	public int col = 4;
	public int iconSize;
	public int titleSize;
	public String titleColor;
	
	public ArrayList<AppendItem> items = new ArrayList<AppendItem>();
	
	public AppendedConfig(UZModuleContext uzContext){
		
		JSONObject stylesObj = uzContext.optJSONObject("styles");
		if(stylesObj != null){
			row = stylesObj.optInt("row", 2);
			col = stylesObj.optInt("col", 4);
			iconSize = UZUtility.dipToPix(stylesObj.optInt("iconSize"));
			titleSize = stylesObj.optInt("titleSize");
			titleColor = stylesObj.optString("titleColor");
		}
		
		JSONArray buttonsArray = uzContext.optJSONArray("buttons");
		if(buttonsArray != null){
			for(int i=0; i<buttonsArray.length(); i++){
				JSONObject tmpObj = buttonsArray.optJSONObject(i);
				if(tmpObj != null){
					AppendItem appendItem = new AppendItem();
					
					String realHighlight = uzContext.makeRealPath(tmpObj.optString("highlight"));
					appendItem.highlight = UZUtility.getLocalImage(realHighlight);
					
					String realNormal = uzContext.makeRealPath(tmpObj.optString("normal"));
					appendItem.normal = UZUtility.getLocalImage(realNormal);
							
					appendItem.title = tmpObj.optString("title");
					items.add(appendItem);
				}
			}
		}
		
	}
	
}
