//
//  PaymentWebViewController.m
//  NicePayAppSample
//
//  Created by  on 12. 4. 27..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PaymentWebViewController.h"
#import "AppDelegate.h"

@implementation PaymentWebViewController
@synthesize bankPayUrlString;

enum AppStoreLinkTag {
	app_link_isp,
	app_link_bank,
}AppStoreLinkTag;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) requestBankPayResult:(NSString*)bodyString
{
    //bankPayUrlString 계좌이체 인증 결과 url
    NSURL *url = [NSURL URLWithString: bankPayUrlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [bodyString dataUsingEncoding: NSUTF8StringEncoding]];
    [self.webViewEngine loadRequest:request];
}

- (void) requestIspPayResult:(NSURL*)url {
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [url.query componentsSeparatedByString:@"&"];

    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];

        [queryStringDictionary setObject:value forKey:key];
    }

    NSString *baseDir = [[NSBundle mainBundle] resourcePath];
    NSString *completeUrl = [NSString stringWithFormat:@"file://%@/www/pages/order/order-cplt.html?orderId=%@", baseDir, [queryStringDictionary objectForKey:@"id"]];

    NSString* webStringURL = [completeUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSURLRequest *request = [[NSURLRequest alloc]initWithURL: [NSURL URLWithString:webStringURL]];

    [self.webViewEngine loadRequest:request];
}

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void) webView: (WKWebView *) webView decidePolicyForNavigationAction: (WKNavigationAction*) navigationAction decisionHandler: (void (^)(WKNavigationActionPolicy)) decisionHandler {
    NSURLRequest *request = navigationAction.request;

    NSURL* url = [navigationAction.request URL];

    //현재 URL 을 읽음
    NSString* URLString = [NSString stringWithString:[request.URL absoluteString]];

    NSLog(@"current URL %@",URLString);

    //app store URL 여부 확인
    BOOL goAppStore =  ([URLString rangeOfString:@"phobos.apple.com" options:NSCaseInsensitiveSearch].location != NSNotFound);
    BOOL goAppStore2 =  ([URLString rangeOfString:@"itunes.apple.com" options:NSCaseInsensitiveSearch].location != NSNotFound);

    //app store 로 연결하는 경우 앱스토어 APP을 열어 준다. (isp, bank app 이 설치하고자 경우)
    if(goAppStore || goAppStore2){
        [[UIApplication sharedApplication] openURL:request.URL];
        return decisionHandler(WKNavigationActionPolicyCancel);
    }

    //isp App을 호출하는 경우
    if([URLString hasPrefix:@"ispmobile://"]){
        //앱이 설치 되어 있는 확인
        if([[UIApplication sharedApplication] canOpenURL:request.URL]) {  //설치 되어 있을 경우 isp App 호출
            [[UIApplication sharedApplication] openURL:request.URL];
        }
        else {    //설치 되어 있지 않다면 app store 연결
            [self showAlertViewWithMessage:@"모바일 ISP가 설치되어 있지 않아\nApp Store로 이동합니다."
                                    tagNum:app_link_isp];
            return decisionHandler(WKNavigationActionPolicyCancel);
        }
    }

    NSMutableDictionary* dic = [[NSMutableDictionary alloc]initWithCapacity:10];
    [dic objectForKey:@""];

    //계좌이체
    if([URLString hasPrefix:@"kftc-bankpay://"]){
        //앱이 설치 되어 있는 확인
        if([[UIApplication sharedApplication] canOpenURL:request.URL]) {

            NSRange range = [URLString rangeOfString:@"callbackparam1="];
            if(range.location != NSNotFound) {
                int cutIdx = range.location + [@"callbackparam1=" length];
                self.bankPayUrlString = [URLString substringFromIndex:cutIdx];
                NSLog(@"bankPayUrlString: %@",bankPayUrlString);
            }
            [[UIApplication sharedApplication] openURL:request.URL]; //설치 되어 있을 경우 App 호출
        }
        else {
            //설치 되어 있지 않다면 app store 연결
            [self showAlertViewWithMessage:@"Bank Pay가 설치되어 있지 않아\nApp Store로 이동합니다."
                                    tagNum:app_link_bank];
            return decisionHandler(WKNavigationActionPolicyCancel);
        }
    }

    else if([URLString containsString:@"droidxantivirus"] ||
            [URLString containsString:@"lottesmartpay"] ||
            [URLString containsString:@"smshinhancardusim://"] ||
            [URLString containsString:@"shinhan-sr-ansimclick"] ||
            [URLString containsString:@"v3mobile"] ||
            [URLString containsString:@"smartwall"] ||
            [URLString containsString:@"appfree"] ||
            [URLString containsString:@"ansimclick://"] ||
            [URLString containsString:@"ansimclickscard"] ||
            [URLString containsString:@"ansim://"] ||
            [URLString containsString:@"mpocket"] ||
            [URLString containsString:@"mvaccine"]) {

            [[UIApplication sharedApplication] openURL:request.URL]; //설치 되어 있을 경우 App 호출
            return decisionHandler(WKNavigationActionPolicyCancel);
    }

    else if([URLString hasPrefix:@"gajago://"]) {

        if([URLString hasPrefix:@"gajago://orderComplete"]) {
            NSString *baseDir = [[NSBundle mainBundle] resourcePath];

            NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
            NSArray *urlComponents = [url.query componentsSeparatedByString:@"&"];

            for (NSString *keyValuePair in urlComponents)
            {
                NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
                NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];

                [queryStringDictionary setObject:value forKey:key];
            }

            NSString *completeUrl = [NSString stringWithFormat:@"file://%@/www/pages/order/order-cplt.html?orderId=%@", baseDir, [queryStringDictionary objectForKey:@"id"]];

            NSString* webStringURL = [completeUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL* url = [NSURL URLWithString:webStringURL];

            NSURLRequest *request = [[NSURLRequest alloc]initWithURL: url];
            [self.webViewEngine loadRequest:request];
        }
    }

    return decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark UIWebDelegate implementation

/*
- (void)webViewDidFinishLoad:(UIWebView*)theWebView
{
    // Black base color for background matches the native apps
    theWebView.backgroundColor = [UIColor blackColor];

    return [super webViewDidFinishLoad:theWebView];
}

- (void) webViewDidStartLoad:(UIWebView*)theWebView
{
    return [super webViewDidStartLoad:theWebView];
}

- (void) webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error
{
    return [super webView:theWebView didFailLoadWithError:error];
}

/*
- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //현재 URL 을 읽음
    NSString* URLString = [NSString stringWithString:[request.URL absoluteString]];

    NSLog(@"current URL %@",URLString);

    //app store URL 여부 확인
    BOOL goAppStore =  ([URLString rangeOfString:@"phobos.apple.com" options:NSCaseInsensitiveSearch].location != NSNotFound);
    BOOL goAppStore2 =  ([URLString rangeOfString:@"itunes.apple.com" options:NSCaseInsensitiveSearch].location != NSNotFound);

    //app store 로 연결하는 경우 앱스토어 APP을 열어 준다. (isp, bank app 이 설치하고자 경우)
    if(goAppStore || goAppStore2){
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }

    //isp App을 호출하는 경우
    if([URLString hasPrefix:@"ispmobile://"]){
        //앱이 설치 되어 있는 확인
        if([[UIApplication sharedApplication] canOpenURL:request.URL]) {  //설치 되어 있을 경우 isp App 호출
            [[UIApplication sharedApplication] openURL:request.URL];
        }
        else {    //설치 되어 있지 않다면 app store 연결
            [self showAlertViewWithMessage:@"모바일 ISP가 설치되어 있지 않아\nApp Store로 이동합니다."
                                    tagNum:app_link_isp];
            return NO;
        }

    }

    NSMutableDictionary* dic = [[NSMutableDictionary alloc]initWithCapacity:10];
    [dic objectForKey:@""];

    //계좌이체
    if([URLString hasPrefix:@"kftc-bankpay://"]){
        //앱이 설치 되어 있는 확인
        if([[UIApplication sharedApplication] canOpenURL:request.URL]) {

            NSRange range = [URLString rangeOfString:@"callbackparam1="];
            if(range.location != NSNotFound) {
                int cutIdx = range.location + [@"callbackparam1=" length];
                self.bankPayUrlString = [URLString substringFromIndex:cutIdx];
                NSLog(@"bankPayUrlString: %@",bankPayUrlString);
            }
            [[UIApplication sharedApplication] openURL:request.URL]; //설치 되어 있을 경우 App 호출
        }
        else {
            //설치 되어 있지 않다면 app store 연결
            [self showAlertViewWithMessage:@"Bank Pay가 설치되어 있지 않아\nApp Store로 이동합니다."
                                    tagNum:app_link_bank];
            return NO;
        }
    }
    return [ super webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType ];
}
*/

- (void) showAlertViewWithMessage:(NSString*)msg tagNum:(NSInteger)tag
{

	UIAlertView *v = [[UIAlertView alloc] initWithTitle:@"알림"
												message:msg
											   delegate:self
									  cancelButtonTitle:@"확인"
									  otherButtonTitles:nil];

	v.tag = tag;

	[v show];
}


#pragma mark UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(alertView.tag == app_link_isp)
	{
        NSString* URLString = @"http://itunes.apple.com/kr/app/id369125087?mt=8";
		NSURL* storeURL = [NSURL URLWithString:URLString];
		[[UIApplication sharedApplication] openURL:storeURL];
	}
	else if(alertView.tag == app_link_bank)
	{
		NSString* URLString = @"http://itunes.apple.com/us/app/id398456030?mt=8";
		NSURL* storeURL = [NSURL URLWithString:URLString];
		[[UIApplication sharedApplication] openURL:storeURL];

	}
}

@end

@implementation PaymentCommandDelegate


#pragma mark CDVCommandDelegate implementation

- (id)getCommandInstance:(NSString*)className
{
    return [super getCommandInstance:className];
}

- (NSString*)pathForResource:(NSString*)resourcepath
{
    return [super pathForResource:resourcepath];
}

@end

@implementation PaymentCommandQueue

- (BOOL)execute:(CDVInvokedUrlCommand*)command {
    return [super execute:command];
}

@end