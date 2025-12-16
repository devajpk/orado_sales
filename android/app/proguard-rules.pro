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

# ==================== FLUTTER BACKGROUND SERVICE ====================
-keep class id.flutter.flutter_background_service.** { *; }
-keep class id.flutter.flutter_background_service_android.** { *; }
-keep class * extends id.flutter.flutter_background_service.BackgroundService { *; }
-keepclassmembers class * extends id.flutter.flutter_background_service.BackgroundService {
    *;
}
-keep class * implements id.flutter.flutter_background_service.ServiceInstance { *; }
-keep class * implements id.flutter.flutter_background_service.AndroidServiceInstance { *; }
-keepclassmembers class * implements id.flutter.flutter_background_service.ServiceInstance {
    *;
}
-keepclassmembers class * implements id.flutter.flutter_background_service.AndroidServiceInstance {
    *;
}
-dontwarn id.flutter.flutter_background_service.**

# ==================== ANDROID SERVICE & NOTIFICATIONS ====================
-keep class android.app.Service { *; }
-keep class android.app.Notification { *; }
-keep class android.app.NotificationChannel { *; }
-keep class android.app.NotificationManager { *; }
-keep class android.app.Notification$* { *; }
-keep class android.app.NotificationChannel { *; }
-keep class android.content.BroadcastReceiver { *; }
-keep class * extends android.content.BroadcastReceiver { *; }
-keep class * extends android.app.Service { *; }
-keep class android.app.RemoteServiceException { *; }
-keep class android.app.RemoteServiceException$* { *; }

# ==================== REFLECTION & ANNOTATIONS ====================
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
-keepattributes AnnotationDefault
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes Signature
-keepattributes Exceptions

# ==================== DART/FLUTTER PLUGIN REGISTRATION ====================
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.android.** { *; }
-dontwarn io.flutter.embedding.**