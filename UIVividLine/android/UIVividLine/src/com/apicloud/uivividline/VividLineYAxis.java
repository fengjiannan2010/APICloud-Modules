package com.apicloud.uivividline;

import com.uzmap.pkg.uzkit.UZUtility;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.View;

public class VividLineYAxis extends View {

	private Paint mPaint;
	private int mHeigth;
	private double mMaxY;
	private double mMinY;
	private double mStepY;
	private String mYSuffix;
	private int mYColor;
	private double mYSize;
	private double mXHeight;

	public VividLineYAxis(Context context) {
		super(context);
		mPaint = new Paint(Paint.DITHER_FLAG);
		mPaint.setAntiAlias(true);
		mPaint.setDither(true);
	}

	public VividLineYAxis(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public void setHeight(int height) {
		mHeigth = height;
	}

	public void setXHeight(int xHeight) {
		mXHeight = xHeight;
	}

	public void setYAxisStyles(double max, double min, double step,
			String suffix, int color, double size) {
		mMaxY = max;
		mMinY = min;
		mStepY = step;
		mYSuffix = suffix;
		mYColor = color;
		mYSize = size;
	}

	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);
		drawYAxis(canvas);
	}

	private void drawYAxis(Canvas canvas) {
		int length = (int) ((mMaxY - mMinY) / mStepY);
		double stepHeight = 1.0 * (mHeigth - mXHeight) / length;
		mPaint.setTextSize(UZUtility.dipToPix((int) mYSize));
		for (int i = 1; i < length; i++) {
			float height = (float) (mHeigth - stepHeight * i - mXHeight - 10 + mPaint
					.getTextSize() / 2);
			mPaint.setColor(mYColor);
			String value = double2Str((mMinY + i * mStepY));
			canvas.drawText(value + mYSuffix, 0, height, mPaint);
		}
	}

	private String double2Str(double value) {
		String str = null;
		boolean isInteger = isInteger(String.valueOf(value));
		if (isInteger) {
			str = String.valueOf((int) value);
		} else {
			str = String.valueOf(value);
		}
		return str;
	}

	private boolean isInteger(String str) {
		String suffix = str.substring(str.indexOf(".") + 1);
		if (suffix != null) {
			for (int i = 0; i < suffix.length(); i++) {
				if (suffix.charAt(i) != '0') {
					return false;
				}
			}
		}
		return true;
	}
}
