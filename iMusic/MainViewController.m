//
//  ViewController.m
//  iMusic
//
//  Created by Malkavia on 2/10/15.
//  Copyright (c) 2015 Malkavia. All rights reserved.
//

#import "MainViewController.h"
@interface MainViewController ()

@end

@implementation MainViewController

NSString *defaultUrl = @"http://www.weibo.com/";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, 400)];
    
    NSString *urlFromInfo = [ShareAssetLibrary getValueForKey:@"WeiboUrlAddress"];
    self.isTheFirstPageOfWeibo = YES;
    if (!self.isChangingWeibo) {
        self.weiboUrlAddress = [defaultUrl stringByAppendingString:urlFromInfo];
    }else{
        self.weiboUrlAddress = [defaultUrl stringByAppendingString:self.weiboUrlAddress];
        self.isChangingWeibo = NO;
    }
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.weiboUrlAddress]];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    [self initBroadCasts];
    }
-(void)initBroadCasts{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeWeibo:) name:@"WeiboUrlAddress" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



//分享
- (void)shareToWeibo:(id)sender{
    [self getSongInfo:self.webView];
    SongInfo *songInfo = [self.songArray objectAtIndex:0];
    self.assetUrlString = songInfo.urlString;
    self.coverURL = [NSURL URLWithString:songInfo.coverImageString];
    self.shareInfo = [NSString stringWithFormat:@"分享了 %@ 的歌曲《%@》，点击试听",songInfo.singer, songInfo.title];
    
   [self setWechatInfo:self.shareInfo];

}

-(void)getSongInfo:(UIWebView *)webView{
    
    NSString *html = [self getCurrentHTML:webView];
    self.songArray = [[NSMutableArray alloc]init];
    
    while ([html containsString:@"weibo-detail"]) {
        NSRange weiboDetailStartRange = [html rangeOfString:@"<section class=\"weibo-detail\">"];
        html = [html substringFromIndex:weiboDetailStartRange.location];
        NSRange weiboDetailEndRange = [html rangeOfString:@"</section>"];
        
        NSString *weiboDetail = [html substringToIndex:weiboDetailEndRange.location+10];
        html = [html substringFromIndex:weiboDetailEndRange.location];
        if ([weiboDetail containsString:@"分享单曲"]) {
            SongInfo *songInfo = [[SongInfo alloc]init];
            [songInfo setBaseInfo:weiboDetail];
            [self.songArray addObject:songInfo];
        }
    }
}

-(void)setWechatInfo:(NSString *)shareInfo{
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"545acb60fd98c5e074008da5"
                                      shareText:shareInfo
                                     shareImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:self.coverURL]]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToSms,UMShareToWechatSession,UMShareToWechatTimeline,nil]
                                       delegate:self];
    [UMSocialData defaultData].extConfig.wechatSessionData.url =self.assetUrlString;
    NSRange range = [self.assetUrlString rangeOfString:@"//"];
    NSString *timelineUrl = [self.assetUrlString substringFromIndex:range.location+2];
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = timelineUrl;
}

//加载更多
- (IBAction)loadMore:(id)sender {
    if (self.isTheFirstPageOfWeibo) {
        [self getLoadingPageAddress:self.webView];
        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.loadingPageAddress]];
        [self.webView loadRequest:request];
        self.isTheFirstPageOfWeibo = NO;
    }else{
        [self scrollToTheEnd];
    }
}
-(void)scrollToTheEnd{
    NSInteger height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
    NSString* javascript = [NSString stringWithFormat:@"window.scrollBy(0, %ld);", height];
    [self.webView stringByEvaluatingJavaScriptFromString:javascript];
}
//修改微博地址
- (IBAction)backToInit:(id)sender {
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:@"initViewController"];
    [self presentViewController: initViewController animated:YES completion:^{}];
}
-(void)changeWeibo:(NSNotificationCenter *)sender{
    self.isChangingWeibo = YES;
    NSString *url = sender.description;
    self.weiboUrlAddress = url;
}
//刷新
- (IBAction)refreshPage:(id)sender {
    NSURLRequest *request ;
//    if (self.loadingPageAddress==nil) {
//        self.loadingPageAddress = @"";
//    }
    if (self.loadingPageAddress == nil||[self.loadingPageAddress isEqualToString:@""]) {
        request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.weiboUrlAddress]];
    }else{
        request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.loadingPageAddress]];
    }
        [self.webView loadRequest:request];
}
- (void)getLoadingPageAddress: (UIWebView *)webView{

    NSString *html = [self getCurrentHTML:webView];
    if ([html containsString:@"default-content txt-xl"]){
        NSRange allWeiboRangeEnd = [html rangeOfString:@"_-_WEIBO_SECOND_PROFILE_WEIBO"];
        NSString *allWeiboAddressString = [html substringToIndex:allWeiboRangeEnd.location];
        NSRange allWeiboRangeStart = [html rangeOfString:@"containerid="];
        allWeiboAddressString = [allWeiboAddressString substringFromIndex:allWeiboRangeStart.location];
        allWeiboAddressString = [[NSString stringWithFormat:@"http://m.weibo.cn/page/tpl?"] stringByAppendingString:allWeiboAddressString];
        allWeiboAddressString = [allWeiboAddressString stringByAppendingString:@"_-_WEIBO_SECOND_PROFILE_WEIBO"];
        self.loadingPageAddress = allWeiboAddressString;
    }
}
-(NSString *)getCurrentHTML:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible =NO;
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
    return html;
}




@end



