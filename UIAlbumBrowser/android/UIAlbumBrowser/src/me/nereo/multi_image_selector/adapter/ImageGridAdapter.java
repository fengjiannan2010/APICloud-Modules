/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package me.nereo.multi_image_selector.adapter;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.os.Build;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.BaseAdapter;
import android.widget.FrameLayout;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.Toast;
import android.widget.ImageView.ScaleType;
import android.widget.TextView;

import com.apicloud.UIAlbumBrowser.UIAlbumBrowser;
import com.bumptech.glide.Glide;

import com.uzmap.pkg.uzcore.UZResourcesIDFinder;
import com.uzmap.pkg.uzkit.UZUtility;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import me.nereo.multi_image_selector.bean.Image;
import me.nereo.multi_image_selector.utils.ResUtils;
import me.nereo.multi_image_selector.utils.Utils;
import me.nereo.multi_image_selector.view.SquaredImageView;
import me.nereo.multi_image_selector.view.SquaredImageView.OnClickListener;

/**
 * 图片Adapter
 * Created by Nereo on 2015/4/7.
 * Updated by nereo on 2016/1/19.
 */
public class ImageGridAdapter extends BaseAdapter {

    private static final int TYPE_CAMERA = 0;
    private static final int TYPE_NORMAL = 1;

    private Context mContext;

    private LayoutInflater mInflater;
    private boolean showCamera = true;
    private boolean showSelectIndicator = true;
    
    private boolean isShowPreview = false;

    private List<Image> mImages = new ArrayList<Image>();
    public static List<Image> mSelectedImages = new ArrayList<Image>();

    final int mGridWidth;
    private GridView mGridView;

