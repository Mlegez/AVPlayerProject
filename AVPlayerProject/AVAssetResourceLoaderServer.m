//
//  AVAssetResourceLoaderServer.m
//  AVPlayerProject
//
//  Created by 杨泽 on 2017/5/26.
//  Copyright © 2017年 yangze. All rights reserved.
//

#import "AVAssetResourceLoaderServer.h"
#import "AVAssetResourceLoaderTask.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AVFileTool.h"


@interface AVAssetResourceLoaderServer ()<AVAssetResourceLoaderTaskDelegate>

@property (nonatomic, strong) NSMutableArray                        *pendingRequests;

@property (nonatomic, strong) AVAssetResourceLoaderTask             *task;

@property (nonatomic, strong) NSURL                             *urlString;

// 是否重复请求
@property (nonatomic, assign) BOOL                              isResetRequest;

@end

@implementation AVAssetResourceLoaderServer

- (instancetype)init {
    if (self = [super init]) {
        self.pendingRequests = @[].mutableCopy;
    }
    return self;
}

#pragma mark ================= AVAssetResourceLoaderDelegate ==============
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    self.urlString = loadingRequest.request.URL;
    [self.pendingRequests addObject:loadingRequest];
    [self dealWithLoadingRequest:loadingRequest];
    
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self.pendingRequests removeObject:loadingRequest];
}

//处理每一次的播放器数据请求
- (void)dealWithLoadingRequest:(AVAssetResourceLoadingRequest *) loadingRequest{
    
    NSURL *currentUrl = loadingRequest.request.URL;
    NSRange range = NSMakeRange((NSUInteger)loadingRequest.dataRequest.currentOffset, NSUIntegerMax);
    
    if (!self.task) {
        self.task = [[AVAssetResourceLoaderTask alloc] init];
        self.task.delegate = self;
        [self.task setUrl:currentUrl offset:0];
    } else {
        // 如果新的rang的起始位置比当前缓存的位置还大，则重新按照range请求数据
        //  task.offset : 上次请求下载时的偏移量初始长度
        // cacheLength : 已经下载的长度
        if (self.task.offset + self.task.cacheLength < range.location ||
            // 如果往回拖也重新请求
            range.location < self.task.offset) {
            self.isResetRequest = YES;
            [self.task setUrl:currentUrl offset:range.location];
        }else {
            [self processPendingRequests];
        }
    }
}

#pragma mark ============== AVAssetResourceLoaderTaskDelegate ============
// 正在下载数据
- (void)requestTask:(AVAssetResourceLoaderTask *)requesttask didReceiveData:(NSData *)data downloadOffset:(NSInteger)offset{
    NSLog(@"下载中");
    [self processPendingRequests];
}

// 下载完成
- (void)requestTask:(AVAssetResourceLoaderTask *)requestTask didCompleteWithError:(NSError *)error {
    if (error) {
        NSLog(@"下载失败");
    }else {
        if (!self.isResetRequest) {
            NSLog(@"下载完成");
            // 下载完成 且数据完整 移动资源文件到缓存目录
            [AVFileTool copyFileToLocalWithUrl:[AVFileTool getMutableHTTPUrl:self.urlString].absoluteString];
        }else {
            [AVFileTool deleteTempFilePathWithUrl:[AVFileTool getMutableHTTPUrl:self.urlString].absoluteString];
        }
    }
}

- (void)processPendingRequests{
    
    // 在判断当前下载完的数据长度中有没有要请求的数据, 如果有,就把这段数据取出来,并且把这段数据填充给请求, 然后关闭这个请求
    // 如果没有, 继续等待下载完成.
    NSMutableArray *requestsCompleted = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest *loadingRequest in self.pendingRequests) {
        
        // 遍历所有的请求, 为每个请求加上请求的数据长度和文件类型等信息.
        [self fillInContentInformation:loadingRequest.contentInformationRequest];
        BOOL didRespondCompletely = [self respondWithDataForRequest:loadingRequest.dataRequest];
        
        if (didRespondCompletely) {
            [requestsCompleted addObject:loadingRequest];
            [loadingRequest finishLoading];
        }
    }
    [self.pendingRequests removeObjectsInArray:[requestsCompleted copy]];
}

// 为每个请求加上数据长度和文件类型
- (void)fillInContentInformation:(AVAssetResourceLoadingContentInformationRequest * _Nonnull)contentInformationRequest{
    if (contentInformationRequest) {
        NSString *mimetype = @"video/mp4";
        CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef _Nonnull)(mimetype), NULL);
        // 要接受任意范围byte 需要设置为YES
        contentInformationRequest.byteRangeAccessSupported = YES;
        contentInformationRequest.contentType = CFBridgingRelease(contentType);
        // 视频总长度
        contentInformationRequest.contentLength = self.task.totalLength;
    }
}

// 判断此次请求的数据是否处理完全, 和填充数据
- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingDataRequest *)dataRequest{
    // 请求起始点
    long long startOffset = dataRequest.requestedOffset;
    // 当前请求点
    if (dataRequest.currentOffset != 0){
        startOffset = dataRequest.currentOffset;
    }
    startOffset = MAX(0, startOffset);
    
    // 播放器拖拽后大于已经缓存的数据
    if (startOffset > self.task.cacheLength)
        return NO;
    
    // 播放器拖拽后小于已经缓存的数据
    if (startOffset < self.task.offset)
        return NO;
    
    // 读取数据
    NSString *path = [AVFileTool getTempFilePath:[AVFileTool getMutableHTTPUrl:self.urlString].absoluteString];
    NSData *fileData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
    
    // 0 - 15  15 - 1300  1200 - 1500
    // 未读取的byte
    NSInteger unreadBytes = self.task.cacheLength - (NSInteger)startOffset;
    unreadBytes = MAX(0, unreadBytes);
    NSUInteger numberOfBytesToRespondWith = MIN((NSUInteger)dataRequest.requestedLength, unreadBytes);
    // 将此次请求到的数据回传给播放器播放
    [dataRequest respondWithData:[fileData subdataWithRange:NSMakeRange((NSUInteger)startOffset, (NSUInteger)numberOfBytesToRespondWith)]];
    
    long long endOffset = startOffset + dataRequest.requestedLength;
    
    // 此次请求的数据 已经全部下载完 返回YES
    BOOL didRespondFully = self.task.cacheLength >= endOffset;
    
    return didRespondFully;
}



@end
