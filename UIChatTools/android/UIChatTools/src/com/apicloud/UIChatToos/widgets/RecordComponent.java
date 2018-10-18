/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.UIChatToos.widgets;

import java.util.Timer;
import java.util.TimerTask;

import com.uzmap.pkg.uzkit.UZUtility;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Paint.FontMetricsInt;
import android.graphics.Paint.Style;
import android.graphics.PorterDuff;
import android.graphics.Rect;
import android.support.v4.view.ViewPager;

import android.view.MotionEvent;
import android.view.View;

public class RecordComponent extends View implements Component{
	
	private Paint mRecordBtnPaint;

	private Bitmap mRecordBtnBmp;
	
	private boolean isRecord = false;
	
	private ViewPager mPager;
	
	private static final int RECORD_BTN_SIZE = UZUtility.dipToPix(120);
	
	private Paint mLabelPaint;
	
	public void setLabel(String label){
		this.mLabel = label;
		postInvalidate();
	}

	public RecordComponent(Context context, ViewPager pager) {
		super(context);
		
		mRecordBtnPaint = new Paint();
		mRecordBtnPaint.setColor(Color.CYAN);
		mRecordBtnPaint.setAntiAlias(true);
		mRecordBtnPaint.setStyle(Style.FILL);
		
		
		mLabelPaint = new Paint();
		mLabelPaint.setColor(0xFFB0B0B0);
		mLabelPaint.setTextSize(UZUtility.dipToPix(20));
		mLabelPaint.setAntiAlias(true);
		this.mPager = pager;
	}
	
	public void setRecordBtnBitmap(Bitmap recordBtnBmp){
		this.mRecordBtnBmp = recordBtnBmp;
	}
		
	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		
		int widthMode = MeasureSpec.getMode(widthMeasureSpec);
		int heightMode = MeasureSpec.getMode(heightMeasureSpec);
		int width = MeasureSpec.getSize(widthMeasureSpec);
		int height = MeasureSpec.getSize(heightMeasureSpec);
		
		int realWidth = 0;
		int realHeight = 0;
		if(widthMode == MeasureSpec.EXACTLY){
			realWidth = width;
		}
		if(widthMode == MeasureSpec.AT_MOST){
			realWidth = Math.min(300, width);
		}
		
		if(heightMode == MeasureSpec.EXACTLY){
			realHeight = height;
		}
		if(heightMode == MeasureSpec.AT_MOST){
			realHeight = Math.min(300, height);
		}
		setMeasuredDimension(realWidth, realHeight);
	}
	
	public Bitmap mSelectBitmap;
	
	public void setSelectedBitmap(Bitmap selectBitmap){
		this.mSelectBitmap = selectBitmap;
	}
	
	private String mLabel = "按住说话";
	
	public void reset(){
		this.mLabel = "按住说话";
		mMin = 0;
		mSec = 0;
		if(recordTimer != null){
			recordTimer.cancel();
			recordTimer = null;
		}
		this.invalidate();
	}

	@Override
	public void onDraw(Canvas canvas){
		 drawLabel(canvas, mLabel);
		 if(isRecord){
			 drawRecordBtn(canvas, mSelectBitmap);
		 } else {
			 drawRecordBtn(canvas, mRecordBtnBmp);
		 }
	}
	
	public void clear(Canvas canvas){
		canvas.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR);  
	}

	public void drawRecordBtn(Canvas canvas, Bitmap recordBmp){
		if(recordBmp != null){
			
			recordBmp = Bitmap.createScaledBitmap(recordBmp, RECORD_BTN_SIZE, RECORD_BTN_SIZE, false);
			
			int bmpWidth = recordBmp.getWidth();
			int bmpHeight = recordBmp.getHeight();
			
			int x = (getWidth() - bmpWidth) / 2;
			int y = (getHeight() - bmpHeight) / 2;
			
			canvas.drawBitmap(recordBmp, x, y, mRecordBtnPaint);
		}
	}
	
	public void drawLabel(Canvas canvas, String label){
		if(mRecordBtnBmp == null){
			return;
		}
		
		int x = (getWidth() - (int)mLabelPaint.measureText(label)) / 2;
		int y = (getHeight() - RECORD_BTN_SIZE) / 2;
		
		Rect rect = new Rect();
		rect.left = x;
		rect.top = y - UZUtility.dipToPix(30) - UZUtility.dipToPix(15);
		rect.bottom = y - UZUtility.dipToPix(15);
		rect.right = x + (int)mLabelPaint.measureText(label);
		
		drawTextInCenter(canvas, mLabelPaint, rect, label);
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
	
	private Timer recordTimer = null;
	private int mMin = 0;
	private int mSec = 0;
	
	public void startTimer(){
		
		recordTimer = new Timer();
		mLabel = String.format("%02d:%02d", mMin, mSec);
		postInvalidate();
		
		recordTimer.scheduleAtFixedRate(new TimerTask(){
			@Override
			public void run() {
				
				mLabel = String.format("%02d:%02d", mMin, mSec);
				mSec ++;
				if(mSec % 60 == 0){
					mMin ++;
					mSec = 0;
				}
				postInvalidate();
				
			}
		}, 0, 1000);
	}

	@SuppressLint("ClickableViewAccessibility")
	@Override
	public boolean onTouchEvent(MotionEvent event) {
		switch(event.getAction()){
		case MotionEvent.ACTION_DOWN:
			break;
		case MotionEvent.ACTION_UP:
			if(isRecordBtnActionDown(event.getX(), event.getY())){
				if(isRecord){
					
				}
				if(!isRecord){
					isRecord = true;
					if(mRecordListener != null){
						mRecordListener.onStart();
					}
				} else {
					isRecord = false;
					if(mRecordListener != null){
						if(recordTimer != null){
							recordTimer.cancel();
							recordTimer = null;
						}
						mRecordListener.onStop();
					}
				}
				mPager.requestDisallowInterceptTouchEvent(true);
				postInvalidate();
			}
			break;
		case MotionEvent.ACTION_MOVE:
			break;
		}
		return true;
	}
	
	public boolean isRecordBtnActionDown(float x, float y){
		if(mRecordBtnBmp == null){
			return false;
		}
		if(getDistance(x, y) <= 100){
			return true;
		}
		return false;
	}
	
	public float getDistance(float x, float y){
		
		float centerX = getWidth() / 2;
		float centerY = getHeight() / 2;
		float distance = (float) Math.sqrt((centerX - x)*(centerX - x) + (centerY - y)*(centerY - y));
		
		return distance;
	}
	
	public interface OnRecordListener{
		public void onStart();
		public void onStop();
	}
	
	private OnRecordListener mRecordListener;
	
	public void setOnRecordListener(OnRecordListener mListener){
		this.mRecordListener = mListener;
	}
	
}
