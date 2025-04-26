package com.example.travel_joy;

import io.flutter.app.FlutterApplication;
import android.util.Log;

public class TravelJoyApplication extends FlutterApplication {
    private static final String TAG = "TravelJoyApplication";

    @Override
    public void onCreate() {
        super.onCreate();
        Log.i(TAG, "应用启动初始化完成");
    }
} 