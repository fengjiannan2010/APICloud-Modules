package com.apicloud.signature;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Arrays;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.CipherInputStream;
import javax.crypto.CipherOutputStream;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.KeyGenerator;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;

import org.json.JSONObject;

import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;

import android.util.Log;

public class AESUtils {
	private static byte[] iv = { 0xA, 1, 0xB, 5, 4, 0xF, 7, 9, 0x17, 3, 1, 6, 8, 0xC, 0xD, 91 };

	public static String encrypt(byte[] text, byte[] key, byte[] iv) {
		try {
			if (key.length % 16 != 0) {
				int groups = key.length / 16 + (key.length % 16 != 0 ? 1 : 0);
				byte[] temp = new byte[groups * 16];
				Arrays.fill(temp, (byte) 0);
				System.arraycopy(key, 0, temp, 0, key.length);
				key = temp;
			}
			KeyGenerator generator = KeyGenerator.getInstance("AES");
			generator.init(128);
			SecretKey k = new SecretKeySpec(key, "AES");
			Cipher c = Cipher.getInstance("AES/CBC/PKCS7Padding");
			c.init(Cipher.ENCRYPT_MODE, k, new IvParameterSpec(iv));
			byte[] encrypted = c.doFinal(text);

			String result = bytesToHexString(encrypted);

			return result.toUpperCase();
		} catch (Exception e) {
			return "";
		}
	}

	public static String decrypt(String data, byte[] key, byte[] iv) {
		try {
			if (key.length % 16 != 0) {
				int groups = key.length / 16 + (key.length % 16 != 0 ? 1 : 0);
				byte[] temp = new byte[groups * 16];
				Arrays.fill(temp, (byte) 0);
				System.arraycopy(key, 0, temp, 0, key.length);
				key = temp;
			}
			KeyGenerator generator = KeyGenerator.getInstance("AES");
			generator.init(128);
			SecretKey k = new SecretKeySpec(key, "AES");
			Cipher c = Cipher.getInstance("AES/CBC/PKCS7Padding");
			c.init(Cipher.DECRYPT_MODE, k, new IvParameterSpec(iv));
			byte[] bys = hexStringToBytes(data);
			byte[] decrypted = c.doFinal(bys);
			String ret = new String(decrypted);

			return ret;
		} catch (Exception e) {

			return "";
		}

	}

	/**
	 * 文件加密
	 * 
	 * @param key
	 * @param sourceFilePath
	 * @param destFilePath
	 * @return
	 */
	public static File encryptFile(String key, String iv, String sourceFilePath, String destFilePath) {
		FileInputStream in = null;
		FileOutputStream out = null;
		File destFile = null;
		File sourceFile = null;
		try {
			sourceFile = new File(sourceFilePath);

			destFile = new File(destFilePath);
			if (sourceFile.exists() && sourceFile.isFile()) {
				if (!destFile.getParentFile().exists()) {
					destFile.getParentFile().mkdirs();
				}
				destFile.createNewFile();
				in = new FileInputStream(sourceFile);
				out = new FileOutputStream(destFile);
				Cipher cipher = initAESCipher256(key, iv, Cipher.ENCRYPT_MODE);
				//Cipher cipher = getCipher(key, iv, Cipher.ENCRYPT_MODE);
				// 以加密流写入文件
				CipherInputStream cipherInputStream = new CipherInputStream(in, cipher);
				byte[] cache = new byte[1024];
				int nRead = 0;
				while ((nRead = cipherInputStream.read(cache)) != -1) {
					out.write(cache, 0, nRead);
					out.flush();
				}
				cipherInputStream.close();
				
				
//				while((nRead = in.read(cache)) != -1) {
//					byte[] ciphertext = encrypt(CIPHERMODEPADDING, skforAES, IV, cache);
//					out.write(ciphertext, 0, nRead);
//					out.flush();
//				}
				
			}
		} catch (FileNotFoundException e) {
			e.printStackTrace(); // To change body of catch statement use File | Settings | File Templates.
		} catch (IOException e) {
			e.printStackTrace(); // To change body of catch statement use File | Settings | File Templates.
		} finally {
			try {
				out.close();
			} catch (IOException e) {
				e.printStackTrace(); // To change body of catch statement use File | Settings | File Templates.
			}
			try {
				in.close();
			} catch (IOException e) {
				e.printStackTrace(); // To change body of catch statement use File | Settings | File Templates.
			}
		}
		return destFile;
	}
	
