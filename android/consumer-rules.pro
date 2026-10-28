# AWS SDK for Android creates signers, HTTP clients and config objects by reflection
# (Class.newInstance, e.g. AWSS3V4Signer) and maps enums/models by name. These are the
# keep rules the SDK recommends; narrower rules broke S3 uploads in release builds.
-keep class com.amazonaws.** { *; }
-keepnames class com.amazonaws.** { *; }
-dontwarn com.amazonaws.**
-dontwarn com.fasterxml.jackson.databind.**
-dontwarn org.apache.commons.logging.**
-dontwarn org.apache.http.**
-dontwarn javax.naming.**
-dontwarn org.joda.time.**
