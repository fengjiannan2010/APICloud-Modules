package com.uzmap.pkg.uzmodules.uzPersonCenter;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.StateListDrawable;
import android.os.AsyncTask;
import android.text.Layout;
import android.text.TextPaint;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnLayoutChangeListener;
import android.view.View.OnTouchListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.RelativeLayout.LayoutParams;
import android.widget.TextView;

import com.lidroid.xutils.BitmapUtils;
import com.lidroid.xutils.bitmap.BitmapDisplayConfig;
import com.lidroid.xutils.bitmap.BitmapGlobalConfig;
import com.lidroid.xutils.bitmap.callback.BitmapLoadCallBack;
import com.lidroid.xutils.bitmap.callback.BitmapLoadFrom;
import com.lidroid.xutils.bitmap.core.BitmapSize;
import com.lidroid.xutils.util.OtherUtils;
import com.uzmap.pkg.uzcore.UZCoreUtil;
import com.uzmap.pkg.uzcore.UZResourcesIDFinder;
import com.uzmap.pkg.uzcore.UZWebView;
import com.uzmap.pkg.uzcore.annotation.UzJavascriptMethod;
import com.uzmap.pkg.uzcore.uzmodule.UZModule;
import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;
import com.uzmap.pkg.uzkit.UZUtility;

public class UzPersonCenter extends UZModule {

	private RelativeLayout view;
	private TextView tv_username;
	private TextView tv_count;
	private TextView tv_collect;
	private TextView tv_browse;
	private TextView tv_downLoad;
	private TextView tv_activity;
	private ImageView img;
	private Paint paint = new Paint();
	public Bitmap bitmap;
	private CircleImageView circleImageView;
	private float density;
	private BitmapUtils bitmapUtils;
	private BitmapGlobalConfig globalConfig;
	private BitmapDisplayConfig defaultDisplayConfig;
	private blurAsynctask asynctask;
	private LinearLayout linearLayout;
	private View currentView;
	private TextView currentTextCount;
	private TextView currentTextTitle;
	private int currentPosition;
	private BitmapLoadCallBack<View> callBack;
	private List<Data> list = new ArrayList<Data>();
	private List<RelativeLayout> viewList = new ArrayList<RelativeLayout>();
	private List<blurAsynctask> blurList = new ArrayList<blurAsynctask>();

	private String mLeftTitle = "修改";
	private String mRightTitle = "设置";

	public UzPersonCenter(UZWebView webView) {
		super(webView);
	}

	@UzJavascriptMethod
	public void jsmethod_open(UZModuleContext moduleContext) {
		JSONObject buttonTitle = moduleContext.optJSONObject("buttonTitle");
		if (buttonTitle != null) {
			mLeftTitle = buttonTitle.optString("left", mLeftTitle);
			mRightTitle = buttonTitle.optString("right", mRightTitle);
		}
		DisplayMetrics metric = new DisplayMetrics();
		mContext.getWindowManager().getDefaultDisplay().getMetrics(metric);
		density = metric.density;
		width = metric.widthPixels;
		int height = metric.heightPixels;
		isUpdate = false;
		btnArray = !moduleContext.isNull("btnArray");
		modButton = !moduleContext.isNull("modButton");
		bitmapUtils = new BitmapUtils(mContext, OtherUtils.getDiskCacheDir(
				mContext, ""));
		// bitmapUtils.setDownLoadBitmapListener(new DownLoadBitmapListener() {
		// @Override
		// public void complete(Bitmap downloadBitmap) {
		// if (downloadBitmap!=null) {
		// blur(downloadBitmap);
		// }
		// }
		// });
		callBack = new BitmapLoadCallBack<View>() {
			@Override
			public void onLoadCompleted(final View container, String uri,
					final Bitmap bitmap, BitmapDisplayConfig displayConfig,
					BitmapLoadFrom from) {
				if (container instanceof ImageView) {
					((ImageView) container)
							.setImageDrawable(new BitmapDrawable(container
									.getResources(), bitmap));
				}
				blur(bitmap);
			}

			@Override
			public void onLoading(View container, String uri,
					BitmapDisplayConfig config, long total, long current) {
			}

			@Override
			public void onLoadFailed(View container, String uri,
					Drawable failedDrawable) {
			}
		};
		globalConfig = BitmapGlobalConfig.getInstance(mContext,
				OtherUtils.getDiskCacheDir(mContext, ""));
		defaultDisplayConfig = new BitmapDisplayConfig();
		if (view != null) {
			removeViewFromCurWindow(view);
		}
		list.clear();
		x = moduleContext.optInt("x");
		y = moduleContext.optInt("y", 44);
		if (moduleContext.isNull("h")) {
			height = moduleContext.optInt("height", 220);
		} else {
			height = moduleContext.optInt("h", 220);
		}
		// if (height < 260) {
		// height = 260;
		// }
		int layoutId = UZResourcesIDFinder
				.getResLayoutID("mo_personcenter_main");
		view = (RelativeLayout) View.inflate(mContext, layoutId, null);
		initView(moduleContext);
		setOnClick(moduleContext);
		LayoutParams params = new LayoutParams(LayoutParams.MATCH_PARENT,
				height);
		params.setMargins(x, y, 0, 0);
		String fixedOn = moduleContext.optString("fixedOn");
		boolean fixed = moduleContext.optBoolean("fixed", true);
		insertViewToCurWindow(view, params, fixedOn, fixed);
		asynctask = new blurAsynctask();
		asynctask.execute(moduleContext);
	}

