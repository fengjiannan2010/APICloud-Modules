/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.UIChatToos;

import java.util.ArrayList;

import com.uzmap.pkg.uzcore.UZResourcesIDFinder;
import com.uzmap.pkg.uzkit.UZUtility;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

public class FaceAdapter extends BaseAdapter{
	
	private Context mCtx;
	private ArrayList<FaceItem> faces;
	
	private boolean isShowItemText = false;
	private boolean isAdaptable = false;
	
	public FaceAdapter(Context context, ArrayList<FaceItem> faces, boolean showText, boolean adaptable){
		this.mCtx = context;
		this.faces = faces;
		this.isShowItemText = showText;
		this.isAdaptable = adaptable;
	}

	@Override
	public int getCount() {
		return faces.size();
	}

	@Override
	public Object getItem(int position) {
		return faces.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		if(convertView == null){
			int faceAdapterItemLayoutId = UZResourcesIDFinder.getResLayoutID("uichattools_face_adapter_item_layout");
			convertView = View.inflate(mCtx, faceAdapterItemLayoutId, null);
		}
		
		int itemIconId = UZResourcesIDFinder.getResIdID("itemIcon");
		ImageView itemIcon = (ImageView)convertView.findViewById(itemIconId);
		
		int itemTextId = UZResourcesIDFinder.getResIdID("itemText");
		TextView itemText = (TextView)convertView.findViewById(itemTextId);
		
		FaceItem faceItem = faces.get(position);
		itemIcon.setImageBitmap(UZUtility.getLocalImage(faceItem.facePath));
		if(!TextUtils.isEmpty(faceItem.faceText) && isShowItemText){
			itemText.setText(faceItem.faceText.replace("[", "").replace("]", ""));
		} else {
			itemText.setVisibility(View.GONE);
		}
		if(isAdaptable){
			LinearLayout.LayoutParams itemIconParams = (LinearLayout.LayoutParams)itemIcon.getLayoutParams();
			itemIconParams.width = UZUtility.dipToPix(80);
			itemIconParams.height = UZUtility.dipToPix(80);
			itemIcon.setLayoutParams(itemIconParams);
		}
		return convertView;
	}
}
