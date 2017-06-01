//
//  AVAssetResourceLoaderTask.h
//  AVPlayerProject
//
//  Created by 杨泽 on 2017/5/26.
//  Copyright © 2017年 yangze. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HYAssetResourceDownloadTask;
@protocol HYAssetResourceDownloadTaskDelegate <NSObject>

@optional
// 接受到数据
-(void)assetResourceDownLoadTask:(HYAssetResourceDownloadTask *)requesttask didReceiveData:(NSData *)data downloadOffset:(long long)offset;

// 下载完成 或 失败
- (void)assetResourceDownLoadTask:(HYAssetResourceDownloadTask *)requestTask didCompleteWithError:(NSError *)error ;

@end


@interface HYAssetResourceDownloadTask : NSObject

- (void)setUrl:(NSURL *)url offset:(NSUInteger)offSet ;
// 已经下载的数据长度
@property (nonatomic, assign) long long            cacheLength;

@property (nonatomic, strong) NSURL                 *url;
// 偏移量
@property (nonatomic, assign) NSUInteger            offset;
// 总长度
@property (nonatomic, assign) long long             totalLength;

@property (nonatomic, weak) id                  <HYAssetResourceDownloadTaskDelegate>delegate;

// 取消本次请求

- (void)cancel ;

@end
