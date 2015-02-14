//
//  InitViewController.h
//  iMusic
//
//  Created by Malkavia on 2/14/15.
//  Copyright (c) 2015 Malkavia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareAssetLibrary.h"
@interface InitViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *weiboURL;
- (IBAction)comfimAddress:(id)sender;

@end
