//
//  SongInfo.h
//  iMusic
//
//  Created by Malkavia on 2/18/15.
//  Copyright (c) 2015 Malkavia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SongInfo : NSObject

@property(nonatomic) NSString *coverImageString;
@property(nonatomic) NSString *title;
@property(nonatomic) NSString *urlString;
@property(nonatomic) NSString *singer;

-(void)setBaseInfo:(NSString *)weiboDetail;
-(NSString *)getCoverImageStringWithParam:(NSString *)param;
@end
