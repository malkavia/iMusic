//
//  ShareAssetLibrary.m
//  iMusic
//
//  Created by Malkavia on 2/14/15.
//  Copyright (c) 2015 Malkavia. All rights reserved.
//

#import "ShareAssetLibrary.h"

@implementation ShareAssetLibrary
static NSString* configFilePath;

+(void)initConfig{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSString *configDirectory = [documentsDirectory stringByAppendingPathComponent:@"config"];
    configFilePath = [configDirectory stringByAppendingPathComponent:@"config.plist"];
    if ( ![fileManage fileExistsAtPath:configFilePath] ) {
        BOOL ok = [fileManage createDirectoryAtPath:configDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        if ( ok ) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
            [dict setObject:@"" forKey:@"WeiboUrlAddress"];
            [dict writeToFile:configFilePath atomically:YES];
        }
        else{
            NSLog(@"create file failed!");
        }
    }

}

+ (NSString *)getValueForKey:(NSString *)key
{
    [self initConfig];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:configFilePath];
    NSString *value =  [dictionary objectForKey:key];
    return value;
}

+ (void)setValue:(NSString *)value ForKey:(NSString *)key
{
    [self initConfig];
    NSMutableDictionary* dicWrite = [[[NSMutableDictionary alloc] initWithContentsOfFile:configFilePath] mutableCopy];
    [dicWrite setValue:value forKey:key];
    [dicWrite writeToFile:configFilePath atomically:YES];
    
}

@end
