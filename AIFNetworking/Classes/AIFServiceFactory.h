//
//  AIFServiceFactory.h
//  JKNetworking
//
//  Created by wangtie on 15/9/22.
//  Copyright © 2015年 wangtie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIFService.h"

@protocol AIFServiceFactoryDataSource <NSObject>

/*
 * key为service的Identifier
 * value为service的Class的字符串
 */

- (NSDictionary <NSString *, NSString *> *)servicesKindsOfServiceFactory;
@end

@interface AIFServiceFactory : NSObject

@property (nonatomic, weak) id <AIFServiceFactoryDataSource> dataSource;

+ (instancetype)shareInstance;
- (AIFService<AIFServiceProtocol> *)serviceWithIdentifier:(NSString *)identifier;


@end
