package com.apicloud.UIChatToos;

/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
import java.util.ArrayList;

import android.support.v4.view.PagerAdapter;
import android.view.View;
import android.view.ViewGroup;

public class SwitchPanelAdapter extends PagerAdapter{
	
	private ArrayList<View> mViews;
	
	public SwitchPanelAdapter(ArrayList<View> views){
		this.mViews = views;
	}

	@Override
	public int getCount() {
		return mViews.size();
	}

	@Override
	public boolean isViewFromObject(View arg0, Object arg1) {
		return arg0 == arg1;
	}
	
	@Override
	public void destroyItem(ViewGroup container, int position, Object object) {
		container.removeView(mViews.get(position));
	}
	
	@Override
	public Object instantiateItem(ViewGroup container, int position) {
		View currentPage = mViews.get(position);
		container.addView(currentPage);
		return currentPage;
	}

}
