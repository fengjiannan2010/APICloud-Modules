/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.UIChatToos;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Rect;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.text.Editable;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.style.ImageSpan;
import android.view.View;
import android.view.View.OnFocusChangeListener;
import android.view.View.OnLayoutChangeListener;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.ScrollView;

import com.apicloud.UIChatToos.common.BasicEmotion;
import com.apicloud.UIChatToos.common.ListenerPool;
import com.apicloud.UIChatToos.common.OnEmojiSelectedListener;
import com.apicloud.UIChatToos.panels.AppendedPanel;
import com.apicloud.UIChatToos.panels.AppendedPanel.OnAppendPanelItemClickListener;
import com.apicloud.UIChatToos.panels.FacePanel;
import com.apicloud.UIChatToos.panels.ImageSelectPanel;
import com.apicloud.UIChatToos.panels.ImageSelectPanel.OnImagePanelListener;
import com.apicloud.UIChatToos.panels.VoiceRecordPanel;
import com.apicloud.UIChatToos.widgets.SwitchTabImage;
import com.uzmap.pkg.uzcore.UZCoreUtil;
import com.uzmap.pkg.uzcore.UZResourcesIDFinder;
import com.uzmap.pkg.uzcore.UZWebView;
import com.uzmap.pkg.uzcore.uzmodule.UZModule;
import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;
import com.uzmap.pkg.uzkit.UZUtility;

public class UIChatTools extends UZModule {

	public static final String TAG = "UIChatTools";
	private View mChatBoxToolbar;

	private static String TAG_RECORDER = "recordBtn";
	private static String TAG_IMAGE = "imageBtn";
	private static String TAG_VIDEO = "cameraBtn";
	private static String TAG_PACKET = "redPacketBtn";
	private static String TAG_FACE = "faceBtn";
	private static String TAG_APPEND = "otherBtn";

	private HashMap<String, IconResource> mIcons = new HashMap<String, IconResource>();

	private ArrayList<ImageView> mToolImages = new ArrayList<ImageView>();

	public UIChatTools(UZWebView webView) {
		super(webView);
	}

	private OnEmojiSelectedListener mEmojiSelectedListener = new OnEmojiSelectedListener() {

		@Override
		public void onItemClick(FaceItem item) {
			String itemText = "[" + item.facePath + "]";
			
			if(currentFacePanelIndex > 0){
				if (ListenerPool.faceItemClick && faceListenerContext != null) {
					faceCallback(faceListenerContext, item.faceDir, item.faceText);
				}
				return;
			}
			
			mInputEdit.getText().insert(mInputEdit.getSelectionStart(), parseString(itemText));
			if (ListenerPool.faceItemClick && faceListenerContext != null) {
				faceCallback(faceListenerContext, item.faceDir, item.faceText);
			}
		}
	};

