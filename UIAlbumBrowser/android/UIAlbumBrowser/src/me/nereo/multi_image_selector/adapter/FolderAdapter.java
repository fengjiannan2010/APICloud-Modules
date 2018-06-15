/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package me.nereo.multi_image_selector.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import me.nereo.multi_image_selector.bean.Folder;
import me.nereo.multi_image_selector.utils.ResUtils;

/**
 * 文件夹Adapter
 * Created by Nereo on 2015/4/7.
 * Updated by nereo on 2016/1/19.
 */
public class FolderAdapter extends BaseAdapter {

    private Context mContext;
    private LayoutInflater mInflater;

    private List<Folder> mFolders = new ArrayList<Folder>();

    int mImageSize;

    int lastSelected = 0;

    public FolderAdapter(Context context){
        mContext = context;
        mInflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        int mis_folder_cover_size_id = ResUtils.getInstance().getDimenId(mContext, "mis_folder_cover_size");
        mImageSize = mContext.getResources().getDimensionPixelOffset(mis_folder_cover_size_id);
    }

    /**
     * 设置数据集
     * @param folders
     */
    public void setData(List<Folder> folders) {
        if(folders != null && folders.size()>0){
            mFolders = folders;
        }else{
            mFolders.clear();
        }
        notifyDataSetChanged();
    }

    @Override
    public int getCount() {
        return mFolders.size()+1;
    }

    @Override
    public Folder getItem(int i) {
        if(i == 0) return null;
        return mFolders.get(i-1);
    }

    @Override
    public long getItemId(int i) {
        return i;
    }

    @SuppressLint("SdCardPath") 
    @Override
    public View getView(int i, View view, ViewGroup viewGroup) {
        ViewHolder holder;
        if(view == null){
            int mis_list_item_folder_id = ResUtils.getInstance().getLayoutId(mContext, "mis_list_item_folder");
            view = mInflater.inflate(mis_list_item_folder_id, viewGroup, false);
            holder = new ViewHolder(view);
        }else{
            holder = (ViewHolder) view.getTag();
        }
        if (holder != null) {
            if(i == 0){
                int mis_folder_all_id = ResUtils.getInstance().getStringId(mContext, "mis_folder_all");
                holder.name.setText(mis_folder_all_id);
                holder.path.setText("/sdcard");
                int mis_photo_unit_id = ResUtils.getInstance().getStringId(mContext, "mis_photo_unit");
                holder.size.setText(String.format("%d%s",
                        getTotalImageSize(), mContext.getResources().getString(mis_photo_unit_id)));
                if(mFolders.size()>0){
                    Folder f = mFolders.get(0);
                    if (f != null) {
//                        int mis_default_error_id = ResUtils.getInstance().getDrawableId(mContext, "mis_default_error");
//                        int mis_folder_cover_size_id = ResUtils.getInstance().getDimenId(mContext, "mis_folder_cover_size");
//                        Picasso.with(mContext)
//                                .load(new File(f.cover.path))
//                                .error(mis_default_error_id)
//                                .resizeDimen(mis_folder_cover_size_id, mis_folder_cover_size_id)
//                                .centerCrop()
//                                .into(holder.cover);
                    }else{
                        int mis_default_error_id = ResUtils.getInstance().getDrawableId(mContext, "mis_default_error");
                        holder.cover.setImageResource(mis_default_error_id);
                    }
                }
            }else {
                holder.bindData(getItem(i));
            }
            if(lastSelected == i){
                holder.indicator.setVisibility(View.VISIBLE);
            }else{
                holder.indicator.setVisibility(View.INVISIBLE);
            }
        }
        return view;
    }

    private int getTotalImageSize(){
        int result = 0;
        if(mFolders != null && mFolders.size()>0){
            for (Folder f: mFolders){
                result += f.images.size();
            }
        }
        return result;
    }

    public void setSelectIndex(int i) {
        if(lastSelected == i) return;

        lastSelected = i;
        notifyDataSetChanged();
    }

    public int getSelectIndex(){
        return lastSelected;
    }

    class ViewHolder{
        ImageView cover;
        TextView name;
        TextView path;
        TextView size;
        ImageView indicator;
        ViewHolder(View view){
            int cover_id = ResUtils.getInstance().getViewId(mContext, "cover");
            cover = (ImageView)view.findViewById(cover_id);

            int name_id = ResUtils.getInstance().getViewId(mContext, "name");
            name = (TextView) view.findViewById(name_id);

            int path_id = ResUtils.getInstance().getViewId(mContext, "path");
            path = (TextView) view.findViewById(path_id);

            int size_id = ResUtils.getInstance().getViewId(mContext, "size");
            size = (TextView) view.findViewById(size_id);

            int indicator_id = ResUtils.getInstance().getViewId(mContext, "indicator");
            indicator = (ImageView) view.findViewById(indicator_id);

            view.setTag(this);
        }

        void bindData(Folder data) {
            if(data == null){
                return;
            }
            name.setText(data.name);
            path.setText(data.path);
            if (data.images != null) {
                int mis_photo_unit_id = ResUtils.getInstance().getStringId(mContext, "mis_photo_unit");
                size.setText(String.format("%d%s", data.images.size(), mContext.getResources().getString(mis_photo_unit_id)));
            }else{
                int mis_photo_unit_id = ResUtils.getInstance().getStringId(mContext, "mis_photo_unit");
                size.setText("*"+mContext.getResources().getString(mis_photo_unit_id));
            }
            if (data.cover != null) {
                // 显示图片
//                int mis_default_error_id = ResUtils.getInstance().getDrawableId(mContext, "mis_default_error");
//                int mis_folder_cover_size_id = ResUtils.getInstance().getDimenId(mContext, "mis_folder_cover_size");
//                Picasso.with(mContext)
//                        .load(new File(data.cover.path))
//                        .placeholder(mis_default_error_id)
//                        .resizeDimen(mis_folder_cover_size_id, mis_folder_cover_size_id)
//                        .centerCrop()
//                        .into(cover);
            }else{
                int mis_default_error_id = ResUtils.getInstance().getDrawableId(mContext, "mis_default_error");
                cover.setImageResource(mis_default_error_id);
            }
        }
    }

}
