#import <Foundation/Foundation.h>
#import "CMPHybridWebViewUi.h"
#import "CMPHybridApi.h"
#import "CMPHybridTools.h"
#import "JSO.h"

@import JavaScriptCore;

@implementation CMPHybridWebViewUi

//NSMutableDictionary* myMessageHandlers;

//------------  UIViewController ------------


//------------  prototol UIWebViewDelegate ------------

//
//-(BOOL)isCorrectProcotocolScheme:(NSURL*)url {
//    if([[url scheme] isEqualToString:@"jsb1"]){
//        return YES;
//    } else {
//        return NO;
//    }
//}

//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//
//    NSURL *url = [request URL];
//    NSLog(@" shouldStartLoadWithRequest() %@ ",url);
//
//    if (webView != self.myWebView) {
//        NSLog(@" TODO why the requested webview is not the one private ??? ");
//        return YES;
//    }
////
////    if ([self isCorrectProcotocolScheme:url]) {
////        NSLog(@" ignore the old jsb1 scheme....no need any more");
////        return NO;
////    } else {
////        return YES;
////    }
//    return YES;
//}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    CMPHybridUi *caller=self;
    
    if (webView != self.myWebView) {
        NSLog(@" skip: not the same webview?? ");
        return;
    }
    
    NSString *js = [CMPHybridTools readAssetInStr:@"WebViewJavascriptBridge.js"];
    
    //    JSContext *ctx = [CMPHybridTools getWebViewJsCtx:webView];
    JSContext *ctx = [CMPHybridTools getWebViewJsCtx :self.myWebView];
    
    //inject nativejsb
    [ctx evaluateScript:@"nativejsb={version:20161116};"];
    
    //inject nativejsb.js2app()
    ctx[@"nativejsb"][@"js2app"]=^(JSValue *callBackId,JSValue *handlerName,JSValue *param){
        
#warning TODO to check the handlerName is auth by api_auth in config.json for current url !!
        
        HybridHandler handler = self.myApiHandlers[[handlerName toString]];
        
        if (nil==handler) {
            NSLog(@" !!! found no handler for %@", handlerName);
            //return nil;
            return;
        }
        NSString *callBackId_s=[callBackId toString];
        HybridCallback callback=^(JSO *responseData){
            NSLog(@" callback(%@) return %@",callBackId_s, [responseData toString]);
            
            //            JSO *rt=[JSO s2o:@"{}"];
            //            [rt setChild:@"responseId" JSO:[JSO s2o:callBackId_s]];
            //            [rt setChild:@"responseData" JSO:responseData];
            //            id dd=@{@"responseId":callBackId_s,@"responseData":[responseData toId]};
            
            NSString *rt_s=[JSO id2s:@{@"responseId":callBackId_s,@"responseData":[responseData toId]}];
            
            NSString* javascriptCommand = [NSString stringWithFormat:@"WebViewJavascriptBridge._app2js(%@);", rt_s];
            [caller evalJs:javascriptCommand];
            
            //            //do the callback a little later
            //            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            //            double delay = 0.01;//1=1 second
            //
            //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), queue, ^{
            //                @try {
            //                    [caller evalJs:javascriptCommand];
            //                } @catch (NSException *exception) {
            //                    callback([JSO id2o:@{@"STS":@"KO",@"errmsg":[exception reason]}]);
            //                }
            //            });
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                @try {
            //                    [caller evalJs:javascriptCommand];
            //                } @catch (NSException *exception) {
            //                    callback([JSO id2o:@{@"STS":@"KO",@"errmsg":[exception reason]}]);
            //                }
            //            });
        };
        //do the callback a little later
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        double delay = 0.01;//1=1 second
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), queue, ^{
            NSString *param_s=[param toString];
            @try {
                handler([JSO s2o:param_s], callback);
            } @catch (NSException *exception) {
                callback([JSO id2o:@{@"STS":@"KO",@"errmsg":[exception reason]}]);
            }
        });
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //            NSString *param_s=[param toString];
        //            @try {
        //                handler([JSO s2o:param_s], callback);
        //            } @catch (NSException *exception) {
        //                callback([JSO id2o:@{@"STS":@"KO",@"errmsg":[exception reason]}]);
        //            }
        //        });
        //        //to the handler a little later (failed for some ui need the main thread now... to optimize later!
        //        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //        double delay = 0.01;//1=1 second
        //
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), queue, ^{
        //            handler([JSO s2o:param_s], callback);
        //        });
    };
    
    //STUB
    //    [ctx setExceptionHandler:^(JSContext *context, JSValue *value) {
    //        NSLog(@"%@", value);
    //    }];
    
    [ctx evaluateScript:js];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@" didFailLoadWithError() %@",error);
    //TODO design a error handler in config.json with handlerClassName...
}

