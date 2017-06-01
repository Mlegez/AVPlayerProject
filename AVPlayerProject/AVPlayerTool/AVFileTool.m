//
//  AVFileTool.m
//  AVPlayerProject
//
//  Created by 杨泽 on 2017/5/26.
//  Copyright © 2017年 yangze. All rights reserved.
//

#import "AVFileTool.h"
#import <CommonCrypto/CommonDigest.h>

#define DIRECTORY_NAME       @"videoFile"

@implementation AVFileTool

// 返回文件缓存路径
+ (NSString *)getLocalVideoFilePath:(NSURL *)url {
    
    NSString *suffix = [[[url lastPathComponent] pathExtension] lowercaseString];
    
    NSString *fileUrl = [self getFilePathStringWithUrl:url];
    NSString *path = [NSString stringWithFormat:@"%@/%@.%@",[self getCacheFilePath:DIRECTORY_NAME],fileUrl,suffix];
    return path;
}

// 创建缓存文件
+ (void)creatLocalVideoFile:(NSURL *)url {
    
    [self createDirectory:[NSString stringWithFormat:@"%@",[self getCacheFilePath:DIRECTORY_NAME]]];
    // 创建一个空的文件到沙盒中
    [[NSFileManager defaultManager] createFileAtPath:[self getLocalVideoFilePath:url] contents:nil attributes:nil];
}

// 下载完成 将临时目录的文件拷贝到 本地缓存目录中
+ (void)copyFileToLocalWithUrl:(NSURL *)url {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *fromFilePath = [self getTempFilePath:url];
    
    if (![fm fileExistsAtPath:fromFilePath]) {
        return;
    }
    
    NSError *error;
    NSString *toFile = [NSString stringWithFormat:@"%@",[self getCacheFilePath:DIRECTORY_NAME]];
    if (![fm fileExistsAtPath:toFile]) {
        [fm createDirectoryAtPath:toFile withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString * cacheFilePath = [self getLocalVideoFilePath:url];
    [fm copyItemAtPath:fromFilePath toPath:cacheFilePath error:&error];
    
    [fm removeItemAtPath:fromFilePath error:&error];
}

// 删除本地缓存文件
+ (void)removeFilePath:(NSURL *)url {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self getLocalVideoFilePath:url]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[self getLocalVideoFilePath:url] error:nil];
    }
}

#pragma mark - 临时文件
// 创建临时文件
+ (void)creatTempFileWithUrl:(NSURL *)url {
    
    NSString *tmpDir =  NSTemporaryDirectory();
    [self createDirectory:[NSString stringWithFormat:@"%@%@",tmpDir,DIRECTORY_NAME]];
    [[NSFileManager defaultManager] createFileAtPath:[self getTempFilePath:url] contents:nil attributes:nil];
}

// 返回临时文件路径
+ (NSString *)getTempFilePath:(NSURL *)url {
    
    NSString *suffix = [[url lastPathComponent] pathExtension];
    NSString *fileUrl = [self getFilePathStringWithUrl:url];
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *path = [NSString stringWithFormat:@"%@%@/%@.%@",tmpDir,DIRECTORY_NAME,fileUrl,suffix];
    return path;
}

// 删除临时文件
+ (void)deleteTempFilePathWithUrl:(NSURL *)url {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self getTempFilePath:url]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[self getTempFilePath:url] error:nil];
    }
}

// 返回正确格式URL
+ (NSURL *)getMutableHTTPUrl:(NSURL *)url {
    
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    urlComponents.scheme = @"http";
    return urlComponents.URL;
}

// 返回失败格式URL;
+ (NSURL *)getMutableCompent:(NSURL *)url {
    
    NSURLComponents *urlConponents = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    urlConponents.scheme = @"NSURLCompontents";
    return urlConponents.URL;
}



//将string转换成MD5格式数据,需引进库<CommonCrypto/CommonDigest.h>
+ (NSString *)stringToMD5Value:(NSString *)string {
    if (string==nil)
    {
        return nil;
    }
    const char *cStr = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}

/*
 * 函数作用: 根据文件名称获取缓存目录中文件路径
 * 函数参数: fileName  文件名称
 * 函数返回值: 返回Doc目录中文件路径
 */
+(NSString *)getCacheFilePath:(NSString *)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    return [NSString stringWithFormat:@"%@/%@",cachesDir,fileName];
}

/*
 * 函数作用:  创建本地文件夹
 * 函数参数:
 * 函数返回值: N/A
 */
+(BOOL)createDirectory:(NSString *)path{
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        return NO;
    }
    return [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

// 返回用于保存本地数据的URL字符
+ (NSString *)getFilePathStringWithUrl:(NSURL *)url {
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    urlComponents.scheme = @"http";
    return [self stringToMD5Value:urlComponents.URL.absoluteString];
}


@end
