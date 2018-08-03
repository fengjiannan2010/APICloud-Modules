/**
 *  LICENSE AND TRADEMARK NOTICES
 *  
 *  Except where noted, sample source code written by Motorola Mobility Inc. and
 *  provided to you is licensed as described below.
 *  
 *  Copyright (c) 2012, Motorola, Inc.
 *  All  rights reserved except as otherwise explicitly indicated.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *
 *  - Redistributions of source code must retain the above copyright notice,
 *  this list of conditions and the following disclaimer.
 *
 *  - Redistributions in binary form must reproduce the above copyright notice,
 *  this list of conditions and the following disclaimer in the documentation
 *  and/or other materials provided with the distribution.
 *
 *  - Neither the name of Motorola, Inc. nor the names of its contributors may
 *  be used to endorse or promote products derived from this software without
 *  specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 *  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *  INTERRUPTION) HOWEVER  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *  POSSIBILITY OF SUCH DAMAGE.
 *  
 *  Other source code displayed may be licensed under Apache License, Version
 *  2.
 *  
 *  Copyright ¬© 2012, Android Open Source Project. All rights reserved unless
 *  otherwise explicitly indicated.
 *  
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may not
 *  use this file except in compliance with the License. You may obtain a copy
 *  of the License at
 *  
 *  http://www.apache.org/licenses/LICENSE-2.0.
 *  
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 *  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 *  License for the specific language governing permissions and limitations
 *  under the License.
 *  
 */

// Please refer to the accompanying article at 
// http://developer.motorola.com/docs/using_the_advanced_encryption_standard_in_android/

package com.apicloud.signature;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

// A tutorial guide to using AES encryption in Android
// First we generate a 256 bit secret key; then we use that secret key to AES encrypt a plaintext message.
// Finally we decrypt the ciphertext to get our original message back.
// We don't keep a copy of the secret key - we generate the secret key whenever it is needed, 
// so we must remember all the parameters needed to generate it -
// the salt, the IV, the human-friendly passphrase, all the algorithms and parameters to those algorithms.
// Peter van der Linden, April 15 2012

import java.io.UnsupportedEncodingException;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.KeySpec;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.CipherOutputStream;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;
import android.annotation.SuppressLint;
import android.util.Log;

public class AES {

	public static String PASSWORD = "";

	private final String KEY_GENERATION_ALG = "PBKDF2WithHmacSHA1";

	private final int HASH_ITERATIONS = 10000;
	private final int KEY_LENGTH = 256;

	private char[] humanPassphrase = { 'P', 'e', 'r', ' ', 'v', 'a', 'l', 'l',
			'u', 'm', ' ', 'd', 'u', 'c', 'e', 's', ' ', 'L', 'a', 'b', 'a',
			'n', 't' };

