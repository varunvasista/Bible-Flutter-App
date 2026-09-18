# Keep the generic signatures so Gson doesn't lose type parameters
-keepattributes Signature, InnerClasses, EnclosingMethod, *Annotation*

# Keep Gson's TypeToken class and its subclasses from being stripped
-keep class com.google.gson.reflect.TypeToken
-keep class * extends com.google.gson.reflect.TypeToken

# Prevent obfuscation of the notification plugin classes
-keep class com.dexterous.flutterlocalnotifications.** { *; }
