package szu.bdi.hybrid.core.eg;

//@doc https://szu-bdi.gitbooks.io/app-hybrid/content/

import android.util.Log;

import java.util.Date;

import szu.bdi.hybrid.core.HybridApi;
import szu.bdi.hybrid.core.HybridCallback;
import szu.bdi.hybrid.core.HybridHandler;

import info.cmptech.JSO;


/**
 *
 *
 */
public class ApiUiTitle extends HybridApi {
    public HybridHandler getHandler() {
        return new HybridHandler() {
//            @Override
//            public void handler(String dataStr, HybridCallback cb) {
//                Log.v("ApiPingPong", dataStr);
//
//                JSO data_o = JSO.s2o(dataStr);
//                data_o.setChild("STS", JSO.s2o("TODO"));
//                data_o.setChild("pong", JSO.s2o("" + (new Date()).getTime()));
//                cb.onCallBack(data_o.toString());
//            }

            @Override
            public void handler(JSO jso, HybridCallback apiCallback) {

                jso.setChild("STS", JSO.s2o("TODO"));
                jso.setChild("pong", JSO.s2o("" + (new Date()).getTime()));
                apiCallback.onCallBack(jso);
                //handler(JSO.o2s(jso), cbFunc);
            }
        };
    }
}
