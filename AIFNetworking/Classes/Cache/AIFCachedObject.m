//
//  AIFCachedObject.m
//  JKNetworking
//
//  Created by wangtie on 15/9/24.
//  Copyright © 2015年 wangtie. All rights reserved.
//

#import "AIFCachedObject.h"
#import "AIFNetworkingConfigurationManager.h"
@interface AIFCachedObject ()

@property (nonatomic, copy, readwrite) NSData *content;
@property (nonatomic, copy, readwrite) NSDate *lastUpdateTime;

@end

@implementation AIFCachedObject
#pragma mark - getters and setters
- (BOOL)isEmpty
{
    return self.content == nil;
}

- (BOOL)isOutdated
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastUpdateTime];
    return timeInterval > [[AIFNetworkingConfigurationManager sharedInstance] cacheOutdataTimeSeconds];
}

- (void)setContent:(NSData *)content
{
    _content = [content copy];
    self.lastUpdateTime = [NSDate dateWithTimeIntervalSinceNow:0];
}

#pragma mark - life cycle
- (instancetype)initWithContent:(NSData *)content
{
    self = [super init];
    if (self) {
        self.content = content;
    }
    return self;
}

#pragma mark - public method
- (void)updateContent:(NSData *)content
{
    self.content = content;
}

@end
