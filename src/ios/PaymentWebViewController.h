//
//  PaymentWebViewController.h
//  NicePayAppSample
//
//  Created by  on 12. 4. 27..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cordova/CDVViewController.h>
#import <Cordova/CDVCommandDelegateImpl.h>
#import <Cordova/CDVCommandQueue.h>
#import <WebKit/WebKit.h>

@interface PaymentWebViewController : CDVViewController <UIAlertViewDelegate, WKNavigationDelegate>
@property(nonatomic,retain)  NSString* bankPayUrlString;
- (void) showAlertViewWithMessage:(NSString*)msg tagNum:(NSInteger)tag;
@end


@interface PaymentCommandDelegate : CDVCommandDelegateImpl
@end

@interface PaymentCommandQueue : CDVCommandQueue
@end