	private class MyAsyncTask extends AsyncTask<Void, Void, Void> {
		@Override
		protected Void doInBackground(Void... arg0) {
			return null;
		}

		@Override
		protected void onPostExecute(Void result) {
			String path = UZUtility.makeRealPath(placeHoldImg, getWidgetInfo());
			final Bitmap bitmap;
			try {
				if (path.contains("android_asset")) {
					InputStream is = UZUtility.guessInputStream(path);
					bitmap = BitmapFactory.decodeStream(is);
				} else if (path.contains("file://")) {
					InputStream is = new FileInputStream(substringAfter(path,
							"file://"));
					bitmap = BitmapFactory.decodeStream(is);
				} else {
					InputStream is = new FileInputStream(path);
					bitmap = BitmapFactory.decodeStream(is);
				}
				blur(bitmap);
				String imgPath = generatePath(imagePath);
				bitmapUtils.configDefaultLoadingImage(bitmap);
				bitmapUtils.configDefaultLoadFailedImage(bitmap);
				bitmapUtils.display(circleImageView, imgPath, callBack);
			} catch (IOException e) {
				e.printStackTrace();
			}
			super.onPostExecute(result);
		}
	}

	public boolean isBlank(CharSequence cs) {
		int strLen;
		if ((cs == null) || ((strLen = cs.length()) == 0))
			return true;
		for (int i = 0; i < strLen; i++) {
			if (!Character.isWhitespace(cs.charAt(i))) {
				return false;
			}
		}
		return true;
	}

	private String placeHoldImg;
	private String imagePath;

	private class blurAsynctask extends AsyncTask<UZModuleContext, Void, Void> {
		private UZModuleContext moduleContext;

		@Override
		protected Void doInBackground(UZModuleContext... params) {
			moduleContext = params[0];
			imagePath = moduleContext.optString("imgPath");
			if (moduleContext.isNull("placeholderImg")) {
				placeHoldImg = moduleContext.optString("placeHoldImg");
			} else {
				placeHoldImg = moduleContext.optString("placeholderImg");
			}

			defaultDisplayConfig.setBitmapMaxSize(new BitmapSize(0, 0));
			final Bitmap cacheBitmap = getBitmapFromCache(
					generatePath(imagePath), defaultDisplayConfig);
			if (cacheBitmap != null) {
				blur(cacheBitmap);
				runOnUiThread(new Runnable() {
					public void run() {
						circleImageView.setImageBitmap(cacheBitmap);
					}
				});
			} else {
				if (isBlank(placeHoldImg)) {
					final String path = generatePath(imagePath);
					Drawable drawable = circleImageView.getDrawable();
					bitmapUtils.configDefaultLoadingImage(drawable);
					bitmapUtils.configDefaultLoadFailedImage(drawable);
					runOnUiThread(new Runnable() {
						public void run() {
							bitmapUtils
									.display(circleImageView, path, callBack);
						}
					});
				} else {
					new Thread() {
						public void run() {
							myAsyncTask = new MyAsyncTask();
							myAsyncTask.execute();
						};
					}.start();
				}
			}
			return null;
		}

		@Override
		protected void onPostExecute(Void result) {
			initData(moduleContext);
		}
	}

	private MyAsyncTask myAsyncTask;

