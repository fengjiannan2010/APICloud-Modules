/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.UIChatToos.panels;

import java.util.ArrayList;

import org.json.JSONException;
import org.json.JSONObject;
import com.apicloud.UIChatToos.widgets.Component;
import com.apicloud.UIChatToos.widgets.RecordComponent;
import com.apicloud.UIChatToos.widgets.RecordComponent.OnRecordListener;
import com.apicloud.UIChatToos.widgets.TalkComponent;
import com.apicloud.UIChatToos.widgets.TalkComponent.OnTalkbackListener;
import com.uzmap.pkg.uzcore.UZResourcesIDFinder;
import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;

public class VoiceRecordPanel extends RelativeLayout {
	
	public static final String TARGET_RECORD = "record";
	public static final String TARGET_TALKBACK = "talkback";
	
	public static final String EVENT_PRESS = "press";
	public static final String EVENT_AUDITION = "audition";
	public static final String EVENT_AUDITION_TOUCH_ON = "auditionTouchOn";
	public static final String EVENT_SEND = "send";
	public static final String EVENT_CANCEL = "cancel";
	public static final String EVENT_SHORT_TIME = "shortTime";
	
	public static final String EVENT_START = "start";
	public static final String EVENT_STOP = "stop";

	public VoiceRecordPanel(Context context) {
		super(context);
		init();
	}
	
	public Component getCurrentComponent(){
		return (Component)views.get(currentIndex);
	}
	
	private ArrayList<View> views = new ArrayList<View>();
	private int currentIndex;
	
	@SuppressWarnings("deprecation")
	public void init(){
		
		ViewPager pager = new ViewPager(getContext());
		
		int width = RelativeLayout.LayoutParams.MATCH_PARENT;
		int height = RelativeLayout.LayoutParams.MATCH_PARENT;
		
		RelativeLayout.LayoutParams pagerParams = new RelativeLayout.LayoutParams(width, height);
		pager.setLayoutParams(pagerParams);
		this.addView(pager);
		
		// ============= VoiceRecord ================
		TalkComponent talkBackView = new TalkComponent(getContext(), pager);
		int talkBtnBmpId = UZResourcesIDFinder.getResDrawableID("uichattools_recordbtn");
		Bitmap talkBtnBmp = BitmapFactory.decodeResource(getContext().getResources(), talkBtnBmpId);
		talkBackView.setRecordBtnBitmap(talkBtnBmp);
		talkBackView.setSelectedBitmap(talkBtnBmp);
		
		talkBackView.setOnTalkbackListener(new OnTalkbackListener() {
			
			@Override
			public void onShortTime() {
				callback(TARGET_TALKBACK, EVENT_SHORT_TIME);
			}
			
			@Override
			public void onSend() {
				callback(TARGET_TALKBACK, EVENT_SEND);
			}
			
			@Override
			public void onPress() {
				callback(TARGET_TALKBACK, EVENT_PRESS);
			}
			
			@Override
			public void onCancel() {
				callback(TARGET_TALKBACK, EVENT_CANCEL);
			}
			
			@Override
			public void onAuditionCancel() {
				callback(TARGET_TALKBACK, EVENT_CANCEL);
			}
			
			@Override
			public void onAudition() {
				callback(TARGET_TALKBACK, EVENT_AUDITION_TOUCH_ON);
				addConfirmView(TARGET_TALKBACK);
			}
		});
		
		int playBtnBmpId = UZResourcesIDFinder.getResDrawableID("uichattools_play_nofull");
		Bitmap playBtnBmp = BitmapFactory.decodeResource(getContext().getResources(), playBtnBmpId);
		talkBackView.setPlayBtnBitmap(playBtnBmp);
		
		int deleteBtnBmpId = UZResourcesIDFinder.getResDrawableID("uichattools_rubbish");
		Bitmap deleteBtnBmp = BitmapFactory.decodeResource(getContext().getResources(), deleteBtnBmpId);
		talkBackView.setDeleteBtnBitmap(deleteBtnBmp);
		
		talkBackView.setBackgroundColor(Color.WHITE);
		views.add(talkBackView);
		// =========================================
		
		final RecordComponent recordView = new RecordComponent(getContext(), pager);
		recordView.setLabel("点击录音");
		int recordBtnBmpId = UZResourcesIDFinder.getResDrawableID("uichattools_record_bg");
		Bitmap recordBtnBmp = BitmapFactory.decodeResource(getContext().getResources(), recordBtnBmpId);
		recordView.setRecordBtnBitmap(recordBtnBmp);
		
		int recordSelectedBtnBmpId = UZResourcesIDFinder.getResDrawableID("uichattools_recording");
		Bitmap recordSelectedBtnBmp = BitmapFactory.decodeResource(getContext().getResources(), recordSelectedBtnBmpId);
		recordView.setSelectedBitmap(recordSelectedBtnBmp);
		
		recordView.setOnRecordListener(new OnRecordListener() {
			
			@Override
			public void onStop() {
				addConfirmView(TARGET_RECORD);
				recordView.reset();
				callback(TARGET_RECORD, EVENT_STOP);
			}
			
			@Override
			public void onStart() {
				callback(TARGET_RECORD, EVENT_START);
			}
		});
		
		views.add(recordView);
		
		VoiceRecorderAdapter adapter = new VoiceRecorderAdapter(views);
		pager.setAdapter(adapter);
		
		pager.setOnPageChangeListener(new OnPageChangeListener() {
			
			@Override
			public void onPageSelected(int arg0) {
				currentIndex = arg0;
			}
			
			@Override
			public void onPageScrolled(int arg0, float arg1, int arg2) {
			}
			
			@Override
			public void onPageScrollStateChanged(int arg0) {
			}
		});
		
	}
	
