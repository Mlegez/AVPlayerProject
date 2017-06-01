//
//  AVAssetResourceLoaderTask.m
//  AVPlayerProject
//
//  Created by 杨泽 on 2017/5/26.
//  Copyright © 2017年 yangze. All rights reserved.
//

#import "HYAssetResourceDownloadTask.h"
#import "AVFileTool.h"

@interface HYAssetResourceDownloadTask ()<NSURLSessionDelegate>


@property (nonatomic, strong) NSURLSession                  *session;
@property (nonatomic, strong) NSURLSessionTask              *sessionTask;

// 文件句柄
@property (nonatomic, strong) NSFileHandle                  *fileHandle;

@end


@implementation HYAssetResourceDownloadTask

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)setUrl:(NSURL *)url offset:(NSUInteger)offSet {
    self.url = url;
    self.offset = offSet;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[AVFileTool getMutableHTTPUrl:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0];
    
    // offset of request(第二次及其以上发起请求时需要修改range)
    if (offSet > 0 && self.totalLength > 0) {
        [request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld",(unsigned long)offSet, (unsigned long)self.totalLength - 1] forHTTPHeaderField:@"Range"];
    }
    
    // 取消上次请求
    [self.session invalidateAndCancel];
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.sessionTask = [self.session dataTaskWithRequest:request];
    // 开始下载
    [self.sessionTask resume];
}

// 接受到服务器响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    // 创建一个用于接收资源的空文件
    [AVFileTool creatTempFileWithUrl:_url];
    // 创建文件句柄
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:[AVFileTool getTempFilePath:_url]];
    completionHandler(NSURLSessionResponseAllow);
    NSLog(@"%lld",response.expectedContentLength);
    // 获取资源总大小
    self.totalLength = response.expectedContentLength;
}

// 接收到服务器返回数据的时候调用,会调用多次
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    if (data.length > 0) {
        _cacheLength += data.length;
        // 跳到文件末尾
        [self.fileHandle seekToEndOfFile];
        //  写入文件
        [self.fileHandle writeData:data];
        if ([self.delegate respondsToSelector:@selector(assetResourceDownLoadTask:didReceiveData:downloadOffset:)]) {
            [self.delegate assetResourceDownLoadTask:self didReceiveData:data downloadOffset:_cacheLength];
        }
    }
}

//请求完成会调用该方法，请求失败则error有值
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    NSLog(@"%lu",(unsigned long)self.cacheLength);
    //可以缓存则保存文件
    if ([self.delegate respondsToSelector:@selector(assetResourceDownLoadTask:didCompleteWithError:)]) {
        [self.delegate assetResourceDownLoadTask:self didCompleteWithError:nil];
    }
}

- (void)cancel {
    [self.sessionTask cancel];
}



@end
