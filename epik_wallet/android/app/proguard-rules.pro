
## 编译R8压缩需要keep内部类，或者关闭R8压缩gradle.properties 加入 'android.enableR8=false'
-keepattributes InnerClasses

## --------------------------------------------------------------------------R 资源ID
-keepclassmembers class **.R$* {
    public static <fields>;
}
-keep class **.R$* {
    <fields>;
}

## --------------------------------------------------------------------------枚举
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

## --------------------------------------------------------------------------Native方法名
-keepclasseswithmembers,allowshrinking class * {
    native <methods>;
}



## --------------------------------------------------------------------------JavaBean
-keep class * implements java.io.Serializable{*;}
-keep class * implements android.os.Parcelable{*;}

## --------------------------------------------------------------------------JavascriptInterface

-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

## --------------------------------------------------------------------------友盟统计 umeng 新版
-keep class com.umeng.** {*;}

-keep class com.uc.** {*;}

-keepclassmembers class * {
   public <init> (org.json.JSONObject);
}
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
-keep class com.zui.** {*;}
-keep class com.miui.** {*;}
-keep class com.heytap.** {*;}
-keep class a.** {*;}
-keep class com.vivo.** {*;}




