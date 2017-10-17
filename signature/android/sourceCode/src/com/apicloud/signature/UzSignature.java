/**
 * APICloud Modules
 * Copyright (c) 2014-2015 by APICloud, Inc. All Rights Reserved.
 * Licensed under the terms of the The MIT License (MIT).
 * Please see the license.html included with this distribution for details.
 */
package com.apicloud.signature;

import java.io.UnsupportedEncodingException;
import java.security.InvalidKeyException;
import java.security.KeyPair;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import java.security.spec.InvalidKeySpecException;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import org.json.JSONException;
import org.json.JSONObject;
import android.annotation.SuppressLint;
import android.util.Base64;
import com.uzmap.pkg.uzcore.UZWebView;
import com.uzmap.pkg.uzcore.uzmodule.ModuleResult;
import com.uzmap.pkg.uzcore.uzmodule.UZModule;
import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;

@SuppressLint("DefaultLocale")
public class UzSignature extends UZModule {

	public UzSignature(UZWebView webView) {
		super(webView);
	}

	public void jsmethod_md5(UZModuleContext moduleContext) {
		String data = moduleContext.optString("data");
		boolean uppercase = moduleContext.optBoolean("uppercase", true);
		if (data != null && !data.isEmpty()) {
			String md5 = md5(data);
			if (uppercase) {
				md5 = md5.toUpperCase();
			}
			callBack(moduleContext, md5, -1);
		} else {
			callBack(moduleContext, null, 1);
		}
	}

	public ModuleResult jsmethod_md5Sync_sync(UZModuleContext moduleContext) {
		String data = moduleContext.optString("data");
		boolean uppercase = moduleContext.optBoolean("uppercase", true);
		if (data != null && !data.isEmpty()) {
			String md5 = md5(data);
			if (uppercase) {
				md5 = md5.toUpperCase();
			}
			return new ModuleResult(md5);
		} else {
			return new ModuleResult();
		}
	}

	public void jsmethod_sha1(UZModuleContext moduleContext) {
		String data = moduleContext.optString("data");
		boolean uppercase = moduleContext.optBoolean("uppercase", true);
		if (data != null && !data.isEmpty()) {
			String sha1 = sha(data);
			if (uppercase) {
				sha1 = sha1.toUpperCase();
			}
			callBack(moduleContext, sha1, -1);
		} else {
			callBack(moduleContext, null, 1);
		}
	}

	public void jsmethod_hmacSha1(UZModuleContext moduleContext) {
		String data = moduleContext.optString("data");
		String key = moduleContext.optString("key");
		if (data != null && !data.isEmpty()) {
			String sha1 = hmacSha1(data, key);
			callBack(moduleContext, sha1, -1);
		} else {
			callBack(moduleContext, null, 1);
		}
	}

	public ModuleResult jsmethod_sha1Sync_sync(UZModuleContext moduleContext) {
		String data = moduleContext.optString("data");
		boolean uppercase = moduleContext.optBoolean("uppercase", true);
		if (data != null && !data.isEmpty()) {
			String sha1 = sha(data);
			if (uppercase) {
				sha1 = sha1.toUpperCase();
			}
			return new ModuleResult(sha1);
		} else {
			return new ModuleResult();
		}
	}

	public ModuleResult jsmethod_hmacSha1Sync_sync(UZModuleContext moduleContext) {
		String data = moduleContext.optString("data");
		String key = moduleContext.optString("key");
		if (data != null && !data.isEmpty()) {
			String sha1 = hmacSha1(data, key);
			return new ModuleResult(sha1);
		} else {
			return new ModuleResult();
		}
	}

	public void jsmethod_aes(UZModuleContext moduleContext) {
		String key = moduleContext.optString("key");
		String data = moduleContext.optString("data");
		if (data != null && !data.isEmpty()) {
			String aes = new AES().encrypt(key, data.getBytes());
			callBack(moduleContext, aes, -1);
		} else {
			callBack(moduleContext, null, 1);
		}
	}

