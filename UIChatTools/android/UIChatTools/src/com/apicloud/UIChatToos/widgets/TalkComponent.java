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
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;

public class TalkComponent extends View implements Component{
	
	private Paint mRecordBtnPaint;
	private Paint mPlayBtnPaint;
	private Paint mDeleteBtnPaint;
	
	private Bitmap mPlayBtnBmp;
	private Bitmap mDeleteBtnBmp;
	private Bitmap mRecordBtnBmp;
	
	private boolean isShowBtn = false;
	
	private boolean isDeleteSelected = false;
	private boolean isPlaySelected = false;
	
	private ViewPager mPager;
	
	private static final int RECORD_BTN_SIZE = UZUtility.dipToPix(120);
	private static final int FUNCTION_BTN_SIZE = UZUtility.dipToPix(40);
	private static final int PADDING = UZUtility.dipToPix(20);
	
	private Paint mLabelPaint;
	
	private Paint mCirclePaint;
	
	public void setLabel(String label){
		this.mLabel = label;
		postInvalidate();
	}

	public TalkComponent(Context context, ViewPager pager) {
		super(context);
		
		mRecordBtnPaint = new Paint();
		mRecordBtnPaint.setColor(Color.CYAN);
		mRecordBtnPaint.setAntiAlias(true);
		mRecordBtnPaint.setStyle(Style.FILL);
		
		mPlayBtnPaint = new Paint();
		mDeleteBtnPaint = new Paint();
		
		mLabelPaint = new Paint();
		mLabelPaint.setColor(0xFFB0B0B0);
		mLabelPaint.setTextSize(UZUtility.dipToPix(20));
		mLabelPaint.setAntiAlias(true);
		
		mCirclePaint = new Paint();
		mCirclePaint.setColor(0xFF8B8B7A);
		mCirclePaint.setAntiAlias(true);
		
		this.mPager = pager;
	}
	
	public void setPlayBtnBitmap(Bitmap playBtnBmp){
		this.mPlayBtnBmp = playBtnBmp;
	}
	
