//
//  HtmlReader.m
//  iMusic
//
//  Created by Malkavia on 3/9/15.
//  Copyright (c) 2015 Malkavia. All rights reserved.
//

#import "HtmlReader.h"

@implementation HtmlReader
-(NSString *)getCurrentHTML:(UIWebView *)webView{

    [UIApplication sharedApplication].networkActivityIndicatorVisible =NO;
    NSString *html = @"";
    if ([webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"]!=nil) {
        html = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
    }
    
    return html;
}

- (NSString *)getLoadingPageAddress: (UIWebView *)webView{
    NSString *allWeiboAddressString = @"";
    NSString *html = [self getCurrentHTML:webView];
    if ([html containsString:@"default-content txt-xl"]){
        NSRange allWeiboRangeEnd = [html rangeOfString:@"_-_WEIBO_SECOND_PROFILE_WEIBO"];
        allWeiboAddressString = [html substringToIndex:allWeiboRangeEnd.location];
        NSRange allWeiboRangeStart = [html rangeOfString:@"containerid="];
        allWeiboAddressString = [allWeiboAddressString substringFromIndex:allWeiboRangeStart.location];
        allWeiboAddressString = [[NSString stringWithFormat:@"http://m.weibo.cn/page/tpl?"] stringByAppendingString:allWeiboAddressString];
        allWeiboAddressString = [allWeiboAddressString stringByAppendingString:@"_-_WEIBO_SECOND_PROFILE_WEIBO"];
    }
    return allWeiboAddressString;
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
-(void)findSong:(UIWebView *)webView{
    [self getSongInfo:webView];
    if ([self.songArray count]!=0) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"didFindSong" object:self.songArray];
    }
}

@end
