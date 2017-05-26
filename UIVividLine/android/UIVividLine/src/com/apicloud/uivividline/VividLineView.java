package com.apicloud.uivividline;

import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.DashPathEffect;
import android.graphics.Paint;
import android.graphics.Paint.FontMetrics;
import android.graphics.Path;
import android.graphics.PathEffect;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.GestureDetector;
import android.view.GestureDetector.SimpleOnGestureListener;
import android.view.MotionEvent;
import android.view.View;

import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;
import com.uzmap.pkg.uzkit.UZUtility;

public class VividLineView extends View {

	private int mId;
	private UZModuleContext mModuleContext;
	private Paint mPaint;
	private int mWidth;
	private int mHeight;
	private double mStepHeight;
	private double mXAxisGap;
	private double mMaxY;
	private double mMinY;
	private double mStepY;
	private double mYWidth;
	private String mYSuffix;

	private int mXColor;
	private double mXSize;
	private double mXHeight;

	private double mBubbleW;
	private double mBubbleH;
	private Bitmap mBubbleBg;
	private int mBubbleColor;
	private double mBubbleFontSize;

	private int mHColor;
	private double mHWidth;
	private String mHStyle;
	private int mVColor;
	private double mVWidth;
	private String mVStyle;

	private int mLineColor;
	private double mLineWidth;

	private double mNodeSize;
	private int mNodeColor;
	private boolean mNodeHollow;

	private double mIconWidth;
	private double mIconHeight;

	private List<VividLineData> mDatas;

	private double mOffsetX;

	private GestureDetector mGestureDetector;

	private int mClickIndex = -1;

	public VividLineView(Context context) {
		super(context);
		mPaint = new Paint(Paint.DITHER_FLAG);
		mPaint.setAntiAlias(true);
		mPaint.setDither(true);
		mGestureDetector = new GestureDetector(context,
				new VividLineOnGestureListener());
	}

	public VividLineView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public void setViewId(int id) {
		mId = id;
	}

	public void init(int width, int height) {
		this.mWidth = width;
		this.mHeight = height;
	}

	public void setDatas(List<VividLineData> datas) {
		mDatas = datas;
	}

	public void addDatas(List<VividLineData> datas) {
		mDatas.addAll(datas);
	}