	private static UZModuleContext mCallbackContext;
	
	public static void setCallbackContext(UZModuleContext uzContext){
		mCallbackContext = uzContext;
	}
	
	public void callback(String target, String eventType){
		if(mCallbackContext == null){
			return;
		}
		JSONObject ret = new JSONObject();
		try {
			ret.put("target", target);
			ret.put("eventType", eventType);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		mCallbackContext.success(ret, false);
	}
	
	public static class VoiceRecorderAdapter extends PagerAdapter{
		
		private ArrayList<View> pageViews;
		
		public VoiceRecorderAdapter(ArrayList<View> pageViews){
			this.pageViews = pageViews;
		}

		@Override
		public int getCount() {
			return pageViews.size();
		}

		@Override
		public boolean isViewFromObject(View arg0, Object arg1) {
			return arg0 == arg1;
		}

		@Override
		public void destroyItem(ViewGroup container, int position, Object object) {
			container.removeView(pageViews.get(position));
		}
		
		@Override
		public Object instantiateItem(ViewGroup container, int position) {
			View currentPage = pageViews.get(position);
			container.addView(currentPage);
			return currentPage;
		}
	}
	
	public void addConfirmView(final String target){
		int confirmViewId = UZResourcesIDFinder.getResLayoutID("uichattools_confirm_view_layout");
		final View confirmView = View.inflate(getContext(), confirmViewId, null);
		
		confirmView.setClickable(true);
		
		addView(confirmView);
		
		int auditionBtnId = UZResourcesIDFinder.getResIdID("auditionBtn");
		ImageView auditionBtn = (ImageView)confirmView.findViewById(auditionBtnId);
		auditionBtn.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				callback(target, EVENT_AUDITION);
			}
		});
		
		int sendBtnId = UZResourcesIDFinder.getResIdID("sendBtn");
		Button sendBtn = (Button)confirmView.findViewById(sendBtnId);
		sendBtn.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				removeView(confirmView);
				callback(target, EVENT_SEND);
			}
		});
		
		int cancelBtnId = UZResourcesIDFinder.getResIdID("cancelBtn");
		Button cancelBtn = (Button)confirmView.findViewById(cancelBtnId);
		cancelBtn.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				removeView(confirmView);
				callback(target, EVENT_CANCEL);
			}
		});
	}
}
