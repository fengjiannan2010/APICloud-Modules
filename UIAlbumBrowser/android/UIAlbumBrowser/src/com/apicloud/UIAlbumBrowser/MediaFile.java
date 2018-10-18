package com.apicloud.UIAlbumBrowser;

import java.util.HashMap;
import java.util.Locale;

public class MediaFile
{
  public static final int FILE_TYPE_MP3 = 1;
  public static final int FILE_TYPE_M4A = 2;
  public static final int FILE_TYPE_WAV = 3;
  public static final int FILE_TYPE_AMR = 4;
  public static final int FILE_TYPE_AWB = 5;
  public static final int FILE_TYPE_WMA = 6;
  public static final int FILE_TYPE_OGG = 7;
  public static final int FILE_TYPE_AAC = 8;
  public static final int FILE_TYPE_MKA = 9;
  public static final int FILE_TYPE_FLAC = 10;
  private static final int FIRST_AUDIO_FILE_TYPE = 1;
  private static final int LAST_AUDIO_FILE_TYPE = 10;
  public static final int FILE_TYPE_MID = 11;
  public static final int FILE_TYPE_SMF = 12;
  public static final int FILE_TYPE_IMY = 13;
  private static final int FIRST_MIDI_FILE_TYPE = 11;
  private static final int LAST_MIDI_FILE_TYPE = 13;
  public static final int FILE_TYPE_MP4 = 21;
  public static final int FILE_TYPE_M4V = 22;
  public static final int FILE_TYPE_3GPP = 23;
  public static final int FILE_TYPE_3GPP2 = 24;
  public static final int FILE_TYPE_WMV = 25;
  public static final int FILE_TYPE_ASF = 26;
  public static final int FILE_TYPE_MKV = 27;
  public static final int FILE_TYPE_MP2TS = 28;
  public static final int FILE_TYPE_AVI = 29;
  public static final int FILE_TYPE_WEBM = 30;
  private static final int FIRST_VIDEO_FILE_TYPE = 21;
  private static final int LAST_VIDEO_FILE_TYPE = 30;
  public static final int FILE_TYPE_MP2PS = 200;
  private static final int FIRST_VIDEO_FILE_TYPE2 = 200;
  private static final int LAST_VIDEO_FILE_TYPE2 = 200;
  public static final int FILE_TYPE_JPEG = 31;
  public static final int FILE_TYPE_GIF = 32;
  public static final int FILE_TYPE_PNG = 33;
  public static final int FILE_TYPE_BMP = 34;
  public static final int FILE_TYPE_WBMP = 35;
  public static final int FILE_TYPE_WEBP = 36;
  private static final int FIRST_IMAGE_FILE_TYPE = 31;
  private static final int LAST_IMAGE_FILE_TYPE = 36;
  public static final int FILE_TYPE_M3U = 41;
  public static final int FILE_TYPE_PLS = 42;
  public static final int FILE_TYPE_WPL = 43;
  public static final int FILE_TYPE_HTTPLIVE = 44;
  private static final int FIRST_PLAYLIST_FILE_TYPE = 41;
  private static final int LAST_PLAYLIST_FILE_TYPE = 44;
  public static final int FILE_TYPE_FL = 51;
  private static final int FIRST_DRM_FILE_TYPE = 51;
  private static final int LAST_DRM_FILE_TYPE = 51;
  public static final int FILE_TYPE_TEXT = 100;
  public static final int FILE_TYPE_HTML = 101;
  public static final int FILE_TYPE_PDF = 102;
  public static final int FILE_TYPE_XML = 103;
  public static final int FILE_TYPE_MS_WORD = 104;
  public static final int FILE_TYPE_MS_EXCEL = 105;
  public static final int FILE_TYPE_MS_POWERPOINT = 106;
  public static final int FILE_TYPE_ZIP = 107;
  
  public static class MediaFileType
  {
    public final int fileType;
    public final String mimeType;
    
    MediaFileType(int fileType, String mimeType)
    {
      this.fileType = fileType;
      this.mimeType = mimeType;
    }
  }
  
  private static final HashMap<String, MediaFileType> sFileTypeMap = new HashMap();
  private static final HashMap<String, Integer> sMimeTypeMap = new HashMap();
  
  static void addFileType(String extension, int fileType, String mimeType)
  {
    sFileTypeMap.put(extension, new MediaFileType(fileType, mimeType));
    sMimeTypeMap.put(mimeType, Integer.valueOf(fileType));
  }
  
