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
NSOperationQueue *opeartionQueue;
NSString *defaultUrl = @"http://www.weibo.com/";

- (void)viewDidLoad {
    [super viewDidLoad];
    opeartionQueue=[[NSOperationQueue alloc] init];
    [opeartionQueue setMaxConcurrentOperationCount:-1];
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, 300)];
    NSString *urlFromInfo = [ShareAssetLibrary getValueForKey:@"WeiboUrlAddress"];
    self.isTheFirstPageOfWeibo = YES;
    if (!self.isChangingWeibo) {
        self.weiboUrlAddress = [defaultUrl stringByAppendingString:urlFromInfo];
    }else{
        self.weiboUrlAddress = [defaultUrl stringByAppendingString:self.weiboUrlAddress];
        self.isChangingWeibo = NO;
    }
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.weiboUrlAddress]];
    [self.webView loadRequest:request];
    self.webView.delegate = self;

    [self.view addSubview:self.webView];
    [self initBroadCasts];
    [self.songCollectionView setBackgroundColor:[UIColor whiteColor]];
    self.songCollectionView.delegate = self;
    self.songCollectionView.dataSource = self;
    }
-(void)initBroadCasts{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeWeibo:) name:@"WeiboUrlAddress" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCollectionView:) name:@"didFindSong" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



//分享
- (void)shareToWeibo:(id)sender{
    self.assetUrlString = self.song.urlString;
    self.coverURL = [NSURL URLWithString:[self.song getCoverImageStringWithParam:@"?param=150y150"]];
    self.shareInfo = [NSString stringWithFormat:@"分享了 %@ 的歌曲《%@》，点击试听",self.song.singer, self.song.title];
    
   [self setWechatInfo:self.shareInfo];

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

-(void)setWechatInfo:(NSString *)shareInfo{
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"545acb60fd98c5e074008da5"
                                      shareText:shareInfo
                                     shareImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:self.coverURL]]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToSms,UMShareToWechatSession,UMShareToWechatTimeline,nil]
                                       delegate:self];
    [UMSocialData defaultData].extConfig.wechatSessionData.url =self.assetUrlString;
    NSRange range = [self.assetUrlString rangeOfString:@"//"];
    NSString *timelineUrl = [self.assetUrlString substringFromIndex:range.location+2];
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = timelineUrl;
}

//加载更多
- (IBAction)loadMore:(id)sender {
    HtmlReader *reader = [[HtmlReader alloc]init];
    [reader findSong:self.webView];
    
    if (self.isTheFirstPageOfWeibo) {
        [self getLoadingPageAddress:self.webView];
        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.loadingPageAddress]];
        [self.webView loadRequest:request];
        self.isTheFirstPageOfWeibo = NO;
    }else{
        [self scrollToTheEnd];
    }
}
-(void)scrollToTheEnd{
    NSInteger height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
    NSString* javascript = [NSString stringWithFormat:@"window.scrollBy(0, %ld);", height];
    [self.webView stringByEvaluatingJavaScriptFromString:javascript];
}
//修改微博地址
- (IBAction)backToInit:(id)sender {
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:@"initViewController"];
    [self presentViewController: initViewController animated:YES completion:^{}];
}
-(void)changeWeibo:(NSNotificationCenter *)sender{
    self.isChangingWeibo = YES;
    NSString *url = sender.description;
    self.weiboUrlAddress = url;
}
//刷新
- (IBAction)refreshPage:(id)sender {
    NSURLRequest *request ;
//    if (self.loadingPageAddress==nil) {
//        self.loadingPageAddress = @"";
//    }
    if (self.loadingPageAddress == nil||[self.loadingPageAddress isEqualToString:@""]) {
        request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.weiboUrlAddress]];
    }else{
        request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.loadingPageAddress]];
    }
        [self.webView loadRequest:request];
    
}
- (void)getLoadingPageAddress: (UIWebView *)webView{

    NSString *html = [self getCurrentHTML:webView];
    if ([html containsString:@"default-content txt-xl"]){
        NSRange allWeiboRangeEnd = [html rangeOfString:@"_-_WEIBO_SECOND_PROFILE_WEIBO"];
        NSString *allWeiboAddressString = [html substringToIndex:allWeiboRangeEnd.location];
        NSRange allWeiboRangeStart = [html rangeOfString:@"containerid="];
        allWeiboAddressString = [allWeiboAddressString substringFromIndex:allWeiboRangeStart.location];
        allWeiboAddressString = [[NSString stringWithFormat:@"http://m.weibo.cn/page/tpl?"] stringByAppendingString:allWeiboAddressString];
        allWeiboAddressString = [allWeiboAddressString stringByAppendingString:@"_-_WEIBO_SECOND_PROFILE_WEIBO"];
        self.loadingPageAddress = allWeiboAddressString;
    }
}
-(NSString *)getCurrentHTML:(UIWebView*)webView{
    sleep(1);
    [UIApplication sharedApplication].networkActivityIndicatorVisible =NO;
    NSString *html = @"";
    if ([webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"]!=nil) {
        html = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
    }
    
    return html;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.song = [self.songArray objectAtIndex:indexPath.row];
    [self shareToWeibo:nil];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.songArray count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
     SongCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    SongInfo *song = [self.songArray objectAtIndex:indexPath.row];
    NSString *coverImgWithParam = [song getCoverImageStringWithParam:@"?param=80y80"];
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverImgWithParam]];
//    UIImage *coverImg =[UIImage imageWithData:data];
//    UIImageView *coverImgView = [[UIImageView alloc]initWithImage:coverImg];
    AsyncImageLoader *asynImgView = [[AsyncImageLoader alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    [asynImgView setImageURL:coverImgWithParam];
    [cell addSubview:asynImgView];
//    [cell setBackgroundColor:[UIColor blackColor]];
//    [cell addSubview:coverImgView];
    return cell;
}

-(void)refreshCollectionView :(NSNotification *)sender{
    self.songArray = sender.object;

    [self.songCollectionView reloadSections:[[NSIndexSet alloc] initWithIndex:0]];
}
-(void)findSong{
    [self getSongInfo:self.webView];
    if ([self.songArray count]!=0) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"didFindSong" object:self];
    }
}

@end



