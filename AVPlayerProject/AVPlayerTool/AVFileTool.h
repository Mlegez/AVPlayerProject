//
//  AVFileTool.h
//  AVPlayerProject
//
//  Created by 杨泽 on 2017/5/26.
//  Copyright © 2017年 yangze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AVFileTool : NSObject

// 返回文件缓存路径
+ (NSString *)getLocalVideoFilePath:(NSString *)url;

// 创建缓存文件
+ (void)creatLocalVideoFile:(NSString *)url ;

// 下载完成 将临时目录的文件拷贝到 本地缓存目录中
+ (void)copyFileToLocalWithUrl:(NSString *)url ;

// 删除本地缓存文件
+ (void)removeFilePath:(NSString *)url ;

// 创建临时文件
+ (void)creatTempFileWithUrl:(NSString *)url ;

// 返回临时文件路径
+ (NSString *)getTempFilePath:(NSString *)url ;

// 删除临时文件
+ (void)deleteTempFilePathWithUrl:(NSString *)url ;

// 返回正确格式URL
+ (NSURL *)getMutableHTTPUrl:(NSURL *)url ;

// 返回失败格式URL;
+ (NSURL *)getMutableCompent:(NSURL *)url ;

@end
