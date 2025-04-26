package com.example.travel_joy;

import io.flutter.embedding.android.FlutterActivity;
import android.os.Bundle;
import android.util.Log;

public class MainActivity extends FlutterActivity {
    private static final String TAG = "MainActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.i(TAG, "MainActivity已创建");
    }
} 