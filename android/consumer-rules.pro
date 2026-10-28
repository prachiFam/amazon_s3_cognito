# AWS SDK for Android maps enums and model classes by name at runtime.
# Kept narrow on purpose: a blanket "-keep class com.amazonaws.** { *; }" would turn off
# R8 shrinking/optimization for the whole SDK in consuming apps.
-keepclassmembers enum com.amazonaws.** { *; }
-dontwarn com.amazonaws.**
-dontwarn com.fasterxml.jackson.databind.**
-dontwarn org.apache.commons.logging.**
-dontwarn org.apache.http.**
-dontwarn javax.naming.**
-dontwarn org.joda.time.**
