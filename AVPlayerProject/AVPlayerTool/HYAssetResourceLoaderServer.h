//
//  AVAssetResourceLoaderServer.h
//  AVPlayerProject
//
//  Created by 杨泽 on 2017/5/26.
//  Copyright © 2017年 yangze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, AssetResourceType) {
    AssetResourceTypeAudio,
    AssetResourceTypeVideo
};

@class HYAssetResourceLoaderServer;
@protocol HYAssetResourceLoaderServerDelegate <NSObject>

// 缓存下载失败
- (void)assetResourceLoaderServer:(HYAssetResourceLoaderServer *)loader didCacheError:(NSError *)error;

@end

@interface HYAssetResourceLoaderServer : NSObject <AVAssetResourceLoaderDelegate>

@property (nonatomic, weak) id            <HYAssetResourceLoaderServerDelegate>delegate;

- (instancetype)initWithMinetype:(AssetResourceType)type;


@end
