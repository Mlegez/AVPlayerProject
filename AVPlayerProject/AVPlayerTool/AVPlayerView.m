//
//  AVPlayerView.m
//  PhoenixChinese
//
//  Created by captain on 2016/10/27.
//  Copyright © 2016年 李诚. All rights reserved.
//

#define WEAKSELF                        __weak typeof(self) weakSelf = self;


#import "AVPlayerView.h"
#import "HYAssetResourceLoaderServer.h"
#import "AVFileTool.h"

@interface AVPlayerView (){
    //总时间
    float second;
    BOOL isPlaying;
}

@property (nonatomic, strong) NSURL                     *videoURL;

@property (nonatomic, strong) AVPlayerItem              *playerItem;
@property (nonatomic, strong) AVPlayer                  *player;

//当前播放时长
@property (nonatomic, assign) CGFloat                   currentTime;

@property (nonatomic, assign) BOOL                      isPlay;

@property (nonatomic, strong) HYAssetResourceLoaderServer           *resourceLoader;
// 缓存文件路径
@property (nonatomic, strong) NSString                              *cacheFilePath;
// 加载URL
@property (nonatomic, strong) NSURL           *loadURL;
// 是否需要缓存
@property (nonatomic, assign) BOOL            isCancache;
// 初始frame
@property (nonatomic, assign) CGRect           initializationFrame;

@end

@implementation AVPlayerView

// 当前资源缓存数据
- (NSString *)cacheFilePath {
    
    return  [AVFileTool getLocalVideoFilePath:[AVFileTool getMutableHTTPUrl:self.videoURL].absoluteString];
}

// 用于请求资源的URL
- (NSURL *)loadURL {
    NSURL *URL = self.videoURL;
    if (self.isCancache) {
        NSData *cacheData = [NSData dataWithContentsOfFile:self.cacheFilePath];
        if (cacheData && cacheData.length > 0) {
            URL = [NSURL fileURLWithPath:self.cacheFilePath];
        }else {
            // NSURLComponents用来替代NSMutableURL，可以readwrite修改URL
            // AVAssetResourceLoader通过你提供的委托对象去调节AVURLAsset所需要的加载资源。
            // 而很重要的一点是，AVAssetResourceLoader仅在AVURLAsset不知道如何去加载这个URL资源时才会被调用
            // 就是说你提供的委托对象在AVURLAsset不知道如何加载资源时才会得到调用。
            // 所以我们又要通过一些方法来曲线解决这个问题，把我们目标视频URL地址的scheme替换为系统不能识别的scheme
            URL = [AVFileTool getMutableCompent:self.videoURL];
        }
    }
    return URL;
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //移除KVO
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferFull"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
}

- (instancetype)initWithURL:(NSURL *)videoURL frame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.videoURL = videoURL;
        [self configPlayView];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)videoURL frame:(CGRect)frame isCancache:(BOOL)isCancache{
    if (self = [super initWithFrame:frame]) {
        self.videoURL = videoURL;
        self.isCancache = isCancache;
        [self configPlayView];
    }
    return self;
}

#pragma mark=======================UI==========================
- (void)configPlayView {
    
    AVURLAsset *movieAsset = [AVURLAsset URLAssetWithURL:self.loadURL options:nil];
    self.resourceLoader = [[HYAssetResourceLoaderServer alloc] init];
    [movieAsset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_get_main_queue()];
    self.playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    // 添加监听
    [self addObserver];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.playerLayer.frame = self.bounds;
    self.playerLayer.backgroundColor = [[UIColor blackColor] CGColor];
    [self.layer addSublayer:self.playerLayer];
}

- (void)addObserver {
    //监听status属性
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监听loadedTimeRanges属性
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    // 是否全部缓冲
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:nil];
    // 是否可以流畅播放
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    // 缓冲数据为空
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    // 播放结束
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}

#pragma mark====================界面布局===========================
- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}

#pragma mark ================== 播放Notification ===============
/**
 *  @author 施峰磊, 15-06-02 11:06:02
 *  TODO:播放结束
 *  @since 1.0
 */
