package com.apicloud.UIAlbumBrowser;

import android.text.TextUtils;
import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.List;
import org.json.JSONException;
import org.json.JSONObject;

public class Utils {
	public static String stringToMD5(String string) {
		if (TextUtils.isEmpty(string)) {
			return null;
		}
		
		byte[] hash;
		try {
			hash = MessageDigest.getInstance("MD5").digest(
					string.getBytes("UTF-8"));
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
			return null;
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
			return null;
		}
		
		StringBuilder hex = new StringBuilder(hash.length * 2);
		for (byte b : hash) {
			if ((b & 0xFF) < 16) {
				hex.append("0");
			}
			hex.append(Integer.toHexString(b & 0xFF));
		}
		return hex.toString();
	}

	public static List<MediaResource.FileInfo> sortFile(
			List<MediaResource.FileInfo> list, int order) {
		if (order == MediaResource.ORDER_DESC) {
			return descSortByTime(list);
		}
		return ascSortByTime(list);
	}

	private static List<MediaResource.FileInfo> descSortByTime(
			List<MediaResource.FileInfo> list) {
		for (int out = 0; out < list.size(); out++) {
			int max = out;
			for (int in = out + 1; in < list.size(); in++) {
				if (((MediaResource.FileInfo) list.get(max)).modifiedTime < ((MediaResource.FileInfo) list
						.get(in)).modifiedTime) {
					max = in;
				}
			}
			if (out != max) {
				MediaResource.FileInfo temp = (MediaResource.FileInfo) list
						.get(out);
				list.set(out, (MediaResource.FileInfo) list.get(max));
				list.set(max, temp);
			}
		}
		return list;
	}

	private static List<MediaResource.FileInfo> ascSortByTime(
			List<MediaResource.FileInfo> list) {
		for (int i = 0; i < list.size() - 1; i++) {
			for (int j = i + 1; j < list.size(); j++) {
				if (((MediaResource.FileInfo) list.get(j)).modifiedTime < ((MediaResource.FileInfo) list
						.get(i)).modifiedTime) {
					MediaResource.FileInfo temp = (MediaResource.FileInfo) list
							.get(i);
					list.set(i, (MediaResource.FileInfo) list.get(j));
					list.set(j, temp);
				}
			}
		}
		return list;
	}

	public static void callbackForOpenGroup(UZModuleContext uzContext,
			String eventType, String groupName, String groupId, String path) {
		JSONObject ret = new JSONObject();
		try {
			ret.put("eventType", eventType);
			if (!TextUtils.isEmpty(groupName)) {
				ret.put("groupName", groupName);
			}
			if (!TextUtils.isEmpty(groupId)) {
				ret.put("groupId", groupId);
			}
			if (!TextUtils.isEmpty(path)) {
				JSONObject target = new JSONObject();
				target.put("path", path);
				target.put("thumbPath", UIAlbumBrowser.checkOrCreateThumbImage(
						path, null, 300, 300));
				ret.put("target", target);
			}
			uzContext.success(ret, false);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	public static void callback(UZModuleContext uzContext, String eventType,
			String groupId, String path) {
		JSONObject ret = new JSONObject();
		try {
			ret.put("eventType", eventType);
			if (!TextUtils.isEmpty(groupId)) {
				ret.put("groupId", groupId);
			}
			if (!TextUtils.isEmpty(path)) {
				JSONObject target = new JSONObject();
				target.put("path", path);
				target.put("thumbPath", UIAlbumBrowser.checkOrCreateThumbImage(
						path, null, 300, 300));
				ret.put("target", target);
			}
			if (uzContext != null) {
				uzContext.success(ret, false);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	public static void AlbumCallback(UZModuleContext uzContext,
			String eventType, String groupId, String path, String type) {
		JSONObject ret = new JSONObject();
		try {
			ret.put("eventType", eventType);
			if (!TextUtils.isEmpty(groupId)) {
				ret.put("groupId", groupId);
			}
			if (!TextUtils.isEmpty(path)) {
				JSONObject target = new JSONObject();
				target.put("path", path);
				target.put("thumbPath", UIAlbumBrowser.checkOrCreateThumbImage(
						path, null, 300, 300));
				target.put("type", type);
				ret.put("target", target);
			}
			if (uzContext != null) {
				uzContext.success(ret, false);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}
}
