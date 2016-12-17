package szu.bdi.hybrid.core;

import android.content.Context;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

public class SimpleHybridWebViewUi extends HybridUi {

    final private static String LOGTAG = (((new Throwable()).getStackTrace())[0]).getClassName();
    private JsBridgeWebView _wv = null;

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

        setContentView(_wv);

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
        _wv.loadUrl(url);
        _wv.setBackgroundColor(Color.TRANSPARENT);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
            _wv.setLayerType(_wv.LAYER_TYPE_SOFTWARE, null);
        }
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

    protected void onPause() {
        super.onPause();
        if (null != _wv) {
            _wv.loadUrl("javascript:try{$(document).trigger('pause');}catch(ex){}");
        }
    }
}
