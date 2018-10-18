/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package me.nereo.multi_image_selector;

import java.util.List;
import me.nereo.multi_image_selector.adapter.ImageGridAdapter;
import me.nereo.multi_image_selector.bean.Image;
import me.nereo.multi_image_selector.utils.ResUtils;
import me.nereo.multi_image_selector.utils.Utils;
import me.nereo.multi_image_selector.view.largeImage.LargeImageView;
import me.nereo.multi_image_selector.view.largeImage.factory.FileBitmapDecoderFactory;

import com.apicloud.UIAlbumBrowser.UIAlbumBrowser;
import com.uzmap.pkg.uzcore.UZResourcesIDFinder;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

public class MultiImageSelectorPreviewActivity extends Activity{
	
	private TextView pageIndicator;
	private ImageView selectorIndicator;
	
	public static int IMAGE_MARGIN = 5;
	
	private int currentPosition = 0;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		requestWindowFeature(Window.FEATURE_NO_TITLE);    
	    getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,  
	                WindowManager.LayoutParams.FLAG_FULLSCREEN);  
		
		int previewPagerId = UZResourcesIDFinder.getResLayoutID("mis_preview_layout");
		setContentView(previewPagerId);
		
		int viewPagerId = UZResourcesIDFinder.getResIdID("previewPager");
		
		ViewPager viewPager = (ViewPager)findViewById(viewPagerId);
		
		viewPager.setOffscreenPageLimit(3);
		
		PreviewPagerAdapter pagerAdapter = new PreviewPagerAdapter(this, MultiImageSelectorFragment.currentImages);
		viewPager.setAdapter(pagerAdapter);
		
		configView(viewPager);
		setPageChangeListener(viewPager);
	}
	
	
	public void updateView(int position){
		if(ImageGridAdapter.mSelectedImages.contains(MultiImageSelectorFragment.currentImages.get(position))){
			int selectedDrawableId = UZResourcesIDFinder.getResDrawableID("mis_preview_image_selected");
			selectorIndicator.setImageResource(selectedDrawableId);
		} else {
			int unselectedDrawableId = UZResourcesIDFinder.getResDrawableID("mis_preview_image_unselected");
			selectorIndicator.setImageResource(unselectedDrawableId);
		}
	}
	
	public void configView(ViewPager viewPager){
		
		Intent intent = getIntent();
		int position = intent.getIntExtra("position", 0);
		
/*		boolean isShowCamera = intent.getBooleanExtra("isShowCamera", false);
		if(isShowCamera){
			position -= 1;
		}
*/		
		viewPager.setCurrentItem(position);
		
		final int maxCount = intent.getIntExtra("maxCount", 9);
		
		currentPosition = position;
		
		int pageIndicatorId = UZResourcesIDFinder.getResIdID("pageIndicator");
		pageIndicator = (TextView)findViewById(pageIndicatorId);
		pageIndicator.setText((position + 1) + "/" + MultiImageSelectorFragment.currentImages.size());
		
		int selectedIndicatorImgId = UZResourcesIDFinder.getResIdID("selectedIndicatorImg");
		selectorIndicator = (ImageView)findViewById(selectedIndicatorImgId);
		if(ImageGridAdapter.mSelectedImages.contains(MultiImageSelectorFragment.currentImages.get(position))){
			int selectedDrawableId = UZResourcesIDFinder.getResDrawableID("mis_preview_image_selected");
			selectorIndicator.setImageResource(selectedDrawableId);
		} else {
			int selectedDrawableId = UZResourcesIDFinder.getResDrawableID("mis_preview_image_unselected");
			selectorIndicator.setImageResource(selectedDrawableId);
		}
		
		selectorIndicator.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View arg0) {
				
				
				if(ImageGridAdapter.mSelectedImages.size() > 0 
						&& !UIAlbumBrowser.config.selectedAll
						&& ImageGridAdapter.mSelectedImages.get(0).isVideo){
					Utils.showToast(MultiImageSelectorPreviewActivity.this, "只能选一个视频");
					return;
				}
				
				if(ImageGridAdapter.mSelectedImages.size() > 0 && !UIAlbumBrowser.config.selectedAll){
					
					Image currentImage = MultiImageSelectorFragment.currentImages.get(currentPosition);
					Image firstSelectedImage = ImageGridAdapter.mSelectedImages.get(0);
					
					if(currentImage.isVideo && !firstSelectedImage.isVideo){
						Utils.showToast(MultiImageSelectorPreviewActivity.this, MultiImageSelectorFragment.SELECTED_FORBID);
						return;
					}
					if(!currentImage.isVideo && firstSelectedImage.isVideo){
						Utils.showToast(MultiImageSelectorPreviewActivity.this, MultiImageSelectorFragment.SELECTED_FORBID);
						return;
					}
				}
				
				if(ImageGridAdapter.mSelectedImages.contains(MultiImageSelectorFragment.currentImages.get(currentPosition))){
					
					ImageGridAdapter.mSelectedImages.remove(MultiImageSelectorFragment.currentImages.get(currentPosition));
					int selectedDrawableId = UZResourcesIDFinder.getResDrawableID("mis_preview_image_unselected");
					selectorIndicator.setImageResource(selectedDrawableId);
				} else {
					
					if(ImageGridAdapter.mSelectedImages.size() >= maxCount ){
						int mis_msg_amount_limit_id = ResUtils.getInstance().getStringId(MultiImageSelectorPreviewActivity.this, "mis_msg_amount_limit");
						Toast.makeText(MultiImageSelectorPreviewActivity.this, mis_msg_amount_limit_id, Toast.LENGTH_SHORT).show();
						return;
					}
					ImageGridAdapter.mSelectedImages.add(MultiImageSelectorFragment.currentImages.get(currentPosition));
					int selectedDrawableId = UZResourcesIDFinder.getResDrawableID("mis_preview_image_selected");
					selectorIndicator.setImageResource(selectedDrawableId);
				}
			}
		});
		
		int backImgId = UZResourcesIDFinder.getResIdID("backImg");
		ImageView backImg = (ImageView)findViewById(backImgId);
		backImg.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				MultiImageSelectorPreviewActivity.this.finish();
			}
		});
	}
	
	@SuppressWarnings("deprecation")
	public void setPageChangeListener(ViewPager viewPager){
		viewPager.setOnPageChangeListener(new OnPageChangeListener() {
			
			@Override
			public void onPageSelected(int arg0) {
				pageIndicator.setText((arg0 + 1) + "/" + MultiImageSelectorFragment.currentImages.size());
				updateView(arg0);
				
				currentPosition = arg0;
				
				if(MultiImageSelectorFragment.currentImages.get(currentPosition).isVideo){
					Utils.showToast(MultiImageSelectorPreviewActivity.this, "暂不支持视频预览");
				}
			}
			
			@Override
			public void onPageScrolled(int arg0, float arg1, int arg2) {}
			
			@Override
			public void onPageScrollStateChanged(int arg0) {}
		});
	}
	
	public void showOrHideTitle(){
		int titleId = UZResourcesIDFinder.getResIdID("title");
		View titleView = findViewById(titleId);
		if(titleView.getVisibility() == View.VISIBLE){
			titleView.setVisibility(View.GONE);
		} else {
			titleView.setVisibility(View.VISIBLE);
		}
	}
	
	class PreviewPagerAdapter extends PagerAdapter{
		
		private List<Image> images;
		private Context mContext;
		
		public PreviewPagerAdapter(Context context, List<Image> images){
			this.images = images;
			this.mContext = context;
		}

		@Override
		public int getCount() {
			return images.size();
		}

		@Override
		public boolean isViewFromObject(View arg0, Object arg1) {
			return arg0 == arg1;
		}

		@Override
		public Object instantiateItem(ViewGroup container, int position) {
			
			
			int mis_preview_layout_id = UZResourcesIDFinder.getResLayoutID("mis_preview_pager_layout");
			View imageContainer = View.inflate(mContext, mis_preview_layout_id, null);
			
			int largeImageId = UZResourcesIDFinder.getResIdID("largeImage");
			LargeImageView largeImageView = (LargeImageView)imageContainer.findViewById(largeImageId);
			
		
			container.addView(imageContainer);
			largeImageView.setImage(new FileBitmapDecoderFactory(images.get(position).path));
			
			largeImageView.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					// TODO Auto-generated method stub
					showOrHideTitle();
				}
			});
			return imageContainer;
		}
		
		@Override
		public void destroyItem(ViewGroup container, int position, Object object) {
			container.removeView((View) object);
		}
	}
}
