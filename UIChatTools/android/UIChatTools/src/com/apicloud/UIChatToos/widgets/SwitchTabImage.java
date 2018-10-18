/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.UIChatToos.widgets;

import android.content.Context;
import android.graphics.Canvas;
import android.util.AttributeSet;
import android.widget.ImageView;

public class SwitchTabImage extends ImageView{

	public SwitchTabImage(Context context) {
		super(context);
	}

	public SwitchTabImage(Context context, AttributeSet attrs, int defStyleAttr) {
		super(context, attrs, defStyleAttr);
	}

	public SwitchTabImage(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	@Override
	protected void onDraw(Canvas canvas) {
		setBackgroundColor(mSelectedColor);
		super.onDraw(canvas);
	}
	
	private int mSelectedColor;
	
	public void setSelected(int selectedColor){
		this.mSelectedColor = selectedColor;
		postInvalidate();
	}
	
	public void setUnSelected(int selectedColor){
		this.mSelectedColor = selectedColor;
		postInvalidate();
	}

}
