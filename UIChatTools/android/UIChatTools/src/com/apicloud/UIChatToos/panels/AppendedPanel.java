/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.UIChatToos.panels;

import java.util.ArrayList;
import java.util.List;

import com.apicloud.UIChatToos.AppendAdapter;
import com.apicloud.UIChatToos.AppendItem;
import com.apicloud.UIChatToos.AppendedConfig;
import com.uzmap.pkg.uzkit.UZUtility;

import android.content.Context;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.GridView;
import android.widget.RelativeLayout;

public class AppendedPanel extends RelativeLayout{
	
	private int currentPagerIndex = 0;

	@SuppressWarnings("deprecation")
	public AppendedPanel(Context context, final AppendedConfig mConfig) {
		super(context);
		
		ArrayList<RelativeLayout> mGridViews = new ArrayList<RelativeLayout>();
		
		List<AppendItem> subList = null;
		for(int i=0; i<mConfig.items.size(); i++){
			if(i % (mConfig.col * mConfig.row) == 0){
				subList = new ArrayList<AppendItem>();
				GridView gridView = new GridView(getContext());
				gridView.setNumColumns(mConfig.col);
				gridView.setVerticalSpacing(UZUtility.dipToPix(8));
				AppendAdapter adapter = new AppendAdapter(context, mConfig, subList);
				gridView.setAdapter(adapter);
				
				gridView.setOnItemClickListener(new OnItemClickListener() {
					@Override
					public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
						if(mOnAppendPanelListener != null){
							int index = currentPagerIndex * mConfig.col * mConfig.row + position;
							mOnAppendPanelListener.onItemClick(index);
						}
					}
				});
				
				RelativeLayout container = new RelativeLayout(getContext());
				container.addView(gridView);
				
				mGridViews.add(container);
			}
			subList.add(mConfig.items.get(i));
		}
		
		ViewPager pager = new ViewPager(context);
		
		int pagerWidth = RelativeLayout.LayoutParams.MATCH_PARENT;
		int pagerHeight = RelativeLayout.LayoutParams.WRAP_CONTENT;
		RelativeLayout.LayoutParams pagerParam = new RelativeLayout.LayoutParams(pagerWidth, pagerHeight);
		pagerParam.addRule(RelativeLayout.CENTER_VERTICAL);
		
		AppendedPagerAdapter pagerAdapter = new AppendedPagerAdapter(mGridViews);
		pager.setAdapter(pagerAdapter);
		pager.setLayoutParams(pagerParam);
		
		pager.setOnPageChangeListener(new OnPageChangeListener() {
			
			@Override
			public void onPageSelected(int arg0) {
				currentPagerIndex = arg0;
			}
			
			@Override
			public void onPageScrolled(int arg0, float arg1, int arg2) {}
			
			@Override
			public void onPageScrollStateChanged(int arg0) {}
		});
		
		addView(pager);
	}
	
	public class AppendedPagerAdapter extends PagerAdapter{
		
		private ArrayList<RelativeLayout> mGrids;
		
		public AppendedPagerAdapter(ArrayList<RelativeLayout> gridViews){
			this.mGrids = gridViews;
		}

		@Override
		public int getCount() {
			return mGrids.size();
		}

		@Override
		public boolean isViewFromObject(View arg0, Object arg1) {
			return arg0 == arg1;
		}
		
		@Override
		public void destroyItem(ViewGroup container, int position, Object object) {
			container.removeView(mGrids.get(position));
		}
		
		@Override
		public Object instantiateItem(ViewGroup container, int position) {
			RelativeLayout currentPage = mGrids.get(position);
			GridView gridView = (GridView)currentPage.getChildAt(0);
			RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams)gridView.getLayoutParams();
			params.topMargin = UZUtility.dipToPix(30);
			
			container.addView(currentPage);
			return currentPage;
		}
	}
	
	public interface OnAppendPanelItemClickListener{
		public void onItemClick(int index);
	}
	
	public OnAppendPanelItemClickListener mOnAppendPanelListener;
	
	public void setOnAppendPanelItemClickListener(OnAppendPanelItemClickListener mListener){
		this.mOnAppendPanelListener = mListener;
	}
}
