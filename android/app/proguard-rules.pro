# CalcMaster ProGuard rules — keep Flutter + plugin classes intact.
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Provider package state classes
-keep class * extends androidx.lifecycle.ViewModel { *; }

# Suppress noisy warnings from transitive deps
-dontwarn io.flutter.embedding.**