    @SuppressWarnings("deprecation")
	public ImageGridAdapter(Context context, GridView gridView, boolean showCamera, int column){
        mContext = context;
        this.mGridView = gridView;
        
        mInflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        this.showCamera = showCamera;
        WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        int width = 0;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB_MR2) {
            Point size = new Point();
            wm.getDefaultDisplay().getSize(size);
            width = size.x;
        }else{
            width = wm.getDefaultDisplay().getWidth();
        }
        mGridWidth = width / column;
    }
    /**
     * 显示选择指示器
     * @param b
     */
    public void showSelectIndicator(boolean b) {
        showSelectIndicator = b;
    }

    public void setShowCamera(boolean b){
        if(showCamera == b) return;

        showCamera = b;
        notifyDataSetChanged();
    }

    public boolean isShowCamera(){
        return showCamera;
    }
    
    public void setShowPreview(boolean isShowPreview){
    	this.isShowPreview = isShowPreview;
    }

    /**
     * 选择某个图片，改变选择状态
     * @param image
     */
    public void select(Image image, int count) {
    	if(mSelectedImages.size() == count && !mSelectedImages.contains(image)){
    		int mis_msg_amount_limit_id = ResUtils.getInstance().getStringId(mContext, "mis_msg_amount_limit");
			Toast.makeText(mContext, mis_msg_amount_limit_id, Toast.LENGTH_SHORT).show();
    		return;
    	}
        if(mSelectedImages.contains(image)){
            mSelectedImages.remove(image);
        }else{
            mSelectedImages.add(image);
        }
        notifyDataSetChanged();
    }

    /**
     * 通过图片路径设置默认选择
     * @param resultList
     */
    public void setDefaultSelected(ArrayList<String> resultList) {
        for(String path : resultList){
            Image image = getImageByPath(path);
            if(image != null){
                mSelectedImages.add(image);
            }
        }
        if(mSelectedImages.size() > 0){
            notifyDataSetChanged();
        }
    }

    private Image getImageByPath(String path){
        if(mImages != null && mImages.size()>0){
            for(Image image : mImages){
                if(image.path.equalsIgnoreCase(path)){
                    return image;
                }
            }
        }
        return null;
    }

    /**
     * 设置数据集
     * @param images
     */
    public void setData(List<Image> images) {
        mSelectedImages.clear();

        if(images != null && images.size()>0){
            mImages = images;
        }else{
            mImages.clear();
        }
        notifyDataSetChanged();
    }
    
    public List<Image> getData(){
    	return mImages;
    }

    @Override
    public int getViewTypeCount() {
        return 2;
    }

    @Override
    public int getItemViewType(int position) {
        if(showCamera){
            return position == 0 ? TYPE_CAMERA : TYPE_NORMAL;
        }
        return TYPE_NORMAL;
    }

    @Override
    public int getCount() {
        return showCamera ? mImages.size()+1 : mImages.size();
    }

    @Override
    public Image getItem(int i) {
        if(showCamera){
            if(i == 0){
                return null;
            }
            return mImages.get(i-1);
        }else{
            return mImages.get(i);
        }
    }
    
    @Override
    public long getItemId(int i) {
        return i;
    }
    
    @Override
    public View getView(int i, View view, ViewGroup viewGroup) {

        if(isShowCamera()){
            if(i == 0){
                int mis_list_item_camera_id = ResUtils.getInstance().getLayoutId(mContext, "mis_list_item_camera");
                view = mInflater.inflate(mis_list_item_camera_id, viewGroup, false);
                if(UIAlbumBrowser.mUZModuleContext != null 
                		&& UIAlbumBrowser.config != null){
                	int takePhotoId = UZResourcesIDFinder.getResIdID("takePhoto");
                	ImageView takePhotoImage = (ImageView)view.findViewById(takePhotoId);
                	String cameraImagePath = UIAlbumBrowser.mUZModuleContext.makeRealPath(UIAlbumBrowser.config.cameraImgPath);
                	Bitmap bmp = UZUtility.getLocalImage(cameraImagePath);
                	takePhotoImage.setScaleType(ScaleType.FIT_XY);
                	if(bmp != null){
                		takePhotoImage.setImageBitmap(bmp);
                	}
                }
                view.setOnClickListener(new View.OnClickListener() {
					@Override
					public void onClick(View arg0) {
						if(mOnItemClickListener != null){
							mOnItemClickListener.onCameraClick();
						}
					}
				});
                return view;
            }
        }

        ViewHolder holder;
        if(view == null){
            int mis_list_item_image_id = ResUtils.getInstance().getLayoutId(mContext, "mis_list_item_image");
            view = mInflater.inflate(mis_list_item_image_id, viewGroup, false);
            holder = new ViewHolder(view);
        } else {
            holder = (ViewHolder) view.getTag();
        }

        if(holder != null) {
            holder.bindData(getItem(i));
        }
        
        final int position = i;
        
        if(mOnItemClickListener != null && isShowPreview){
        	holder.indicator.setOnClickListener(new View.OnClickListener() {
				@Override
				public void onClick(View arg0) {
					mOnItemClickListener.onItemClick(mGridView, position);
				}
			});
        	
//        	holder.image.setOnClickListener(new View.OnClickListener() {
//				@Override
//				public void onClick(View arg0) {
//					mOnItemClickListener.gotoPreview(position);
//				}
//			});
        	((SquaredImageView)holder.image).setTouchEnable(true);
        	((SquaredImageView)holder.image).setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClickCorner() {
					mOnItemClickListener.onItemClick(mGridView, position);
				}
				
				@Override
				public void onClick() {
					mOnItemClickListener.gotoPreview(position);
				}
			}, UIAlbumBrowser.config.markPosition);
        }
        
        if(getItem(i).isVideo){
    	   holder.timeLabel.setText(Utils.time2Str((int)getItem(i).duration / 1000));
    	   holder.timeLabel.setVisibility(View.VISIBLE);
        } else {
           holder.timeLabel.setVisibility(View.GONE);
        }
        
        return view;
    }
    
    public interface OnItemClickListener{
    	void onItemClick(GridView gridView, int position);
    	void gotoPreview(int position);
    	void onCameraClick();
    }
    
    private OnItemClickListener mOnItemClickListener;
    public void setOnItemClickListener(OnItemClickListener onItemClickListener){
    	this.mOnItemClickListener = onItemClickListener;
    }

    class ViewHolder {
        ImageView image;
        ImageView indicator;
        View mask;
        
        TextView timeLabel;

        ViewHolder(View view){
            int image_id = ResUtils.getInstance().getViewId(mContext, "image");
            image = (ImageView) view.findViewById(image_id);

            int checkmark_id = ResUtils.getInstance().getViewId(mContext, "checkmark");
            indicator = (ImageView) view.findViewById(checkmark_id);
            
            int timeLabel_id = ResUtils.getInstance().getViewId(mContext, "timeLabel");
            timeLabel = (TextView) view.findViewById(timeLabel_id);
            
            // ==========================
            
            // top_left（左上角）
            // bottom_left（左下角）
            // top_right（右上角）
            // bottom_right（右下角）
            
           FrameLayout.LayoutParams checkmarkParams = (FrameLayout.LayoutParams)indicator.getLayoutParams();
           checkmarkParams.width = UZUtility.dipToPix(UIAlbumBrowser.config.markSize);
           checkmarkParams.height = UZUtility.dipToPix(UIAlbumBrowser.config.markSize);
        		   
           int margin =  UZUtility.dipToPix(5);
           
           if(UIAlbumBrowser.mUZModuleContext != null && UIAlbumBrowser.config != null){
        	   if("top_left".equals(UIAlbumBrowser.config.markPosition)){
        		   checkmarkParams.gravity = Gravity.LEFT | Gravity.TOP;
        		   checkmarkParams.leftMargin = margin;
        		   checkmarkParams.topMargin = margin;
        	   }
        	   if("bottom_left".equals(UIAlbumBrowser.config.markPosition)){
        		   checkmarkParams.gravity = Gravity.LEFT | Gravity.BOTTOM;
        		   checkmarkParams.leftMargin = margin;
        		   checkmarkParams.bottomMargin = margin;
        	   }
        	   if("top_right".equals(UIAlbumBrowser.config.markPosition)){
        		   checkmarkParams.gravity = Gravity.TOP | Gravity.RIGHT;
        		   checkmarkParams.topMargin = margin;
        		   checkmarkParams.rightMargin = margin;
        	   }
        	   if("bottom_right".equals(UIAlbumBrowser.config.markPosition)){
        		   checkmarkParams.gravity = Gravity.BOTTOM | Gravity.RIGHT;
        		   checkmarkParams.bottomMargin = margin;
        		   checkmarkParams.rightMargin = margin;
        	   }
           }
            // ==========================
           
           FrameLayout.LayoutParams timeLabelParams = (FrameLayout.LayoutParams)timeLabel.getLayoutParams();
           timeLabelParams.gravity = Gravity.BOTTOM| Gravity.RIGHT;
           timeLabelParams.rightMargin = UZUtility.dipToPix(5);
           timeLabelParams.bottomMargin = UZUtility.dipToPix(5);

            int mask_id = ResUtils.getInstance().getViewId(mContext, "mask");
            mask = view.findViewById(mask_id);
            view.setTag(this);
        }

        void bindData(final Image data){
            if(data == null) return;
            // 处理单选和多选状态
            if(showSelectIndicator){
                indicator.setVisibility(View.VISIBLE);
                if(mSelectedImages.contains(data)){
                    // 设置选中状态
                    int mis_btn_selected_id = ResUtils.getInstance().getDrawableId(mContext, "mis_btn_selected");
                    indicator.setImageResource(mis_btn_selected_id);
                    mask.setVisibility(View.VISIBLE);
                }else{
                    // 未选择
                    int mis_btn_unselected_id = ResUtils.getInstance().getDrawableId(mContext, "mis_btn_unselected");
                    indicator.setImageResource(mis_btn_unselected_id);
                    mask.setVisibility(View.GONE);
                }
            }else{
                indicator.setVisibility(View.GONE);
            }
            File imageFile = new File(data.path);
            int mis_default_error_id = ResUtils.getInstance().getDrawableId(mContext, "mis_default_error");
            if (imageFile.exists()) {
                // 显示图片
            	
//            	RequestOptions options = new RequestOptions()
//                .placeholder(mis_default_error_id)
//                .error(mis_default_error_id)
//                .centerCrop()
//                .override(mGridWidth, mGridWidth);
//            	 Glide.with(mContext).load(imageFile).apply(options).into(image);
            		
            	Glide.with(mContext)
            		  .load(imageFile)
            		  .placeholder(mis_default_error_id)
            		  .override(mGridWidth, mGridWidth)
            		  .error(mis_default_error_id)
            		  .centerCrop()
            		  .into(image);
            		  	
//                Picasso.with(mContext)
//                        .load(imageFile)
//                        .placeholder(mis_default_error_id)
//                        .tag(MultiImageSelectorFragment.TAG)
//                        .resize(mGridWidth, mGridWidth)
//                        .into(image);
            } else {
                image.setImageResource(mis_default_error_id);
            }
        }
    }
}
