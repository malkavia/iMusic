//
//  InitViewController.m
//  iMusic
//
//  Created by Malkavia on 2/14/15.
//  Copyright (c) 2015 Malkavia. All rights reserved.
//

#import "InitViewController.h"

@interface InitViewController ()

@end

@implementation InitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.weiboURL.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.weiboURL resignFirstResponder];
    return YES;
}


- (IBAction)comfimAddress:(id)sender {
    NSString *urlAddress = [_weiboURL.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![urlAddress isEqualToString:@""]) {
        
        if (![[ShareAssetLibrary getValueForKey:@"WeiboUrlAddress"] isEqualToString:@""]) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"WeiboUrlAddress" object:urlAddress];
        }
        [ShareAssetLibrary setValue:urlAddress ForKey:@"WeiboUrlAddress"];

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"mainViewController"];
        mainViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:mainViewController animated:YES completion:^{ }];
    }
}

@end
