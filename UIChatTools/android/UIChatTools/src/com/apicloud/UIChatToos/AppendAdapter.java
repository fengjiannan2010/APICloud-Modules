/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.UIChatToos;

import java.util.List;

import com.apicloud.UIChatToos.utils.ViewUtil;
import com.uzmap.pkg.uzcore.UZResourcesIDFinder;
import com.uzmap.pkg.uzkit.UZUtility;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

public class AppendAdapter extends BaseAdapter{
	
	private List<AppendItem> mItems;
	private Context mCtx;
	private AppendedConfig mConfig;
	
	public AppendAdapter(Context ctx, AppendedConfig config, List<AppendItem> items){
		this.mItems = items;
		this.mCtx = ctx;
		this.mConfig = config;
	}

	@Override
	public int getCount() {
		return mItems.size();
	}

	@Override
	public Object getItem(int position) {
		return mItems.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		
		if(convertView == null){
			int itemViewId = UZResourcesIDFinder.getResLayoutID("uichattools_append_adapter_item_layout");
			convertView = View.inflate(mCtx, itemViewId, null);
		}
		int itemImageId = UZResourcesIDFinder.getResIdID("itemImage");
		ImageView itemImage = (ImageView) convertView.findViewById(itemImageId);
		
		LinearLayout.LayoutParams itemImageParams = (LinearLayout.LayoutParams)itemImage.getLayoutParams();
		itemImageParams.width = mConfig.iconSize;
		itemImageParams.height = mConfig.iconSize;
		itemImage.setLayoutParams(itemImageParams);
		
		int itemTextId = UZResourcesIDFinder.getResIdID("itemText");
		TextView itemText = (TextView) convertView.findViewById(itemTextId);
		itemText.setTextSize(mConfig.titleSize);
		itemText.setTextColor(UZUtility.parseCssColor(mConfig.titleColor));
		
		AppendItem appendItem = mItems.get(position);
		
		itemImage.setImageDrawable(ViewUtil.addStateDrawable(appendItem.normal, appendItem.highlight));
		itemText.setText(appendItem.title);
		
		return convertView;
	}
	
}
