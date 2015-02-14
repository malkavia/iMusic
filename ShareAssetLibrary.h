//
//  ShareAssetLibrary.h
//  iMusic
//
//  Created by Malkavia on 2/14/15.
//  Copyright (c) 2015 Malkavia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareAssetLibrary : NSObject

//读取和设置配置文件
+ (NSString*)getValueForKey:(NSString *)key;
+ (void)setValue:(NSString *)value ForKey:(NSString *)key;
@end
