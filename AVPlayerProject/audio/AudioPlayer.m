//
//  AudioPlayer.m
//  MEIKU
//
//  Created by 李诚 on 15/6/24.
//  Copyright (c) 2015年 Mrrck. All rights reserved.
//

#import "AudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

static AudioPlayer  *_audioPlayer = nil;

@interface AudioPlayer ()

@property (nonatomic, strong) AVPlayerItem              *playerItem;
@property (nonatomic, strong) AVPlayer                  *player;

@property (nonatomic, strong) NSURL                     *audioPath;

@end

@implementation AudioPlayer

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //移除KVO
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

/**
 *  @author 李诚, 15-06-24 16:06:02
 *
 *  TODO:创建音频播放单例
 *
 *  @return
 */
+ (AudioPlayer *)shareInstance {
    @synchronized(self) {
        if (!_audioPlayer) {
            _audioPlayer = [[self alloc] init];
        }
    }
    return _audioPlayer;
}

/**
 *  @author 李诚, 15-06-24 16:06:17
 *
 *  TODO:释放单例
 */
+ (void)freeInstance {
    [_audioPlayer pause];
    _audioPlayer = nil;
}

- (void)configPlayer{
    //音频播放一定要加上这句，否则声音很小
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:self.audioPath options:nil];
    self.playerItem = [AVPlayerItem playerItemWithAsset:audioAsset];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}

- (void)playAudioWithFileURL:(NSURL *)fileURL {
    self.audioPath = fileURL;
    // 移除监听
    [self removeObserver];
    [self configPlayer];
}

- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
}

/**
 *  @author 李诚, 15-07-03 11:07:43
 *
 *  TODO:播放
 */
- (void)play {
    if (self.player) {
        [self.player play];
    }else {
        [self configPlayer];
        [self.player play];
    }
}

/**
 *  @author 李诚, 15-06-24 16:06:41
 *
 *  TODO:暂停播放
 */
- (void)pause {
    [self.player pause];
}


#pragma mark =================== KVO ================
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            if (self.beginBlock) {
                self.beginBlock();
            }
            CMTime duration = self.playerItem.duration;// 获取视频总长度
            NSLog(@"movie total duration:%f",CMTimeGetSeconds(duration));
            [self monitoringPlayback:self.playerItem];// 监听播放状态
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            NSLog(@"AVPlayerStatusFailed");
            if (self.errorBlock) {
                self.errorBlock();
            }
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
//                NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
//                CMTime duration = self.playerItem.duration;
//                CGFloat totalDuration = CMTimeGetSeconds(duration);
//                CGFloat cache = timeInterval / totalDuration;
    }
}

- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    __weak typeof(self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 24) queue:NULL usingBlock:^(CMTime time) {
        CGFloat currentSecond = CMTimeGetSeconds(time);// 计算当前在第几秒
        
        if (weakSelf.progressBlock) {
            weakSelf.progressBlock(currentSecond);
        }
    }];
}

/**
 *  @author 李诚, 15-06-24 16:06:38
 *
 *  TODO:音频播放正常结束
 *
 */
- (void)moviePlayDidEnd:(NSNotificationCenter *)notification{
    CMTime dragedCMTime = CMTimeMake(0, 1);
    [self.player seekToTime:dragedCMTime completionHandler:^(BOOL finish){
        
    }];
    if (self.completionBlock) {
        self.completionBlock();
    }
}

- (void)seekToTime:(CGFloat)duation {

    CMTime dragedCMTime = CMTimeMake(0, 1);
    [self.player seekToTime:dragedCMTime completionHandler:^(BOOL finish){
    }];
}

#pragma mark - Get Method
- (CGFloat)duration {
    CMTime duration = self.playerItem.duration;// 获取视频总长度
    CGFloat totalTime = CMTimeGetSeconds(duration);
    return totalTime;
}

@end
