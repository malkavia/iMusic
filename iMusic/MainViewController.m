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

-(void) webViewDidFinishLoad:(UIWebView *)webView {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible =NO;
    self.title =  [webView stringByEvaluatingJavaScriptFromString:@"document.title"];//获取当前页面的title
    self.currentURL = webView.request.URL.absoluteString;
    NSString *lJs = @"document.documentElement.innerHTML";//获取当前网页的html
    self.currentHTML = [webView stringByEvaluatingJavaScriptFromString:lJs];
    NSString *shareInfo =  [self getUsefulString:self.currentHTML];
    [self shareToWeChat:shareInfo];
}
- (void)loadWebView:(id)sender{
    [self webViewDidFinishLoad:_webView];
}

- (IBAction)backToInit:(id)sender {
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:@"initViewController"];
    [self presentViewController: initViewController animated:YES completion:^{}];
}

- (IBAction)refreshPage:(id)sender {
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.weiboUrlAddress]];
    [_webView loadRequest:request];
}

- (NSString *)getUsefulString: (NSString *)html{
    if ([html containsString:@"default-content txt-xl"]){
        NSRange range = [html rangeOfString:@"default-content txt-xl"];
        NSString *subString = [html substringFromIndex:range.location+24];
       // subString = [subString substringToIndex:500];
        
        NSRange urlRange = [subString rangeOfString:@"<a data-url"];
        NSString *urlString = [subString substringFromIndex:urlRange.location+13];
        urlString = [urlString substringToIndex:19];
        _weiboUrlAddress = urlString;
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
    }else{
        return @"";
    }
}

-(void)shareToWeChat:(NSString *)shareInfo{
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"545acb60fd98c5e074008da5"
                                      shareText:shareInfo
                                     shareImage:[UIImage imageNamed:@"icon.png"]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToSms,UMShareToWechatSession,UMShareToWechatTimeline,nil]
                                       delegate:self];
    NSLog(@"%@",_weiboUrlAddress);
    [UMSocialData defaultData].extConfig.wechatSessionData.url =_weiboUrlAddress;
    NSRange range = [_weiboUrlAddress rangeOfString:@"//"];
    NSString *timelineUrl = [_weiboUrlAddress substringFromIndex:range.location+2];
    NSLog(@"timelineUrl + %@",timelineUrl);
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = timelineUrl;
}

//更改微博地址
-(void)changeWeibo:(NSNotificationCenter *)sender{
    self.isChangingWeibo = YES;
    NSString *url = sender.description;
    self.weiboUrlAddress = url;
}

@end