	private Bitmap getBitmapFromCache(String url,
			BitmapDisplayConfig displayConfig) {
		Bitmap bitmap = globalConfig.getBitmapCache().getBitmapFromDiskCache(
				url, displayConfig);
		return bitmap;
	}

	public String generatePath(String pathname) {
		String path = UZUtility.makeRealPath(pathname, getWidgetInfo());
		if (path != null) {
			String sharePath;
			if (path.contains("file://")) {
				sharePath = substringAfter(path, "file://");
			} else if (path.contains("android_asset")) {
				sharePath = path;
			} else {
				sharePath = path;
			}
			return sharePath;
		}
		return null;
	}

	public boolean isEmpty(CharSequence cs) {
		return (cs == null) || (cs.length() == 0);
	}

	public String substringAfter(String str, String separator) {
		if (isEmpty(str)) {
			return str;
		}
		if (separator == null) {
			return "";
		}
		int pos = str.indexOf(separator);
		if (pos == -1) {
			return "";
		}
		return str.substring(pos + separator.length());
	}

	private boolean btnArray;
	private boolean leftShow;
	private boolean rightShow;
	private boolean modButton;

	private void initData(final UZModuleContext moduleContext) {
		if (!isUpdate) {
			// if (!moduleContext.isNull("showLeftBtn")) {
			leftShow = moduleContext.optBoolean("showLeftBtn", true);
			if (null != left) {
				if (leftShow) {
					left.setVisibility(View.VISIBLE);
				} else {
					left.setVisibility(View.INVISIBLE);
				}
			}
			// }
			// if (!moduleContext.isNull("showRightBtn")) {
			rightShow = moduleContext.optBoolean("showRightBtn", true);
			if (null != right) {
				if (rightShow) {
					right.setVisibility(View.VISIBLE);
				} else {
					right.setVisibility(View.INVISIBLE);
				}
			}
			// }
		}
		if (!isUpdate) {
			String username = null;
			if (moduleContext.isNull("userName")) {
				username = moduleContext.optString("username", "username");
			} else {
				username = moduleContext.optString("userName", "username");
			}
			tv_username.setText(username);
		} else {
			if (moduleContext.isNull("userName")) {
				if (!moduleContext.isNull("username")) {
					String username = moduleContext.optString("username");
					tv_username.setText(username);
				}
			} else {
				String username = moduleContext.optString("userName");
				tv_username.setText(username);
			}
		}

		int userNameSize = moduleContext.optInt("userNameSize", 13);
		tv_username.setTextSize(userNameSize);
		String userColor = moduleContext.optString("userColor", "#FFFFFF");
		int userNameColor = UZUtility.parseCssColor(userColor);
		tv_username.setTextColor(userNameColor);

		if (!moduleContext.isNull("subTitle")) {
			String subTitle = moduleContext.optString("subTitle");
			if (null != tv_count)
				tv_count.setText(subTitle);
		}
		int subTitleSize = moduleContext.optInt("subTitleSize", 13);
		tv_count.setTextSize(subTitleSize);
		String subTitleColorStr = moduleContext.optString("subTitleColor",
				"#FFFFFF");
		int subTitleColor = UZUtility.parseCssColor(subTitleColorStr);
		tv_count.setTextColor(subTitleColor);

		if (btnArray) {
			linearLayout.setVisibility(View.GONE);
			if (modButton) {
				JSONObject jsonObject = moduleContext
						.optJSONObject("modButton");
				if (jsonObject != null) {
					String bgImg = jsonObject.optString("bgImg");
					String lightImg = jsonObject.optString("lightImg");
					Bitmap nomalBitmap = generateBitmap(bgImg);
					Bitmap pressBitmap = generateBitmap(lightImg);
					img.setBackgroundDrawable(addStateDrawable(nomalBitmap,
							pressBitmap));
				}
			} else {
				img.setVisibility(View.GONE);
			}
			if (!isUpdate) {
				LinearLayout linearLayout = new LinearLayout(mContext);
				LayoutParams params = new LayoutParams(
						LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
				params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM,
						RelativeLayout.TRUE);
				linearLayout.setOrientation(LinearLayout.HORIZONTAL);
				JSONArray jsonArray = moduleContext.optJSONArray("btnArray");
				length = jsonArray.length();
				int btnWidth = width / length;
				for (int i = 0; i < length; i++) {
					Data data = new Data();
					JSONObject jsonObject = jsonArray.optJSONObject(i);
					String bgImg = jsonObject.optString("bgImg");
					String selectedImg = jsonObject.optString("selectedImg");
					String lightImg = jsonObject.optString("lightImg");
					String title = jsonObject.optString("title");
					String count = jsonObject.optString("count");
					String titleColor = jsonObject.optString("titleColor");
					if (isBlank(titleColor)) {
						titleColor = "#AAAAAA";
					}
					String titleLightColor = jsonObject
							.optString("titleLightColor");
					if (isBlank(titleLightColor)) {
						titleLightColor = "#A4D3EE";
					}
					String countColor = jsonObject.optString("countColor");
					if (isBlank(countColor)) {
						countColor = "#FFFFFF";
					}
					String countLightColor = jsonObject
							.optString("countLightColor");
					if (isBlank(countLightColor)) {
						countLightColor = "#A4D3EE";
					}
					data.setBgImg(new BitmapDrawable(generateBitmap(bgImg)));
					data.setSelectedImg(new BitmapDrawable(
							generateBitmap(selectedImg)));
					data.setLightImg(new BitmapDrawable(
							generateBitmap(lightImg)));
					data.setTitle(title);
					data.setCount(count);
					data.setTitleColor(titleColor);
					data.setTitleLightColor(titleLightColor);
					data.setCountColor(countColor);
					data.setCountLightColor(countLightColor);
					list.add(data);
				}

				for (int i = 0; i < list.size(); i++) {
					final Data data = list.get(i);
					final RelativeLayout relativeLayout = new RelativeLayout(
							mContext);
					LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(
							btnWidth, UZUtility.dipToPix(60));

					LinearLayout layout = new LinearLayout(mContext);
					LayoutParams params2 = new LayoutParams(
							LayoutParams.WRAP_CONTENT,
							LayoutParams.WRAP_CONTENT);
					params2.addRule(RelativeLayout.CENTER_IN_PARENT,
							RelativeLayout.TRUE);
					layout.setOrientation(LinearLayout.VERTICAL);

					final TextView tv = new TextView(mContext);
					LinearLayout.LayoutParams layoutParams2 = new LinearLayout.LayoutParams(
							LinearLayout.LayoutParams.WRAP_CONTENT,
							LinearLayout.LayoutParams.WRAP_CONTENT);
					layoutParams2.gravity = Gravity.CENTER_HORIZONTAL;
					layoutParams2.setMargins(UZUtility.dipToPix(5), 0,
							UZUtility.dipToPix(2), 0);
					tv.setSingleLine(true);
					tv.setTextSize(17);
					tv.setTextColor(UZUtility.parseCssColor(data
							.getCountColor()));
					tv.setText(data.getCount());
					tv.setTypeface(Typeface.SANS_SERIF, Typeface.BOLD);
					tv.setTag(0);

					final TextView title = new TextView(mContext);
					title.setLayoutParams(layoutParams2);
					title.setTextSize(14);
					title.setText(data.getTitle());
					title.setTextColor(UZUtility.parseCssColor(data
							.getTitleColor()));
					title.setTypeface(Typeface.SANS_SERIF, Typeface.BOLD);
					title.setTag(1);

					layout.addView(tv, layoutParams2);
					layout.addView(title, layoutParams2);

					relativeLayout.addView(layout, params2);
					if (i != list.size() - 1) {
						ImageView imageView = new ImageView(mContext);
						LayoutParams layoutParams3 = new LayoutParams(
								LayoutParams.WRAP_CONTENT,
								LayoutParams.WRAP_CONTENT);
						layoutParams3.addRule(
								RelativeLayout.ALIGN_PARENT_RIGHT,
								RelativeLayout.TRUE);
						layoutParams3.setMargins(0, UZUtility.dipToPix(5), 0,
								UZUtility.dipToPix(7));
						imageView.setBackgroundResource(UZResourcesIDFinder
								.getResDrawableID("mo_personcenter_fenge"));
						relativeLayout.addView(imageView, layoutParams3);
					}
					relativeLayout.setBackgroundDrawable(data.getBgImg());
					final int position = i;
					relativeLayout.setOnTouchListener(new OnTouchListener() {
						@Override
						public boolean onTouch(View v, MotionEvent event) {
							switch (event.getAction()) {
							case MotionEvent.ACTION_DOWN:
								v.setBackgroundDrawable(data.getLightImg());
								break;
							case MotionEvent.ACTION_UP:
							case MotionEvent.ACTION_CANCEL:
								float newX = event.getX();
								float nexY = event.getY();
								// if (oldX == newX && oldY == nexY) {
								refleshView();
								v.setBackgroundDrawable(data.getSelectedImg());
								tv.setTextColor(UZUtility.parseCssColor(data
										.getCountLightColor()));
								title.setTextColor(UZUtility.parseCssColor(data
										.getTitleLightColor()));
								currentView = v;
								currentTextCount = tv;
								currentTextTitle = title;
								currentPosition = position;
								try {
									// ret.put("click",
									// modButton ? (leftShow ? (rightShow ?
									// position + 3
									// : position + 2)
									// : position + 1)
									// : position);
									ret.put("click", position);
									moduleContext.success(ret, false);
								} catch (JSONException e) {
									e.printStackTrace();
								}
								// }
								// else{
								// v.setBackgroundDrawable(data.getBgImg());
								// }
								break;
							case MotionEvent.ACTION_MOVE:
								v.setBackgroundDrawable(data.getLightImg());
								break;
							}
							return true;
						}
					});
					linearLayout.addView(relativeLayout, layoutParams);
					viewList.add(relativeLayout);
				}
				if (view != null) {
					view.addView(linearLayout, params);
				}
				boolean clearBtn = moduleContext.optBoolean("clearBtn", false);
				if (clearBtn)
					linearLayout.setVisibility(View.GONE);
			} else {
				JSONArray jsonArray = moduleContext.optJSONArray("btnArray");
				if (jsonArray != null) {
					int length = jsonArray.length();
					for (int i = 0; i < length; i++) {
						Data data = list.get(i);
						RelativeLayout relativeLayout = viewList.get(i);
						LinearLayout linearLayout = (LinearLayout) relativeLayout
								.getChildAt(0);
						TextView textView = (TextView) linearLayout
								.findViewWithTag(0);
						TextView tv_title = (TextView) linearLayout
								.findViewWithTag(1);
						JSONObject jsonObject = jsonArray.optJSONObject(i);
						String bgImg = jsonObject.optString("bgImg");
						String selectedImg = jsonObject
								.optString("selectedImg");
						String lightImg = jsonObject.optString("lightImg");
						String title = jsonObject.optString("title");
						String count = jsonObject.optString("count");
						String titleColor = jsonObject.optString("titleColor");
						String titleLightColor = jsonObject
								.optString("titleLightColor");
						String countColor = jsonObject.optString("countColor");
						String countLightColor = jsonObject
								.optString("countLightColor");
						if (!isBlank(bgImg)) {
							relativeLayout
									.setBackgroundDrawable(new BitmapDrawable(
											generateBitmap(bgImg)));
							data.setBgImg(new BitmapDrawable(
									generateBitmap(bgImg)));
						}
						if (!isBlank(selectedImg)) {
							data.setSelectedImg(new BitmapDrawable(
									generateBitmap(selectedImg)));
						}
						if (!isBlank(lightImg)) {
							data.setLightImg(new BitmapDrawable(
									generateBitmap(lightImg)));
						}
						if (!isBlank(title)) {
							tv_title.setText(title);
							data.setTitle(title);
						}
						if (!isBlank(count)) {
							textView.setText(count);
							data.setCount(count);
						}
						if (!isBlank(titleColor)) {
							tv_title.setTextColor(UZUtility
									.parseCssColor(titleColor));
							data.setTitleColor(titleColor);
						}
						if (!isBlank(titleLightColor)) {
							data.setTitleLightColor(titleLightColor);
						}
						if (!isBlank(countColor)) {
							textView.setTextColor(UZUtility
									.parseCssColor(countColor));
							data.setCountColor(countColor);
						}
						if (!isBlank(countLightColor)) {
							data.setCountLightColor(countLightColor);
						}
					}
					boolean clearBtn = moduleContext.optBoolean("clearBtn",
							false);
					if (clearBtn) {
						LinearLayout linearLayout = (LinearLayout) viewList
								.get(0).getParent();
						if (null != linearLayout) {
							linearLayout.setVisibility(View.GONE);
						}
					}
				}
			}
		} else {
			int rl_length = width / 4;
			linearLayout.setVisibility(View.VISIBLE);
			boolean clearBtn = moduleContext.optBoolean("clearBtn", false);
			if (clearBtn)
				linearLayout.setVisibility(View.GONE);
			img.setBackgroundResource(UZResourcesIDFinder
					.getResDrawableID("mo_personcenter_update"));
			int pointSize = (int) paint.measureText(".");
			// circleImageView.setImageBitmap(bitmap);
			if (!moduleContext.isNull("activity")) {
				String activity = moduleContext.optString("activity");
				if (null != tv_activity) {
					tv_activity.setText(activity);
					paint.setTextSize(tv_activity.getTextSize());
					int tv_length = (int) paint.measureText(tv_activity
							.getText() + "");

					if ((tv_length + pointSize) >= rl_length) {
						tv_activity.setText(activity.substring(0, 6) + "...");
					}
				}
			}
			if (!moduleContext.isNull("collect")) {
				String collect = moduleContext.optString("collect");
				if (null != tv_collect) {
					tv_collect.setText(collect);
					paint.setTextSize(tv_collect.getTextSize());
					int collect_length = (int) paint.measureText(tv_collect
							.getText() + "");
					if ((collect_length + pointSize) >= rl_length) {
						tv_collect.setText(collect.substring(0, 6) + "...");
					}
				}
			}
			if (!moduleContext.isNull("browse")) {
				String browse = moduleContext.optString("browse");
				if (null != tv_browse) {
					tv_browse.setText(browse);
					paint.setTextSize(tv_browse.getTextSize());
					int browse_length = (int) paint.measureText(tv_browse
							.getText() + "");
					if ((browse_length + pointSize) >= rl_length) {
						tv_browse.setText(browse.substring(0, 6) + "...");
					}
				}
			}
			if (!moduleContext.isNull("dwonload")) {
				String downLoad = moduleContext.optString("dwonload");
				if (null != tv_downLoad) {
					tv_downLoad.setText(downLoad);
					paint.setTextSize(tv_downLoad.getTextSize());
					int downLoad_length = (int) paint.measureText(tv_downLoad
							.getText() + "");
					if ((downLoad_length + pointSize) >= rl_length) {
						tv_downLoad.setText(downLoad.substring(0, 6) + "...");
					}
				}
			}
		}

	}

