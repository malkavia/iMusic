//
//  HtmlReader.h
//  iMusic
//
//  Created by Malkavia on 3/9/15.
//  Copyright (c) 2015 Malkavia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SongInfo.h"
@interface HtmlReader : NSObject
@property (strong, nonatomic) SongInfo *song;
@property (strong,nonatomic) NSMutableArray *songArray;
-(void)findSong:(UIWebView *)webView;
@end
