/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.UIChatToos.utils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;

import android.graphics.drawable.StateListDrawable;
import android.view.WindowManager;

public class ViewUtil {

	@SuppressWarnings("deprecation")
	public static StateListDrawable addStateDrawable(Bitmap normal, Bitmap highlight) {
		StateListDrawable sd = new StateListDrawable();
		sd.addState(new int[] { android.R.attr.state_pressed }, new BitmapDrawable(highlight));
		sd.addState(new int[] { android.R.attr.state_focused }, new BitmapDrawable(normal));
		sd.addState(new int[] {}, new BitmapDrawable(normal));
		return sd;
	}

	@SuppressWarnings("deprecation")
	public static int getScreenWidth(Context context) {
		WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
		return wm.getDefaultDisplay().getWidth();
	}

	@SuppressWarnings("deprecation")
	public static int getScreenHeight(Context context) {
		WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
		return wm.getDefaultDisplay().getHeight();
	}

}