	public void setOnClick(final UZModuleContext moduleContext) {
		left.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				try {

					ret.put("click", btnArray ? (modButton ? (length + 1)
							: length) : 5);
					moduleContext.success(ret, false);
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}
		});

		right.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				try {
					ret.put("click",
							btnArray ? (modButton ? (leftShow ? length + 2
									: length + 1) : (leftShow ? length + 1
									: length)) : 6);
					moduleContext.success(ret, false);
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}
		});

		img.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				try {
					ret.put("click", btnArray ? length : 0);
					moduleContext.success(ret, false);
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}
		});

		rl_collect.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				try {
					ret.put("click", 1);
					moduleContext.success(ret, false);
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}
		});

		rl_browse.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				try {
					ret.put("click", 2);
					moduleContext.success(ret, false);
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}
		});

		rl_downLoad.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				try {
					ret.put("click", 3);
					moduleContext.success(ret, false);
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}
		});

		ll_activity.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				try {
					ret.put("click", 4);
					moduleContext.success(ret, false);
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}
		});
	}

	@UzJavascriptMethod
	public void jsmethod_updateValue(final UZModuleContext moduleContext) {
		if (view != null) {
			isUpdate = true;
			blurAsynctask asynctask = new blurAsynctask();
			if (asynctask != null) {
				blurList.add(asynctask);
				asynctask.execute(moduleContext);
			}
		}
	}

	private void refleshView() {
		if (currentView != null) {
			Data data = list.get(currentPosition);
			// currentView.setPressed(false);
			// currentView.setFocusable(false);
			currentView.setBackgroundDrawable(data.getBgImg());
			currentTextCount.setTextColor(UZUtility.parseCssColor(data
					.getCountColor()));
			currentTextTitle.setTextColor(UZUtility.parseCssColor(data
					.getTitleColor()));
		}
	}

	private RelativeLayout rl_collect;

	private void initView(UZModuleContext moduleContext) {
		if (view != null) {

			int img_circleID = UZResourcesIDFinder.getResIdID("img_circle");
			circleImageView = (CircleImageView) view.findViewById(img_circleID);

			int ID = UZResourcesIDFinder.getResIdID("left_setting");
			left = (RelativeLayout) view.findViewById(ID);

			int rightID = UZResourcesIDFinder.getResIdID("right_setting");
			right = (RelativeLayout) view.findViewById(rightID);

			int tv_usernameID = UZResourcesIDFinder.getResIdID("tv_username");
			tv_username = (TextView) view.findViewById(tv_usernameID);
			int tv_countID = UZResourcesIDFinder.getResIdID("tv_count");
			tv_count = (TextView) view.findViewById(tv_countID);
			int imgID = UZResourcesIDFinder.getResIdID("img_update");
			img = (ImageView) view.findViewById(imgID);
			int rl_collectID = UZResourcesIDFinder.getResIdID("rl_collect");
			rl_collect = (RelativeLayout) view.findViewById(rl_collectID);
			int tv_collectID = UZResourcesIDFinder.getResIdID("tv_collect");
			tv_collect = (TextView) view.findViewById(tv_collectID);
			int rl_browseID = UZResourcesIDFinder.getResIdID("rl_browse");
			rl_browse = (RelativeLayout) view.findViewById(rl_browseID);
			int rl_downLoadID = UZResourcesIDFinder.getResIdID("rl_downLoad");
			rl_downLoad = (RelativeLayout) view.findViewById(rl_downLoadID);
			int ll_activityID = UZResourcesIDFinder.getResIdID("ll_activity");
			ll_activity = (RelativeLayout) view.findViewById(ll_activityID);
			int tv_activityID = UZResourcesIDFinder.getResIdID("tv_activity");
			tv_activity = (TextView) view.findViewById(tv_activityID);

			int tv_browseID = UZResourcesIDFinder.getResIdID("tv_browse");
			tv_browse = (TextView) view.findViewById(tv_browseID);

			int tv_downLoadID = UZResourcesIDFinder.getResIdID("tv_downLoad");
			tv_downLoad = (TextView) view.findViewById(tv_downLoadID);

			int linearLayoutId = UZResourcesIDFinder.getResIdID("ll_button");
			linearLayout = (LinearLayout) view.findViewById(linearLayoutId);

			TextView leftTitle = (TextView) view
					.findViewById(UZResourcesIDFinder.getResIdID("left_title"));
			leftTitle.setText(mLeftTitle);

			LayoutParams leftLayoutParams = (LayoutParams) left
					.getLayoutParams();
			leftLayoutParams.width = (int) (UZUtility.dipToPix(35) + textWidth(leftTitle));
			System.out.println("leftLayoutParams.width:"
					+ leftLayoutParams.width);
			left.setLayoutParams(leftLayoutParams);

			TextView rightTitle = (TextView) view
					.findViewById(UZResourcesIDFinder.getResIdID("right_title"));
			rightTitle.setText(mRightTitle);
			LayoutParams rightLayoutParams = (LayoutParams) right
					.getLayoutParams();
			rightLayoutParams.width = (int) (UZUtility.dipToPix(35) + +textWidth(rightTitle));
			System.out.println("rightLayoutParams.width:"
					+ rightLayoutParams.width);
			right.setLayoutParams(rightLayoutParams);
		}
	}

	private int textWidth(TextView tv) {
		TextPaint paint = tv.getPaint();
		int width = (int) Layout.getDesiredWidth(tv.getText().toString(), 0, tv
				.getText().length(), paint);
		return width;
	}

	private RelativeLayout left;
	private RelativeLayout right;
	private boolean isUpdate = false;

	@UzJavascriptMethod
	public void jsmethod_close(UZModuleContext moduleContext) {
		if (view != null) {
			isUpdate = false;
			removeViewFromCurWindow(view);
			if (null != asynctask) {
				asynctask.cancel(true);
			}
			if (null != myAsyncTask) {
				myAsyncTask.cancel(true);
			}
			for (int i = 0; i < blurList.size(); i++) {
				blurAsynctask asynctask = blurList.get(i);
				if (asynctask != null) {
					asynctask.cancel(true);
				}
			}
			view = null;
			list.clear();
		}
	}

	@Override
	protected void onClean() {
		if (view != null) {
			isUpdate = false;
			removeViewFromCurWindow(view);
			for (int i = 0; i < blurList.size(); i++) {
				blurAsynctask asynctask = blurList.get(i);
				if (asynctask != null) {
					asynctask.cancel(true);
				}
			}
			if (null != asynctask) {
				asynctask.cancel(true);
			}
			if (null != myAsyncTask) {
				myAsyncTask.cancel(true);
			}
			view = null;
			list.clear();
		}
	}

	private JSONObject ret = new JSONObject();
	private int width;
	private int x;
	private int y;
	private int height;
	private RelativeLayout rl_browse;
	private RelativeLayout rl_downLoad;
	private RelativeLayout ll_activity;
	private Bitmap overlay;
	private int length;

	private void blur(Bitmap bmp) {
		if (null != bmp) {
			float radius = 10;
			overlay = Bitmap.createBitmap((int) (bmp.getWidth()),
					(int) (bmp.getHeight()), Bitmap.Config.ARGB_8888);
			Canvas canvas = new Canvas(overlay);
			canvas.translate(0, 0);
			Paint paint = new Paint();
			paint.setFlags(Paint.FILTER_BITMAP_FLAG);
			canvas.drawBitmap(bmp, 0, 0, paint);
			overlay = FastBlur.doBlur(overlay, (int) radius, true);
			runOnUiThread(new Runnable() {
				@Override
				public void run() {
					if (view != null) {
						view.setBackgroundDrawable(new BitmapDrawable(overlay));
					}
				}
			});
		}
	}

	private StateListDrawable addStateDrawable(Bitmap nomalBitmap,
			Bitmap pressBitmap) {
		StateListDrawable sd = new StateListDrawable();
		sd.addState(new int[] { android.R.attr.state_pressed },
				new BitmapDrawable(pressBitmap));
		sd.addState(new int[] {}, new BitmapDrawable(nomalBitmap));
		return sd;
	}

	// private StateListDrawable addSelectDrawable(Bitmap nomalBitmap,
	// Bitmap pressBitmap) {
	// StateListDrawable sd = new StateListDrawable();
	// sd.addState(new int[] { android.R.attr.state_pressed },
	// new BitmapDrawable(pressBitmap));
	// sd.addState(new int[] { android.R.attr.state_focused },
	// new BitmapDrawable(pressBitmap));
	// sd.addState(new int[] {}, new BitmapDrawable(nomalBitmap));
	// return sd;
	// }

	public Bitmap generateBitmap(String path) {
		String pathname = UZUtility.makeRealPath(path, getWidgetInfo());
		if (!isBlank(pathname)) {
			String sharePath;
			File file;
			try {
				if (pathname.contains("android_asset")) {
					int dotPosition = pathname.lastIndexOf('/');
					String ext = pathname.substring(dotPosition + 1,
							pathname.length()).toLowerCase();
					file = new File(getContext().getExternalCacheDir(), ext);
					sharePath = file.getAbsolutePath();
					InputStream input = UZUtility.guessInputStream(pathname);
					copy(input, file);
				} else if (pathname.contains("file://")) {
					sharePath = substringAfter(pathname, "file://");
				} else {
					sharePath = path;
				}
				InputStream input = UZUtility.guessInputStream(sharePath);
				return BitmapFactory.decodeStream(input);
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return null;
	}

	private static void copy(InputStream inputStream, File output)
			throws IOException {
		OutputStream outputStream = null;
		try {
			if (!output.exists()) {
				output.createNewFile();
			}
			outputStream = new FileOutputStream(output);
			int read = 0;
			byte[] bytes = new byte[1024];
			if (inputStream != null)
				while ((read = inputStream.read(bytes)) != -1) {
					outputStream.write(bytes, 0, read);
				}
		} finally {
			try {
				if (inputStream != null) {
					inputStream.close();
				}
			} finally {
				if (outputStream != null) {
					outputStream.close();
				}
			}
		}
	}

	public void jsmethod_show(UZModuleContext moduleContext) {
		if (view != null) {
			view.setVisibility(View.VISIBLE);
		}
	}

	public void jsmethod_hide(UZModuleContext moduleContext) {
		if (view != null) {
			view.setVisibility(View.GONE);
		}
	}

	public void jsmethod_setSelect(UZModuleContext moduleContext) {
		int index = moduleContext.optInt("index");
		Data data = list.get(index);
		RelativeLayout relativeLayout = viewList.get(index);
		if (data != null && relativeLayout != null) {
			refleshView();
			LinearLayout linearLayout = (LinearLayout) relativeLayout
					.getChildAt(0);
			TextView textView = (TextView) linearLayout.findViewWithTag(0);
			TextView tv_title = (TextView) linearLayout.findViewWithTag(1);
			relativeLayout.setBackgroundDrawable(data.getLightImg());
			textView.setTextColor(UZUtility.parseCssColor(data
					.getCountLightColor()));
			tv_title.setTextColor(UZUtility.parseCssColor(data
					.getTitleLightColor()));
			currentView = relativeLayout;
			currentTextCount = textView;
			currentTextTitle = tv_title;
			currentPosition = index;
		}
	}
}
