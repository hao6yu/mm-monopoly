# Godot is an embedded native engine. Its JNI lookups and GDScript/plugin
# reflection are not visible to R8. In a minified store build, renaming return
# types (e.g. GodotRenderView) changes JNI signatures even if the method name
# itself is kept; this crashed initialize() with NoSuchMethodError.
# Keep the engine boundary, while retaining shrinking for the rest of the app.
-keep class org.godotengine.godot.** { *; }
-keep class ** extends org.godotengine.godot.plugin.GodotPlugin { *; }
-keepattributes RuntimeVisibleAnnotations,RuntimeInvisibleAnnotations
