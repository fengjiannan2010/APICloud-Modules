/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package me.nereo.multi_image_selector.view;

import com.uzmap.pkg.uzkit.UZUtility;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.widget.ImageView;

/** An image view which always remains square with respect to its width. */
public class SquaredImageView extends ImageView {
	
  public static final int THRESHOLD = UZUtility.dipToPix(50);
  
  public SquaredImageView(Context context) {
    super(context);
  }

  public SquaredImageView(Context context, AttributeSet attrs) {
    super(context, attrs);
  }

  @Override 
  protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
    super.onMeasure(widthMeasureSpec, heightMeasureSpec);
    setMeasuredDimension(getMeasuredWidth(), getMeasuredWidth());
  }

  @SuppressLint("ClickableViewAccessibility") 
  @Override
  public boolean onTouchEvent(MotionEvent event) {
	  
	 if(!mEnable){
		  return super.onTouchEvent(event);
	 }
	 
	switch(event.getAction()){
		case MotionEvent.ACTION_UP:
			if(mClickListener != null){
				Log.i("debug", "x: " + (int)event.getX());
				Log.i("debug", "y: " + (int)event.getY());
				Log.i("debug", "width: " + getWidth());
				if(checkisClickCorner((int)event.getX(), (int)event.getY())){
					mClickListener.onClickCorner();
				} else {
					mClickListener.onClick();
				}
			}
			break;
	}
	return true;
  }
  
  public boolean checkisClickCorner(int x, int y){
	  switch(cornerPosition){
	  case "top_left":
		  if(x < THRESHOLD && y < THRESHOLD){
			  return true;
		  }
		  break;
	  case "bottom_left":
		  if(x < THRESHOLD && y > getHeight() - THRESHOLD){
			  return true;
		  }
		  break;
	  case "top_right":
		  if(x > getWidth() - THRESHOLD && y < THRESHOLD){
			  return true;
		  }
		  break;
	  case "bottom_right":
		  if(x > getWidth() - THRESHOLD && y > getHeight() - THRESHOLD){
			  return true;
		  }
		  break;
	  }
	  return false;
  }
  
  private String cornerPosition = "bottom_left";
  private OnClickListener mClickListener;
  
  public void setOnClickListener(OnClickListener listener, String position){
	  this.mClickListener = listener;
	  this.cornerPosition = position;
  }
  
  public interface OnClickListener{
	  void onClick();
	  void onClickCorner();
  }
  private boolean mEnable;
  public void setTouchEnable(boolean enable){
	  this.mEnable = enable;
  }
}
