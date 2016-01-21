//
//  AppDelegate+NicePayment.h
//  Gajago
//
//  Created by KangDongho on 1/21/16.
//
//

#import "AppDelegate.h"
#import "PaymentWebViewController.h"

@interface AppDelegate (NicePayment) <UIAlertViewDelegate>

-(void) callByPaymentAppWith:(NSURL*)url;
@end