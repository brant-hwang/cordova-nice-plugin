//
//  AppDelegate+NicePayment.m
//  Gajago
//
//  Created by KangDongho on 1/21/16.
//
//

#import "AppDelegate+NicePayment.h"

@implementation AppDelegate (NicePayment)

#pragma mark UIApplicationDelegate implementation

/**
 * This is main kick off after the app inits, the views and Settings are setup here. (preferred - iOS4 and up)
 */
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [[NSHTTPCookieStorage sharedHTTPCookieStorage]
     setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
#if __has_feature(objc_arc)
    self.window = [[UIWindow alloc] initWithFrame:screenBounds];
#else
    self.window = [[[UIWindow alloc] initWithFrame:screenBounds] autorelease];
#endif
    self.window.autoresizesSubviews = YES;
    
#if __has_feature(objc_arc)
    self.viewController = [[PaymentWebViewController alloc] init];
#else
    self.viewController = [[[PaymentWebViewController alloc] init] autorelease];
#endif
    
    // Set your app's start page by setting the <content src='foo.html' /> tag in config.xml.
    // If necessary, uncomment the line below to override it.
    // self.viewController.startPage = @"index.html";
    
    // NOTE: To customize the view's frame size (which defaults to full screen), override
    // [self.viewController viewWillAppear:] in your view controller.
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    // iOS 4.1이전에서 custom url scheme handle
    [self callByPaymentAppWith:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // iOS 4.2이후
    [self callByPaymentAppWith:url];
    return YES;
}

#pragma mark - AppDelegate Payment Methods

-(void) callByPaymentAppWith:(NSURL*)url
{
    NSString* URLkeyString = [NSString stringWithString:[url absoluteString]];
    NSLog(@"URLkey : %@",URLkeyString);
    
#define MY_APP_URL_KEY  @"nicepaysample://"
    //scheme 를 통한 호출 여부
    if(URLkeyString !=  nil)
    {
        if([URLkeyString hasPrefix:MY_APP_URL_KEY])
        {
            
            NSRange range = [URLkeyString rangeOfString:@"?bankpaycode"];    //계좌이체 인경우
            if(range.location != NSNotFound) { //계좌이체 인증 후 거래 진행
                
                //[MY_APP_URL_KEY length]+1 => 계좌이체인 경우  scheme + ? 로 리던 되어 "?" 도 함께 삭제 함.
                //nicepaysample://?bankpaycode=xxxx ...." 에서 "bankpaycode=xxxx ...." 추출하기 위함
                URLkeyString = [URLkeyString substringFromIndex:[MY_APP_URL_KEY length]+1];
//                [self.webViewController requestBankPayResult:URLkeyString];
                return;
            }
            
            //결제 요청 필드 내
            range = [URLkeyString rangeOfString:@"ISPCancel"];
            if(range.location != NSNotFound) { //ISP 취소인 경우
                UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"알림"
                                                                    message:@"결제를 취소하셨습니다."
                                                                   delegate:self cancelButtonTitle:@"확인"
                                                          otherButtonTitles:nil];
                alertView.tag = 900;
                [alertView show];
                return;
            }
            
            range = [URLkeyString rangeOfString:@"ispResult.jsp"];
            if(range.location != NSNotFound) { //ISP 인증 후 결제 진행
                //[MY_APP_URL_KEY length]+3 => ISP 경우  scheme + :// 로 리턴 되어 "://" 도 함께 삭제 함.
                //  nicepaysample://://http://web.nicepay.co.kr/smart/card/isp/ .... ispResult.jsp 에서
                // http://web.nicepay.co.kr/smart/card/isp/.... ispResult.jsp" 추출하기 위함
                URLkeyString = [URLkeyString substringFromIndex:[MY_APP_URL_KEY length]+3];
//                [self.webViewController requesIspPayResult:URLkeyString];
                return;
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 900){
//        [self.webViewController close];  // ISP 결제 취소로 인해 결제 화면을 닫습니다.
    }
}
@end