	public void setDeleteBtnBitmap(Bitmap deleteBtnBmp){
		this.mDeleteBtnBmp = deleteBtnBmp;
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

	@Override
	public void onDraw(Canvas canvas){
		
		 drawLabel(canvas, mLabel);
		 
		 if(isShowBtn){
			 drawPlayBtn(canvas, mPlayBtnBmp, isPlaySelected);
			 drawDeleteBtn(canvas, mDeleteBtnBmp, isDeleteSelected);
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
	
	public void drawPlayBtn(Canvas canvas, Bitmap playBtnBmp, boolean isSelected){
		if(playBtnBmp != null){
			
			if(isSelected){
				int left = PADDING;
				int top = PADDING;
				int radius = FUNCTION_BTN_SIZE / 2;
				canvas.drawCircle(left + radius, top + radius, radius + UZUtility.dipToPix(5), mCirclePaint);
			}
			
			playBtnBmp =  Bitmap.createScaledBitmap(playBtnBmp, FUNCTION_BTN_SIZE, FUNCTION_BTN_SIZE, false);
			canvas.drawBitmap(playBtnBmp, PADDING, PADDING, mPlayBtnPaint);
		}
	}
	
	public void drawDeleteBtn(Canvas canvas, Bitmap deleteBtnBmp, boolean isSelected){
		if(deleteBtnBmp != null){
			
			if(isSelected){
				int left =  getWidth() - FUNCTION_BTN_SIZE - PADDING;
				int top = PADDING;
				int radius = FUNCTION_BTN_SIZE / 2;
				canvas.drawCircle(left + radius, top + radius, radius + UZUtility.dipToPix(5), mCirclePaint);
			}
			deleteBtnBmp =  Bitmap.createScaledBitmap(deleteBtnBmp, FUNCTION_BTN_SIZE, FUNCTION_BTN_SIZE, false);
			canvas.drawBitmap(deleteBtnBmp, getWidth() - deleteBtnBmp.getWidth() - PADDING, PADDING, mDeleteBtnPaint);
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
		rect.right = x + (int)mLabelPaint.measureText(label) ;
		
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
		if(recordTimer != null){
			return;
		}
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
	
	private long pressDownTime = 0;
	private long pressUpTime = 0;
	
	private boolean isEnteredPlay = false;
	private boolean isEnteredDelete = false;
	
	@SuppressLint("ClickableViewAccessibility")
	@Override
	public boolean onTouchEvent(MotionEvent event) {
		switch(event.getAction()){
		case MotionEvent.ACTION_DOWN:
			
			pressDownTime = System.currentTimeMillis();
			if(recordTimer != null){
				recordTimer.cancel();
				recordTimer = null;
			}
			if(isRecordBtnActionDown(event.getX(), event.getY())){
				isShowBtn = true;
				mPager.requestDisallowInterceptTouchEvent(true);
				postInvalidate();
				if(mOnTalkbackListener != null){
					mOnTalkbackListener.onPress();
				}
			} else {
				isShowBtn = false;
				return false;
			}
			break;
		case MotionEvent.ACTION_UP:
			
			if(mOnTalkbackListener != null && !isPlaySelected && !isDeleteSelected){
				Log.i("debug", "send");
				mOnTalkbackListener.onSend();
			}
			
			pressUpTime = System.currentTimeMillis();
			isShowBtn = false;
			isPlaySelected = false;
			isDeleteSelected = false;
			
			isEnteredPlay = false;
			isEnteredDelete = false;
			
			if(recordTimer != null){
				recordTimer.cancel();
				recordTimer = null;
			}
			mLabel = "按住说话";
			mMin = 0;
			mSec = 0;
			
			postInvalidate();
			
			if(pressUpTime - pressDownTime < 800 && mOnTalkbackListener != null){
				mOnTalkbackListener.onShortTime();
				return true;
			}
			
			break;
		case MotionEvent.ACTION_MOVE:
			
			if(isMovedToPlayBtn(event.getX(), event.getY())){
				if(isEnteredPlay){
					return true;
				}
				isEnteredPlay = true;
				isPlaySelected = true;
				isDeleteSelected = false;
				postInvalidate();
				if(mOnTalkbackListener != null){
					mOnTalkbackListener.onAudition();
				}
			} else if(isMovedToDeleteBtn(event.getX(), event.getY())){
				if(isEnteredDelete){
					return true;
				}
				isEnteredDelete = true;
				isPlaySelected = false;
				isDeleteSelected = true;
				postInvalidate();
				if(mOnTalkbackListener != null){
					Log.i("debug", "cancel trigger");
					mOnTalkbackListener.onCancel();
				}
			} else {
				isPlaySelected = false;
				isDeleteSelected = false;
				isEnteredPlay = false;
				isEnteredDelete = false;
				postInvalidate();
			}
			break;
//		default:
//			if(recordTimer != null){
//				recordTimer.cancel();
//				recordTimer = null;
//			}
//			break;
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
	
	private boolean isMovedToPlayBtn(float x, float y){
		if(mPlayBtnBmp != null){
			if(x > PADDING && x < FUNCTION_BTN_SIZE + PADDING
					&& y > PADDING && y < FUNCTION_BTN_SIZE + PADDING){
				return true;
			}
		}
		return false;
	}
	
	private boolean isMovedToDeleteBtn(float x, float y){
		if(mDeleteBtnBmp != null){
			if(x > (getWidth() - FUNCTION_BTN_SIZE - PADDING) && x < getWidth() - PADDING
					&& y > PADDING && y < FUNCTION_BTN_SIZE + PADDING){
				return true;
			}
		}
		return false;
	}
	
	public float getDistance(float x, float y){
		
		float centerX = getWidth() / 2;
		float centerY = getHeight() / 2;
		float distance = (float) Math.sqrt((centerX - x)*(centerX - x) + (centerY - y)*(centerY - y));
		
		return distance;
	}
	
	public interface OnTalkbackListener{
		public void onPress();
		public void onAudition();
		public void onAuditionCancel();
		public void onSend();
		public void onCancel();
		public void onShortTime();
	}
	
	private OnTalkbackListener mOnTalkbackListener;
	public void setOnTalkbackListener(OnTalkbackListener listener){
		this.mOnTalkbackListener = listener;
	}
	
}
