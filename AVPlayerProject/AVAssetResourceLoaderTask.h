//
//  AVAssetResourceLoaderTask.h
//  AVPlayerProject
//
//  Created by 杨泽 on 2017/5/26.
//  Copyright © 2017年 yangze. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVAssetResourceLoaderTask;
@protocol AVAssetResourceLoaderTaskDelegate <NSObject>

@optional
// 接受到数据
-(void)requestTask:(AVAssetResourceLoaderTask *)requesttask didReceiveData:(NSData *)data downloadOffset:(NSInteger)offset;

// 下载完成 或 失败
- (void)requestTask:(AVAssetResourceLoaderTask *)requestTask didCompleteWithError:(NSError *)error ;

@end


@interface AVAssetResourceLoaderTask : NSObject

- (void)setUrl:(NSURL *)url offset:(NSUInteger)offSet ;
// 已经下载的数据长度
@property (nonatomic, assign) NSUInteger            cacheLength;

@property (nonatomic, strong) NSURL                 *url;
// 偏移量
@property (nonatomic, assign) NSUInteger            offset;
// 总长度
@property (nonatomic, assign) long long             totalLength;

@property (nonatomic, weak) id                  <AVAssetResourceLoaderTaskDelegate>delegate;


@end
