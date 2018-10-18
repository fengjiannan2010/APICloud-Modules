package com.apicloud.UIAlbumBrowser;

import android.content.Context;
import android.media.MediaMetadataRetriever;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.widget.VideoView;

public class CustomVideoView
  extends VideoView
{
  private int mVideoWidth = 480;
  private int mVideoHeight = 480;
  private int videoRealW = 1;
  private int videoRealH = 1;
  
  public CustomVideoView(Context context)
  {
    super(context);
  }
  
  public CustomVideoView(Context context, AttributeSet attrs)
  {
    super(context, attrs);
  }
  
  public CustomVideoView(Context context, AttributeSet attrs, int defStyle)
  {
    super(context, attrs, defStyle);
  }
  
  public void setVideoPath(String path)
  {
    super.setVideoPath(path);
    
    MediaMetadataRetriever retr = new MediaMetadataRetriever();
    retr.setDataSource(path);
    String height = retr.extractMetadata(19);
    String width = retr.extractMetadata(18);
    try
    {
      this.videoRealH = Integer.parseInt(height);
      this.videoRealW = Integer.parseInt(width);
    }
    catch (NumberFormatException e)
    {
      Log.e("----->VideoView", "setVideoPath:" + e.toString());
    }
  }
  
  protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec)
  {
    int width = getDefaultSize(0, widthMeasureSpec);
    int height = getDefaultSize(0, heightMeasureSpec);
    if (height > width)
    {
      if (this.videoRealH > this.videoRealW)
      {
        this.mVideoHeight = height;
        this.mVideoWidth = width;
      }
      else
      {
        this.mVideoWidth = width;
        float r = this.videoRealH / this.videoRealW;
        this.mVideoHeight = ((int)(this.mVideoWidth * r));
      }
    }
    else if (this.videoRealH > this.videoRealW)
    {
      this.mVideoHeight = height;
      float r = this.videoRealW / this.videoRealH;
      this.mVideoWidth = ((int)(this.mVideoHeight * r));
    }
    else
    {
      this.mVideoHeight = height;
      this.mVideoWidth = width;
    }
    if ((this.videoRealH == this.videoRealW) && (this.videoRealH == 1)) {
      super.onMeasure(widthMeasureSpec, heightMeasureSpec);
    } else {
      setMeasuredDimension(this.mVideoWidth, this.mVideoHeight);
    }
  }
  
  public boolean onTouchEvent(MotionEvent ev)
  {
    return true;
  }
}
