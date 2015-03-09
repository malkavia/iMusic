//
//  AsyncImageLoader.h
//  iMusic
//
//  Created by Malkavia on 3/9/15.
//  Copyright (c) 2015 Malkavia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AsyncImageLoader : UIImageView
{
    NSURLConnection *connection;
    NSMutableData *loadData;
}
//图片对应的缓存在沙河中的路径
@property (nonatomic, retain) NSString *fileName;

//请求网络图片的URL
@property (nonatomic, strong) NSString *imageURL;
@end
