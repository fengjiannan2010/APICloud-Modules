/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.UIChatToos.widgets;

import java.util.ArrayList;

import com.uzmap.pkg.uzkit.UZUtility;


import android.content.Context;
import android.widget.RelativeLayout;
import android.widget.TextView;

public class SlideBar extends RelativeLayout{
	
	private TextView lastTv;
	private int MARGIN_BETWEEN = UZUtility.dipToPix(25);
	private int TEXT_WIDTH = UZUtility.dipToPix(30);
	
	private ArrayList<TextView> mTvs;

	public SlideBar(Context context, ArrayList<TextView> views) {
		super(context);
		this.mTvs = views;
		initView(mTvs);
	}
	
	private void initView(ArrayList<TextView> mTvs){
		for(int i=0; i<mTvs.size(); i++){
			addItem(mTvs.get(i));
		}
	}
	
	public void addItem(TextView textView){
		if(getChildCount() > 0){
			int height = RelativeLayout.LayoutParams.WRAP_CONTENT;
			RelativeLayout.LayoutParams childParams = new RelativeLayout.LayoutParams(TEXT_WIDTH, height);
			childParams.leftMargin = MARGIN_BETWEEN;
			childParams.addRule(RelativeLayout.RIGHT_OF, this.lastTv.getId());
			textView.setLayoutParams(childParams);
		} else {
			int height = RelativeLayout.LayoutParams.WRAP_CONTENT;
			RelativeLayout.LayoutParams firstChildParam = new RelativeLayout.LayoutParams(TEXT_WIDTH, height);
			firstChildParam.addRule(RelativeLayout.CENTER_HORIZONTAL);
			textView.setLayoutParams(firstChildParam);
		}
		addView(textView);
		this.lastTv = textView;
	}
	
	public void updateLayout(int offset){
		
	}
	
	public static class Position {
		public int left;
		public int right;
	}
	
	// 实现录音
	// 实现相册
	// 实现setAppend
	// 实现各种接口
	// 实现表情输入
	
}
