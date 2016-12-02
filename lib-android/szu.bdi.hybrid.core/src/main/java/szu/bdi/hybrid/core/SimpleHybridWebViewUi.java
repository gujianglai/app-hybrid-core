package szu.bdi.hybrid.core;


import android.annotation.TargetApi;
import android.content.Context;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

//@SuppressLint({"SetJavaScriptEnabled", "JavascriptInterface"})
public class SimpleHybridWebViewUi extends HybridUi {

    final private static String LOGTAG = "SimpleHybridWebViewUi";
    private JsBridgeWebView _wv = null;

    @TargetApi(Build.VERSION_CODES.ICE_CREAM_SANDWICH)
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.v(LOGTAG, ".onCreate()");
        super.onCreate(savedInstanceState);

        String title = HybridTools.optString(this.getUiData("title"));
        if (!HybridTools.isEmptyString(title)) {
            setTitle(title);
        }

        final Context _ctx = this;

        _wv = new JsBridgeWebView(_ctx);

        String address = HybridTools.optString(this.getUiData("address"));
        String url = "";
        if (address == null || "".equals(address)) {
            url = "file://" + HybridTools.getLocalWebRoot() + "error.htm";
        } else {
            if (address.matches("^\\w+://.*$")) {
                //if have schema already
                url = address;
            } else {
                //assume local...
                url = "file://" + HybridTools.getLocalWebRoot() + address;
            }
        }

        HybridTools.bindWebViewApi(_wv, this);

        setContentView(_wv);
        _wv.loadUrl(url);
    }

    protected void onPostResume() {
        super.onPostResume();
        if (null != _wv) {
            _wv.loadUrl("javascript:try{$(document).trigger('postresume');}catch(ex){}");
        }
    }

    protected void onResume() {
        super.onResume();
        if (null != _wv) {
            _wv.loadUrl("javascript:try{$(document).trigger('resume');}catch(ex){}");
        }
    }
}
