/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.NVTabBar;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.graphics.Bitmap;
import android.graphics.Typeface;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup.MarginLayoutParams;
import android.view.animation.Animation;
import android.view.animation.Animation.AnimationListener;
import android.view.animation.AnimationSet;
import android.view.animation.TranslateAnimation;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.apicloud.NVTabBar.Config.Item;
import com.uzmap.pkg.uzcore.UZResourcesIDFinder;
import com.uzmap.pkg.uzcore.UZWebView;
import com.uzmap.pkg.uzcore.uzmodule.UZModule;
import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;
import com.uzmap.pkg.uzkit.UZUtility;

public class TabBar extends UZModule {
	
	private boolean isShow;
	
	private static final String TAG = "TabBar";

	public static final String EVENT_TYPE_CLICK = "click";
	public static final String EVENT_TYPE_SHOW = "show";
	
	/**
	 * tabbar
	 */
	private RelativeLayout tabbarLayout;
	private RelativeLayout.LayoutParams params;
	
	/**
	 * all items of the tabbar
	 */
	private ArrayList<View> itemViews = new ArrayList<View>();
	
	private ArrayList<Item> items = new ArrayList<Item>();
	
	private int curSelectedIndex = 0;
	private Config config;

	public TabBar(UZWebView webView) {
		super(webView);
	}

	public void jsmethod_open(UZModuleContext uzContext) {
		
		if(tabbarLayout != null){
			return;
		}
		
		itemViews.clear();
		items.clear();
		
		config = new Config(context(), uzContext);
		items = config.items;
		
		curSelectedIndex = config.selectedIndex;

		int tabbarLayoutId = UZResourcesIDFinder.getResLayoutID("nv_tabbar_main_layout");
		tabbarLayout = (RelativeLayout) View.inflate(context(), tabbarLayoutId, null);
		tabbarLayout.setBackgroundColor(0x00000000);

		initFakeBg(config, uzContext);
		initBorderLine(config);

		params = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.WRAP_CONTENT);

		createItem(uzContext, config.items, config);

		this.insertViewToCurWindow(tabbarLayout, params);
		callback(uzContext, EVENT_TYPE_SHOW, -1);
		setSelect(uzContext, curSelectedIndex, true, null, -1);
		
