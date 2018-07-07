package com.apicloud.NVTabBar;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONObject;

import android.content.Context;

import com.uzmap.pkg.uzcore.UZCoreUtil;
import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;
import com.uzmap.pkg.uzkit.UZUtility;

public class Config {

	public String bg = "#FFF";
	public int height = UZUtility.dipToPix(50);

	public double dividerWidth = 0.5;
	public String dividerColor = "#000";

	public String badgeBgColor = "ff0";
	public String badgeTextColor = "#fff";
	public int badgeSize = 6;
	public int badgeCenterX = -1;
	public int badgeCenterY = -1;
	
	public int selectedIndex;

	public ArrayList<Item> items = new ArrayList<Item>();

	public Config(Context context, UZModuleContext uzContext) {

		int screenWdith = ViewUtil.getScreenWidth(context);

		JSONObject stylesObj = uzContext.optJSONObject("styles");
		if (stylesObj != null) {
			bg = stylesObj.optString("bg", "#FFF");
			height = UZUtility.dipToPix(stylesObj.optInt("h", 50));

			JSONObject dividingLineObj = stylesObj.optJSONObject("dividingLine");
			if (dividingLineObj != null) {
				dividerWidth = dividingLineObj.optDouble("width", 0.5);
				dividerColor = dividingLineObj.optString("color", "#000");
			}

			JSONObject badgeObj = stylesObj.optJSONObject("badge");
			if (badgeObj != null) {
				badgeBgColor = badgeObj.optString("bgColor", "#ff0");
				badgeTextColor = badgeObj.optString("numColor", "#fff");
				badgeSize = badgeObj.optInt("size", 6);
				if(!badgeObj.isNull("centerX")){
					badgeCenterX = UZUtility.dipToPix(badgeObj.optInt("centerX"));
				}
				if(!badgeObj.isNull("centerY")){
					badgeCenterY = UZUtility.dipToPix(badgeObj.optInt("centerY"));
				}
			}
		}

		JSONArray itemArr = uzContext.optJSONArray("items");
		if (itemArr != null) {
			for (int i = 0; i < itemArr.length(); i++) {

				JSONObject curObj = itemArr.optJSONObject(i);

				Item item = new Item();
				item.w = UZUtility.dipToPix(curObj.optInt("w", UZCoreUtil.pixToDip(screenWdith / itemArr.length())));

				JSONObject bgObj = curObj.optJSONObject("bg");
				if (bgObj != null) {
					item.itemMarginB = UZUtility.dipToPix(bgObj.optInt("marginB", 0));
					item.itemBg = bgObj.optString("image", "rgba(0,0,0,0)");
				}

				JSONObject iconRectObj = curObj.optJSONObject("iconRect");
				if (iconRectObj != null) {
					item.iconWidth = UZUtility.dipToPix(iconRectObj.optInt("w", 25));
					item.iconHeight = UZUtility.dipToPix(iconRectObj.optInt("h", 25));
				}

				JSONObject iconObj = curObj.optJSONObject("icon");
				if (iconObj != null) {
					item.normal = iconObj.optString("normal");
					item.highlight = iconObj.optString("highlight");
					item.selected = iconObj.optString("selected");
				}

				JSONObject titleObj = curObj.optJSONObject("title");
				if (titleObj != null) {
					item.titleText = titleObj.optString("text");
					item.titleTextSize = titleObj.optInt("size", 12);
					item.titleNormalTextColor = titleObj.optString("normal");
					item.titleSelectedTextColor = titleObj.optString("selected");
					item.titleMarginBottom = UZUtility.dipToPix(titleObj.optInt("marginB"));
					String ttfPath = titleObj.optString("ttf", "");
					item.ttf = ttfPath;
				}
				items.add(item);
			}
		}
		selectedIndex = uzContext.optInt("selectedIndex");
	}

	public class Item {

		public int w;
		public int itemMarginB;
		public String itemBg;

		public int iconWidth;
		public int iconHeight;

		public String normal;
		public String highlight;
		public String selected;

		public String titleText;
		public int titleTextSize;

		public String titleNormalTextColor;
		public String titleSelectedTextColor;
		public int titleMarginBottom;
		
		public String ttf;
		
	}
	
}
