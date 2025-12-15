# ==================== FIREBASE MESSAGING ====================
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.iid.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

# ==================== GOOGLE PLAY SERVICES ====================
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# ==================== FLUTTER LOCAL NOTIFICATIONS ====================
-keep class com.dexterous.** { *; }
-keep class io.flutter.plugins.localnotifications.** { *; }
-dontwarn com.dexterous.**

# ==================== JSON/SERIALIZATION ====================
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keep class * implements java.io.Serializable { *; }

# ==================== KOTLIN/FLUTTER ====================
-keep class kotlin.** { *; }
-dontwarn kotlin.**
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }

# ==================== CRITICAL: NOTIFICATION SERVICES ====================
-keep class * extends com.google.firebase.messaging.FirebaseMessagingService
-keep class * extends com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin
-keep class * extends java.lang.Throwable

# ==================== SHARED PREFERENCES ====================
-keep class * extends android.content.Context {
    public android.content.SharedPreferences getSharedPreferences(java.lang.String, int);
}