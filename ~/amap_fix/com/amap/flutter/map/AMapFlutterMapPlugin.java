package com.amap.flutter.map;

import android.app.Activity;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;

import com.amap.flutter.map.utils.LogUtil;


import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;

/**
 * AmapFlutterMapPlugin
 */
public class AMapFlutterMapPlugin implements
        FlutterPlugin,
        ActivityAware {
    private static final String CLASS_NAME = "AMapFlutterMapPlugin";
    private FlutterPluginBinding pluginBinding;
    private Lifecycle lifecycle;

    private static final String VIEW_TYPE = "com.amap.flutter.map";

    // 旧的registerWith方法已不再支持，新的Flutter版本不使用这个方法
    // 此方法保留为空，防止调用错误
    public static void registerWith(Object registrar) {
        LogUtil.i(CLASS_NAME, "registerWith方法已不支持，请使用FlutterPlugin接口");
    }

    public AMapFlutterMapPlugin() {
    }

    // FlutterPlugin

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        LogUtil.i(CLASS_NAME, "onAttachedToEngine==>");
        pluginBinding = binding;
        binding
                .getPlatformViewRegistry()
                .registerViewFactory(
                        VIEW_TYPE,
                        new AMapPlatformViewFactory(
                                binding.getBinaryMessenger(),
                                new LifecycleProvider() {
                                    @Nullable
                                    @Override
                                    public Lifecycle getLifecycle() {
                                        return lifecycle;
                                    }
                                }));
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        LogUtil.i(CLASS_NAME, "onDetachedFromEngine==>");
        pluginBinding = null;
    }


    // ActivityAware

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        LogUtil.i(CLASS_NAME, "onAttachedToActivity==>");
        lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        LogUtil.i(CLASS_NAME, "onDetachedFromActivity==>");
        lifecycle = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        LogUtil.i(CLASS_NAME, "onReattachedToActivityForConfigChanges==>");
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        LogUtil.i(CLASS_NAME, "onDetachedFromActivityForConfigChanges==>");
        this.onDetachedFromActivity();
    }
} 