		isShow = true;
		
	}
	
	
	private LinearLayout fakeLayout;

	@SuppressWarnings("deprecation")
	public void initFakeBg(Config config, UZModuleContext uzContext) {

		int fakeLayoutId = UZResourcesIDFinder.getResIdID("fakeLayout");
		fakeLayout = (LinearLayout) tabbarLayout.findViewById(fakeLayoutId);

		RelativeLayout.LayoutParams fakeLayoutParam = (RelativeLayout.LayoutParams) fakeLayout.getLayoutParams();
		fakeLayoutParam.height = config.height;
		fakeLayout.setLayoutParams(fakeLayoutParam);
		
		Bitmap bgBitmap = getBitmap(uzContext, config.bg);
		if(bgBitmap != null){
			fakeLayout.setBackgroundDrawable(new BitmapDrawable(context().getResources(), bgBitmap));
		} else {
			fakeLayout.setBackgroundColor(UZUtility.parseCssColor(config.bg));
		}
	}

	public void initBorderLine(Config config) {
		
		// border line
		int borderLineId = UZResourcesIDFinder.getResIdID("borderLine");
		View borderLine = tabbarLayout.findViewById(borderLineId);

		LinearLayout.LayoutParams borderLineParams = (LinearLayout.LayoutParams) borderLine.getLayoutParams();
		borderLineParams.height = (int) (config.dividerWidth * UZUtility.dipToPix(1));

		borderLine.setLayoutParams(borderLineParams);
		borderLine.setBackgroundColor(UZUtility.parseCssColor(config.dividerColor));
		
	}

	public void jsmethod_close(UZModuleContext uzContext) {
		tabbarLayout.clearAnimation();
		this.removeViewFromCurWindow(tabbarLayout);
		tabbarLayout = null;
		isShow = false;
	}

	public void jsmethod_hide(UZModuleContext uzContext) {
		if(!isShow){
			return ;
		}
		if (tabbarLayout != null) {
			isShow = false;
			if(uzContext.optBoolean("animation")){
				
				final AnimationSet set = new AnimationSet(true);

				TranslateAnimation translate = new TranslateAnimation(

				Animation.RELATIVE_TO_SELF, 0, Animation.RELATIVE_TO_SELF, 0, 

				Animation.ABSOLUTE, 0, Animation.ABSOLUTE, fakeLayout.getMeasuredHeight());
				set.addAnimation(translate);
				
				set.setDuration(300);
				set.setFillAfter(true);
				set.setAnimationListener(new AnimationListener() {
					
					@Override
					public void onAnimationStart(Animation animation) {
					}
					
					@Override
					public void onAnimationRepeat(Animation animation) {
						// TODO Auto-generated method stub
						
					}
					
					@Override
					public void onAnimationEnd(Animation animation) {
						// TODO Auto-generated method stub
					    tabbarLayout.setVisibility(View.GONE);
					}
				});
				
				tabbarLayout.startAnimation(set);
				tabbarLayout.setVisibility(View.VISIBLE);
				
			} else {
				tabbarLayout.setVisibility(View.GONE);
			}
		}
	}

	public void jsmethod_show(UZModuleContext uzContext) {
		if(isShow){
			return;
		}
		if (tabbarLayout != null) {
			isShow = true;
			if(uzContext.optBoolean("animation")){
				
				AnimationSet set = new AnimationSet(true);
				TranslateAnimation translate = new TranslateAnimation(
				Animation.RELATIVE_TO_SELF, 0, Animation.RELATIVE_TO_SELF, 0, 

				Animation.ABSOLUTE, fakeLayout.getMeasuredHeight(), Animation.ABSOLUTE, 0);
				set.addAnimation(translate);
				
				set.setDuration(300);
				set.setFillAfter(true);
				tabbarLayout.startAnimation(set);
				
				tabbarLayout.setVisibility(View.VISIBLE);
				
			} else {
				tabbarLayout.setVisibility(View.VISIBLE);
			}
			
		}
	}
	
	public void jsmethod_setBadge(UZModuleContext uzContext) {
		
		if (tabbarLayout == null) {
			return;
		}
		int index = uzContext.optInt("index");

		if (index >= itemViews.size()) {
			return;
		}

		View itemView = itemViews.get(index);
		
		int itemImageId = UZResourcesIDFinder.getResIdID("itemImage");
		ImageView itemImage = (ImageView) itemView.findViewById(itemImageId);
		BadgeView badge = (BadgeView) itemImage.getTag();

		if (uzContext.isNull("badge")) {
			badge.setVisibility(View.GONE);
		}

		if (!uzContext.isNull("badge") && TextUtils.isEmpty(uzContext.optString("badge").trim())) {
			badge.setVisibility(View.VISIBLE);
			MarginLayoutParams badgeParams = (MarginLayoutParams)badge.getLayoutParams();
			badgeParams.width = UZUtility.dipToPix(10);
			badgeParams.height = UZUtility.dipToPix(10);
			badge.setLayoutParams(badgeParams);
			badge.setText("");
		}

		if (!uzContext.isNull("badge") && !TextUtils.isEmpty(uzContext.optString("badge"))) {
			badge.setVisibility(View.VISIBLE);
			badge.setText(uzContext.optString("badge"));
		}
		
	}

	public void jsmethod_bringToFront(UZModuleContext uzContext) {
		if (tabbarLayout != null) {
			// tabbarLayout.bringToFront();
			// tabbarLayout.getParent().requestLayout();
			removeViewFromCurWindow(tabbarLayout);
			insertViewToCurWindow(tabbarLayout, params);
		}
	}
	
	public void jsmethod_setSelect(UZModuleContext uzContext) {

		int index = uzContext.optInt("index");
		boolean isSelect = uzContext.optBoolean("selected", true);
		
		int interval = uzContext.optInt("interval", 300);
		
		JSONArray iconsArray = uzContext.optJSONArray("icons");
		AnimationDrawable animDrawable = null;
		if(iconsArray != null){
			animDrawable = new AnimationDrawable();
			for(int i=0; i<iconsArray.length(); i++){
				String realPath = uzContext.makeRealPath(iconsArray.optString(i));
				Bitmap gifFrame = UZUtility.getLocalImage(realPath);
				animDrawable.addFrame(new BitmapDrawable(context().getResources(), gifFrame), interval);
			}
		}
		resetAllItem(uzContext);
		setSelect(uzContext, index, isSelect, animDrawable, uzContext.optInt("animatedRepetitions"));
	}

	@SuppressWarnings("deprecation")
	public void resetAllItem(UZModuleContext uzContext) {
		for (int i = 0; i < itemViews.size(); i++) {
			
			View itemView = itemViews.get(i);
			int itemImageId = UZResourcesIDFinder.getResIdID("itemImage");
			ImageView itemImage = (ImageView) itemView.findViewById(itemImageId);

			int itemText_id = UZResourcesIDFinder.getResIdID("itemText");
			TextView itemText = (TextView) itemView.findViewById(itemText_id);

			if (i >= items.size()) {
				return;
			}
			
			BitmapDrawable normalDrawable = new BitmapDrawable(getBitmap(uzContext, items.get(i).normal));
			BitmapDrawable pressDrawable = new BitmapDrawable(getBitmap(uzContext, items.get(i).highlight));

			itemImage.setImageDrawable(ViewUtil.addStateDrawable(pressDrawable, normalDrawable));
			itemText.setTextColor(UZUtility.parseCssColor(items.get(i).titleNormalTextColor));
		}
	}
	
	@SuppressWarnings("deprecation")
	public void setSelect(UZModuleContext uzContext, int index, boolean isSelected, AnimationDrawable anim, int animationType) {

		View itemView = itemViews.get(index);

		int itemImageId = UZResourcesIDFinder.getResIdID("itemImage");
		ImageView itemImage = (ImageView) itemView.findViewById(itemImageId);

		int itemText_id = UZResourcesIDFinder.getResIdID("itemText");
		TextView itemText = (TextView) itemView.findViewById(itemText_id);

		if (index >= items.size()) {
			return;
		}
		
		curSelectedIndex = index;
		
		BitmapDrawable normalDrawable = new BitmapDrawable(getBitmap(uzContext, items.get(index).normal));
		BitmapDrawable pressDrawable = new BitmapDrawable(getBitmap(uzContext, items.get(index).highlight));
		BitmapDrawable selectedDrawable = new BitmapDrawable(getBitmap(uzContext, items.get(index).selected));
		
		if (isSelected) {
			itemImage.setImageDrawable(ViewUtil.addStateDrawable(pressDrawable, selectedDrawable));
			itemText.setTextColor(UZUtility.parseCssColor(items.get(index).titleSelectedTextColor));
		} else {
			itemImage.setImageDrawable(ViewUtil.addStateDrawable(pressDrawable, normalDrawable));
			itemText.setTextColor(UZUtility.parseCssColor(items.get(index).titleNormalTextColor));
		}
		
		if(anim != null){
			itemImage.setImageDrawable(anim);
			if(animationType <= 0){
				anim.setOneShot(false);
			} else {
				anim.setOneShot(true);
			}
			anim.start();
		}
		
	}

	@SuppressWarnings("deprecation")
	public void createItem(final UZModuleContext uzContext, ArrayList<Item> items, Config config) {

		int id = 0x00100;
		for (int i = 0; i < items.size(); i++) {
			Item item = items.get(i);

			int nv_tabbar_item_layout_id = UZResourcesIDFinder.getResLayoutID("nv_tabbar_item_layout");
			View itemLayout = View.inflate(context(), nv_tabbar_item_layout_id, null);
			
			itemLayout.setClickable(true);
			itemLayout.setId(id);
			
			int imageRectLayoutID = UZResourcesIDFinder.getResIdID("imageRectLayout");
			FrameLayout imageRectLayout = (FrameLayout)itemLayout.findViewById(imageRectLayoutID);
			
			Bitmap bgBmp = getBitmap(uzContext, item.itemBg);
			
			int itemImage_id = UZResourcesIDFinder.getResIdID("itemImage");
			final ImageView itemImage = (ImageView) itemLayout.findViewById(itemImage_id);

			BadgeView badgeView = new BadgeView(context());
			badgeView.setTargetView(imageRectLayout);
			
			badgeView.setVisibility(View.GONE);
			itemImage.setTag(badgeView);
			
			FrameLayout.LayoutParams badgeParams = (FrameLayout.LayoutParams)badgeView.getLayoutParams();
			badgeParams.gravity = Gravity.LEFT | Gravity.TOP;
			if(config.badgeCenterX < 0){
				badgeParams.leftMargin = (ViewUtil.getScreenWidth(context())/ items.size()) / 2 + item.iconWidth / 2;
			} else {
				badgeParams.leftMargin = config.badgeCenterX + badgeParams.width / 2;
			}
			if(config.badgeCenterY < 0){
				badgeParams.topMargin = 0;
			} else {
				badgeParams.topMargin = config.badgeCenterY + badgeParams.height / 2;
			}
			
			setBadgeStyle(badgeView, config);

			int itemText_id = UZResourcesIDFinder.getResIdID("itemText");
			TextView itemText = (TextView) itemLayout.findViewById(itemText_id);

			// item text params
			FrameLayout.LayoutParams itemTextParams = (FrameLayout.LayoutParams) itemText.getLayoutParams();
			itemTextParams.bottomMargin = item.titleMarginBottom;
			itemText.setLayoutParams(itemTextParams);
			
			int w = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
			int h = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
			itemText.measure(w, h);
			int titleHeight = itemText.getMeasuredHeight();
			int marginTop;
			if(!TextUtils.isEmpty(item.titleText)){
				marginTop = (config.height - titleHeight - item.titleMarginBottom - item.iconHeight) / 2;
			} else {
				marginTop = (config.height - item.iconHeight) / 2;
			}
			// layout params
			FrameLayout.LayoutParams itemImageParams = (FrameLayout.LayoutParams) itemImage.getLayoutParams();
			itemImageParams.width = item.iconWidth;
			itemImageParams.height = item.iconHeight;
			if(marginTop < 0){
				marginTop = 0;
			}
			itemImageParams.topMargin = marginTop;
			itemImage.setLayoutParams(itemImageParams);
			
			if(i == 2){
				Log.i("debug", "marginTop : " + marginTop);
			}
			
			
			FrameLayout.LayoutParams imageRectParams = (FrameLayout.LayoutParams)imageRectLayout.getLayoutParams();
			imageRectParams.height = config.height + item.itemMarginB;
			imageRectParams.bottomMargin = item.itemMarginB;
			
			if(i == 2){
				Log.i("debug", "bottomMargin : " + item.itemMarginB);
			}
			imageRectLayout.setLayoutParams(imageRectParams);
			
					
			if(bgBmp != null){
				imageRectLayout.setBackgroundDrawable(new BitmapDrawable(bgBmp));
			} else {
				imageRectLayout.setBackgroundColor(UZUtility.parseCssColor(item.itemBg));
			}
			
						
			
			Drawable highlightDrawable = new BitmapDrawable(getBitmap(uzContext, item.highlight));
			Drawable normalDrawable = new BitmapDrawable(getBitmap(uzContext, item.normal));
			itemImage.setImageDrawable(ViewUtil.addStateDrawable(highlightDrawable, normalDrawable));

			final int index = i;

			itemImage.setOnClickListener(new View.OnClickListener() {
				@Override
				public void onClick(View v) {
					// XXX: note
					// setSelect(uzContext, curSelectedIndex, false, null);
					resetAllItem(uzContext);
					curSelectedIndex = index;
					setSelect(uzContext, index, true, null, -1);
					callback(uzContext, EVENT_TYPE_CLICK, index);
				}
			});
			
			itemText.setSoundEffectsEnabled(false);
			itemText.setOnClickListener(new View.OnClickListener() {
				@Override
				public void onClick(View v) {
					itemImage.performClick();
				}
			});
			
			itemLayout.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View v) {
					itemImage.performClick();
				}
			});

			Typeface ttf = null;
			try{
				if(item.ttf.startsWith("widget")){
					Log.i(TAG, "== original ttf path == " + item.ttf);
					String ttfPath = uzContext.makeRealPath(item.ttf).replaceAll(".+widget", "widget");
					Log.i(TAG, "== uzContext.makeRealPath == " + ttfPath);
					try{
						ttf = Typeface.createFromAsset(context().getAssets(), ttfPath);
					} catch (Exception e){
						// make a try
						ttf = Typeface.createFromFile(uzContext.makeRealPath(item.ttf).replaceAll("file://", ""));
					}
				}
				if(item.ttf.startsWith("fs")){
					ttf = Typeface.createFromFile(uzContext.makeRealPath(item.ttf));
				}
			}catch(Exception e){
				e.printStackTrace();
			}
			if(ttf != null){
				itemText.setTypeface(ttf);
			}
			itemText.setText(item.titleText);
			if(TextUtils.isEmpty(item.titleText)){
				itemText.setVisibility(View.GONE);
			}
			itemText.setTextColor(UZUtility.parseCssColor(item.titleNormalTextColor));
			itemText.setTextSize(item.titleTextSize);

			RelativeLayout.LayoutParams itemLayoutParams = new RelativeLayout.LayoutParams(item.w, RelativeLayout.LayoutParams.WRAP_CONTENT);
			itemLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
			itemLayoutParams.addRule(RelativeLayout.RIGHT_OF, id - 1);
			tabbarLayout.addView(itemLayout, itemLayoutParams);

			itemViews.add(itemLayout);
			id++;
		}
	}
	
	public void setBadgeStyle(BadgeView badgeView, Config config){
		
		badgeView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 2 * config.badgeSize - 2);
		badgeView.setTextColor(UZUtility.parseCssColor(config.badgeTextColor));
		badgeView.setBackground(2 * config.badgeSize, UZUtility.parseCssColor(config.badgeBgColor));
		
	}
	
	public Bitmap getBitmap(UZModuleContext uzContext, String originalPath) {
		String realPath = uzContext.makeRealPath(originalPath);
		return UZUtility.getLocalImage(realPath);
	}

	public void callback(UZModuleContext uzContext, String eventType, int index) {
		JSONObject ret = new JSONObject();
		try {
			ret.put("eventType", eventType);
			if (index >= 0) {
				ret.put("index", index);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		uzContext.success(ret, false);
	}
	
	public void callback(UZModuleContext uzContext, String[] args){
		JSONObject obj = new JSONObject();
		try {
			obj.put("status", args);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}
	
	@Override
	protected void onClean() {
		curSelectedIndex = 0;
	}
	
}