	public void jsmethod_desECB(UZModuleContext moduleContext) {
		String key = moduleContext.optString("key");
		String data = moduleContext.optString("data");
		if (data != null && !data.isEmpty()) {
			String des = DesEncryptUtil.encryptCondition(data, key);
			callBack(moduleContext, des, -1);
		} else {
			callBack(moduleContext, null, 1);
		}
	}

	public void jsmethod_aesECB(UZModuleContext moduleContext) {
		String key = moduleContext.optString("key");
		String data = moduleContext.optString("data");
		if (data != null && !data.isEmpty()) {
			String aes = new AES().aesEncryptECB(key, data.getBytes());
			callBack(moduleContext, aes, -1);
		} else {
			callBack(moduleContext, null, 1);
		}
	}

	public ModuleResult jsmethod_aesSync_sync(UZModuleContext moduleContext) {
		String key = moduleContext.optString("key");
		String data = moduleContext.optString("data");
		if (data != null && !data.isEmpty()) {
			String aes = new AES().encrypt(key, data.getBytes());
			return new ModuleResult(aes);
		} else {
			return new ModuleResult();
		}
	}

	public ModuleResult jsmethod_desECBSync_sync(UZModuleContext moduleContext) {
		String key = moduleContext.optString("key");
		String data = moduleContext.optString("data");
		if (data != null && !data.isEmpty()) {
			String des = DesEncryptUtil.encryptCondition(data, key);
			return new ModuleResult(des);
		} else {
			return new ModuleResult();
		}
	}

	public ModuleResult jsmethod_aesECBSync_sync(UZModuleContext moduleContext) {
		String key = moduleContext.optString("key");
		String data = moduleContext.optString("data");
		if (data != null && !data.isEmpty()) {
			String aes = new AES().aesEncryptECB(key, data.getBytes());
			return new ModuleResult(aes);
		} else {
			return new ModuleResult();
		}
	}

	public void jsmethod_aesDecode(UZModuleContext moduleContext) {
		String key = moduleContext.optString("key");
		String data = moduleContext.optString("data");
		if (data != null && !data.isEmpty()) {
			String aesDecode = new AES().decrypt(key, data);
			callBack(moduleContext, aesDecode, -1);
		} else {
			callBack(moduleContext, null, 1);
		}
	}

	public void jsmethod_desDecodeECB(UZModuleContext moduleContext) {
		String key = moduleContext.optString("key");
		String data = moduleContext.optString("data");
		if (data != null && !data.isEmpty()) {
			String desDecode = DesEncryptUtil.decryptString(data, key);
			callBack(moduleContext, desDecode, -1);
		} else {
			callBack(moduleContext, null, 1);
		}
	}

	public void jsmethod_aesDecodeECB(UZModuleContext moduleContext) {
		String key = moduleContext.optString("key");
		String data = moduleContext.optString("data");
		if (data != null && !data.isEmpty()) {
			String aesDecode = new AES().aesDecryptECB(key, data);
			callBack(moduleContext, aesDecode, -1);
		} else {
			callBack(moduleContext, null, 1);
		}
	}

	public ModuleResult jsmethod_aesDecodeSync_sync(
			UZModuleContext moduleContext) {
		String key = moduleContext.optString("key");
		String data = moduleContext.optString("data");
		if (data != null && !data.isEmpty()) {
			String aesDecode = new AES().decrypt(key, data);
			return new ModuleResult(aesDecode);
		} else {
			return new ModuleResult();
		}
	}

	public ModuleResult jsmethod_desDecodeECBSync_sync(
			UZModuleContext moduleContext) {
		String key = moduleContext.optString("key");
		String data = moduleContext.optString("data");
		if (data != null && !data.isEmpty()) {
			String aesDecode = DesEncryptUtil.decryptString(data, key);
			return new ModuleResult(aesDecode);
		} else {
			return new ModuleResult();
		}
	}

