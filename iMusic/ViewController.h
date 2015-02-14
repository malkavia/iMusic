//
//  ViewController.h
//  iMusic
//
//  Created by Malkavia on 2/10/15.
//  Copyright (c) 2015 Malkavia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMSocial.h"
@interface ViewController : UIViewController <UMSocialUIDelegate>
@property (strong,nonatomic)UIWebView *webView;
@property (strong,nonatomic)NSString *currentURL;
@property (strong,nonatomic)NSString *currentTitle;
@property (strong,nonatomic)NSString *currentHTML;
@property (strong,nonatomic)NSString *url;
- (IBAction)loadWebView:(id)sender;

@end

