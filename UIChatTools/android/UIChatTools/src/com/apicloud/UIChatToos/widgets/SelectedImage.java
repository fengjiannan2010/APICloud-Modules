/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.UIChatToos.widgets;

import com.uzmap.pkg.uzkit.UZUtility;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Paint.FontMetricsInt;
import android.view.View;
import android.widget.ImageView;

public class SelectedImage extends ImageView{
	
	private boolean selectedFlag = false;
	
	private Paint mCirclePaint;
	
	private Paint numPaint;
	
	private int circleX;
	private int circleY;
	
	private int circleRadius = UZUtility.dipToPix(12);
	
	private Rect mNumRect;

	public SelectedImage(Context context) {
		super(context);
		
		this.mCirclePaint = new Paint();
		mCirclePaint.setAntiAlias(true);
		
		mNumRect = new Rect();
		
		this.numPaint = new Paint();
		numPaint.setColor(Color.WHITE);
		numPaint.setAntiAlias(true);
		numPaint.setTextSize(UZUtility.dipToPix(10));
		
		
		setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				if(mOnImageSelectedListener != null){
					if(selectedFlag){
						selectedFlag = false;
					} else {
						selectedFlag = true;
					}
					mOnImageSelectedListener.onImageSelected(selectedFlag);
					postInvalidate();
				}
			}
		});
	}
	
	private int num = -1;
	
	public void setNumCount(int count){
		this.num = count;
		postInvalidate();
	}
	
	public void drawTextInCenter(Canvas canvas, Paint paint, Rect targetRect,
			String label) {

		FontMetricsInt fontMetrics = paint.getFontMetricsInt();
		int baseline = targetRect.top
				+ (targetRect.bottom - targetRect.top - fontMetrics.bottom + fontMetrics.top)
				/ 2 - fontMetrics.top;
		paint.setTextAlign(Paint.Align.CENTER);
		canvas.drawText(label, targetRect.centerX(), baseline, paint);

	}

	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);
		if(selectedFlag){
			drawSelected(canvas);
		} else {
			drawUnSelected(canvas);
		}
		
		mNumRect.left = circleX - circleRadius;
		mNumRect.top = circleY - circleRadius;
		
		mNumRect.right = circleX + circleRadius;
		mNumRect.bottom = circleY + circleRadius;
		
		if(this.num == 0){
			this.num = 1;
		}
		
		if(this.num > 0){
			drawTextInCenter(canvas, numPaint, mNumRect, this.num + "");
		}
		
		
	}
	
	public int getNums(){
		return this.num;
	}
	
	public void drawSelected(Canvas canvas){
		
		circleX = getWidth() - UZUtility.dipToPix(20);
		circleY = UZUtility.dipToPix(20);
		
		mCirclePaint.setColor(0xff0fb9f4);
		
		canvas.drawCircle(circleX, circleY, circleRadius, mCirclePaint);
		
	}
	
	public void drawUnSelected(Canvas canvas){
		
		circleX = getWidth() - UZUtility.dipToPix(20);
		circleY = UZUtility.dipToPix(20);
		
		mCirclePaint.setColor(0x66000000);
		
		canvas.drawCircle(circleX, circleY, circleRadius, mCirclePaint);
	}
	
	public interface OnImageSelectedListener{
		public void onImageSelected(boolean isSelected);
	}
	
	private OnImageSelectedListener mOnImageSelectedListener;
	
	public void setOnImageSelectedListener(OnImageSelectedListener mListener){
		this.mOnImageSelectedListener = mListener;
	}
}