	public ModuleResult jsmethod_aesDecodeECBSync_sync(
			UZModuleContext moduleContext) {
		String key = moduleContext.optString("key");
		String data = moduleContext.optString("data");
		if (data != null && !data.isEmpty()) {
			String aesDecode = new AES().aesDecryptECB(key, data);
			return new ModuleResult(aesDecode);
		} else {
			return new ModuleResult();
		}
	}

	public void jsmethod_base64(UZModuleContext moduleContext) {
		String data = moduleContext.optString("data");
		if (data != null && !data.isEmpty()) {
			String base64 = base64(data);
			callBack(moduleContext, base64, -1);
		} else {
			callBack(moduleContext, null, 1);
		}
	}

	public ModuleResult jsmethod_base64Sync_sync(UZModuleContext moduleContext) {
		String data = moduleContext.optString("data");
		if (data != null && !data.isEmpty()) {
			String base64 = base64(data);
			ModuleResult mr = new ModuleResult(base64);
			return mr;
		} else {
			return new ModuleResult();
		}
	}

	public void jsmethod_base64Decode(UZModuleContext moduleContext) {
		String data = moduleContext.optString("data");
		if (data != null && !data.isEmpty()) {
			String base64Decode = base64Decode(data);
			callBack(moduleContext, base64Decode, -1);
		} else {
			callBack(moduleContext, null, 1);
		}
	}

	public ModuleResult jsmethod_base64DecodeSync_sync(
			UZModuleContext moduleContext) {
		String data = moduleContext.optString("data");
		if (data != null && !data.isEmpty()) {
			String base64Decode = base64Decode(data);
			return new ModuleResult(base64Decode);
		} else {
			return new ModuleResult();
		}
	}

	public void jsmethod_rsaKeyPair(UZModuleContext moduleContext) {
		int keyLength = moduleContext.optInt("keyLength", 1024);
		KeyPair keyPair = RSAUtils.generateRSAKeyPair(keyLength);
		rsaKeyCallBack(moduleContext, keyPair.getPrivate(), keyPair.getPublic());
	}

	public ModuleResult jsmethod_rsaKeyPairSync_sync(
			UZModuleContext moduleContext) {
		int keyLength = moduleContext.optInt("keyLength", 1024);
		KeyPair keyPair = RSAUtils.generateRSAKeyPair(keyLength);
		return rsaKeyResult(moduleContext, keyPair.getPrivate(),
				keyPair.getPublic());
	}

	public void jsmethod_rsaRestorePrivateKey(UZModuleContext moduleContext) {
		String modulus = moduleContext.optString("modulus");
		String privateExponent = moduleContext.optString("exponent");
		PrivateKey privateKey;
		try {
			privateKey = RSAUtils.getPrivateKey(modulus, privateExponent);
			rsaKeyCallBack(moduleContext, privateKey, null);
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		} catch (InvalidKeySpecException e) {
			e.printStackTrace();
		}
	}

	public void jsmethod_rsaRestorePublicKey(UZModuleContext moduleContext) {
		String modulus = moduleContext.optString("modulus");
		String publicExponent = moduleContext.optString("exponent");
		PublicKey publicKey;
		try {
			publicKey = RSAUtils.getPublicKey(modulus, publicExponent);
			rsaKeyCallBack(moduleContext, null, publicKey);
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		} catch (InvalidKeySpecException e) {
			e.printStackTrace();
		}
	}

	public void jsmethod_rsa(UZModuleContext moduleContext) {
		String data = moduleContext.optString("data");
		String publicKey = moduleContext.optString("publicKey");
		if (data != null && !data.isEmpty() && publicKey != null
				&& !publicKey.isEmpty()) {
			try {
				byte[] result = RSAUtils.encryptData(data.getBytes(),
						RSAUtils.loadPublicKey(publicKey));
				callBack(
						moduleContext,
						Base64.encodeToString(result, Base64.DEFAULT).replace(
								"\n", ""), -1);
			} catch (Exception e) {
				e.printStackTrace();
				callBack(moduleContext, null, -1);
			}
		} else {
			callBack(moduleContext, null, 1);
		}
	}

