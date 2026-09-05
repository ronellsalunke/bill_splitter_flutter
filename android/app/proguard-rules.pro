# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.kts.
#
# The Flutter Gradle plugin already supplies the rules required by the
# engine, and most plugins ship their own consumer rules, so only
# project-specific additions belong in this file.

# Keep the generated plugin registrant, which is referenced via reflection.
-keep class io.flutter.plugins.** { *; }
