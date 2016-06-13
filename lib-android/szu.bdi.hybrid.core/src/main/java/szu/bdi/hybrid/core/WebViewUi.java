package szu.bdi.hybrid.core;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.ActionBar;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MenuItem;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.JsResult;
import android.webkit.WebChromeClient;
import android.webkit.WebView;

import com.github.lzyzsd.jsbridge.BridgeHandler;
import com.github.lzyzsd.jsbridge.BridgeWebView;
import com.github.lzyzsd.jsbridge.CallBackFunction;

//TODO rewrite the jsbridge...

//@ref http://stackoverflow.com/questions/20138434/alternate-solution-for-setjavascriptenabledtrue
@SuppressLint({"SetJavaScriptEnabled", "JavascriptInterface"})
public class WebViewUi extends HybridUi {

    final private static String LOGTAG = "WebViewUi";
//    final private static String LOGTAG = "" + (new Object() {
//        public String getClassName() {
//            String clazzName = this.getClass().getName();
//            return clazzName.substring(0, clazzName.lastIndexOf('$'));
//        }
//    }.getClassName());

    private String mURL;

    private BridgeWebView mWebView;

//    private WebView mWebView;

//    public class JavaScriptInterface {
//        Context mContext1;
//
//        JavaScriptInterface(Context c) {
//            mContext1 = c;
//        }
//    }

    protected CallBackFunction _cb = null;

    //work with this.startActivityForResult() + popupActivity(setResult() + finish())
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.v(LOGTAG, "onActivityResult resultCode=" + resultCode);
        if (_cb != null && resultCode > 0) {
            Log.v(LOGTAG, "onCallBack OK");
//            _cb.onCallBack("{\"STS\":\"OK\"}");//OK
//            _cb.onCallBack("{STS:\"OK\"}");//OK
            //_cb.onCallBack("What the hell");//KO, proves the result need the JSON format
            _cb.onCallBack("{STS:\"OK\"}");//TODO return the param of current Ui?
        }
    }

    //NOTES: when user click the left-upper button on the top bar
    //@ref setDisplayHomeAsUpEnabled()
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                onBackPressed();
                break;
        }
        return true;
    }

//    boolean bClose;
//    @Override
//    protected void onNewIntent(Intent intent) {
//        super.onNewIntent(intent);
//        bClose = intent.getExtras().getBoolean("bClose");
//        if (bClose == false) {
//            //finish();
//            onBackPressed();
//        }
//    }

    @TargetApi(Build.VERSION_CODES.ICE_CREAM_SANDWICH)
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.v(LOGTAG, ".onCreate()");
        super.onCreate(savedInstanceState);
        Intent iin = getIntent();
        String s_uiData = iin.getStringExtra("uiData");
        Log.v(LOGTAG, "s_uiData=" + s_uiData);
        this.uiData = HybridTools.s2o(s_uiData);
        Log.v(LOGTAG, "uiData=" + uiData);

        //Log.v(LOGTAG, "pageData=" + pageData.toString());

        //N: FullScreen + top status, Y: Have Bar + top status, M: only bar - top status, F: full screen - top status
        String topbar = HybridTools.optString(getUiData("topbar"));

        switch (topbar) {
            case "F":
                requestWindowFeature(Window.FEATURE_NO_TITLE);
                this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
                break;
            case "Y":
                requestWindowFeature(Window.FEATURE_NO_TITLE);
                break;
            case "M":
                this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
            case "N":
                break;
        }
        setTitle("TODO setTitle()");
        try {
            ActionBar actionBar = getActionBar();
            //NOTES: setDisplayHomeAsUpEnabled make onOptionsItemSelected() work
            actionBar.setDisplayHomeAsUpEnabled(true);
        } catch (NullPointerException ex) {
            ex.printStackTrace();
        } catch (NoSuchMethodError ex) {
            ex.printStackTrace();
        }
//        //Hide title bar, TODO base on param...
//        if (false) {
//            requestWindowFeature(Window.FEATURE_NO_TITLE);
//        } else {
////            requestWindowFeature(Window.FEATURE_CUSTOM_TITLE);
////            requestWindowFeature(Window.FEATURE_LEFT_ICON);
//            //setContentView(R.layout.); //or whatever layout is shows
////            setFeatureDrawableResource(Window.FEATURE_LEFT_ICON,R.drawable.abc_btn_check_material);
//            //getActionBar().setIcon(R.drawable.abc_btn_radio_material);
////            getActionBar().setIcon(R.drawable.back3x);
////            try {
//////                getActionBar().setDisplayHomeAsUpEnabled(true);
////                //getActionBar().setdis
////            } catch (NullPointerException ex) {
////                ex.printStackTrace();
////            }
//            setTitle("TODO setTitle()");
////            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.HONEYCOMB) {
////            }
//            try {
//                ActionBar actionBar = getActionBar();
//                //setDisplayHomeAsUpEnabled make onOptionsItemSelected() work
//                actionBar.setDisplayHomeAsUpEnabled(true);
//            } catch (NullPointerException ex) {
//                ex.printStackTrace();
//            } catch (NoSuchMethodError ex) {
//                ex.printStackTrace();
//            }
//        }

//Hide status bar.  todo by param
//        if(true)
//        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        final Context _ctx = this;

//        mWebView = HybridService.BuildWebViewWithJsBridgeSupport(_ctx);//TODO

        //com.github.lzyzsd.jsbridge
        mWebView = HybridTools.BuildOldJsBridge(_ctx);

        //NOTES: if not set, the js alert won't effect...(maybe the default return is true)
        mWebView.setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onJsAlert(WebView view, String url, String message, final JsResult result) {
                HybridTools.appAlert(_ctx, message, new AlertDialog.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        result.confirm();
                    }
                });
                return true;
            }

            @Override
            public boolean onJsConfirm(WebView view, String url, String message, final JsResult jsrst) {
                HybridTools.appConfirm(_ctx, message, new AlertDialog.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        jsrst.confirm();
                    }
                }, new AlertDialog.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        jsrst.cancel();
                    }
                });
                return true;
            }
        });

        setContentView(mWebView);

        mURL = "file:///android_asset/root.htm";//TODO
        mWebView.registerHandler("_app_activity_close", new BridgeHandler() {

            @Override
            public void handler(String data, CallBackFunction function) {
                Log.v(LOGTAG, "handler = _app_activity_close");
                WebViewUi.this.onBackPressed();
            }
        });
        mWebView.registerHandler("_app_activity_open", new BridgeHandler() {

                    @Override
                    public void handler(String data, CallBackFunction cb) {
                        Log.v("_app_activity_open", data);

                        WebViewUi.this._cb = cb;
//                        new Handler().postDelayed(new Runnable() {
//                            @Override
//                            public void run() {
                        Intent intent = new Intent(WebViewUi.this, WebViewUi.class);
                        intent.putExtra("uiData", data);

//                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        startActivityForResult(intent, 1);//@ref onActivityResult()
                        Log.v("_app_activity_open", "startActivityForResult");
//                            }
//                        }, 11);
                    }

                }
        );

        Log.v(LOGTAG, "load mURL=" + mURL);
        mWebView.loadUrl(mURL);

    }

    @Override
    public void onBackPressed() {        // to prevent irritating accidental logouts
        Log.v(LOGTAG, "onBackPressed set Result 1");
        setResult(1, new Intent());
        finish();
    }

    //in case old androids dont have onBackPress()
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        Log.v(LOGTAG, "onKeyDown KEYCODE_BACK");
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            onBackPressed();
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }
}
