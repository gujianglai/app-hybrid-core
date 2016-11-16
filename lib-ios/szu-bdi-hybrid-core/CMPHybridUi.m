#import "CMPHybridUi.h"
#import "CMPHybridTools.h"
#import "JSO.h"

@implementation CMPHybridUi


-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self trigger:@"close" :@{@"debug":@"closeUi"}];
}
-(void) restoreTopBarStatus
{
    JSO *param =self.uiData;
    JSO *topbarmode=[param getChild:@"topbar"];
    NSString *topbarmode_s=[JSO o2s:topbarmode];
    [self CustomTopBar :topbarmode_s];
}
-(void) CustomTopBar :(NSString *)mode
{
    if ([CMPHybridTools isEmptyString:mode])
        mode=@"Y";
    
    if([@"F" isEqualToString:mode]){
        [self hideTopStatusBar];
        [self hideTopBar];
    }
    if([@"M" isEqualToString:mode]){
        [self hideTopStatusBar];
        [self showTopBar];
    }
    if([@"Y" isEqualToString:mode]){
        [self showTopStatusBar];
        [self showTopBar];
    }
    if([@"N" isEqualToString:mode]){
        [self showTopStatusBar];
        [self hideTopBar];
    }
}
//NOTES: can be overrided!
- (void) CustomTopBarBtn
{
    //    [[self navigationController] setNavigationBarHidden:YES animated:NO];
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
    
    //    UIBarButtonItem *rightBtn
    //    = [[UIBarButtonItem alloc]
    //       initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:nil];
    //    self.navigationItem.rightBarButtonItem = rightBtn;
}

//NOTES: child can override the behavior...
- (void)closeUi{
    
    BOOL flagIsLast=YES;
    id<UIApplicationDelegate> ddd = [UIApplication sharedApplication].delegate;
    UINavigationController *nnn=self.navigationController;
    if (nnn!=nil){
        NSArray *vvv = nnn.viewControllers;
        if(vvv!=nil){
            if(vvv.count>1){
                [self.navigationController popViewControllerAnimated:YES];
                flagIsLast=NO;
            }
        }
        if(flagIsLast==YES){
            NSLog(@" TODO for flagIsLast==YES");
        }
    }else{
        UIViewController *rootUi  =ddd.window.rootViewController;
        if (rootUi == self){
            NSLog(@" TODO !!! root = self");
            flagIsLast=YES;
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    if(flagIsLast==YES){
        //quit app if prompted yes
        [CMPHybridTools
         quickConfirmMsgMain:@"Sure to Quit?"
         //handlerYes:^(UIAlertAction *action)
         handlerYes:(HybridDialogCallback) ^{
             [self dismissViewControllerAnimated:YES completion:nil];
             [CMPHybridTools quitGracefully];
         }
         handlerNo:nil];
    }
}

//////////////////////////////  on/trigger mechanism
-(void) on:(NSString *)eventName :(HybridEventHandler) handler
{
    [self on:eventName :handler :nil];
}
-(void) on:(NSString *)eventName :(HybridEventHandler) handler :(id)extraData
{
    self.tmpHandler=handler;
}
-(void) trigger :(NSString *)eventName :(id)extraData
{
    HybridEventHandler hdl=self.tmpHandler;
    if(nil!=hdl){
        hdl(eventName, extraData);
    }
    NSLog(@"TODO trigger event %@", eventName);
}
//////////////////////////////

/* About FullScreen (hide top status bar)
 // Plan A, It works for iOS 5 and iOS 6 , but not in iOS 7.
 // [UIApplication sharedApplication].statusBarHidden = YES;
 // Info.plist need add:
 //    <key>UIStatusBarHidden</key>
 //    <true/>
 // Plan B: Info.plist
 //    <key>UIViewControllerBasedStatusBarAppearance</key>
 //    <false/>
 //    [[UIApplication sharedApplication] setStatusBarHidden:YES
 //                                            withAnimation:UIStatusBarAnimationFade];
 
 //@ref http://stackoverflow.com/questions/18979837/how-to-hide-ios-status-bar
 */
- (BOOL)prefersStatusBarHidden {
    return YES;
}
-(void) hideTopStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}
-(void) showTopStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}
-(void) hideTopBar
{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}
-(void) showTopBar
{
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
}
@end