	private byte[] salt = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0xA, 0xB, 0xC, 0xD,
			0xE, 0xF}; // must save this for next time we want the key

	private PBEKeySpec myKeyspec = new PBEKeySpec(humanPassphrase, salt,
			HASH_ITERATIONS, KEY_LENGTH);
	
	private final String CIPHERMODEPADDING = "AES/CBC/PKCS5Padding";
	

	private final String ECB = "AES/ECB/PKCS7Padding";

	private SecretKeyFactory keyfactory = null;
	private SecretKey sk = null;
	private SecretKeySpec skforAES = null;
	
	private byte[] iv = { 0xA, 1, 0xB, 5, 4, 0xF, 7, 9, 0x17, 3, 1, 6, 8, 0xC, 0xD, 91 };
	
	private IvParameterSpec IV;

	private void initPassword(String password) {
		try {
			if (password != null && !password.isEmpty()) {
				myKeyspec = new PBEKeySpec(password.toCharArray(), salt,
						HASH_ITERATIONS, KEY_LENGTH);
			}
			keyfactory = SecretKeyFactory.getInstance(KEY_GENERATION_ALG);
			sk = keyfactory.generateSecret(myKeyspec);
		} catch (NoSuchAlgorithmException nsae) {
			Log.e("AESdemo",
					"no key factory support for PBEWITHSHAANDTWOFISH-CBC");
		} catch (InvalidKeySpecException ikse) {
			Log.e("AESdemo", "invalid key spec for PBEWITHSHAANDTWOFISH-CBC");
		}

		// This is our secret key. We could just save this to a file instead of
		// regenerating it
		// each time it is needed. But that file cannot be on the device (too
		// insecure). It could
		// be secure if we kept it on a server accessible through https.
		byte[] skAsByteArray = sk.getEncoded();
		
		skforAES = new SecretKeySpec(skAsByteArray, "AES");
		
		IV = new IvParameterSpec(iv);
		
	}
	
	/**
	 * TODO Test
	 * @param password
	 * @param iv
	 */
	private void initPassword(String password, String iv) {
		try {
			if (password != null && !password.isEmpty()) {
				myKeyspec = new PBEKeySpec(password.toCharArray(), salt,
						HASH_ITERATIONS, KEY_LENGTH);
			}
			keyfactory = SecretKeyFactory.getInstance(KEY_GENERATION_ALG);
			sk = keyfactory.generateSecret(myKeyspec);
		} catch (NoSuchAlgorithmException nsae) {
			Log.e("AESdemo",
					"no key factory support for PBEWITHSHAANDTWOFISH-CBC");
		} catch (InvalidKeySpecException ikse) {
			Log.e("AESdemo", "invalid key spec for PBEWITHSHAANDTWOFISH-CBC");
		}

		// This is our secret key. We could just save this to a file instead of
		// regenerating it
		// each time it is needed. But that file cannot be on the device (too
		// insecure). It could
		// be secure if we kept it on a server accessible through https.
		byte[] skAsByteArray = sk.getEncoded();
		
		skforAES = new SecretKeySpec(skAsByteArray, "AES");
		
		IV = new IvParameterSpec(iv.getBytes());
		
	}
	

	// public String aesEncryptECB(String password, byte[] plaintext) {
	// byte[] result = null;
	// try {
	// byte[] enCodeFormat = password.getBytes();
	// SecretKeySpec key = new SecretKeySpec(enCodeFormat, ECB);
	// Cipher cipher = Cipher.getInstance(ECB);
	// cipher.init(Cipher.ENCRYPT_MODE, key);
	// result = cipher.doFinal(plaintext);
	// } catch (InvalidKeyException e) {
	// e.printStackTrace();
	// } catch (NoSuchAlgorithmException e) {
	// e.printStackTrace();
	// } catch (NoSuchPaddingException e) {
	// e.printStackTrace();
	// } catch (IllegalBlockSizeException e) {
	// e.printStackTrace();
	// } catch (BadPaddingException e) {
	// e.printStackTrace();
	// }
	// return Base64Encoder.encode(result);
	// }

	public String aesEncryptECB(String password, byte[] plaintext) {
		byte[] result = null;
		try {
			SecretKeyFactory factory = SecretKeyFactory
					.getInstance("PBKDF2WithHmacSHA1");
			KeySpec spec = new PBEKeySpec(password.toCharArray(), salt, 1024,
					128);
			SecretKey tmp = factory.generateSecret(spec);
			SecretKey secret = new SecretKeySpec(tmp.getEncoded(), ECB);
			Cipher cipher = Cipher.getInstance(ECB);
			cipher.init(Cipher.ENCRYPT_MODE, secret);
			result = cipher.doFinal(plaintext);
		} catch (InvalidKeyException e) {
			e.printStackTrace();
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		} catch (NoSuchPaddingException e) {
			e.printStackTrace();
		} catch (IllegalBlockSizeException e) {
			e.printStackTrace();
		} catch (BadPaddingException e) {
			e.printStackTrace();
		} catch (InvalidKeySpecException e) {
			e.printStackTrace();
		}
		return Base64Encoder.encode(result);
	}

	@SuppressLint("SimpleDateFormat")
	private static String getDateToString(long time) {
		Date d = new Date(time);
		SimpleDateFormat sf = new SimpleDateFormat("yyyyMMddHHmmss");
		return sf.format(d);
	}

	public String encrypt(String password, byte[] plaintext) {
		initPassword(password);
		byte[] ciphertext = encrypt(CIPHERMODEPADDING, skforAES, IV, plaintext);
		String base64_ciphertext = Base64Encoder.encode(ciphertext);
		return base64_ciphertext;
	}

	public String decrypt(String password, String ciphertext_base64) {
		initPassword(password);
		byte[] s = Base64Decoder.decodeToBytes(ciphertext_base64);
		byte[] bys = decrypt(CIPHERMODEPADDING, skforAES, IV, s);
		String decrypted = null;
		if (bys != null) {
			decrypted = new String(bys);
		}
		return decrypted;
	}

	// public String aesDecryptECB(String password, String ciphertext_base64) {
	// byte[] enCodeFormat = password.getBytes();
	// SecretKeySpec key = new SecretKeySpec(enCodeFormat, ECB);
	// Cipher cipher;
	// try {
	// cipher = Cipher.getInstance(ECB);
	// cipher.init(Cipher.DECRYPT_MODE, key);
	// byte[] result = cipher.doFinal(Base64Decoder
	// .decodeToBytes(ciphertext_base64));
	// return new String(result, "UTF-8");
	// } catch (NoSuchAlgorithmException e) {
	// e.printStackTrace();
	// } catch (NoSuchPaddingException e) {
	// e.printStackTrace();
	// } catch (IllegalBlockSizeException e) {
	// e.printStackTrace();
	// } catch (BadPaddingException e) {
	// e.printStackTrace();
	// } catch (InvalidKeyException e) {
	// e.printStackTrace();
	// } catch (UnsupportedEncodingException e) {
	// e.printStackTrace();
	// }
	// return null;
	// }

	public String aesDecryptECB(String password, String ciphertext_base64) {
		try {
			SecretKeyFactory factory = SecretKeyFactory
					.getInstance("PBKDF2WithHmacSHA1");
			KeySpec spec = new PBEKeySpec(password.toCharArray(), salt, 1024,
					128);
			SecretKey tmp = factory.generateSecret(spec);
			SecretKey secret = new SecretKeySpec(tmp.getEncoded(), ECB);
			Cipher cipher = Cipher.getInstance(ECB);
			cipher.init(Cipher.DECRYPT_MODE, secret);
			byte[] result = cipher.doFinal(Base64Decoder
					.decodeToBytes(ciphertext_base64));
			return new String(result, "UTF-8");
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		} catch (NoSuchPaddingException e) {
			e.printStackTrace();
		} catch (IllegalBlockSizeException e) {
			e.printStackTrace();
		} catch (BadPaddingException e) {
			e.printStackTrace();
		} catch (InvalidKeyException e) {
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		} catch (InvalidKeySpecException e) {
			e.printStackTrace();
		}
		return null;
	}

	// Use this method if you want to add the padding manually
	// AES deals with messages in blocks of 16 bytes.
	// This method looks at the length of the message, and adds bytes at the end
	// so that the entire message is a multiple of 16 bytes.
	// the padding is a series of bytes, each set to the total bytes added (a
	// number in range 1..16).
	private byte[] addPadding(byte[] plain) {
		byte plainpad[] = null;
		int shortage = 16 - (plain.length % 16);
		// if already an exact multiple of 16, need to add another block of 16
		// bytes
		if (shortage == 0)
			shortage = 16;

		// reallocate array bigger to be exact multiple, adding shortage bits.
		plainpad = new byte[plain.length + shortage];
		for (int i = 0; i < plain.length; i++) {
			plainpad[i] = plain[i];
		}
		for (int i = plain.length; i < plain.length + shortage; i++) {
			plainpad[i] = (byte) shortage;
		}
		return plainpad;
	}

	// Use this method if you want to remove the padding manually
	// This method removes the padding bytes
	private byte[] dropPadding(byte[] plainpad) {
		byte plain[] = null;
		int drop = plainpad[plainpad.length - 1]; // last byte gives number of
													// bytes to drop

		// reallocate array smaller, dropping the pad bytes.
		plain = new byte[plainpad.length - drop];
		for (int i = 0; i < plain.length; i++) {
			plain[i] = plainpad[i];
			plainpad[i] = 0; // don't keep a copy of the decrypt
		}
		return plain;
	}

	private byte[] encrypt(String cmp, SecretKey sk, IvParameterSpec IV, byte[] msg) {
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

	private byte[] encryptECB(String cmp, SecretKey sk, byte[] msg) {
		try {
			Cipher c = Cipher.getInstance(cmp);
			c.init(Cipher.ENCRYPT_MODE, sk);
			return c.doFinal(msg);
		} catch (NoSuchAlgorithmException nsae) {
			Log.e("AESdemo", "no cipher getinstance support for " + cmp);
		} catch (NoSuchPaddingException nspe) {
			Log.e("AESdemo", "no cipher getinstance support for padding " + cmp);
		} catch (InvalidKeyException e) {
			Log.e("AESdemo", "invalid key exception");
		} catch (IllegalBlockSizeException e) {
			Log.e("AESdemo", "illegal block size exception");
		} catch (BadPaddingException e) {
			Log.e("AESdemo", "bad padding exception");
		}
		return null;
	}

	private byte[] decrypt(String cmp, SecretKey sk, IvParameterSpec IV, byte[] ciphertext) {
		try {
			Cipher c = Cipher.getInstance(cmp);
			c.init(Cipher.DECRYPT_MODE, sk, IV);
			return c.doFinal(ciphertext);
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
			e.printStackTrace();
		}
		return null;
	}

	private byte[] decryptECB(String cmp, SecretKey sk, byte[] ciphertext) {
		try {
			Cipher c = Cipher.getInstance(cmp);
			c.init(Cipher.DECRYPT_MODE, sk);
			return c.doFinal(ciphertext);
		} catch (NoSuchAlgorithmException nsae) {
			Log.e("AESdemo", "no cipher getinstance support for " + cmp);
		} catch (NoSuchPaddingException nspe) {
			Log.e("AESdemo", "no cipher getinstance support for padding " + cmp);
		} catch (InvalidKeyException e) {
			Log.e("AESdemo", "invalid key exception");
		} catch (IllegalBlockSizeException e) {
			Log.e("AESdemo", "illegal block size exception");
		} catch (BadPaddingException e) {
			Log.e("AESdemo", "bad padding exception");
			e.printStackTrace();
		}
		return null;
	}
	
	
	public File encryptFile(String key, String iv, String sourceFilePath, String destFilePath) {
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
				initPassword(key, iv);
				destFile.createNewFile();
				in = new FileInputStream(sourceFile);
				out = new FileOutputStream(destFile);
				//Cipher cipher = initAESCipher(key, "", Cipher.DECRYPT_MODE);
				
				//CipherOutputStream cipherOutputStream = new CipherOutputStream(out, cipher);
				byte[] buffer = new byte[1024];
				int r;
				StringBuilder builder = new StringBuilder();
//				while ((r = in.read(buffer)) >= 0) {
//					byte[] en = encrypt(CIPHERMODEPADDING, skforAES, IV, buffer);
//					out.write(en, 0, r);
//					
//				}
//				out.close();
				
				
				while ((r = in.read(buffer)) >= 0) {
					byte[] en = encrypt(CIPHERMODEPADDING, skforAES, IV, buffer);
					String base64_ciphertext = Base64Encoder.encode(en);
					builder.append(base64_ciphertext);
					
				}
				out.write(buffer.toString().getBytes());
			}
		} catch (IOException e) {
			e.printStackTrace();
		}finally {
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
	 * 解密文件
	 * @param key
	 * @param iv
	 * @param sourceFilePath
	 * @param destFilePath
	 */
	public File decryptFile(String key, String iv, String sourceFilePath, String destFilePath) {
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
				initPassword(key, iv);
				destFile.createNewFile();
				in = new FileInputStream(sourceFile);
				out = new FileOutputStream(destFile);
				//Cipher cipher = initAESCipher(key, "", Cipher.DECRYPT_MODE);
				
				//CipherOutputStream cipherOutputStream = new CipherOutputStream(out, cipher);
				byte[] buffer = new byte[1024];
				int r;
				StringBuilder builder = new StringBuilder();
//				while ((r = in.read(buffer)) >= 0) {
//					byte[] en = encrypt(CIPHERMODEPADDING, skforAES, IV, buffer);
//					out.write(en, 0, r);
//					
//				}
//				out.close();
				
				
//				while ((r = in.read(buffer)) >= 0) {
//					byte[] en = encrypt(CIPHERMODEPADDING, skforAES, IV, buffer);
//					String base64_ciphertext = Base64Encoder.encode(en);
//					builder.append(base64_ciphertext);
//					
//				}
//				out.write(buffer.toString().getBytes());
				
				String string = getStringFromInputStream(in);
				byte[] s = Base64Decoder.decodeToBytes(string);
				String decrypted = new String(decrypt(CIPHERMODEPADDING, skforAES, IV, s));
				out.write(decrypted.getBytes());
			}
		} catch (IOException e) {
			e.printStackTrace();
		}finally {
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
	
	public String getStringFromInputStream(InputStream a_is) {
        BufferedReader br = null;
        StringBuilder sb = new StringBuilder();
        String line;
        try {
            br = new BufferedReader(new InputStreamReader(a_is));
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
        } catch (IOException e) {
        } finally {
            if (br != null) {
                try {
                    br.close();
                } catch (IOException e) {
                }
            }
        }
        return sb.toString();
    }

}