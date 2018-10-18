/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.UIChatToos.panels;

import java.util.ArrayList;

import com.apicloud.UIChatToos.FaceAdapter;
import com.apicloud.UIChatToos.FaceItem;
import com.apicloud.UIChatToos.common.OnEmojiSelectedListener;
import com.uzmap.pkg.uzcore.UZResourcesIDFinder;
import com.uzmap.pkg.uzkit.UZUtility;

import android.content.Context;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.GridView;
import android.widget.LinearLayout;
import android.widget.TextView;

public class FacePanel extends LinearLayout{
	
	private OnEmojiSelectedListener mOnEmojiSelectedListener;
	
	public FacePanel(Context context, OnEmojiSelectedListener emojiListener) {
		super(context);
		this.mOnEmojiSelectedListener = emojiListener;
		setOrientation(LinearLayout.VERTICAL);
	}
	
	public void addItem(String title, ArrayList<FaceItem> items){
		
		int face_panel_item_id = UZResourcesIDFinder.getResLayoutID("uichattools_facepanel_item_layout");
		View facePanelItem = View.inflate(getContext(), face_panel_item_id, null);
		
		int faceTypeLabel_id = UZResourcesIDFinder.getResIdID("faceTypeLabel");
		TextView faceTypeLabel = (TextView)facePanelItem.findViewById(faceTypeLabel_id);
		int faceTypeGrid_id = UZResourcesIDFinder.getResIdID("faceTypeGrid");
		final GridView faceTypeGrid = (GridView)facePanelItem.findViewById(faceTypeGrid_id);
		faceTypeGrid.setNumColumns(7);
		faceTypeLabel.setText(title);
		
		int rows = 0;
		if(items.size() % 7 == 0){
			rows = items.size() / 7;
		} else {
			rows = items.size() / 7 + 1;
		}
		
		LinearLayout.LayoutParams gridViewParams = (LinearLayout.LayoutParams)faceTypeGrid.getLayoutParams();
		gridViewParams.height = rows * UZUtility.dipToPix(40);
		faceTypeGrid.setLayoutParams(gridViewParams);
		
		FaceAdapter faceAdapter = new FaceAdapter(getContext(), items, false, false);
		faceTypeGrid.setAdapter(faceAdapter);
		
		addView(facePanelItem);
		
		faceTypeGrid.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
				if(mOnEmojiSelectedListener != null){
					FaceAdapter faceAdapter = (FaceAdapter)faceTypeGrid.getAdapter();
					mOnEmojiSelectedListener.onItemClick((FaceItem)faceAdapter.getItem(position));
				}
			}
		});
	}
	
	public void addItem(ArrayList<FaceItem> customFaceItems){
		final GridView customFaceGrid = new GridView(getContext());
		FaceAdapter faceAdapter = new FaceAdapter(getContext(), customFaceItems, true, true);
		customFaceGrid.setAdapter(faceAdapter);
		customFaceGrid.setNumColumns(4);
		customFaceGrid.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
				if(mOnEmojiSelectedListener != null){
					FaceAdapter faceAdapter = (FaceAdapter)customFaceGrid.getAdapter();
					mOnEmojiSelectedListener.onItemClick((FaceItem)faceAdapter.getItem(position));
				}
			}
		});
		addView(customFaceGrid);
	}
	
	public void setOnEmojiSelectedListener(OnEmojiSelectedListener listener){
		this.mOnEmojiSelectedListener = listener;
	}
}