	/**
	 * TODO Test
	 * @param text
	 * @param key
	 * @param iv
	 * @return
	 */
	public static byte[] encrypt1(byte[] text, byte[] key, byte[] iv) {
		try {
			if (key.length % 16 != 0) {
				int groups = key.length / 16 + (key.length % 16 != 0 ? 1 : 0);
				byte[] temp = new byte[groups * 16];
				Arrays.fill(temp, (byte) 0);
				System.arraycopy(key, 0, temp, 0, key.length);
				key = temp;
			}
			KeyGenerator generator = KeyGenerator.getInstance("AES");
			generator.init(256);
			SecretKey k = new SecretKeySpec(key, "AES");
			Cipher c = Cipher.getInstance("AES/CBC/PKCS7Padding");
			c.init(Cipher.ENCRYPT_MODE, k, new IvParameterSpec(iv));
			byte[] encrypted = c.doFinal(text);

			return encrypted;
		} catch (Exception e) {
			return null;
		}
	}

	/**
	 * 文件解密
	 * @param key
	 * @param sourceFilePath
	 * @param destFilePath
	 * @return
	 */
	public static File decryptFile(String key, String iv, String sourceFilePath, String destFilePath) {
		FileInputStream in = null;
		FileOutputStream out = null;
		File destFile = null;
		File sourceFile = null;
		try {
			sourceFile = new File(sourceFilePath);
			destFile = new File(destFilePath);
			if (sourceFile.exists() && sourceFile.isFile()) {
				if (!destFile.getParentFile().exists()) {
					destFile.getParentFile().mkdirs();
				}
				destFile.createNewFile();
				in = new FileInputStream(sourceFile);
				out = new FileOutputStream(destFile);
				Cipher cipher = initAESCipher256(key, iv, Cipher.DECRYPT_MODE);
				//Cipher cipher = getCipher(key, iv, Cipher.DECRYPT_MODE);
				CipherOutputStream cipherOutputStream = new CipherOutputStream(out, cipher);
				byte[] buffer = new byte[1024];
				int r;
				while ((r = in.read(buffer)) >= 0) {
					cipherOutputStream.write(buffer, 0, r);
				}
				cipherOutputStream.close();
				
//				while((r = in.read(buffer)) >= 0) {
//					byte[] ciphertext = decrypt(cipher, CIPHERMODEPADDING, skforAES, IV, buffer);
//					out.write(ciphertext, 0, r);
//					out.flush();
//				}
			}
		} catch (IOException e) {
			e.printStackTrace(); // To change body of catch statement use File | Settings | File Templates.
		} finally {
			try {
				in.close();
			} catch (IOException e) {
				e.printStackTrace(); // To change body of catch statement use File | Settings | File Templates.
			}
			try {
				out.close();
			} catch (IOException e) {
				e.printStackTrace(); // To change body of catch statement use File | Settings | File Templates.
			}
		}
		return destFile;
	}

