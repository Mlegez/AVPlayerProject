//
//  AVPlayerView.h
//  PhoenixChinese
//
//  Created by captain on 2016/10/27.
//  Copyright © 2016年 李诚. All rights reserved.
//

/*
 *  播放器界面
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class AVPlayerView;

@protocol AVPlayerViewDelegate <NSObject>

@optional
//基本信息加载完毕
- (void)avPlayerView:(AVPlayerView *)playerView didFinishLoadingBaseInfo:(CGFloat)totalTime;

//加载失败
- (void)avPlayerViewLoadFailed:(AVPlayerView *)playerView;

//当前播放的时间
- (void)avPlayerView:(AVPlayerView *)playerView currentTime:(CGFloat)currentTime;

//播放结束
- (void)avPlayerViewDidPlayEnd:(AVPlayerView *)playerView;

// 正在缓冲
- (void)avPlayerView:(AVPlayerView *)playerView didloadingRange:(CGFloat)loadingDuration;

// 缓冲数据为空
- (void)avPlayerViewPlaybackBufferIsEmpty:(AVPlayerView *)playerView;

@end

@interface AVPlayerView : UIView

@property (nonatomic, weak) id<AVPlayerViewDelegate>    delegate;

@property (nonatomic, assign, readonly) CGFloat          totalDuration;

- (instancetype)initWithURL:(NSURL *)videoURL frame:(CGRect)frame;

- (instancetype)initWithURL:(NSURL *)videoURL frame:(CGRect)frame isCancache:(BOOL)isCancache;

/**
 * 开始播放
 */
- (void)play;

/**
 * 开始播放
 */
- (void)pause;

/**
 * 停止播放
 */
- (void)stopPlay;

/*
 *  设置播放进度
 */
- (void)setPlayerProgress:(CGFloat)progress;

/*
 *  设置音量
 */
- (void)setVediovolume:(CGFloat)volume;

// 设置全屏
- (void)fullScreen;

// 取消全屏
- (void)cancelFullScreenWithSuperView:(UIView *)superView;

@end
