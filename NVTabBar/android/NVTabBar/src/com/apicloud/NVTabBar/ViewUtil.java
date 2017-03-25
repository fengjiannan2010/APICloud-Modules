/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.NVTabBar;

import android.content.Context;
import android.content.res.ColorStateList;
import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.PorterDuff.Mode;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.StateListDrawable;
import android.graphics.drawable.shapes.RoundRectShape;
import android.view.WindowManager;

public class ViewUtil {

	public static StateListDrawable addStateDrawable(int nomalColor,
			int pressColor) {
		StateListDrawable sd = new StateListDrawable();
		sd.addState(new int[] { android.R.attr.state_pressed },
				new ColorDrawable(pressColor));
		sd.addState(new int[] { android.R.attr.state_focused },
				new ColorDrawable(nomalColor));
		sd.addState(new int[] {}, new ColorDrawable(nomalColor));
		return sd;
	}

	public static StateListDrawable addStateDrawable(Drawable pressDrawable,
			Drawable normalDrawable) {
		StateListDrawable sd = new StateListDrawable();
		sd.addState(new int[] { android.R.attr.state_pressed }, pressDrawable);
		sd.addState(new int[] { android.R.attr.state_focused }, normalDrawable);
		sd.addState(new int[] {}, normalDrawable);
		return sd;
	}

	@SuppressWarnings("deprecation")
	public static int getScreenWidth(Context context) {
		WindowManager wm = (WindowManager) context
				.getSystemService(Context.WINDOW_SERVICE);
		return wm.getDefaultDisplay().getWidth();
	}

	@SuppressWarnings("deprecation")
	public static int getScreenHeight(Context context) {
		WindowManager wm = (WindowManager) context
				.getSystemService(Context.WINDOW_SERVICE);
		return wm.getDefaultDisplay().getHeight();
	}
	
	public static ShapeDrawable createRoundCornerShapeDrawable(float Radii, int borderColor) {

		float[] outerR = new float[] { Radii, Radii, Radii, Radii, Radii,
				Radii, Radii, Radii };
		RoundRectShape rr = new RoundRectShape(outerR, null, null);
		ShapeDrawable bgDrawable = new ShapeDrawable(rr);

		bgDrawable.getPaint().setColor(borderColor);

		return bgDrawable;
	}

	public static ColorStateList getColorStateList(int titleLight, int titleNormal) {
		int[][] states = new int[2][];
		states[0] = new int[] { android.R.attr.state_pressed,
				android.R.attr.state_enabled };
		states[1] = new int[] { android.R.attr.state_enabled };
		int[] colors = new int[] { titleLight, titleNormal };
		ColorStateList colorList = new ColorStateList(states, colors);
		
		return colorList;
	}
	
	public static Bitmap getRoundBitmap(Bitmap bitmap, int roundPx) {

		Bitmap output = Bitmap.createBitmap(bitmap.getWidth(), bitmap.getHeight(),
				Config.ARGB_8888);
		Canvas canvas = new Canvas(output);

		final int color = 0xff424242;

		final Rect srcRect = new Rect(0, 0, bitmap.getWidth(),
				bitmap.getHeight());
		final Rect descRect = new Rect(0, 0, bitmap.getWidth(), bitmap.getHeight());

		final Rect rect = new Rect(0, 0, bitmap.getWidth(), bitmap.getHeight());
		final RectF rectF = new RectF(rect);
		
		Paint paint = new Paint();
		paint.setAntiAlias(true);
		canvas.drawARGB(0, 0, 0, 0);
		paint.setColor(color);

		canvas.drawRoundRect(rectF, roundPx, roundPx, paint);
		paint.setXfermode(new PorterDuffXfermode(Mode.SRC_IN));
		canvas.drawBitmap(bitmap, srcRect, descRect, paint);

		return output;
	}
}