- (void)moviePlayDidEnd:(NSNotificationCenter *)notification{
    CMTime dragedCMTime = kCMTimeZero;
    [self.player seekToTime:dragedCMTime completionHandler:^(BOOL finish){
        
    }];
    if (self.delegate && [self.delegate respondsToSelector:@selector(avPlayerViewDidPlayEnd:)]) {
        [self.delegate avPlayerViewDidPlayEnd:self];
    }
}

/**
 *  TODO:监听播放状态
 */
- (void)monitoringPlayStatus:(AVPlayerItem *)playerItem {
    WEAKSELF
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 24) queue:NULL usingBlock:^(CMTime time) {
        weakSelf.currentTime = CMTimeGetSeconds(time);// 计算当前在第几秒
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(avPlayerView:currentTime:)]) {
            [weakSelf.delegate avPlayerView:weakSelf currentTime:weakSelf.currentTime];
        }
    }];
}

#pragma mark ================= 播放监听KVO ==============
/**
 *  @author 施峰磊, 15-06-02 15:06:46
 *
 *  TODO:kvo监听
 *  @since 1.0
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            //获取视频总长度
            CMTime duration = self.playerItem.duration;
            self.totalDuration = CMTimeGetSeconds(duration);
            // 监听播放状态
            [self monitoringPlayStatus:self.playerItem];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(avPlayerView:didFinishLoadingBaseInfo:)]) {
                [self.delegate avPlayerView:self didFinishLoadingBaseInfo:CMTimeGetSeconds(duration)];
            }
            
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            // 加载失败
            if (self.delegate && [self.delegate respondsToSelector:@selector(avPlayerViewLoadFailed:)]) {
                [self.delegate avPlayerViewLoadFailed:self];
            }
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        //持续加载
        NSArray *array = playerItem.loadedTimeRanges;
        //本次缓冲时间范围
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        CGFloat startSeconds = CMTimeGetSeconds(timeRange.start);
        CGFloat durationSeconds = CMTimeGetSeconds(timeRange.duration);
        //缓冲总长度
        CGFloat totalBuffer = startSeconds + durationSeconds;
        if ([self.delegate respondsToSelector:@selector(avPlayerView:didloadingRange:)]) {
            [self.delegate avPlayerView:self didloadingRange:totalBuffer];
        }
    }else if ( [keyPath isEqualToString:@"playbackBufferEmpty"]){
        NSLog(@"playbackBufferEmpty");
        // 没有了缓冲数据
        if (playerItem.playbackBufferEmpty) {
            if ([self.delegate respondsToSelector:@selector(avPlayerViewPlaybackBufferIsEmpty:)]) {
                [self.delegate avPlayerViewPlaybackBufferIsEmpty:self];
            }
        }
    }
}

/**
 *  @author 施峰磊, 15-06-02 15:06:17
 *
 *  TODO:计算缓冲时间
 *
 *  @return NSTimeInterval
 *
 *  @since 1.0
 */
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}


#pragma mark ==== Public Method =====
// 开始播放
- (void)play {
    self.isPlay = YES;
    [self.player play];
}

// 暂停播放
- (void)pause {
    self.isPlay = NO;
    [self.player pause];
}

// 停止播放
- (void)stopPlay {
    self.isPlay = YES;
    [self.player pause];
    [self setPlayerProgress:0];
}

/*
 *  设置播放进度
 */
- (void)setPlayerProgress:(CGFloat)progress {
    CMTime dragedCMTime = CMTimeMake(progress, 1);
    [self.player seekToTime:dragedCMTime completionHandler:^(BOOL finish){
        
    }];
}

/*
 *  设置音量
 */
- (void)setVediovolume:(CGFloat)volume {
    NSArray *audioTracks = [self.playerItem.asset tracksWithMediaType:AVMediaTypeAudio];
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams =
        [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:volume atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    [audioMix setInputParameters:allAudioParams];
    [self.playerItem setAudioMix:audioMix];
}

// 设置全屏
- (void)fullScreen{
    self.initializationFrame = self.frame;
    //横屏
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
    //添加到Window上
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.frame = [UIApplication sharedApplication].keyWindow.bounds;
}

// 取消全屏
- (void)cancelFullScreenWithSuperView:(UIView *)superView{
    //旋转屏幕
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    [superView addSubview:self];
    self.frame = self.initializationFrame;
}


@end