//------------   <HybridUi> ------------

- (JSValue *) evalJs:(NSString *)js_s
{
    //    if ([[NSThread currentThread] isMainThread]) {
    //        //NSLog(@" debug HybridWebView %@",js_s);
    //        return [CMPHybridTools callWebViewDoJs:self.myWebView :js_s];
    //    } else {
    //        dispatch_sync(dispatch_get_main_queue(), ^{
    //            //NSLog(@" dispatch_sync to dispatch_get_main_queue %@",js_s);
    ////            [self evalJs:js_s];
    //            //return
    //            [CMPHybridTools callWebViewDoJs:self.myWebView :js_s];
    //        });
    //    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [CMPHybridTools callWebViewDoJs:self.myWebView :js_s];
    });
    return nil;
}

//------------ self -----------------

- (void)registerHandlerApi{
    
    self.myApiHandlers = [NSMutableDictionary dictionary];
    
    // get the appConfig:
    JSO *appConfig = [CMPHybridTools wholeAppConfig];
    
    JSO *api_mapping = [appConfig getChild:@"api_mapping"];
    
    for (NSString *kkk in [api_mapping getChildKeys]) {
        
        // Get the value through the key:
        
        NSString *apiname = [[api_mapping getChild:kkk] toString] ;
        CMPHybridApi *api = [CMPHybridTools getHybridApi:apiname];
        api.currentUi = self;
        self.myApiHandlers[kkk] = [[api getHandler] copy];
    }
}

- (void) loadUrl:(NSString *)url{
    NSURL *requesturl = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:requesturl];
    [self.myWebView loadRequest:request];
}

-(void) initUi
{
    [self registerHandlerApi];
    
    [self CustomTopBarBtn];
    
    // initial the webView and add webview in window：
    CGRect rect = [UIScreen mainScreen].bounds;
    
    self.myWebView = [[UIWebView alloc]initWithFrame:rect];
    
    self.myWebView.backgroundColor = [UIColor whiteColor];
    self.myWebView.delegate = self;// NOTES: UIWebViewDelegate, using "self" as the responder...
    
    // The page automatically zoom to fit the screen, default NO.
    self.myWebView.scalesPageToFit = YES;
    
    // Edges prohibit sliding (default YES)
    self.myWebView.scrollView.bounces = NO;
    
    self.view = self.myWebView;
    
    NSString *address = [[self.uiData getChild:@"address"] toString];
    NSURL *address_url = [NSURL URLWithString:address];
    NSString *scheme_s=[address_url scheme];
    
    if( [ CMPHybridTools isEmptyString:scheme_s ])
    {
        [self loadUrl:[@"file://" stringByAppendingString:[CMPHybridTools fullPathOfAsset:address]]];
    }else{
        [self loadUrl:[address_url absoluteString]];
    }
}

//@overrided
- (void) CustomTopBarBtn
{
    //    UIBarButtonItem *leftBar
    //    = [[UIBarButtonItem alloc]
    //       initWithImage:[UIImage imageNamed:@"btn_nav bar_left arrow"]//see Images.xcassets
    //       style:UIBarButtonItemStylePlain
    //       target:self
    //       action:@selector(closeUi) //on('click')=>close()
    //       ];
    //    leftBar.tintColor = [UIColor blueColor];
    
    self.navigationItem.leftBarButtonItem
    = [[UIBarButtonItem alloc]
       initWithBarButtonSystemItem:UIBarButtonSystemItemReply
       target:self
       action:@selector(closeUi)];
    //
    //    UIBarButtonItem *rightBtn
    //    = [[UIBarButtonItem alloc]
    //       initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:nil];
    //    self.navigationItem.rightBarButtonItem = rightBtn;
}

@end