	private static Cipher initAESCipher(String sKey, String iv, int cipherMode) {
		// 创建Key gen
		KeyGenerator keyGenerator = null;
		Cipher cipher = null;
		try {
			IvParameterSpec zeroIv = new IvParameterSpec(iv.getBytes());
			byte[] keyBy = sKey.getBytes();
			if (keyBy.length % 16 != 0) {
				int groups = keyBy.length / 16 + (keyBy.length % 16 != 0 ? 1 : 0);
				byte[] temp = new byte[groups * 16];
				Arrays.fill(temp, (byte) 0);
				System.arraycopy(keyBy, 0, temp, 0, keyBy.length);
				keyBy = temp;
			}
			SecretKeySpec key = new SecretKeySpec(keyBy, "AES");
			cipher = Cipher.getInstance("AES/CBC/PKCS7Padding");
			cipher.init(cipherMode, key, zeroIv);
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace(); // To change body of catch statement use File | Settings | File Templates.
		} catch (NoSuchPaddingException e) {
			e.printStackTrace(); // To change body of catch statement use File | Settings | File Templates.
		} catch (InvalidKeyException e) {
			e.printStackTrace(); // To change body of catch statement use File | Settings | File Templates.
		} catch (InvalidAlgorithmParameterException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return cipher;
	}
	
	private static Cipher initAESCipher256(String sKey, String iv, int cipherMode) {
		// 创建Key gen
		KeyGenerator keyGenerator = null;
		Cipher c = null;
		try {
			IvParameterSpec zeroIv = new IvParameterSpec(iv.getBytes());
			byte[] keyBy = sKey.getBytes();
			if (keyBy.length % 16 != 0) {
				int groups = keyBy.length / 16 + (keyBy.length % 16 != 0 ? 1 : 0);
				byte[] temp = new byte[groups * 16];
				Arrays.fill(temp, (byte) 0);
				System.arraycopy(keyBy, 0, temp, 0, keyBy.length);
				keyBy = temp;
			}
//			SecretKeySpec key = new SecretKeySpec(keyBy, "AES");
//			cipher = Cipher.getInstance("AES/CBC/PKCS7Padding");
//			cipher.init(cipherMode, key, zeroIv);
			
			
			
			KeyGenerator generator = KeyGenerator.getInstance("AES");
			generator.init(256);
			SecretKey k = new SecretKeySpec(keyBy, "AES");
			c = Cipher.getInstance("AES/CBC/PKCS7Padding");
			byte[] ivbyte = iv.getBytes();
			if (ivbyte.length % 16 != 0) {
				int groups = ivbyte.length / 16 + (ivbyte.length % 16 != 0 ? 1 : 0);
				byte[] temp = new byte[groups * 16];
				Arrays.fill(temp, (byte) 0);
				System.arraycopy(ivbyte, 0, temp, 0, ivbyte.length);
				ivbyte = temp;
			}
			c.init(cipherMode, k, new IvParameterSpec(ivbyte));
			
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace(); // To change body of catch statement use File | Settings | File Templates.
		} catch (NoSuchPaddingException e) {
			e.printStackTrace(); // To change body of catch statement use File | Settings | File Templates.
		} catch (InvalidKeyException e) {
			e.printStackTrace(); // To change body of catch statement use File | Settings | File Templates.
		} catch (InvalidAlgorithmParameterException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return c;
	}

	private static char[] humanPassphrase = { 'P', 'e', 'r', ' ', 'v', 'a', 'l', 'l',
			'u', 'm', ' ', 'd', 'u', 'c', 'e', 's', ' ', 'L', 'a', 'b', 'a',
			'n', 't' };
	private static byte[] salt = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0xA, 0xB, 0xC, 0xD,
			0xE, 0xF}; // must save this for next time we want the key
	private static final int HASH_ITERATIONS = 10000;
	private static final int KEY_LENGTH = 256;
	private static PBEKeySpec myKeyspec = new PBEKeySpec(humanPassphrase, salt,
			HASH_ITERATIONS, KEY_LENGTH);
	private static final String KEY_GENERATION_ALG = "PBKDF2WithHmacSHA1";
	private static SecretKeyFactory keyfactory = null;
	private static SecretKey sk = null;
	private static SecretKeySpec skforAES = null;
	private static IvParameterSpec IV;
	private static final String CIPHERMODEPADDING = "AES/CBC/PKCS7Padding";
	private static Cipher getCipher(String key, String iv, int mode) {
		try {
			if (key != null && !key.isEmpty()) {
				myKeyspec = new PBEKeySpec(key.toCharArray(), salt,
						HASH_ITERATIONS, KEY_LENGTH);
			}
			keyfactory = SecretKeyFactory.getInstance(KEY_GENERATION_ALG);
			sk = keyfactory.generateSecret(myKeyspec);
			
			byte[] skAsByteArray = sk.getEncoded();
			
			skforAES = new SecretKeySpec(skAsByteArray, "AES");
			
			IV = new IvParameterSpec(iv.getBytes());
			Cipher c = Cipher.getInstance(CIPHERMODEPADDING);
			c.init(mode, sk, IV);
			return c;
		} catch (NoSuchAlgorithmException nsae) {
			Log.e("AESdemo",
					"no key factory support for PBEWITHSHAANDTWOFISH-CBC");
		} catch (InvalidKeySpecException ikse) {
			Log.e("AESdemo", "invalid key spec for PBEWITHSHAANDTWOFISH-CBC");
		} catch (NoSuchPaddingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (InvalidKeyException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (InvalidAlgorithmParameterException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}
	
	
	
	private static byte[] encrypt(String cmp, SecretKey sk, IvParameterSpec IV, byte[] msg) {
		try {
			Cipher c = Cipher.getInstance(cmp);
			c.init(Cipher.ENCRYPT_MODE, sk, IV);
			return c.doFinal(msg);
		} catch (NoSuchAlgorithmException nsae) {
			Log.e("AESdemo", "no cipher getinstance support for " + cmp);
		} catch (NoSuchPaddingException nspe) {
			Log.e("AESdemo", "no cipher getinstance support for padding " + cmp);
		} catch (InvalidKeyException e) {
			Log.e("AESdemo", "invalid key exception");
		} catch (InvalidAlgorithmParameterException e) {
			Log.e("AESdemo", "invalid algorithm parameter exception");
		} catch (IllegalBlockSizeException e) {
			Log.e("AESdemo", "illegal block size exception");
		} catch (BadPaddingException e) {
			Log.e("AESdemo", "bad padding exception");
		}
		return null;
	}
	
	private static byte[] decrypt(Cipher cipher, String cmp, SecretKey sk, IvParameterSpec IV, byte[] ciphertext) {
		try {
			
			return cipher.doFinal(ciphertext);
		} catch (IllegalBlockSizeException e) {
			Log.e("AESdemo", "illegal block size exception");
		} catch (BadPaddingException e) {
			Log.e("AESdemo", "bad padding exception");
			e.printStackTrace();
		}
		return null;
	}
	
	

	private static final byte[] hexStringToBytes(String string) {
		if (string == null)
			return null;
		int len = string.length();
		if (len % 2 != 0)
			return null;
		len = len / 2;
		byte[] res = new byte[len];
		for (int i = 0; i < len; i++) {
			int bt = 0;
			int ch0 = string.charAt(i * 2);
			int ch1 = string.charAt(i * 2 + 1);

			if (ch0 >= '0' && ch0 <= '9')
				bt += ((ch0 - '0') << 4);
			else if (ch0 >= 'a' && ch0 <= 'f')
				bt += ((ch0 - 'a' + 10) << 4);
			else if (ch0 >= 'A' && ch0 <= 'F')
				bt += ((ch0 - 'A' + 10) << 4);
			else
				return null;

			if (ch1 >= '0' && ch1 <= '9')
				bt += (ch1 - '0');
			else if (ch1 >= 'a' && ch1 <= 'f')
				bt += (ch1 - 'a' + 10);
			else if (ch1 >= 'A' && ch1 <= 'F')
				bt += (ch1 - 'A' + 10);
			else
				return null;
			res[i] = (byte) bt;
		}
		return res;
	}

	private static final String bytesToHexString(byte[] bytes) {
		if (bytes == null) {
			return "";
		}
		StringBuffer sb = new StringBuffer();
		for (byte b : bytes) {
			int val = b & 0xff;
			if (val < 0x10) {
				sb.append("0");
			}
			sb.append(Integer.toHexString(val));
		}
		return sb.toString();
	}
}