	public ModuleResult jsmethod_rsaSync_sync(UZModuleContext moduleContext) {
		String data = moduleContext.optString("data");
		String publicKey = moduleContext.optString("publicKey");
		if (data != null && !data.isEmpty() && publicKey != null
				&& !publicKey.isEmpty()) {
			try {
				byte[] result = RSAUtils.encryptData(data.getBytes(),
						RSAUtils.loadPublicKey(publicKey));
				return new ModuleResult(Base64.encodeToString(result,
						Base64.DEFAULT).replace("\n", ""));
			} catch (Exception e) {
				e.printStackTrace();
			}
			return new ModuleResult();
		} else {
			return new ModuleResult();
		}
	}

	public void jsmethod_rsaDecode(UZModuleContext moduleContext) {
		String data = moduleContext.optString("data");
		String privateKey = moduleContext.optString("privateKey");
		if (data != null && !data.isEmpty() && privateKey != null
				&& !privateKey.isEmpty()) {
			try {
				byte[] result = RSAUtils.decryptData(
						Base64.decode(data.getBytes(), Base64.DEFAULT),
						RSAUtils.loadPrivateKey(privateKey));
				callBack(moduleContext, new String(result), -1);
			} catch (Exception e) {
				e.printStackTrace();
				callBack(moduleContext, null, -1);
			}
		} else {
			callBack(moduleContext, null, 1);
		}
	}

	public ModuleResult jsmethod_rsaDecodeSync_sync(
			UZModuleContext moduleContext) {
		String data = moduleContext.optString("data");
		String privateKey = moduleContext.optString("privateKey");
		if (data != null && !data.isEmpty() && privateKey != null
				&& !privateKey.isEmpty()) {
			try {
				byte[] result = RSAUtils.decryptData(
						Base64.decode(data.getBytes(), Base64.DEFAULT),
						RSAUtils.loadPrivateKey(privateKey));
				return new ModuleResult(new String(result));
			} catch (Exception e) {
				e.printStackTrace();
				return new ModuleResult();
			}
		} else {
			return new ModuleResult();
		}
	}

