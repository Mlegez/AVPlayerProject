//
//  AudioPlayer.h
//  MEIKU
//
//  Created by 李诚 on 15/6/24.
//  Copyright (c) 2015年 Mrrck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@class AudioPlayer;

@interface AudioPlayer : NSObject

// 总播放时长
@property (nonatomic, assign, readonly) CGFloat         duration;
// 开始播放
@property (nonatomic, copy) void                      (^beginBlock)(void);
// 播放错误
@property (nonatomic, copy) void                      (^errorBlock)(void);
// 播放完成
@property (nonatomic, copy) void                      (^completionBlock)(void);
// 播放进度
@property (nonatomic, copy) void                      (^progressBlock)(CGFloat currentTime);
// 缓冲。。。
@property (nonatomic, copy) void                      (^didLoadingRange)(CGFloat totalBuffer);
// 缓冲为空时回调
@property (nonatomic, copy) void                      (^loadingBufferIsEmpty)(BOOL bufferIsEmpty);


/**
 *  TODO:创建音频播放单例
 */
+ (AudioPlayer *)shareInstance;

/**
 *  @author 李诚, 15-06-24 16:06:17
 *
 *  TODO:释放单例
 */
+ (void)freeInstance;

- (void)playAudioWithFileURL:(NSURL *)fileURL;

/**
 *  @author 李诚, 15-07-03 11:07:43
 *
 *  TODO:播放
 */
- (void)play;

/**
 *  @author 李诚, 15-06-24 16:06:41
 *
 *  TODO:暂停播放
 */
- (void)pause;

// 设置播放进度
- (void)seekToTime:(CGFloat)duation ;

// 清除当前缓存文件
- (void)clearCurrentCachecFile ;

@end
