//
//  ViewController.m
//  iMusic
//
//  Created by Malkavia on 2/10/15.
//  Copyright (c) 2015 Malkavia. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, 400)];
    NSString *url = @"http://www.weibo.com/malkavia";
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) webViewDidFinishLoad:(UIWebView *)webView {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible =NO;
    self.title =  [webView stringByEvaluatingJavaScriptFromString:@"document.title"];//获取当前页面的title
    
    self.currentURL = webView.request.URL.absoluteString;
  //  NSLog(@"title-%@--url-%@--",self.title,self.currentURL);
    
    NSString *lJs = @"document.documentElement.innerHTML";//获取当前网页的html
    self.currentHTML = [webView stringByEvaluatingJavaScriptFromString:lJs];
    NSString *shareInfo =  [self getUsefulString:self.currentHTML];
    [self shareToWeChat:shareInfo];
    
}
- (void)loadWebView:(id)sender{
    [self webViewDidFinishLoad:_webView];
}

- (NSString *)getUsefulString: (NSString *)html{
    NSRange range = [html rangeOfString:@"default-content txt-xl"];
    NSString *subString = [html substringFromIndex:range.location+24];
   // subString = [subString substringToIndex:500];
    
    NSRange urlRange = [subString rangeOfString:@"<a data-url"];
    NSString *urlString = [subString substringFromIndex:urlRange.location+13];
    urlString = [urlString substringToIndex:19];
    _url = urlString;
    NSRange singgerFrom = [subString rangeOfString:@"cDesc"];
    NSString *singgerString = [subString substringFromIndex:singgerFrom.location+7];
    NSRange singgerTo = [singgerString rangeOfString:@"</"];
    singgerString = [singgerString substringToIndex:singgerTo.location];
    
    NSRange titleRangeFrom = [subString rangeOfString:@"surl-text"];
    NSString *titleString = [subString substringFromIndex:titleRangeFrom.location+11];
    NSRange titleRangeTo = [titleString rangeOfString:@"</span"];
    titleString = [titleString substringToIndex:titleRangeTo.location];
    
    
    NSString *finalString = [NSString stringWithFormat:@"分享了 %@ 的歌曲《%@》，点击试听",singgerString,titleString];
    NSLog(@"%@",finalString);
    
    NSRange coverRangeFrom = [subString rangeOfString:@"media-main"];
    NSString *coverString = [subString substringFromIndex:coverRangeFrom.location];
    NSRange coverRangeFrom2 = [coverString rangeOfString:@"="];
    coverString = [coverString substringFromIndex:coverRangeFrom2.location+2];
    NSRange coverRangeTo = [coverString rangeOfString:@"height"];
    coverString = [coverString substringToIndex:coverRangeTo.location-2];
    
    NSLog(@"%@",coverString);

    return finalString;
}

-(void)shareToWeChat:(NSString *)shareInfo{
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"545acb60fd98c5e074008da5"
                                      shareText:shareInfo
                                     shareImage:[UIImage imageNamed:@"icon.png"]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToSms,UMShareToWechatSession,UMShareToWechatTimeline,nil]
                                       delegate:self];
    NSLog(@"%@",_url);
    [UMSocialData defaultData].extConfig.wechatSessionData.url =_url;
    NSRange range = [_url rangeOfString:@"//"];
    NSString *timelineUrl = [_url substringFromIndex:range.location+2];
    NSLog(@"timelineUrl + %@",timelineUrl);
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = timelineUrl;
}
@end



