package com.hybrid.core;

import android.app.Application;
import android.content.Context;
import android.util.Log;

public class TestApp extends Application {
    private static Context context;
    //    final private static String LOGTAG = "SmsDogApplication";
    final private static String LOGTAG = "" + (new Object() {
        public String getClassName() {
            String clazzName = this.getClass().getName();
            return clazzName.substring(0, clazzName.lastIndexOf('$'));
        }
    }.getClassName());

    @Override
    public void onCreate() {
        super.onCreate();

        context = getApplicationContext();
        Log.v(LOGTAG, "Application.onCreate");

    }

    public static Context getContext() {
        return context;
    }
}