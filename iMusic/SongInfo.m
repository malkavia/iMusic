//
//  SongInfo.m
//  iMusic
//
//  Created by Malkavia on 2/18/15.
//  Copyright (c) 2015 Malkavia. All rights reserved.
//

#import "SongInfo.h"

@implementation SongInfo

-(void)setBaseInfo:(NSString *)weiboDetail{
    self.title = [self getSongTitle:weiboDetail];
    self.urlString = [self getUrlString:weiboDetail];
    self.singer = [self getSingerString:weiboDetail];
    self.coverImageString = [self getCoverImageString:weiboDetail];
}


-(NSString *)getSongTitle:(NSString *)weiboDetail{
    NSRange titleStart = [weiboDetail rangeOfString:@"<span class=\"surl-text\">"];
    NSString *title = [weiboDetail substringFromIndex:titleStart.location+24];
    NSRange titleEnd = [title rangeOfString:@"</span>"];
    title = [title substringToIndex:titleEnd.location];
//    NSLog(@"%@",title);
    return title;
}
-(NSString *)getCoverImageString:(NSString *)weiboDetail{
    NSRange imgStart = [weiboDetail rangeOfString:@"<div class=\"media-main\">"];
    NSString *imgString = [weiboDetail substringFromIndex:imgStart.location];
    NSRange imgStart2 = [imgString rangeOfString:@"img src"];
    imgString = [imgString substringFromIndex:imgStart2.location+9];
    NSRange imgEnd = [imgString rangeOfString:@"?"];
    imgString = [imgString substringToIndex:imgEnd.location];
//  NSLog(@"%@",imgString);
    return  imgString;
}
-(NSString *)getUrlString:(NSString *)weiboDetail{
    NSRange urlStart = [weiboDetail rangeOfString:@"<a data-url=\""];
    NSString *urlString = [weiboDetail substringFromIndex:urlStart.location+13];
    NSRange urlEnd = [urlString rangeOfString:@"href="];
    urlString = [urlString substringToIndex:urlEnd.location-2];
//    NSLog(@"%@",urlString);
    return urlString;
}
-(NSString *)getSingerString:(NSString *)weiboDetail{
    NSRange singerStart = [weiboDetail rangeOfString:@"cDesc"];
    NSString *singerString = [weiboDetail substringFromIndex:singerStart.location+7];
    NSRange singerEnd = [singerString rangeOfString:@"</div>"];
    singerString = [singerString substringToIndex:singerEnd.location];
//    NSLog(@"%@",singerString);
    return singerString;
}
-(NSString *)getCoverImageStringWithParam:(NSString *)param{
    return [self.coverImageString stringByAppendingString:param];
}

@end
