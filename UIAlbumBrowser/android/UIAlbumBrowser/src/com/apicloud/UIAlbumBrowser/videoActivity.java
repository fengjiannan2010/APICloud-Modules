package com.apicloud.UIAlbumBrowser;

import android.app.Activity;
import android.content.Intent;
import android.content.res.Resources;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.RelativeLayout.LayoutParams;
import android.widget.TextView;
import com.uzmap.pkg.uzcore.UZResourcesIDFinder;

public class videoActivity extends Activity implements View.OnClickListener {
	private TextureVideoPlayer mVideoPlayer;

	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		int album_image_layout_id = UZResourcesIDFinder
				.getResLayoutID("mo_activity_video");
		setContentView(album_image_layout_id);
		Intent intent = getIntent();
		Bundle bundle = intent.getExtras();
		String videoPath = (String) bundle.get("path");
		int media_playerId = UZResourcesIDFinder.getResIdID("media_player");
		this.mVideoPlayer = ((TextureVideoPlayer) findViewById(media_playerId));
		int btn_playId = UZResourcesIDFinder.getResIdID("btn_play");
		Button play = (Button) findViewById(btn_playId);
		int iv_backId = UZResourcesIDFinder.getResIdID("iv_back");

		ImageView back = (ImageView) findViewById(iv_backId);
		int tv_complieId = UZResourcesIDFinder.getResIdID("tv_complie");
		TextView complie = (TextView) findViewById(tv_complieId);
		this.mVideoPlayer.setUrl(videoPath);
		this.mVideoPlayer.setVideoMode(2);
		this.mVideoPlayer.setOnVideoPlayingListener(new TextureVideoPlayer.OnVideoPlayingListener() {
					public void onVideoSizeChanged(int vWidth, int vHeight) {
						if (vWidth<vHeight) {
							RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams) mVideoPlayer.getLayoutParams();
							params.width =videoActivity.this.getResources().getDisplayMetrics().widthPixels;
							params.height = ((int) (params.width / vWidth * vHeight));
						}
					
					}
					public void onStart() {
					}

					public void onPlaying(int duration, int percent) {
					}

					public void onPause() {
					}

					public void onRestart() {
					}

					public void onPlayingFinish() {
					}

					public void onTextureDestory() {
						if (videoActivity.this.mVideoPlayer != null) {
							videoActivity.this.mVideoPlayer.pause();
						}
					}
				});
		back.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				if (videoActivity.this.mVideoPlayer != null) {
					videoActivity.this.mVideoPlayer.stop();
				}
				videoActivity.this.finish();
			}
		});
		complie.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				Intent intent = new Intent();
				Bundle bundle = new Bundle();
				bundle.putBoolean("boolean", true);
				intent.putExtras(bundle);
				videoActivity.this.setResult(102, intent);
				if (videoActivity.this.mVideoPlayer != null) {
					videoActivity.this.mVideoPlayer.stop();
				}
				videoActivity.this.finish();
			}
		});
	}

	protected void onResume() {
		super.onResume();
		if ((this.mVideoPlayer.mState == TextureVideoPlayer.VideoState.pause)
				&& (this.mVideoPlayer != null)
				&& (!this.mVideoPlayer.isPlaying())) {
			this.mVideoPlayer.pause();
		}
	}

	public void onClick(View arg0) {
	}

	public void onBackPressed() {
		if (this.mVideoPlayer != null) {
			this.mVideoPlayer.stop();
		}
		finish();
	}
}