  static
  {
    addFileType("MP3", 1, "audio/mpeg");
    addFileType("MPGA", 1, "audio/mpeg");
    addFileType("M4A", 2, "audio/mp4");
    addFileType("WAV", 3, "audio/x-wav");
    addFileType("AMR", 4, "audio/amr");
    addFileType("AWB", 5, "audio/amr-wb");
    addFileType("WMA", 6, "audio/x-ms-wma");
    addFileType("OGG", 7, "audio/ogg");
    addFileType("OGG", 7, "application/ogg");
    addFileType("OGA", 7, "application/ogg");
    addFileType("AAC", 8, "audio/aac");
    addFileType("AAC", 8, "audio/aac-adts");
    addFileType("MKA", 9, "audio/x-matroska");
    
    addFileType("MID", 11, "audio/midi");
    addFileType("MIDI", 11, "audio/midi");
    addFileType("XMF", 11, "audio/midi");
    addFileType("RTTTL", 11, "audio/midi");
    addFileType("SMF", 12, "audio/sp-midi");
    addFileType("IMY", 13, "audio/imelody");
    addFileType("RTX", 11, "audio/midi");
    addFileType("OTA", 11, "audio/midi");
    addFileType("MXMF", 11, "audio/midi");
    
    addFileType("MPEG", 21, "video/mpeg");
    addFileType("MPG", 21, "video/mpeg");
    addFileType("MP4", 21, "video/mp4");
    addFileType("M4V", 22, "video/mp4");
    addFileType("3GP", 23, "video/3gpp");
    addFileType("3GPP", 23, "video/3gpp");
    addFileType("3G2", 24, "video/3gpp2");
    addFileType("3GPP2", 24, "video/3gpp2");
    addFileType("MKV", 27, "video/x-matroska");
    addFileType("WEBM", 30, "video/webm");
    addFileType("TS", 28, "video/mp2ts");
    addFileType("AVI", 29, "video/avi");
    addFileType("WMV", 25, "video/x-ms-wmv");
    addFileType("ASF", 26, "video/x-ms-asf");
    
    addFileType("JPG", 31, "image/jpeg");
    addFileType("JPEG", 31, "image/jpeg");
    addFileType("GIF", 32, "image/gif");
    addFileType("PNG", 33, "image/png");
    addFileType("BMP", 34, "image/x-ms-bmp");
    addFileType("WBMP", 35, "image/vnd.wap.wbmp");
    addFileType("WEBP", 36, "image/webp");
    
    addFileType("M3U", 41, "audio/x-mpegurl");
    addFileType("M3U", 41, "application/x-mpegurl");
    addFileType("PLS", 42, "audio/x-scpls");
    addFileType("WPL", 43, "application/vnd.ms-wpl");
    addFileType("M3U8", 44, "application/vnd.apple.mpegurl");
    addFileType("M3U8", 44, "audio/mpegurl");
    addFileType("M3U8", 44, "audio/x-mpegurl");
    addFileType("FL", 51, "application/x-android-drm-fl");
    
    addFileType("TXT", 100, "text/plain");
    addFileType("HTM", 101, "text/html");
    addFileType("HTML", 101, "text/html");
    addFileType("PDF", 102, "application/pdf");
    addFileType("DOC", 104, "application/msword");
    addFileType("XLS", 105, "application/vnd.ms-excel");
    addFileType("PPT", 106, "application/mspowerpoint");
    addFileType("FLAC", 10, "audio/flac");
    addFileType("ZIP", 107, "application/zip");
    addFileType("MPG", 200, "video/mp2p");
    addFileType("MPEG", 200, "video/mp2p");
  }
  
  public static boolean isAudioFileType(int fileType)
  {
    return ((fileType >= 1) && 
      (fileType <= 10)) || (
      (fileType >= 11) && (
      fileType <= 13));
  }
  
  public static boolean isVideoFileType(int fileType)
  {
    return ((fileType >= 21) && 
      (fileType <= 30)) || (
      (fileType >= 200) && (
      fileType <= 200));
  }
  
  public static boolean isImageFileType(int fileType)
  {
    return (fileType >= 31) && (
      fileType <= 36);
  }
  
  public static boolean isPlayListFileType(int fileType)
  {
    return (fileType >= 41) && (
      fileType <= 44);
  }
  
  public static boolean isDrmFileType(int fileType)
  {
    return (fileType >= 51) && (
      fileType <= 51);
  }
  
  public static MediaFileType getFileType(String path)
  {
    int lastDot = path.lastIndexOf('.');
    if (lastDot < 0) {
      return null;
    }
    return (MediaFileType)sFileTypeMap.get(path.substring(lastDot + 1).toUpperCase(Locale.ROOT));
  }
  
  public static boolean isMimeTypeMedia(String mimeType)
  {
    int fileType = getFileTypeForMimeType(mimeType);
    return (isAudioFileType(fileType)) || (isVideoFileType(fileType)) || 
      (isImageFileType(fileType)) || (isPlayListFileType(fileType));
  }
  
  public static String getFileTitle(String path)
  {
    int lastSlash = path.lastIndexOf('/');
    if (lastSlash >= 0)
    {
      lastSlash++;
      if (lastSlash < path.length()) {
        path = path.substring(lastSlash);
      }
    }
    int lastDot = path.lastIndexOf('.');
    if (lastDot > 0) {
      path = path.substring(0, lastDot);
    }
    return path;
  }
  
  public static int getFileTypeForMimeType(String mimeType)
  {
    Integer value = (Integer)sMimeTypeMap.get(mimeType);
    return value == null ? 0 : value.intValue();
  }
  
  public static String getMimeTypeForFile(String path)
  {
    MediaFileType mediaFileType = getFileType(path);
    return mediaFileType == null ? null : mediaFileType.mimeType;
  }
}
