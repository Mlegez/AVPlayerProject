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

@property (nonatomic, assign) BOOL                      cancelPlayAllAudio;

@property (nonatomic, assign, readonly) NSTimeInterval   currentTime;

@property (nonatomic, assign, readonly) CGFloat         duration;

@property (nonatomic, strong) void                      (^beginBlock)(void);
@property (nonatomic, strong) void                      (^errorBlock)(void);
@property (nonatomic, strong) void                      (^completionBlock)(void);
@property (nonatomic, strong) void                      (^progressBlock)(CGFloat currentTime);

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

- (void)seekToTime:(CGFloat)duation ;

@end
