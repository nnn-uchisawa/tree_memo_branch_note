# Flutter/Dart
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Firebase/Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# OkHttp/Okio（警告抑制）
-dontwarn okhttp3.**
-dontwarn okio.**