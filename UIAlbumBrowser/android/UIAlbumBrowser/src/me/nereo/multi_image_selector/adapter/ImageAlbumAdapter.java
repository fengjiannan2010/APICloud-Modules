package me.nereo.multi_image_selector.adapter;

import android.content.Context;
import android.graphics.Point;
import android.graphics.drawable.BitmapDrawable;
import android.os.Build;
import android.os.Build.VERSION;
import android.util.Log;
import android.view.Display;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.view.WindowManager;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.Toast;

import com.apicloud.UIAlbumBrowser.MediaFile;
import com.apicloud.UIAlbumBrowser.MediaResource;
import com.apicloud.UIAlbumBrowser.MediaResource.FileInfo;
import com.apicloud.UIAlbumBrowser.Utils;
import com.bumptech.glide.DrawableRequestBuilder;
import com.bumptech.glide.DrawableTypeRequest;
import com.bumptech.glide.Glide;
import com.bumptech.glide.RequestManager;
import com.uzmap.pkg.uzcore.UZResourcesIDFinder;
import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;
import com.uzmap.pkg.uzkit.UZUtility;
import java.util.ArrayList;
import java.util.List;
import me.nereo.multi_image_selector.utils.ResUtils;

public class ImageAlbumAdapter extends BaseAdapter {
	private Context context;
	private List<MediaResource.FileInfo> paths = new ArrayList();
	public List<MediaResource.FileInfo> selectedPaths = new ArrayList();
	private int width;
	private int max;
	final int mGridWidth;
	private BitmapDrawable normal;
	private BitmapDrawable active;
	private int iconSize;

	public void setSelectedPaths(List<MediaResource.FileInfo> selectedFileInfos) {
		selectedPaths = selectedFileInfos;
		notifyDataSetChanged();
	}

	public void addSelectedPath(MediaResource.FileInfo fileInfo,
			UZModuleContext cbContext, String groupId) {
		String path = fileInfo.path;
		String SS = MediaFile.getMimeTypeForFile(path);

		boolean contains = SS.contains("video");
		if (contains) {
			return;
		}
		if (this.selectedPaths.size() >= this.max) {
			if (this.selectedPaths.contains(fileInfo)) {
				this.selectedPaths.remove(fileInfo);
				Utils.AlbumCallback(cbContext, "cancel", groupId,
						fileInfo.path, "image");
				notifyDataSetChanged();
			} else {
				Utils.callbackForOpenGroup(cbContext, "max", null, null, null);
				Toast.makeText(this.context, "图片最多选择" + this.max + "张", 0)
						.show();
			}
		} else {
			if (!this.selectedPaths.contains(fileInfo)) {
				this.selectedPaths.add(fileInfo);

				Log.i("debug", "path: " + fileInfo.path);

				Utils.AlbumCallback(cbContext, "select", groupId,
						fileInfo.path, "image");
			} else {
				this.selectedPaths.remove(fileInfo);
				Utils.AlbumCallback(cbContext, "cancel", groupId,
						fileInfo.path, "image");
			}
			notifyDataSetChanged();
		}
	}

	public ImageAlbumAdapter(Context context, int width, int max,
			BitmapDrawable normal, BitmapDrawable active, int iconSize,
			int conlum) {
		this.context = context;
		this.width = width;
		this.max = max;
		this.normal = normal;
		this.active = active;
		this.iconSize = iconSize;

		WindowManager wm = (WindowManager) context.getSystemService("window");
		int width1 = 0;
		if (Build.VERSION.SDK_INT >= 13) {
			Point size = new Point();
			wm.getDefaultDisplay().getSize(size);
			width1 = size.x;
		} else {
			width = wm.getDefaultDisplay().getWidth();
		}
		this.mGridWidth = (width / conlum);
	}

	public int getCount() {
		return this.paths.size();
	}

	public MediaResource.FileInfo getItem(int arg0) {
		return (MediaResource.FileInfo) this.paths.get(arg0);
	}

	public long getItemId(int arg0) {
		return arg0;
	}

	public void setPaths(List<MediaResource.FileInfo> paths) {
		this.paths = paths;
		notifyDataSetChanged();
	}

	public View getView(int arg0, View arg1, ViewGroup arg2) {
		if (arg1 == null) {
			int album_image_layout_id = UZResourcesIDFinder
					.getResLayoutID("mis_album_image_layout");
			arg1 = View.inflate(this.context, album_image_layout_id, null);
		}
		int showImageId = UZResourcesIDFinder.getResIdID("image1");
		ImageView showImage = (ImageView) arg1.findViewById(showImageId);
		int mo_video_Id = UZResourcesIDFinder.getResIdID("mo_video");
		ImageView Imagevideo = (ImageView) arg1.findViewById(mo_video_Id);

		int coverimagebgId = UZResourcesIDFinder.getResIdID("coverimagebg");
		ImageView coverimagebg = (ImageView) arg1.findViewById(coverimagebgId);
		int coverImageId = UZResourcesIDFinder.getResIdID("coverImage1");
		ImageView coverImage = (ImageView) arg1.findViewById(coverImageId);

		ViewGroup.LayoutParams layoutParams = coverImage.getLayoutParams();
		layoutParams.width = UZUtility.dipToPix(this.iconSize);
		layoutParams.height = UZUtility.dipToPix(this.iconSize);

		int mo_seleter_press_id = ResUtils.getInstance().getDrawableId(
				this.context, "mo_seleter_press");
		int mo_seleter_normal_id = ResUtils.getInstance().getDrawableId(
				this.context, "mo_seleter_normal");

		MediaResource.FileInfo fileInfo = (MediaResource.FileInfo) this.paths
				.get(arg0);
		String path = fileInfo.path;
		String SS = MediaFile.getMimeTypeForFile(path);

		boolean contains = SS.contains("video");
		if (contains) {
			coverImage.setVisibility(8);
			coverimagebg.setVisibility(8);
			Imagevideo.setVisibility(0);
		} else {
			Imagevideo.setVisibility(8);
			if (this.selectedPaths.contains(this.paths.get(arg0))) {
				if (this.active != null) {
					coverImage.setVisibility(0);
					coverImage.setBackgroundDrawable(this.active);
					coverimagebg.setVisibility(0);
				} else {
					coverImage.setVisibility(0);
					coverImage.setImageResource(mo_seleter_press_id);
					coverimagebg.setVisibility(0);
				}
			} else if (this.normal != null) {
				coverImage.setVisibility(0);
				coverImage.setBackgroundDrawable(this.normal);
				coverimagebg.setVisibility(8);
			} else {
				coverImage.setImageResource(mo_seleter_normal_id);
				coverImage.setVisibility(0);
				coverimagebg.setVisibility(8);
			}
		}
		int mis_default_error_id = ResUtils.getInstance().getDrawableId(
				this.context, "mis_default_error");
		Glide.with(this.context)
				.load(((MediaResource.FileInfo) this.paths.get(arg0)).path)
				.placeholder(mis_default_error_id)
				.override(this.mGridWidth, this.mGridWidth)
				.error(mis_default_error_id).centerCrop().into(showImage);
		return arg1;
	}

	public void videoCallBack() {
	}
}
