# Flutter ProGuard Rules for court+ release build
# Keeps necessary Flutter engine classes and Supabase client classes

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.app.** { *; }

# Supabase / PostgREST
-keep class com.supabase.** { *; }
-keep class postgrest.** { *; }
-keep class kotlinx.serialization.** { *; }

# Google Maps
-keep class com.google.android.gms.maps.** { *; }

# Keep model classes for JSON deserialization
-keep class com.courtplus.court_plus.** { *; }

# Keep Gson/Reflection
-keepattributes Signature
-keepattributes *Annotation*
-keep class kotlin.Metadata { *; }

# Riverpod (no special rules needed, kept by default)
# SharedPreferences
-keep class com.tencent.** { *; }