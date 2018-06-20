//
//  AIFService.m
//  JKNetworking
//
//  Created by wangtie on 15/9/22.
//  Copyright © 2015年 wangtie. All rights reserved.
//

#import "AIFService.h"

@interface AIFService()

@property (nonatomic, weak, readwrite) id<AIFServiceProtocol> child;

@end


@implementation AIFService

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(AIFServiceProtocol)]) {
            self.child = (id<AIFServiceProtocol>)self;
        }
    }
    return self;
}

- (NSString *)urlGeneratingRuleByModuleName:(NSString *)moduleName methodName:(NSString *)method
{
   
    return [self.child urlGeneratingRuleByModuleName:moduleName methodName:method];
}

#pragma mark - getters and setters
//- (NSString *)privateKey
//{
//    return self.child.isOnline ? self.child.onlinePrivateKey : self.child.offlinePrivateKey;
//}
//
//- (NSString *)publicKey
//{
//    return self.child.isOnline ? self.child.onlinePublicKey : self.child.offlinePublicKey;
//}

- (NSString *)apiBaseUrl
{
    return self.child.isOnline ? self.child.onlineApiBaseUrl : self.child.offlineApiBaseUrl;
}

- (NSString *)apiVersion
{
    return self.child.isOnline ? self.child.onlineApiVersion : self.child.offlineApiVersion;
}

@end
