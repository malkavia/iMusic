//
//  ViewController.h
//  iMusic
//
//  Created by Malkavia on 2/10/15.
//  Copyright (c) 2015 Malkavia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareAssetLibrary.h"
#import "UMSocial.h"
#import "SongInfo.h"
#import "SongCell.h"
#import "HtmlReader.h"
#import "AsyncImageLoader.h"
@interface MainViewController : UIViewController <UMSocialUIDelegate,UIWebViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property (strong,nonatomic)UIWebView *webView;
@property (strong,nonatomic)NSString *weiboUrlAddress;
@property (strong,nonatomic)NSString *loadingPageAddress;
@property (strong,nonatomic)NSString *assetUrlString;
@property (strong, nonatomic)NSURL *coverURL;
@property (nonatomic)BOOL isChangingWeibo;
@property (strong,nonatomic) NSString *shareInfo;
@property (nonatomic)BOOL isTheFirstPageOfWeibo;
@property (strong,nonatomic) NSMutableArray *songArray;
@property (strong, nonatomic) IBOutlet UICollectionView *songCollectionView;
@property (strong, nonatomic) SongInfo *song;
- (IBAction)shareToWeibo:(id)sender;
- (IBAction)backToInit:(id)sender;
- (IBAction)refreshPage:(id)sender;
- (IBAction)loadMore:(id)sender;

@end

