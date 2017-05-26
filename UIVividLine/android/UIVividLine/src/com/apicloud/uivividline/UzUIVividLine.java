package com.apicloud.uivividline;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.View.OnAttachStateChangeListener;
import android.widget.FrameLayout;
import android.widget.RelativeLayout.LayoutParams;
import com.uzmap.pkg.uzcore.UZCoreUtil;
import com.uzmap.pkg.uzcore.UZWebView;
import com.uzmap.pkg.uzcore.uzmodule.UZModule;
import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;
import com.uzmap.pkg.uzkit.UZUtility;

public class UzUIVividLine extends UZModule {

	private int mId;
	@SuppressLint("UseSparseArrays")
	private Map<Integer, VividLines> mVividesMap = new HashMap<Integer, VividLines>();

	public UzUIVividLine(UZWebView webView) {
		super(webView);
	}

	public void jsmethod_open(final UZModuleContext moduleContext) {
		mId++;
		final VividLines vividLines = new VividLines();
		mVividesMap.put(mId, vividLines);
		vividLines.moduleContext = moduleContext;
		vividLines.id = mId;
		vividLines.vividLayout = new FrameLayout(mContext);
		vividLines.vividLineYAxis = new VividLineYAxis(mContext);
		vividLines.vividLineView = new VividLineView(mContext);
		vividLines.layoutParams = getLayoutParams(moduleContext);
		initDatas(moduleContext, vividLines.vividLineView);
		initStyles(moduleContext, vividLines);
		vividLines.vividLineYAxis.setHeight(dx(vividLines.layoutParams.height));
		vividLines.vividLayout
				.addView(vividLines.vividLineYAxis,
						(int) vividLines.yAxisWidth,
						dx(vividLines.layoutParams.height));
		vividLines.vividLayout.addView(vividLines.vividLineView,
				(int) dx(vividLines.layoutParams.width),
				dx(vividLines.layoutParams.height));
		vividLines.vividLineView
				.init((int) (dx(vividLines.layoutParams.width) - vividLines.yAxisWidth),
						dx(vividLines.layoutParams.height));
		vividLines.vividLineView.setViewId(mId);
		vividLines.vividLineView.setCallBack(moduleContext);
		boolean fixed = moduleContext.optBoolean("fixed", true);
		String fixedOn = moduleContext.optString("fixedOn");
		insertViewToCurWindow(vividLines.vividLayout, vividLines.layoutParams,
				fixedOn, fixed, true);
		vividLines.vividLayout
				.addOnAttachStateChangeListener(new OnAttachStateChangeListener() {

					@Override
					public void onViewDetachedFromWindow(View v) {
					}

					@Override
					public void onViewAttachedToWindow(View v) {
						showCallBack(vividLines);
					}
				});
	}

	public void jsmethod_reloadData(UZModuleContext moduleContext) {
		int id = moduleContext.optInt("id");
		VividLines vividLines = mVividesMap.get(id);
		if (vividLines != null) {
			initDatas(moduleContext, vividLines.vividLineView);
			vividLines.vividLineView.invalidate();
		}
	}

	public void jsmethod_appendData(UZModuleContext moduleContext) {
		int id = moduleContext.optInt("id");
		VividLines vividLines = mVividesMap.get(id);
		if (vividLines != null) {
			appendDatas(moduleContext, vividLines.vividLineView);
			vividLines.vividLineView.invalidate();
		}
	}

	public void jsmethod_close(UZModuleContext moduleContext) {
		int id = moduleContext.optInt("id");
		VividLines vividLines = mVividesMap.get(id);
		if (vividLines != null) {
			mVividesMap.remove(vividLines);
			removeViewFromCurWindow(vividLines.vividLayout);
			vividLines = null;
		}
	}

	public void jsmethod_hide(UZModuleContext moduleContext) {
		int id = moduleContext.optInt("id");
		VividLines vividLines = mVividesMap.get(id);
		if (vividLines != null) {
			vividLines.vividLayout.setVisibility(View.GONE);
		}
	}

	public void jsmethod_show(UZModuleContext moduleContext) {
		int id = moduleContext.optInt("id");
		VividLines vividLines = mVividesMap.get(id);
		if (vividLines != null) {
			vividLines.vividLayout.setVisibility(View.VISIBLE);
		}
	}