	private void rsaKeyCallBack(UZModuleContext moduleContext,
			PrivateKey privateKey, PublicKey publicKey) {
		JSONObject ret = new JSONObject();
		JSONObject privateKeyJson = new JSONObject();
		JSONObject publicKeyJson = new JSONObject();
		try {
			if (privateKey != null) {
				privateKeyJson.put(
						"encoded",
						Base64.encodeToString(privateKey.getEncoded(),
								Base64.DEFAULT).replace("\n", ""));
				RSAPrivateKey rsaPrivateKey = (RSAPrivateKey) privateKey;
				privateKeyJson.put("modulus", rsaPrivateKey.getModulus()
						.toString());
				privateKeyJson.put("exponent", rsaPrivateKey
						.getPrivateExponent().toString());
				ret.put("privateKey", privateKeyJson);
			}

			if (publicKey != null) {
				publicKeyJson.put(
						"encoded",
						Base64.encodeToString(publicKey.getEncoded(),
								Base64.DEFAULT).replace("\n", ""));
				RSAPublicKey rsaPublicKey = (RSAPublicKey) publicKey;
				publicKeyJson.put("modulus", rsaPublicKey.getModulus()
						.toString());
				publicKeyJson.put("exponent", rsaPublicKey.getPublicExponent()
						.toString());
				ret.put("publicKey", publicKeyJson);
			}
			moduleContext.success(ret, true);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	private ModuleResult rsaKeyResult(UZModuleContext moduleContext,
			PrivateKey privateKey, PublicKey publicKey) {
		JSONObject ret = new JSONObject();
		JSONObject privateKeyJson = new JSONObject();
		JSONObject publicKeyJson = new JSONObject();
		try {
			if (privateKey != null) {
				privateKeyJson.put(
						"encoded",
						Base64.encodeToString(privateKey.getEncoded(),
								Base64.DEFAULT).replace("\n", ""));
				RSAPrivateKey rsaPrivateKey = (RSAPrivateKey) privateKey;
				privateKeyJson.put("modulus", rsaPrivateKey.getModulus()
						.toString());
				privateKeyJson.put("exponent", rsaPrivateKey
						.getPrivateExponent().toString());
				ret.put("privateKey", privateKeyJson);
			}

			if (publicKey != null) {
				publicKeyJson.put(
						"encoded",
						Base64.encodeToString(publicKey.getEncoded(),
								Base64.DEFAULT).replace("\n", ""));
				RSAPublicKey rsaPublicKey = (RSAPublicKey) publicKey;
				publicKeyJson.put("modulus", rsaPublicKey.getModulus()
						.toString());
				publicKeyJson.put("exponent", rsaPublicKey.getPublicExponent()
						.toString());
				ret.put("publicKey", publicKeyJson);
			}
			return new ModuleResult(ret);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return new ModuleResult();
	}

	private void callBack(UZModuleContext moduleContext, String value, int code) {
		JSONObject ret = new JSONObject();
		JSONObject err = new JSONObject();
		try {
			if (value != null) {
				ret.put("status", true);
				ret.put("value", value);
				moduleContext.success(ret, true);
			} else {
				ret.put("status", false);
				err.put("code", code);
				moduleContext.error(ret, err, true);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	private String md5(String s) {
		char hexDigits[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
				'a', 'b', 'c', 'd', 'e', 'f' };
		try {
			byte[] strTemp = s.getBytes();
			MessageDigest mdTemp = MessageDigest.getInstance("MD5");
			mdTemp.update(strTemp);
			byte[] md = mdTemp.digest();
			int j = md.length;
			char str[] = new char[j * 2];
			int k = 0;
			for (int i = 0; i < j; i++) {
				byte byte0 = md[i];
				str[k++] = hexDigits[byte0 >>> 4 & 0xf];
				str[k++] = hexDigits[byte0 & 0xf];
			}
			return new String(str);
		} catch (Exception e) {
			return null;
		}
	}

	private String sha(String s) {
		byte[] digesta = null;
		try {
			MessageDigest alga = MessageDigest.getInstance("SHA-1");
			alga.update(s.getBytes());
			digesta = alga.digest();
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		}
		return bytesToHexString(digesta);
	}

	public static String bytesToHexString(byte[] src) {
		StringBuilder stringBuilder = new StringBuilder("");
		if (src == null || src.length <= 0) {
			return null;
		}
		for (int i = 0; i < src.length; i++) {
			int v = src[i] & 0xFF;
			String hv = Integer.toHexString(v);
			if (hv.length() < 2) {
				stringBuilder.append(0);
			}
			stringBuilder.append(hv);
		}
		return stringBuilder.toString();
	}

	private String base64(String s) {
		return new String(Base64.encode(s.getBytes(), Base64.DEFAULT)).replace(
				"\n", "");
	}

	private String base64Decode(String s) {
		return new String(Base64.decode(s.getBytes(), Base64.DEFAULT));
	}

	private String hmacSha1(String base, String key) {
		String type = "HmacSHA1";
		SecretKeySpec secret;
		Mac mac;
		try {
			secret = new SecretKeySpec(key.getBytes("UTF-8"), type);
			mac = Mac.getInstance(type);
			mac.init(secret);
			byte[] digest = mac.doFinal(base.getBytes("UTF-8"));
			return bytesToHexString(digest);
		} catch (UnsupportedEncodingException e1) {
			e1.printStackTrace();
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		} catch (InvalidKeyException e) {
			e.printStackTrace();
		}
		return null;
	}
}