	public SpannableStringBuilder parseString(String inputText) {
		SpannableStringBuilder builder = new SpannableStringBuilder(inputText);
		
		Pattern pattern = Pattern.compile("\\[.+\\]");
		Matcher matcher = pattern.matcher(inputText);
		while (matcher.find()) {
			builder.setSpan(new ImageSpan(context(), UZUtility.getLocalImage(inputText.substring(matcher.start() + 1, matcher.end() - 1))), matcher.start(), matcher.end(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
		}
		return builder;
	}

	public void faceCallback(UZModuleContext uzContext, String emoticonName, String text) {
		JSONObject ret = new JSONObject();
		try {
			ret.put("emoticonName", emoticonName);
			ret.put("text", text);
			uzContext.success(ret, false);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	public void loadToolBarBmps(Config config, UZModuleContext uzContext) {
		if (config.hasRecorder) {
			IconResource recorderRes = new IconResource();
			recorderRes.normal = UZUtility.getLocalImage(uzContext.makeRealPath(config.recorderNomal));
			recorderRes.selected = UZUtility.getLocalImage(uzContext.makeRealPath(config.recorderSelected));
			mIcons.put(TAG_RECORDER, recorderRes);
		}

		if (config.hasImage) {
			IconResource imageRes = new IconResource();
			imageRes.normal = UZUtility.getLocalImage(uzContext.makeRealPath(config.imageNormal));
			imageRes.selected = UZUtility.getLocalImage(uzContext.makeRealPath(config.imageSelected));
			mIcons.put(TAG_IMAGE, imageRes);
		}

		if (config.hasVideo) {
			IconResource videoRes = new IconResource();
			videoRes.normal = UZUtility.getLocalImage(uzContext.makeRealPath(config.videoNormal));
			videoRes.selected = UZUtility.getLocalImage(uzContext.makeRealPath(config.videoSelected));
			mIcons.put(TAG_VIDEO, videoRes);
		}

		if (config.hasPacket) {
			IconResource packetRes = new IconResource();
			packetRes.normal = UZUtility.getLocalImage(uzContext.makeRealPath(config.packetNormal));
			packetRes.selected = UZUtility.getLocalImage(uzContext.makeRealPath(config.packetSelected));
			mIcons.put(TAG_PACKET, packetRes);
		}

		if (config.hasFace) {
			IconResource faceRes = new IconResource();
			faceRes.normal = UZUtility.getLocalImage(uzContext.makeRealPath(config.faceNormal));
			faceRes.selected = UZUtility.getLocalImage(uzContext.makeRealPath(config.faceSelected));
			mIcons.put(TAG_FACE, faceRes);
		}

		if (config.hasAppend) {
			IconResource appendRes = new IconResource();
			appendRes.normal = UZUtility.getLocalImage(uzContext.makeRealPath(config.appendNormal));
			appendRes.selected = UZUtility.getLocalImage(uzContext.makeRealPath(config.appendSelected));
			mIcons.put(TAG_APPEND, appendRes);
		}
	}

	public static class IconResource {
		public Bitmap normal;
		public Bitmap selected;
	}

	private boolean mHasLoaded = false;

	private Config mConfig;

	private EditText mInputEdit;

	public void jsmethod_open(final UZModuleContext uzContext) {

		if (mChatBoxToolbar != null) {
			return;
		}
		mConfig = new Config(uzContext);

		// just load once
		if (!mHasLoaded) {
			loadToolBarBmps(mConfig, uzContext);
			mHasLoaded = true;
		}

		int width = RelativeLayout.LayoutParams.MATCH_PARENT;
		int height = RelativeLayout.LayoutParams.WRAP_CONTENT;

		RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(width, height);
		params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);

		int chatboxToolbarId = UZResourcesIDFinder.getResLayoutID("uichattools_toolbar_layout");
		mChatBoxToolbar = View.inflate(context(), chatboxToolbarId, null);

		// =============== EditText ===============
		int input_id = UZResourcesIDFinder.getResIdID("inputField");
		mInputEdit = (EditText) mChatBoxToolbar.findViewById(input_id);
		mInputEdit.setHint(mConfig.chatBoxPlaceHolder);
		
		if (mConfig.autoFocus) {
			new Handler(Looper.getMainLooper()).postDelayed(new Runnable(){
				@Override
				public void run() {
					mInputEdit.setFocusable(true);
					mInputEdit.setFocusableInTouchMode(true);
					mInputEdit.requestFocus();
					showSoftInputKeyBoard(mInputEdit);
				}
			}, 300);
			
		}
		
		mInputEdit.setMaxLines(mConfig.maxRows);

		RelativeLayout.LayoutParams inputParams = (RelativeLayout.LayoutParams) mInputEdit.getLayoutParams();
		inputParams.leftMargin = mConfig.styleMargin;
		inputParams.rightMargin = mConfig.styleMargin;

		mChatBoxToolbar.setBackgroundColor(UZUtility.parseCssColor(mConfig.styleMaskBg));

		if(mConfig.hasMask){
			mChatBoxToolbar.setOnClickListener(new View.OnClickListener() {
				@Override
				public void onClick(View v) {
					hideSoftInputKeyBoard(mInputEdit);
					hideShowPanel();
				}
			});
		}
		
		int chatBoxLayoutId = UZResourcesIDFinder.getResIdID("chatBoxLayoutId");
		mChatBoxToolbar.findViewById(chatBoxLayoutId).setBackgroundColor(UZUtility.parseCssColor(mConfig.styleBgColor));

		// =============== bindView ===============
		initView(uzContext, mConfig, mChatBoxToolbar, mInputEdit);

		// ================ handle keyboard ==============
		mInputEdit.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				hideShowPanel();
			}
		});

		mInputEdit.setOnFocusChangeListener(new OnFocusChangeListener() {

			@Override
			public void onFocusChange(View v, boolean hasFocus) {
				if (hasFocus) {
					hideShowPanel();
				}
			}
		});

		// ================= send button ================
		int sendBtnId = UZResourcesIDFinder.getResIdID("sendBtn");
		Button sendBtn = (Button) mChatBoxToolbar.findViewById(sendBtnId);
		sendBtn.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				
				String tempStr = mInputEdit.getText().toString();
				
				if(!mConfig.useFacePath){
					Pattern pattern = Pattern.compile("([\\:\\/a-zA-Z0-9\\.\\-_]{0,})");
					Matcher matcher = pattern.matcher(mInputEdit.getText().toString());
					
					while(matcher.find()){
						if(matcher.group(0).startsWith("file")){
							tempStr = tempStr.replace(matcher.group(0), getFaceTextByFacePath(mConfig, matcher.group(0)).replace("[", "").replace("]", ""));
						}
					}
				}
				callbackForOpen(uzContext, "send",tempStr);
			}
		});

		this.insertViewToCurWindow(mChatBoxToolbar, params);
		callbackForOpen(uzContext, "show", null);
	}
	
	public void callbackForOpen(UZModuleContext uzContext, String eventType, String msg) {
		JSONObject ret = new JSONObject();
		try {
			ret.put("eventType", eventType);
			if (!TextUtils.isEmpty(msg)) {
				ret.put("msg", msg);
			}
			uzContext.success(ret, false);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	public void hideShowPanel() {
		if (mChatBoxToolbar == null) {
			return;
		}
		int showPanel_id = UZResourcesIDFinder.getResIdID("showPanel");
		mChatBoxToolbar.findViewById(showPanel_id).setVisibility(View.GONE);
		clearAllToolBtnsState();
	}

	private ImageSelectPanel mImageSelectPanel = null;

	public void initView(final UZModuleContext uzContext, final Config config, final View chatBoxToolbar, final EditText input) {

		// ============= tools bar setting ===========
		int toolsbarLayout_id = UZResourcesIDFinder.getResIdID("toolsbarLayout");
		View toolsbarLayout = chatBoxToolbar.findViewById(toolsbarLayout_id);

		RelativeLayout.LayoutParams toolsbarLayoutParams = (RelativeLayout.LayoutParams) toolsbarLayout.getLayoutParams();
		toolsbarLayoutParams.height = config.toolBarHeight;
		toolsbarLayout.setLayoutParams(toolsbarLayoutParams);

		// ============== record button =============
		int recordBtn_id = UZResourcesIDFinder.getResIdID("recordBtn");
		final ImageView recordBtn = (ImageView) chatBoxToolbar.findViewById(recordBtn_id);
		recordBtn.getLayoutParams().width = config.toolsIconSize;
		recordBtn.getLayoutParams().height = config.toolsIconSize;
		recordBtn.setTag(TAG_RECORDER);
		mToolImages.add(recordBtn);

		final IconResource recorderRes = mIcons.get(TAG_RECORDER);
		if (recorderRes == null) {
			recordBtn.setVisibility(View.GONE);
		} else {
			if (recorderRes.normal != null) {
				recordBtn.setImageBitmap(recorderRes.normal);
			}
		}

		recordBtn.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				clearAllToolBtnsState();
				if (recorderRes != null && recorderRes.selected != null) {
					recordBtn.setImageBitmap(recorderRes.selected);
				}
				hideSoftInputKeyBoard(input);
				showVoiceRecordPanel();
				if (mOnToolBarListener != null) {
					mOnToolBarListener.onRecordClick();
				}
			}
		});

		// ============= image button ============
		int imageBtn_id = UZResourcesIDFinder.getResIdID(TAG_IMAGE);
		final ImageView imageBtn = (ImageView) chatBoxToolbar.findViewById(imageBtn_id);
		imageBtn.setTag(TAG_IMAGE);
		imageBtn.getLayoutParams().width = config.toolsIconSize;
		imageBtn.getLayoutParams().height = config.toolsIconSize;
		mToolImages.add(imageBtn);

		final IconResource imageRes = mIcons.get(TAG_IMAGE);
		if (imageRes == null) {
			imageBtn.setVisibility(View.GONE);
		} else {
			if (imageRes.normal != null) {
				imageBtn.setImageBitmap(imageRes.normal);
			}
		}
		imageBtn.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				clearAllToolBtnsState();
				if (imageRes != null && imageRes.selected != null) {
					imageBtn.setImageBitmap(imageRes.selected);
				}

				int showPanel_id = UZResourcesIDFinder.getResIdID("showPanel");
				RelativeLayout showPanel = (RelativeLayout) mChatBoxToolbar.findViewById(showPanel_id);
				showPanel.removeAllViews();
				showPanel.setVisibility(View.VISIBLE);

				hideSoftInputKeyBoard(input);
				mImageSelectPanel = new ImageSelectPanel(context());
				showPanel.addView(mImageSelectPanel);

				if (mOnToolBarListener != null) {
					mOnToolBarListener.onImageClick();
				}
			}
		});

		// ============== video button =============
		int cameraBtn_id = UZResourcesIDFinder.getResIdID(TAG_VIDEO);
		final ImageView cameraBtn = (ImageView) chatBoxToolbar.findViewById(cameraBtn_id);
		cameraBtn.setTag(TAG_VIDEO);
		cameraBtn.getLayoutParams().width = config.toolsIconSize;
		cameraBtn.getLayoutParams().height = config.toolsIconSize;
		mToolImages.add(cameraBtn);

		final IconResource videoRes = mIcons.get(TAG_VIDEO);
		if (videoRes == null) {
			cameraBtn.setVisibility(View.GONE);
		} else {
			if (videoRes.normal != null) {
				cameraBtn.setImageBitmap(videoRes.normal);
			}
		}
		cameraBtn.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				clearAllToolBtnsState();
				if (videoRes != null && videoRes.selected != null) {
					cameraBtn.setImageBitmap(videoRes.selected);
				}
				if (mOnToolBarListener != null) {
					mOnToolBarListener.onVideoClick();
				}
			}
		});

		// ============== packet button =============
		int packetBtn_id = UZResourcesIDFinder.getResIdID(TAG_PACKET);
		final ImageView packetBtn = (ImageView) chatBoxToolbar.findViewById(packetBtn_id);
		packetBtn.setTag(TAG_PACKET);
		packetBtn.getLayoutParams().width = config.toolsIconSize;
		packetBtn.getLayoutParams().height = config.toolsIconSize;
		mToolImages.add(packetBtn);

		final IconResource packetRes = mIcons.get(TAG_PACKET);
		if (packetRes == null) {
			packetBtn.setVisibility(View.GONE);
		} else {
			if (packetRes.normal != null) {
				packetBtn.setImageBitmap(packetRes.normal);
			}
		}

		packetBtn.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				clearAllToolBtnsState();
				if (packetRes != null && packetRes.selected != null) {
					packetBtn.setImageBitmap(packetRes.selected);
				}

				if (mOnToolBarListener != null) {
					mOnToolBarListener.onPacketClick();
				}
			}
		});

		// ============= face button =============
		int faceBtn_id = UZResourcesIDFinder.getResIdID(TAG_FACE);
		final ImageView faceBtn = (ImageView) chatBoxToolbar.findViewById(faceBtn_id);
		faceBtn.setTag(TAG_FACE);
		faceBtn.getLayoutParams().width = config.toolsIconSize;
		faceBtn.getLayoutParams().height = config.toolsIconSize;
		mToolImages.add(faceBtn);

		final IconResource faceRes = mIcons.get(TAG_FACE);
		if (faceRes == null) {
			faceBtn.setVisibility(View.GONE);
		} else {
			if (faceRes.normal != null) {
				faceBtn.setImageBitmap(faceRes.normal);
			}
		}
		faceBtn.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				clearAllToolBtnsState();
				if (faceRes != null && faceRes.selected != null) {
					faceBtn.setImageBitmap(faceRes.selected);
				}
				int showPanel_id = UZResourcesIDFinder.getResIdID("showPanel");
				chatBoxToolbar.findViewById(showPanel_id).setVisibility(View.VISIBLE);
				hideSoftInputKeyBoard(input);
				showFacePanel(uzContext, config);

				if (mOnToolBarListener != null) {
					mOnToolBarListener.onFaceClick();
				}
			}
		});

		// =============== other button ===============
		int otherBtn_id = UZResourcesIDFinder.getResIdID(TAG_APPEND);
		final ImageView otherBtn = (ImageView) chatBoxToolbar.findViewById(otherBtn_id);
		otherBtn.setTag(TAG_APPEND);
		otherBtn.getLayoutParams().width = config.toolsIconSize;
		otherBtn.getLayoutParams().height = config.toolsIconSize;
		mToolImages.add(otherBtn);

		final IconResource otherRes = mIcons.get(TAG_APPEND);
		if (otherRes == null) {
			otherBtn.setVisibility(View.GONE);
		} else {
			if (otherRes.normal != null) {
				otherBtn.setImageBitmap(otherRes.normal);
			}
		}

		otherBtn.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				clearAllToolBtnsState();
				if (otherRes != null && otherRes.selected != null) {
					otherBtn.setImageBitmap(otherRes.selected);
				}

				if (mAppendPanel != null) {
					addAppendPanel();
				}

				if (mOnToolBarListener != null) {
					mOnToolBarListener.onAppendClick();
				}
			}
		});
	}

	public void addAppendPanel() {

		int showPanel_id = UZResourcesIDFinder.getResIdID("showPanel");
		RelativeLayout showPanel = (RelativeLayout) mChatBoxToolbar.findViewById(showPanel_id);
		showPanel.removeAllViews();
		showPanel.setVisibility(View.VISIBLE);
		hideSoftInputKeyBoard(mInputEdit);

		int width = RelativeLayout.LayoutParams.MATCH_PARENT;
		int height = RelativeLayout.LayoutParams.WRAP_CONTENT;

		RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(width, height);
		params.addRule(RelativeLayout.CENTER_VERTICAL);
		showPanel.addView(mAppendPanel, params);
	}

	public void clearAllToolBtnsState() {
		for (int i = 0; i < mToolImages.size(); i++) {
			ImageView toolImage = mToolImages.get(i);
			String key = (String) toolImage.getTag();
			IconResource iconRes = mIcons.get(key);
			if (iconRes != null && iconRes.normal != null) {
				toolImage.setImageBitmap(iconRes.normal);
			}
		}
	}

	private VoiceRecordPanel mRecordPanel;

	public void showVoiceRecordPanel() {
		if (mChatBoxToolbar == null) {
			return;
		}
		int showPanel_id = UZResourcesIDFinder.getResIdID("showPanel");
		RelativeLayout showPanel = (RelativeLayout) mChatBoxToolbar.findViewById(showPanel_id);
		showPanel.removeAllViews();
		showPanel.setVisibility(View.VISIBLE);

		mRecordPanel = new VoiceRecordPanel(context());
		showPanel.addView(mRecordPanel);
	}

	public void showFacePanel(UZModuleContext uzContext, Config config) {
		if (mChatBoxToolbar == null) {
			return;
		}
		
		int showPanel_id = UZResourcesIDFinder.getResIdID("showPanel");
		RelativeLayout showPanel = (RelativeLayout) mChatBoxToolbar.findViewById(showPanel_id);
		showPanel.removeAllViews();
		showPanel.setVisibility(View.VISIBLE);

		initFaceSwitchTab(showPanel, config, uzContext);

	}
	
	private int currentFacePanelIndex = 0;

	@SuppressWarnings("deprecation")
	public void initFaceSwitchTab(final ViewGroup container, Config config, UZModuleContext uzContext) {
		final LinearLayout switchTabContainer = new LinearLayout(context());
		switchTabContainer.setId(0x100000);

		int width = RelativeLayout.LayoutParams.MATCH_PARENT;
		int height = RelativeLayout.LayoutParams.WRAP_CONTENT;
		RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(width, height);
		params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
		params.topMargin = UZUtility.dipToPix(3);

		int padding = UZUtility.dipToPix(3);
		switchTabContainer.setPadding(padding, padding, padding, padding);

		switchTabContainer.setLayoutParams(params);
		switchTabContainer.setBackgroundColor(0xFFFFFFFF);

		final ArrayList<BasicEmotion> basicEmotions = config.parseBasicEmotion();
		final ArrayList<ArrayList<FaceItem>> appendsEmotions = config.parseAllAppendEmotions();
		
		ArrayList<View> emotionPanels = new ArrayList<View>();
		
		for(int i=0; i < config.emotionsPathArray.size(); i++){
			if(i == 0){
				emotionPanels.add(createBasicFacePanel(container, basicEmotions));
			} else {
				emotionPanels.add(createAppendedFacePanel(container, appendsEmotions.get(i - 1), switchTabContainer.getId()));
			}
		}
		
		// TODO : new feature
		final ViewPager switchPanelPager = new ViewPager(context());
		SwitchPanelAdapter switchPanelAdapter = new SwitchPanelAdapter(emotionPanels);
		switchPanelPager.setAdapter(switchPanelAdapter);
		
		int switchPanelSize = RelativeLayout.LayoutParams.MATCH_PARENT;
		RelativeLayout.LayoutParams switchPanelParams = new RelativeLayout.LayoutParams(switchPanelSize, switchPanelSize);
		switchPanelParams.addRule(RelativeLayout.ABOVE, 0x100000);
		switchPanelPager.setLayoutParams(switchPanelParams);

		for (int i = 0; i < config.emotionsPathArray.size(); i++) {
			final SwitchTabImage emotionTabIcon = new SwitchTabImage(context());
			String iconPath = getTabIconPath(uzContext, config.emotionsPathArray.get(i));
			emotionTabIcon.setImageBitmap(UZUtility.getLocalImage(iconPath));
			int widthParams = UZUtility.dipToPix(30);
			LinearLayout.LayoutParams tabIconParams = new LinearLayout.LayoutParams(widthParams, widthParams);
			tabIconParams.leftMargin = UZUtility.dipToPix(5);
			emotionTabIcon.setLayoutParams(tabIconParams);
			switchTabContainer.addView(emotionTabIcon);
			emotionTabIcon.setTag(i);
			emotionTabIcon.setOnClickListener(new View.OnClickListener() {
				@Override
				public void onClick(View v) {					
					for (int i = 0; i < switchTabContainer.getChildCount(); i++) {
						((SwitchTabImage) switchTabContainer.getChildAt(i)).setUnSelected(0xFFFFFFFF);
					}
					emotionTabIcon.setSelected(0xFFCDCDB4);
					switchPanelPager.setCurrentItem(((Integer) emotionTabIcon.getTag()));
				}
			});
		}
		
		container.addView(switchPanelPager);
		switchPanelPager.setOnPageChangeListener(new OnPageChangeListener() {
			@Override
			public void onPageSelected(int arg0){
				currentFacePanelIndex = arg0;
				for (int i = 0; i < switchTabContainer.getChildCount(); i++) {
					((SwitchTabImage) switchTabContainer.getChildAt(i)).setUnSelected(0xFFFFFFFF);
				}
				((SwitchTabImage) switchTabContainer.getChildAt(arg0)).setUnSelected(0xFFCDCDB4);
			}
			
			@Override
			public void onPageScrolled(int arg0, float arg1, int arg2) {}
			
			@Override
			public void onPageScrollStateChanged(int arg0) {}
		});
		
		container.addView(switchTabContainer);
		if(config.isShowAddImg){
			container.addView(initAddFaceBtn());
		}
		if (switchTabContainer.getChildAt(0) != null) {
			switchTabContainer.getChildAt(0).performClick();
		}
	}

	public View initAddFaceBtn() {
		ImageView addFaceImage = new ImageView(context());
		RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(UZUtility.dipToPix(25), UZUtility.dipToPix(25));
		params.rightMargin = UZUtility.dipToPix(5);
		params.bottomMargin = UZUtility.dipToPix(5);
		params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
		params.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
		addFaceImage.setBackgroundColor(0xff0fb9f4);
		addFaceImage.setLayoutParams(params);

		int addFaceIconId = UZResourcesIDFinder.getResDrawableID("uichattools_addface_icon");
		addFaceImage.setImageResource(addFaceIconId);
		addFaceImage.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				if (ListenerPool.faceAddClick) {
					callbackEmpty();
				}
			}
		});

		return addFaceImage;
	}

	public void callbackEmpty() {
		if (appendFaceContext == null) {
			return;
		}
		JSONObject ret = new JSONObject();
		appendFaceContext.success(ret, false);
	}

	public View createBasicFacePanel(ViewGroup container, ArrayList<BasicEmotion> basicEmotios) {
		if (basicEmotios == null) {
			return null;
		}
		int width = RelativeLayout.LayoutParams.MATCH_PARENT;
		int height = RelativeLayout.LayoutParams.MATCH_PARENT;
		RelativeLayout.LayoutParams svParams = new RelativeLayout.LayoutParams(width, height);
		// svParams.addRule(RelativeLayout.ABOVE, tabLayoutId);
		ScrollView sv = new ScrollView(context());
		
		sv.setLayoutParams(svParams);
		FacePanel panel = new FacePanel(context(), mEmojiSelectedListener);
		sv.addView(panel);

		for (int i = 0; i < basicEmotios.size(); i++) {
			BasicEmotion emotionItem = basicEmotios.get(i);
			panel.addItem(emotionItem.label, emotionItem.faceItems);
		}
		
		return sv;

//		if (container.getChildCount() == 3) {
//			container.removeViewAt(2);
//		}
//		container.addView(sv);
	}

	public View createAppendedFacePanel(ViewGroup container, ArrayList<FaceItem> faceItems, int tabLayoutId) {
		if (faceItems == null) {
			return null;
		}

		FacePanel facePanel = new FacePanel(context(), mEmojiSelectedListener);
		int width = RelativeLayout.LayoutParams.MATCH_PARENT;
		int height = RelativeLayout.LayoutParams.MATCH_PARENT;
		RelativeLayout.LayoutParams gridParams = new RelativeLayout.LayoutParams(width, height);
		gridParams.addRule(RelativeLayout.ABOVE, tabLayoutId);
		facePanel.setLayoutParams(gridParams);
		facePanel.addItem(faceItems);

//		container.removeViewAt(2);
//		container.addView(facePanel);
		
		return facePanel;
	}

	public String getTabIconPath(UZModuleContext uzContext, String path) {
		if (TextUtils.isEmpty(path)) {
			return null;
		}
		int index = path.lastIndexOf("/") + 1;
		String iconName = path.substring(index);
		return uzContext.makeRealPath(path + '/' + iconName + ".png");
	}

	private AppendedPanel mAppendPanel;

	// ============= setAppendButton ================
	public void jsmethod_setAppendButton(final UZModuleContext uzContext) {
		AppendedConfig config = new AppendedConfig(uzContext);
		mAppendPanel = new AppendedPanel(context(), config);
		mAppendPanel.setOnAppendPanelItemClickListener(new OnAppendPanelItemClickListener() {
			@Override
			public void onItemClick(int index) {
				callbackForAppend(uzContext, index);
			}
		});
	}

	public void callbackForAppend(UZModuleContext uzContext, int index) {
		JSONObject ret = new JSONObject();
		try {
			ret.put("index", index);
			uzContext.success(ret, false);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	private UZModuleContext faceListenerContext;
	private UZModuleContext appendFaceContext;

	// ============= faceListener ===================
	public void jsmethod_faceListener(UZModuleContext uzContext) {

		if ("face".equals(uzContext.optString("name"))) {
			this.faceListenerContext = uzContext;
			ListenerPool.faceItemClick = true;
		}
		if ("appendFace".equals(uzContext.optString("name"))) {
			this.appendFaceContext = uzContext;
			ListenerPool.faceAddClick = true;
		}
	}

	// ============ addFace ====================
	public void jsmethod_addFace(final UZModuleContext uzContext) {
		String path = uzContext.optString("path");
		if (mConfig != null && !TextUtils.isEmpty(path)) {
			mConfig.emotionsPathArray.add(path);
			callback(uzContext, true);
		} else {
			callback(uzContext, false);
		}
	}

	public void callback(UZModuleContext uzContext, boolean status) {
		JSONObject ret = new JSONObject();
		try {
			ret.put("status", status);
			uzContext.success(ret, false);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	// =========== imageListener ==============
	public void jsmethod_imageListener(final UZModuleContext uzContext) {

		ImageSelectPanel.setOnImagePanelListener(new OnImagePanelListener() {

			@Override
			public void onSendClick(ArrayList<String> result) {
				callbackForImageListener(uzContext, "send", result);
			}

			@Override
			public void onEditClick(ArrayList<String> result) {
				callbackForImageListener(uzContext, "edit", result);
			}

			@Override
			public void onAlbumClick() {
				callbackForImageListener(uzContext, "album", null);
			}
		});

	}

	public void callbackForImageListener(UZModuleContext uzContext, String eventType, ArrayList<String> result) {
		JSONObject ret = new JSONObject();
		try {
			ret.put("eventType", eventType);
		} catch (JSONException e1) {
			e1.printStackTrace();
		}
		if (result != null) {
			JSONArray images = new JSONArray();
			for (int i = 0; i < result.size(); i++) {
				images.put(result.get(i));
			}
			try {
				ret.put("images", images);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		uzContext.success(ret, false);
	}

	// ========== toolsListener ==============
	public void jsmethod_toolsListener(final UZModuleContext uzContext) {
		setOnToolBarListener(new OnToolBarListener() {

			@Override
			public void onVideoClick() {
				callbackToolBar(uzContext, "video");
			}

			@Override
			public void onRecordClick() {
				callbackToolBar(uzContext, "recorder");
			}

			@Override
			public void onPacketClick() {
				callbackToolBar(uzContext, "packet");
			}

			@Override
			public void onImageClick() {
				callbackToolBar(uzContext, "image");
			}

			@Override
			public void onFaceClick() {
				callbackToolBar(uzContext, "face");
			}

			@Override
			public void onAppendClick() {
				callbackToolBar(uzContext, "append");
			}
		});
	}

	public void callbackToolBar(UZModuleContext uzContext, String eventType) {
		JSONObject ret = new JSONObject();
		try {
			ret.put("eventType", eventType);
			uzContext.success(ret, false);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	// ============ recorderListener =============
	public void jsmethod_recorderListener(UZModuleContext uzContext) {
		VoiceRecordPanel.setCallbackContext(uzContext);
	}

	// ============ startTimer ==============
	public void jsmethod_startTimer(UZModuleContext uzContext) {
		if (mRecordPanel != null) {
			mRecordPanel.getCurrentComponent().startTimer();
		}
	}

	// ============ close =================
	public void jsmethod_close(UZModuleContext uzContext) {
		removeViewFromCurWindow(mChatBoxToolbar);
		mChatBoxToolbar = null;
	}

	public void jsmethod_show(UZModuleContext uzContext) {
		if (mChatBoxToolbar != null) {
			mChatBoxToolbar.setVisibility(View.VISIBLE);
		}
	}

	public void jsmethod_hide(UZModuleContext uzContext) {
		if (mChatBoxToolbar != null) {
			mChatBoxToolbar.setVisibility(View.GONE);
		}
	}

	public void showSoftInputFromWindow(Context context, EditText editText) {
		editText.setFocusable(true);
		editText.setFocusableInTouchMode(true);
		editText.requestFocus();
		((Activity) context()).getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE);
	}

	public void jsmethod_popupKeyboard(UZModuleContext uzContext) {
		if (mInputEdit != null) {
			new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
				@Override
				public void run() {
					mInputEdit.setFocusable(true);
					mInputEdit.setFocusableInTouchMode(true);
					mInputEdit.requestFocus();
					((Activity)context()).getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE);
					showSoftInputKeyBoard(mInputEdit);
				}
			}, 500);
		}
	}

	public void jsmethod_closeKeyboard(UZModuleContext uzContext) {
		hideSoftInputKeyBoard(mInputEdit);
	}

	public void jsmethod_popupBoard(UZModuleContext uzContext) {
		if (mConfig == null) {
			return;
		}
		if ("emotion".equals(uzContext.optString("target"))) {
			showFacePanel(uzContext, mConfig);
		}
		if ("extras".equals(uzContext.optString("target")) && mAppendPanel != null) {
			addAppendPanel();
		}
	}

	public void jsmethod_closeBoard(UZModuleContext uzContext) {
		hideShowPanel();
	}

	public void jsmethod_value(UZModuleContext uzContext) {
		
		if (mInputEdit == null) {
			callbackForValue(uzContext, false, null);
			return;
		}
		
		if(uzContext.isNull("msg")){
			callbackForValue(uzContext, true, mInputEdit.getText().toString());
			return;
		} else {
			mInputEdit.setText(uzContext.optString("msg"));
			callbackForValue(uzContext, true, null);
		}
	}

	public void callbackForValue(UZModuleContext uzContext, boolean status, String msg) {
		JSONObject ret = new JSONObject();
		try {
			ret.put("status", status);
			ret.put("msg", msg);
		} catch (JSONException e) {
			e.printStackTrace();
		}

		uzContext.success(ret, false);
	}

	public void jsmethod_insertValue(UZModuleContext uzContext) {
		int index = uzContext.optInt("index");
		String msg = uzContext.optString("msg");

		if (!TextUtils.isEmpty(msg) && mInputEdit != null) {
			String inputTxt = mInputEdit.getText().toString();
			if (index >= inputTxt.length()) {
				mInputEdit.setText(inputTxt + msg);
			} else {
				String before = inputTxt.substring(0, index);
				String after = inputTxt.substring(index, inputTxt.length());
				mInputEdit.setText(before + msg + after);
			}
		}
	}
	
	private UZModuleContext mValueChangeCallback;
	private UZModuleContext mMoveCallback;
	private UZModuleContext mChangeCallback;
	
	private int mKeyBoardHeight;

	private boolean cb_flag = false;
	@SuppressLint("NewApi")
	public void jsmethod_chatBoxListener(final UZModuleContext uzContext) {
		
		if ("valueChanged".equals(uzContext.optString("name")) && mInputEdit != null) {
			mValueChangeCallback = uzContext;
		}
		
		if("change".equals(uzContext.optString("name"))){
			mChangeCallback = uzContext;
		}
		
		if("move".equals(uzContext.optString("name"))){
			mMoveCallback = uzContext;
		}
		
//		mInputEdit.setOnEditorActionListener(new OnEditorActionListener() {
//			
//			@Override
//			public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
//				 int keyCode = event.getKeyCode();
//				 if ( keyCode == KeyEvent.KEYCODE_ENTER) {  
//					 if(mChangeCallback != null){
//							int chatBoxLayoutId = UZResourcesIDFinder.getResIdID("chatBoxLayoutId");
//							View chatBoxLayout = mChatBoxToolbar.findViewById(chatBoxLayoutId);
//							if(chatBoxLayout != null){
//								int chatboxHeight = UZCoreUtil.pixToDip(chatBoxLayout.getMeasuredHeight());
//								callbackForChatBoxMove(mChangeCallback, chatboxHeight, UZCoreUtil.pixToDip(mKeyBoardHeight));
//							}
//						}
//	                return false;  
//	            }  
//				return false;
//			}
//		});
		
		int chatBoxLayoutId = UZResourcesIDFinder.getResIdID("chatBoxLayoutId");
		View chatBoxLayout = mChatBoxToolbar.findViewById(chatBoxLayoutId);
		chatBoxLayout.addOnLayoutChangeListener(new OnLayoutChangeListener() {
			
			@Override
			public void onLayoutChange(View v, int left, int top, int right, int bottom, int oldLeft, int oldTop, int oldRight, int oldBottom) {
				if((bottom - top) != (oldBottom - oldTop)){ // 只有高度发生变化的时候回调 -.-
					if(cb_flag){  // 只回调一次
						return;
					}
					cb_flag = true;
					int chatBoxLayoutId = UZResourcesIDFinder.getResIdID("chatBoxLayoutId");
					final View chatBoxLayout = mChatBoxToolbar.findViewById(chatBoxLayoutId);
					if(chatBoxLayout != null && mChangeCallback != null){
						new Handler(Looper.getMainLooper()).postDelayed(new Runnable(){
							@Override
							public void run() {
								int chatboxHeight = UZCoreUtil.pixToDip(chatBoxLayout.getMeasuredHeight());
								callbackForChatBoxChange(mChangeCallback, chatboxHeight, UZCoreUtil.pixToDip(mKeyBoardHeight));
								cb_flag = false;
							}
							
						}, 100);
					}
				}
			}
		});
		
		mInputEdit.addTextChangedListener(new TextWatcher() {
			@Override
			public void onTextChanged(CharSequence s, int start, int before, int count) {
				if(mValueChangeCallback != null){
					callbackForChatBox(mValueChangeCallback, s.toString());
				}
			}
			
			@Override
			public void beforeTextChanged(CharSequence s, int start, int count, int after) {
				
			}

			@Override
			public void afterTextChanged(Editable s) {
				
			}
		});
		
		addOnSoftKeyBoardVisibleListener((Activity)context(), new IKeyBoardVisibleListener() {
			@Override
			public void onSoftKeyBoardVisible(boolean visible, int windowBottom) {
				mKeyBoardHeight = windowBottom;
				if(mMoveCallback != null && mChatBoxToolbar != null){
					int chatBoxLayoutId = UZResourcesIDFinder.getResIdID("chatBoxLayoutId");
					View chatBoxLayout = mChatBoxToolbar.findViewById(chatBoxLayoutId);
					if(chatBoxLayout != null){
						int chatboxHeight = UZCoreUtil.pixToDip(chatBoxLayout.getMeasuredHeight());
						callbackForChatBoxMove(mMoveCallback, chatboxHeight, UZCoreUtil.pixToDip(windowBottom));
					}
				}
			}
		});
	}
	
	public void callbackForChatBox(UZModuleContext uzContext, String value) {
		JSONObject ret = new JSONObject();
		try {
			ret.put("value", value);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		uzContext.success(ret, false);
	}
	
	public void callbackForChatBoxChange(UZModuleContext uzContext, int chatBoxHeight, int panelHeight){
		JSONObject ret = new JSONObject();
		try {
			ret.put("chatBoxHeight", chatBoxHeight);
			ret.put("panelHeight", panelHeight);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		uzContext.success(ret, false);
	}
	
	public void callbackForChatBoxMove(UZModuleContext uzContext, int chatBoxHeight, int panelHeight){
		JSONObject ret = new JSONObject();
		try {
			ret.put("chatBoxHeight", chatBoxHeight);
			ret.put("panelHeight", panelHeight);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		uzContext.success(ret, false);
	}

	public void jsmethod_setPlaceholder(UZModuleContext uzContext) {
		if (mInputEdit != null) {
			String placeholder = uzContext.optString("placeholder");
			if (TextUtils.isEmpty(placeholder)) {
				mInputEdit.setHint("");
			} else {
				mInputEdit.setHint(placeholder);
			}
		}
	}
	
	public void jsmethod_clearText(UZModuleContext uzContext){
		if(mInputEdit != null){
			mInputEdit.setText("");
		}
	}

	public void showSoftInputKeyBoard(EditText inputField) {
		if (inputField == null) {
			return;
		}
		InputMethodManager imm = (InputMethodManager) inputField.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
		imm.showSoftInput(inputField, 0);
	}

	public void hideSoftInputKeyBoard(EditText inputField) {
		if (inputField == null) {
			return;
		}
		InputMethodManager imm = (InputMethodManager) inputField.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
		if (imm.isActive()) {
			imm.hideSoftInputFromWindow(inputField.getApplicationWindowToken(), 0);
		}
	}

	public interface OnToolBarListener {
		public void onRecordClick();

		public void onImageClick();

		public void onVideoClick();

		public void onPacketClick();

		public void onFaceClick();

		public void onAppendClick();
	}

	public OnToolBarListener mOnToolBarListener;

	public void setOnToolBarListener(OnToolBarListener mListener) {
		this.mOnToolBarListener = mListener;
	}
	
	public String getFaceTextByFacePath(Config config, String path){
		ArrayList<BasicEmotion> basicEmotions = config.parseBasicEmotion();
		for(int i=0; i<basicEmotions.size(); i++){
			BasicEmotion basicEmotion = basicEmotions.get(i);
			ArrayList<FaceItem> faceItems = basicEmotion.faceItems;
			for(int j=0; j<faceItems.size(); j++){
				if(!TextUtils.isEmpty(faceItems.get(j).facePath)
						&& faceItems.get(j).facePath.equals(path)){
					return faceItems.get(j).faceText;
				}
			}
		}
		
		ArrayList<ArrayList<FaceItem>> emotions = config.parseAllAppendEmotions();
		for(int i=0; i<emotions.size(); i++){
			for(int j=0; j<emotions.get(i).size(); j++){
				ArrayList<FaceItem> items =  emotions.get(i);
				for(int k=0; k<items.size(); k++){
					if(!TextUtils.isEmpty(items.get(j).facePath)
							&& items.get(j).facePath.equals(path)){
						return items.get(j).faceText;
					}
				}
			}
		}
		return null;
	}
	
	public interface IKeyBoardVisibleListener{  
        void onSoftKeyBoardVisible(boolean visible , int windowBottom);  
    }  
    boolean isVisiableForLast = false;  
    public void addOnSoftKeyBoardVisibleListener(Activity activity, final IKeyBoardVisibleListener listener) {  
        final View decorView = activity.getWindow().getDecorView();  
        decorView.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {  
            @Override  
            public void onGlobalLayout() {  
                Rect rect = new Rect();  
                decorView.getWindowVisibleDisplayFrame(rect);  
                int displayHight = rect.bottom - rect.top;
                int hight = decorView.getHeight();  
                int keyboardHeight = hight-displayHight;  
                boolean visible = (double) displayHight / hight < 0.8; 
                if(visible != isVisiableForLast){  
                    listener.onSoftKeyBoardVisible(visible,keyboardHeight);  
                }  
                isVisiableForLast = visible; 
            }  
        });  
    }
}
