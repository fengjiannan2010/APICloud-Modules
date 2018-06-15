/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package me.nereo.multi_image_selector.utils;

import android.content.Context;

/**
 * Created by liyaohua on 2017/8/23.
 */

public class ResUtils {

    private ResUtils(){}

    private static ResUtils mInstance;

    public static ResUtils getInstance(){
        if(mInstance == null){
            mInstance = new ResUtils();
        }
        return mInstance;
    }

    public int getDrawableId(Context context, String resName){
        return context.getResources().getIdentifier(resName,"drawable", context.getPackageName());
    }

    public int getLayoutId(Context context, String resName){
        return context.getResources().getIdentifier(resName,"layout", context.getPackageName());
    }

    public int getViewId(Context context, String resName){
        return context.getResources().getIdentifier(resName,"id", context.getPackageName());
    }

    public int getDimenId(Context context, String resName){
        return context.getResources().getIdentifier(resName,"dimen", context.getPackageName());
    }

    public int getStringId(Context context, String resName){
        return context.getResources().getIdentifier(resName,"string", context.getPackageName());
    }
    
    public int getStyleId(Context context, String resName){
    	return context.getResources().getIdentifier(resName,"style", context.getPackageName());
    }

}