	private void showCallBack(VividLines vividLines) {
		JSONObject ret = new JSONObject();
		try {
			ret.put("id", vividLines.id);
			ret.put("eventType", "show");
			vividLines.moduleContext.success(ret, false);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	private void initDatas(UZModuleContext moduleContext,
			VividLineView vividLineView) {
		JSONArray datas = moduleContext.optJSONArray("datas");
		List<VividLineData> dataList = new ArrayList<VividLineData>();
		if (datas != null) {
			int length = datas.length();
			for (int i = 0; i < length; i++) {
				JSONObject data = datas.optJSONObject(i);
				String icon = data.optString("icon");
				Bitmap iconBitmap = null;
				if (icon != null) {
					icon = makeRealPath(icon);
					try {
						iconBitmap = BitmapFactory.decodeStream(UZUtility
								.guessInputStream(icon));
					} catch (IOException e) {
						e.printStackTrace();
					}
				}
				dataList.add(new VividLineData(data.optString("mark"), data
						.optDouble("value"), iconBitmap));
			}
		}
		vividLineView.setDatas(dataList);
	}

	private void appendDatas(UZModuleContext moduleContext,
			VividLineView vividLineView) {
		JSONArray datas = moduleContext.optJSONArray("datas");
		List<VividLineData> dataList = new ArrayList<VividLineData>();
		if (datas != null) {
			int length = datas.length();
			for (int i = 0; i < length; i++) {
				JSONObject data = datas.optJSONObject(i);
				String icon = data.optString("icon");
				Bitmap iconBitmap = null;
				if (icon != null) {
					icon = makeRealPath(icon);
					try {
						iconBitmap = BitmapFactory.decodeStream(UZUtility
								.guessInputStream(icon));
					} catch (IOException e) {
						e.printStackTrace();
					}
				}
				dataList.add(new VividLineData(data.optString("mark"), data
						.optDouble("value"), iconBitmap));
			}
		}
		vividLineView.addDatas(dataList);
	}

	private void initStyles(UZModuleContext moduleContext, VividLines vividLines) {
		setVividLineBg(moduleContext, vividLines);
		setXAxisGap(vividLines);
		setYAxisStyles(vividLines);
		setXAxisStyles(vividLines);
		setCoordinate(vividLines);
		setLineStyles(vividLines);
		setNodeStyles(vividLines);
		setIconStyles(vividLines);
	}

	private void setVividLineBg(UZModuleContext moduleContext,
			VividLines vividLines) {
		String defaultBgStr = "rgba(0,0,0,0)";
		vividLines.styles = moduleContext.optJSONObject("styles");
		if (vividLines.styles != null) {
			String bg = vividLines.styles.optString("bg", defaultBgStr);
			if (bg.contains("://")) {
				bg = makeRealPath(bg);
				setBgBitmap(bg, vividLines);
			} else {
				vividLines.vividLayout.setBackgroundColor(UZUtility
						.parseCssColor(bg));
			}
		}
	}

	@SuppressWarnings("deprecation")
	private void setBgBitmap(String bg, VividLines vividLines) {
		try {
			Bitmap bgBitmap = BitmapFactory.decodeStream(UZUtility
					.guessInputStream(bg));
			vividLines.vividLayout.setBackgroundDrawable(new BitmapDrawable(
					bgBitmap));
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	private void setXAxisGap(VividLines vividLines) {
		double xAxisGap = vividLines.layoutParams.width / 6.0;
		if (vividLines.styles != null) {
			xAxisGap = vividLines.styles.optDouble("xAxisGap", xAxisGap);
		}
		vividLines.vividLineView.setXAxisGap(dx((int) xAxisGap));
	}

	private void setYAxisStyles(VividLines vividLines) {
		double max = 5;
		double min = 1;
		double step = 1;
		double width = vividLines.layoutParams.width / 6.5;
		String suffix = "";
		String color = "#696969";
		double fontSize = 12;
		if (vividLines.styles != null) {
			JSONObject yAxis = vividLines.styles.optJSONObject("yAxis");
			if (yAxis != null) {
				max = yAxis.optDouble("max", max);
				min = yAxis.optDouble("min", min);
				step = yAxis.optDouble("step", step);
				width = yAxis.optDouble("width", width);
				color = yAxis.optString("color", color);
				suffix = yAxis.optString("suffix", suffix);
				fontSize = yAxis.optDouble("size", fontSize);
			}
		}
		vividLines.yAxisWidth = dx((int) width);
		vividLines.vividLineYAxis.setYAxisStyles(max, min, step, suffix,
				UZUtility.parseCssColor(color), fontSize);
		vividLines.vividLineView.setYAxisStyles(max, min, step, suffix,
				vividLines.yAxisWidth);
	}

	private void setXAxisStyles(VividLines vividLines) {
		String color = "#fff";
		double fontSize = 12;
		double height = 1.0 * vividLines.layoutParams.height / 6;

		double bubbleW = vividLines.layoutParams.width / (6.5 * 2);
		double bubbleH = vividLines.layoutParams.height / 9.0;
		Bitmap bubbleBg = null;
		String bubbleColor = "#fff";
		double bubbleFontSize = 14;
		if (vividLines.styles != null) {
			JSONObject xAxis = vividLines.styles.optJSONObject("xAxis");
			if (xAxis != null) {
				color = xAxis.optString("color", color);
				fontSize = xAxis.optDouble("size", fontSize);
				height = xAxis.optDouble("height", height);
				JSONObject bubble = xAxis.optJSONObject("bubble");
				if (bubble != null) {
					bubbleW = bubble.optDouble("w", bubbleW);
					bubbleH = bubble.optDouble("h", bubbleH);
					String bg = bubble.optString("bg");
					if (bg != null && !bg.isEmpty()) {
						try {
							bubbleBg = BitmapFactory.decodeStream(UZUtility
									.guessInputStream(makeRealPath(bg)));
						} catch (IOException e) {
							e.printStackTrace();
						}
					}
					bubbleColor = bubble.optString("color", bubbleColor);
					bubbleFontSize = bubble.optDouble("size", bubbleFontSize);
				}
			}
		}
		vividLines.vividLineYAxis.setXHeight(dx((int) height));
		vividLines.vividLineView.setXAxisStyles(UZUtility.parseCssColor(color),
				fontSize, dx((int) height), dx((int) bubbleW),
				dx((int) bubbleH), bubbleBg,
				UZUtility.parseCssColor(bubbleColor), bubbleFontSize);
	}

	private void setCoordinate(VividLines vividLines) {
		String hColor = "#696969";
		double hWidth = 0.5;
		String hStyle = "solid";
		String vColor = "rgba(0,0,0,0)";
		double vWidth = 0.5;
		String vStyle = "solid";
		if (vividLines.styles != null) {
			JSONObject coordinate = vividLines.styles
					.optJSONObject("coordinate");
			if (coordinate != null) {
				JSONObject horizontal = coordinate.optJSONObject("horizontal");
				if (horizontal != null) {
					hColor = horizontal.optString("color", hColor);
					hWidth = horizontal.optDouble("width", hWidth);
					hStyle = horizontal.optString("style", hStyle);
				}
				JSONObject vertical = coordinate.optJSONObject("vertical");
				if (vertical != null) {
					vColor = vertical.optString("color", vColor);
					vWidth = vertical.optDouble("width", vWidth);
					vStyle = vertical.optString("style", vStyle);
				}
			}
		}
		vividLines.vividLineView.setCoordinateSytles(
				UZUtility.parseCssColor(hColor), hWidth, hStyle,
				UZUtility.parseCssColor(vColor), vWidth, vStyle);
	}

	private void setLineStyles(VividLines vividLines) {
		String color = "#fff";
		double width = 1;
		if (vividLines.styles != null) {
			JSONObject line = vividLines.styles.optJSONObject("line");
			if (line != null) {
				color = line.optString("color", color);
				width = line.optDouble("width", width);
			}
		}
		vividLines.vividLineView.setLineSytles(UZUtility.parseCssColor(color),
				width);
	}

	private void setNodeStyles(VividLines vividLines) {
		String color = "#fff";
		double size = 5;
		boolean hollow = false;
		if (vividLines.styles != null) {
			JSONObject node = vividLines.styles.optJSONObject("node");
			if (node != null) {
				color = node.optString("color", color);
				size = node.optDouble("size", size);
				hollow = node.optBoolean("hollow", hollow);
			}
		}
		vividLines.vividLineView.setNodeSytles(UZUtility.parseCssColor(color),
				size, hollow);
	}

	private void setIconStyles(VividLines vividLines) {
		double width = 60;
		double height = 60;
		if (vividLines.styles != null) {
			JSONObject icon = vividLines.styles.optJSONObject("icon");
			if (icon != null) {
				width = icon.optDouble("width", width);
				height = icon.optDouble("height", height);
			}
		}
		vividLines.vividLineView.setIconSytles(dx((int) width),
				dx((int) height));
	}

	private LayoutParams getLayoutParams(UZModuleContext moduleContext) {
		JSONObject rect = moduleContext.optJSONObject("rect");
		int screenWidth = getScreenWidth(mContext);
		int screenHeigth = getScreenHeight(mContext);
		LayoutParams layoutParams = null;
		if (rect != null) {
			int x = rect.optInt("x");
			int y = rect.optInt("y");
			int w = rect.optInt("w", screenWidth);
			int h = rect.optInt("h", screenHeigth);
			layoutParams = new LayoutParams(w, h);
			layoutParams.setMargins(x, y, 0, 0);
		} else {
			layoutParams = new LayoutParams(screenWidth, screenHeigth);
		}
		return layoutParams;
	}

	private int dx(int dip) {
		return UZUtility.dipToPix(dip);
	}

	private int getScreenWidth(Activity act) {
		DisplayMetrics metric = new DisplayMetrics();
		act.getWindowManager().getDefaultDisplay().getMetrics(metric);
		return UZCoreUtil.pixToDip(metric.widthPixels);
	}

	private int getScreenHeight(Activity act) {
		DisplayMetrics metric = new DisplayMetrics();
		act.getWindowManager().getDefaultDisplay().getMetrics(metric);
		return UZCoreUtil.pixToDip(metric.heightPixels);
	}

	class VividLines {
		int id;
		UZModuleContext moduleContext;
		FrameLayout vividLayout;
		VividLineYAxis vividLineYAxis;
		VividLineView vividLineView;
		JSONObject styles;
		double yAxisWidth;
		LayoutParams layoutParams;
	}
}
