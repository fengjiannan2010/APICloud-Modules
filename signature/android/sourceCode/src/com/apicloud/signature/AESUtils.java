package com.apicloud.signature;

import java.util.Arrays;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import org.json.JSONObject;

import com.uzmap.pkg.uzcore.uzmodule.UZModuleContext;

public class AESUtils {
	
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
