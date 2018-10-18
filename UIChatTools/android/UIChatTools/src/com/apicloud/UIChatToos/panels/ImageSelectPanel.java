/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.UIChatToos.panels;

import java.util.ArrayList;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView.ScaleType;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.apicloud.UIChatToos.utils.FileInfo;
import com.apicloud.UIChatToos.utils.SortUtils;
import com.apicloud.UIChatToos.utils.Util;
import com.apicloud.UIChatToos.widgets.SelectedImage;
import com.apicloud.UIChatToos.widgets.SelectedImage.OnImageSelectedListener;
import com.uzmap.pkg.uzcore.UZResourcesIDFinder;
import com.uzmap.pkg.uzkit.UZUtility;

public class ImageSelectPanel extends RelativeLayout {

	public ImageSelectPanel(Context context) {
		super(context);
		initView();
	}

	private ArrayList<SelectedImage> images = new ArrayList<SelectedImage>();
	private ArrayList<Bitmap> bmps = new ArrayList<Bitmap>();
	private static final int SHOW_LIMIT = 30;

	private ArrayList<String> selectedPaths = new ArrayList<String>();

	public void initView() {

		int selectedPanelId = UZResourcesIDFinder.getResLayoutID("uichattools_imageselectpanel_layout");
		View selectedPanel = View.inflate(getContext(), selectedPanelId, null);

		// ========== album ===========
		int albumTextId = UZResourcesIDFinder.getResIdID("albumTxt");
		TextView albumText = (TextView) selectedPanel.findViewById(albumTextId);
		albumText.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				if (mOnImagePanelListener != null) {
					mOnImagePanelListener.onAlbumClick();
				}
			}
		});

		// ========== edit =============
		int editTextId = UZResourcesIDFinder.getResIdID("editTxt");
		TextView editText = (TextView) selectedPanel.findViewById(editTextId);
		editText.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				if (mOnImagePanelListener != null) {
					mOnImagePanelListener.onEditClick(selectedPaths);
				}
			}
		});

		// ========== send button ===========
		int sendBtnId = UZResourcesIDFinder.getResIdID("sendBtn");
		Button sendBtn = (Button) selectedPanel.findViewById(sendBtnId);
		sendBtn.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				if (mOnImagePanelListener != null) {
					mOnImagePanelListener.onSendClick(selectedPaths);
				}
			}
		});

		int imagesPanelId = UZResourcesIDFinder.getResIdID("imagesPanel");
		final LinearLayout imagePanel = (LinearLayout) selectedPanel.findViewById(imagesPanelId);

		new Thread(new LoadViewTask(imagePanel)).start();

		this.addView(selectedPanel);
	}

	public static void setOnImagePanelListener(OnImagePanelListener mListener) {
		mOnImagePanelListener = mListener;
	}

	public static OnImagePanelListener mOnImagePanelListener;

	public interface OnImagePanelListener {
		public void onAlbumClick();

		public void onEditClick(ArrayList<String> result);
		public void onSendClick(ArrayList<String> result);
	}

	public void setListener(final SelectedImage image) {
		image.setOnImageSelectedListener(new OnImageSelectedListener() {
			@Override
			public void onImageSelected(boolean isSelected) {
				if (isSelected) {
					selectedPaths.add((String) image.getTag());
					image.setNumCount(selectedPaths.size());
				} else {
					selectedPaths.remove((String) image.getTag());
					image.setNumCount(-1);
					updateNums();
				}
			}
		});
	}

	public void updateNums() {
		for (SelectedImage image : images) {
			if (image.getNums() >= 0) {
				image.setNumCount(image.getNums() - 1);
			}
		}
	}

	public class LoadViewTask implements Runnable {

		private ViewGroup mContainer;

		public LoadViewTask(ViewGroup container) {
			this.mContainer = container;
		}

		@Override
		public void run() {
			ArrayList<FileInfo> imageList = null;
			try {
				imageList = Util.listAlldirForFileList(getContext(), Util.IMAGE_TYPE);
				SortUtils.dascSortByTime(imageList);
			} catch (Exception e) {
				e.printStackTrace();
				return;
			}

			for (int i = 0; i < SHOW_LIMIT; i++) {

				final SelectedImage imageView = new SelectedImage(getContext());

				if (i < imageList.size()) {

					imageView.setTag(imageList.get(i).path);
					images.add(imageView);

					Bitmap bmp = Util.getBitmap(imageList.get(i).thumbImgPath);
					if (bmp == null) {
						BitmapFactory.Options newOpts = new BitmapFactory.Options();
						newOpts.inSampleSize = 4;
						bmp = BitmapFactory.decodeFile(imageList.get(i).path, newOpts);
						// bmp = ThumbnailUtils.extractThumbnail(bmp, UZUtility.dipToPix(108), UZUtility.dipToPix(192));
					}
					bmps.add(bmp);

					final int index = i;
					new Handler(Looper.getMainLooper()).post(new Runnable() {
						@Override
						public void run() {
							imageView.setScaleType(ScaleType.CENTER_CROP);
							LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(UZUtility.dipToPix(200), LinearLayout.LayoutParams.MATCH_PARENT);
							imageView.setLayoutParams(params);
							imageView.setImageBitmap(bmps.get(index));
							mContainer.addView(imageView);

							setListener(imageView);
							int padding = UZUtility.dipToPix(5);
							imageView.setPadding(padding, 0, padding, 0);
						}
					});
				}
			}
		}
	}
}