	public void setCallBack(UZModuleContext moduleContext) {
		mModuleContext = moduleContext;
	}

	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);
		drawYAxis(canvas);
		drawXAxis(canvas);
		if (mClickIndex != -1) {
			drawBubble(canvas, mClickIndex);
		}
	}

	private void drawIcon(Canvas canvas, Bitmap icon, int x, int y) {
		if (icon != null) {
			Rect src = new Rect(0, 0, icon.getWidth(), icon.getHeight());
			int nodeX = x - (int) mIconWidth / 2;
			int nodeY = y - (int) mIconHeight - (int) mNodeSize * 2 - 20;
			Rect dst = new Rect(nodeX, nodeY, nodeX + (int) mIconWidth, nodeY
					+ (int) mIconHeight);
			canvas.drawBitmap(icon, src, dst, mPaint);
		}
	}

	private void drawBubble(Canvas canvas, int index) {
		VividLineData data = mDatas.get(index);
		if (data != null) {
			if (mBubbleBg != null) {
				String value = double2Str(data.getValue()) + mYSuffix;
				Rect src = new Rect(0, 0, mBubbleBg.getWidth(),
						mBubbleBg.getHeight());
				int nodeX = (int) (mOffsetX + mXAxisGap * index + mYWidth);
				int nodeY = (int) (mHeight - mXHeight - mBubbleH);
				Rect dst = new Rect(nodeX, nodeY, nodeX + (int) mBubbleW, nodeY
						+ (int) mBubbleH);
				canvas.drawBitmap(mBubbleBg, src, dst, mPaint);
				mPaint.setColor(mBubbleColor);
				mPaint.setTextSize(UZUtility.dipToPix((int) mBubbleFontSize));
				float textWidth = mPaint.measureText(value);
				int textX = (int) (nodeX + Math.abs((mBubbleW - textWidth) / 2));
				FontMetrics fm = mPaint.getFontMetrics();
				int textY = (int) (nodeY + mBubbleH / 2 - fm.descent + (fm.descent - fm.ascent) / 2);
				canvas.drawText(value, textX, textY, mPaint);
			}
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

	private void drawYAxis(Canvas canvas) {
		mPaint.setStrokeWidth((float) UZUtility.dipToPix((int) mHWidth));
		int length = (int) ((mMaxY - mMinY) / mStepY);
		mStepHeight = 1.0 * (mHeight - mXHeight) / length;
		for (int i = 0; i < length; i++) {
			float height = (float) (mHeight - mStepHeight * i - mXHeight);
			mPaint.setColor(mHColor);
			float toX = (float) (mWidth > mXAxisGap * mDatas.size() ? mWidth
					: mXAxisGap * mDatas.size());
			if (mHStyle.equals("solid")) {
				canvas.drawLine((float) mOffsetX, height, toX, height, mPaint);
			} else {
				drawDash(canvas, (float) mOffsetX, height, toX, height);
			}
		}
	}

	private void drawXAxis(Canvas canvas) {
		float y = (float) (mHeight - mXHeight);
		drawXText(canvas);
		drawVLines(canvas, y);
		drawNodes(canvas, y);
		drawVividLines(canvas, y);
		drawIcons(canvas, y);
	}

	private void drawXText(Canvas canvas) {
		VividLineData data = null;
		mPaint.setTextSize(UZUtility.dipToPix((int) mXSize));
		float textY = (float) (mHeight - mXHeight / 2 + mPaint.getTextSize() / 2);
		for (int i = 0; i < mDatas.size(); i++) {
			data = mDatas.get(i);
			if (data != null) {
				float textX = (float) (mOffsetX + mYWidth + mXAxisGap * i);
				mPaint.setColor(mXColor);
				canvas.drawText(data.getMark(), textX, textY, mPaint);
			}
		}
	}

	private void drawVLines(Canvas canvas, float y) {
		VividLineData data = null;
		for (int i = 0; i < mDatas.size(); i++) {
			data = mDatas.get(i);
			if (data != null) {
				float textWidth = mPaint.measureText(data.getMark()) / 2;
				float x = (float) (mOffsetX + mXAxisGap * i + mYWidth + textWidth);
				mPaint.setColor(mVColor);
				mPaint.setStrokeWidth((float) UZUtility.dipToPix((int) mVWidth));
				if (mVStyle.equals("solid")) {
					canvas.drawLine(x, y, x, 0, mPaint);
				} else {
					drawDash(canvas, x, y, x, 0);
				}
			}
		}
	}

	private void drawNodes(Canvas canvas, float y) {
		VividLineData data = null;
		float nodeY;
		for (int i = 0; i < mDatas.size(); i++) {
			data = mDatas.get(i);
			if (data != null) {
				float textWidth = mPaint.measureText(data.getMark()) / 2;
				float x = (float) (mOffsetX + mXAxisGap * i + mYWidth + textWidth);
				mPaint.setColor(mNodeColor);
				nodeY = (float) (y - (data.getValue() - mMinY) / mStepY
						* mStepHeight);
				if (mNodeHollow) {
					mPaint.setStyle(Paint.Style.STROKE);
				} else {
					mPaint.setStyle(Paint.Style.FILL);
				}
				canvas.drawCircle(x, nodeY,
						UZUtility.dipToPix((int) mNodeSize), mPaint);
				mPaint.setStyle(Paint.Style.FILL);
			}
		}
	}

	private int getCurrentClickIndex(float clickX, float clickY) {
		float y = (float) (mHeight - mXHeight);
		VividLineData data = null;
		float nodeX;
		float nodeY;
		for (int i = 0; i < mDatas.size(); i++) {
			data = mDatas.get(i);
			if (data != null) {
				nodeX = (float) (mOffsetX + mXAxisGap * i + mYWidth);
				nodeY = (float) (y - (data.getValue() - mMinY) / mStepY
						* mStepHeight);
				if ((Math.pow((clickX - nodeX), 2) + Math.pow((clickY - nodeY),
						2)) < Math.pow(
						(UZUtility.dipToPix((int) mNodeSize + 10)), 2)) {
					mClickIndex = i;
					clickCallBack();
					break;
				}

			}
		}
		return mClickIndex;
	}

	private void drawVividLines(Canvas canvas, float y) {
		VividLineData data = null;
		float nodeY;
		for (int i = 0; i < mDatas.size(); i++) {
			data = mDatas.get(i);
			if (data != null) {
				float textWidth = mPaint.measureText(data.getMark()) / 2;
				float x = (float) (mOffsetX + mXAxisGap * i + mYWidth + textWidth);
				nodeY = (float) (y - (data.getValue() - mMinY) / mStepY
						* mStepHeight);
				if (i > 0) {
					mPaint.setColor(mLineColor);
					mPaint.setStrokeWidth((float) UZUtility
							.dipToPix((int) mLineWidth));
					float preNodeY = (float) (y - (mDatas.get(i - 1).getValue() - mMinY)
							/ mStepY * mStepHeight);
					canvas.drawLine((float) (x - mXAxisGap), preNodeY, x,
							nodeY, mPaint);
				}
			}
		}
	}

	private void drawIcons(Canvas canvas, float y) {
		VividLineData data = null;
		float nodeY;
		for (int i = 0; i < mDatas.size(); i++) {
			data = mDatas.get(i);
			if (data != null) {
				float textWidth = mPaint.measureText(data.getMark()) / 2;
				float x = (float) (mOffsetX + mXAxisGap * i + mYWidth + textWidth);
				nodeY = (float) (y - (data.getValue() - mMinY) / mStepY
						* mStepHeight);
				Bitmap icon = data.getIcon();
				if (icon != null) {
					drawIcon(canvas, data.getIcon(), (int) x, (int) nodeY);
				}
			}
		}
	}

	private void drawDash(Canvas canvas, float startX, float startY,
			float stopX, float stopY) {
		Path path = new Path();
		path.moveTo(startX, startY);
		path.lineTo(stopX, stopY);
		PathEffect effects = new DashPathEffect(new float[] { 10, 10, 10, 10 },
				1);
		mPaint.setPathEffect(effects);
		mPaint.setStyle(Paint.Style.STROKE);
		canvas.drawPath(path, mPaint);
		mPaint.setPathEffect(null);
		mPaint.setStyle(Paint.Style.FILL);
	}

	@SuppressLint("ClickableViewAccessibility")
	@Override
	public boolean onTouchEvent(MotionEvent event) {
		return mGestureDetector.onTouchEvent(event);
	}

	public int getViewWidth() {
		return mWidth;
	}

	public int getViewHeight() {
		return mHeight;
	}

	public void setXAxisGap(double xAxisGap) {
		mXAxisGap = xAxisGap;
	}

	public void setYAxisStyles(double max, double min, double step,
			String suffix, double yWidth) {
		mMaxY = max;
		mMinY = min;
		mStepY = step;
		mYSuffix = suffix;
		mYWidth = yWidth;
	}

	public void setXAxisStyles(int color, double size, double height,
			double bubbleW, double bubbleH, Bitmap bubbleBg, int bubbleColor,
			double bubbleSize) {
		mXColor = color;
		mXSize = size;
		mXHeight = height;
		mBubbleW = bubbleW;
		mBubbleH = bubbleH;
		mBubbleBg = bubbleBg;
		mBubbleColor = bubbleColor;
		mBubbleFontSize = bubbleSize;
	}

	public void setCoordinateSytles(int hColor, double hWidth, String hStyle,
			int vColor, double vWidth, String vStyle) {
		mHColor = hColor;
		mHWidth = hWidth;
		mHStyle = hStyle;
		mVColor = vColor;
		mVWidth = vWidth;
		mVStyle = vStyle;
	}

	public void setLineSytles(int color, double width) {
		mLineColor = color;
		mLineWidth = width;
	}

	public void setNodeSytles(int color, double size, boolean hollow) {
		mNodeColor = color;
		mNodeSize = size;
		mNodeHollow = hollow;
	}

	public void setIconSytles(double width, double height) {
		mIconWidth = width;
		mIconHeight = height;
	}

	private float mScrollX;
	private boolean mIsCallBack = true;

	private void scrollBack(float distanceX) {
		mScrollX += distanceX;
		if (distanceX < 0 && Math.abs(mScrollX) > UZUtility.dipToPix(40)) {
			if (mIsCallBack) {
				scrollCallBack("scrollRight");
			}
			mIsCallBack = false;
		} else {
			if (Math.abs(mScrollX) > UZUtility.dipToPix(40)) {
				if (mIsCallBack) {
					scrollCallBack("scrollLeft");
				}
				mIsCallBack = false;
			}
		}
	}

	class VividLineOnGestureListener extends SimpleOnGestureListener {
		@Override
		public boolean onSingleTapUp(MotionEvent e) {
			return true;
		}

		@Override
		public void onLongPress(MotionEvent e) {
		}

		@Override
		public boolean onScroll(MotionEvent e1, MotionEvent e2,
				float distanceX, float distanceY) {
			if (mWidth > mXAxisGap * mDatas.size()) {
				return true;
			}
			mOffsetX -= distanceX;
			if (mOffsetX > 0) {
				mOffsetX = 0;
				scrollBack(distanceX);
			}
			if (mOffsetX < (-mXAxisGap * mDatas.size() + mWidth)) {
				mOffsetX = -mXAxisGap * mDatas.size() + mWidth;
				scrollBack(distanceX);
			}
			invalidate();
			return true;
		}

		@Override
		public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX,
				float velocityY) {
			return true;
		}

		@Override
		public void onShowPress(MotionEvent e) {
		}

		@Override
		public boolean onDown(MotionEvent e) {
			mScrollX = 0;
			mIsCallBack = true;
			return true;
		}

		@Override
		public boolean onDoubleTap(MotionEvent e) {
			return false;
		}

		@Override
		public boolean onDoubleTapEvent(MotionEvent e) {
			return false;
		}

		@Override
		public boolean onSingleTapConfirmed(MotionEvent e) {
			mClickIndex = getCurrentClickIndex(e.getX(), e.getY());
			invalidate();
			return false;
		}
	}

	private void clickCallBack() {
		JSONObject ret = new JSONObject();
		try {
			ret.put("id", mId);
			ret.put("eventType", "nodeClick");
			ret.put("index", mClickIndex);
			mModuleContext.success(ret, false);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	private void scrollCallBack(String eventType) {
		JSONObject ret = new JSONObject();
		try {
			ret.put("id", mId);
			ret.put("eventType", eventType);
			mModuleContext.success(ret, false);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}
}
