# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**
-dontwarn com.google.firebase.**

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep model classes used with JSON
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keep class kotlin.Metadata { *; }
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
