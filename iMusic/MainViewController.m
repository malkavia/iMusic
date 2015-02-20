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
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, 400)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeWeibo:) name:@"WeiboUrlAddress" object:nil];
    NSString *urlFromInfo = [ShareAssetLibrary getValueForKey:@"WeiboUrlAddress"];
    self.isInTheFirstPage = YES;
    if (!self.isChangingWeibo) {
        self.weiboUrlAddress = [defaultUrl stringByAppendingString:urlFromInfo];
    }else{
        self.weiboUrlAddress = [defaultUrl stringByAppendingString:self.weiboUrlAddress];
        self.isChangingWeibo = NO;
    }
    
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.weiboUrlAddress]];
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
    }
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)shareToWeibo:(id)sender{
    self.shareInfo = [self getUsefulString:_webView];
    [self setWechatInfo:self.shareInfo];

}

-(void)scrollToTheEnd{
    NSInteger height = [[_webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
    NSString* javascript = [NSString stringWithFormat:@"window.scrollBy(0, %ld);", height];
    [_webView stringByEvaluatingJavaScriptFromString:javascript];
}


- (IBAction)backToInit:(id)sender {
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:@"initViewController"];
    [self presentViewController: initViewController animated:YES completion:^{}];
}

- (IBAction)refreshPage:(id)sender {
    NSURLRequest *request ;
    if (self.loadingPageAddress==nil) {
        self.loadingPageAddress = @"";
    }
    if ([self.loadingPageAddress isEqualToString:@""]) {
        request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.weiboUrlAddress]];
    }else{
        request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.loadingPageAddress]];
    }
        [_webView loadRequest:request];
}

- (IBAction)loadMore:(id)sender {
    if (self.isInTheFirstPage) {
        [self getUsefulString:_webView];
        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.loadingPageAddress]];
        [_webView loadRequest:request];
        self.isInTheFirstPage = NO;
    }else{
        [self scrollToTheEnd];
    }
}

- (NSString *)getUsefulString: (UIWebView *)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible =NO;
    self.title =  [webView stringByEvaluatingJavaScriptFromString:@"document.title"];//获取当前页面的title
    self.currentURL = webView.request.URL.absoluteString;
    NSString *lJs = @"document.documentElement.innerHTML";//获取当前网页的html
    self.currentHTML = [webView stringByEvaluatingJavaScriptFromString:lJs];
    NSString *html = self.currentHTML;
    if ([html containsString:@"default-content txt-xl"]){
   //     NSLog(@"%@",html);
        
        NSRange allWeiboRangeEnd = [html rangeOfString:@"_-_WEIBO_SECOND_PROFILE_WEIBO"];
        NSString *allWeiboAddressString = [html substringToIndex:allWeiboRangeEnd.location];
        NSRange allWeiboRangeStart = [html rangeOfString:@"containerid="];
        allWeiboAddressString = [allWeiboAddressString substringFromIndex:allWeiboRangeStart.location];
        allWeiboAddressString = [[NSString stringWithFormat:@"http://m.weibo.cn/page/tpl?"] stringByAppendingString:allWeiboAddressString];
       allWeiboAddressString = [allWeiboAddressString stringByAppendingString:@"_-_WEIBO_SECOND_PROFILE_WEIBO"];
        NSLog(@"%@",allWeiboAddressString);
        _loadingPageAddress = allWeiboAddressString;
        
        NSRange range = [html rangeOfString:@"default-content txt-xl"];
        NSString *subString = [html substringFromIndex:range.location+24];
       // subString = [subString substringToIndex:500];
        
        NSRange urlRange = [subString rangeOfString:@"<a data-url"];
        NSString *urlString = [subString substringFromIndex:urlRange.location+13];
        urlString = [urlString substringToIndex:19];
        _assetUrlString = urlString;
        NSRange singgerFrom = [subString rangeOfString:@"cDesc"];
        NSString *singgerString = [subString substringFromIndex:singgerFrom.location+7];
        NSRange singgerTo = [singgerString rangeOfString:@"</"];
        singgerString = [singgerString substringToIndex:singgerTo.location];
        
        NSRange titleRangeFrom = [subString rangeOfString:@"surl-text"];
        NSString *titleString = [subString substringFromIndex:titleRangeFrom.location+11];
        NSRange titleRangeTo = [titleString rangeOfString:@"</span"];
        titleString = [titleString substringToIndex:titleRangeTo.location];
    
    
        NSString *finalString = [NSString stringWithFormat:@"分享了 %@ 的歌曲《%@》，点击试听",singgerString,titleString];
//        NSLog(@"%@",finalString);
        
        NSRange coverRangeFrom = [subString rangeOfString:@"media-main"];
        NSString *coverString = [subString substringFromIndex:coverRangeFrom.location];
        NSRange coverRangeFrom2 = [coverString rangeOfString:@"="];
        coverString = [coverString substringFromIndex:coverRangeFrom2.location+2];
        NSRange coverRangeTo = [coverString rangeOfString:@"height"];
        coverString = [coverString substringToIndex:coverRangeTo.location-2];
        NSLog(@"coverString : %@",coverString);
        self.coverURL = [NSURL URLWithString:coverString];
        
        SongInfo *songInfo;
        songInfo.title = titleString;
        songInfo.urlString = urlString;
        songInfo.coverImageString = coverString;
        
        [self.songArray addObject:songInfo];
        return finalString;
    }else{
        return @"";
    }
}

-(void)setWechatInfo:(NSString *)shareInfo{
    NSLog(@"coverString : %@",self.coverURL);

    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"545acb60fd98c5e074008da5"
                                      shareText:shareInfo
                                     shareImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:self.coverURL]]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToSms,UMShareToWechatSession,UMShareToWechatTimeline,nil]
                                       delegate:self];
//    NSLog(@"%@",_assetUrlString);
    [UMSocialData defaultData].extConfig.wechatSessionData.url =_assetUrlString;
    NSRange range = [_assetUrlString rangeOfString:@"//"];
    NSString *timelineUrl = [_assetUrlString substringFromIndex:range.location+2];
//  NSLog(@"timelineUrl + %@",timelineUrl);
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = timelineUrl;
}

//更改微博地址
-(void)changeWeibo:(NSNotificationCenter *)sender{
    self.isChangingWeibo = YES;
    NSString *url = sender.description;
    self.weiboUrlAddress = url;
}


@end



