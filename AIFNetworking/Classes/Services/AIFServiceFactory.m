//
//  AIFServiceFactory.m
//  JKNetworking
//
//  Created by wangtie on 15/9/22.
//  Copyright © 2015年 wangtie. All rights reserved.
//

#import "AIFServiceFactory.h"
#import "AIFService.h"

@interface AIFServiceFactory ()
@property (nonatomic, strong) NSMutableDictionary *serviceStorage;
@end

@implementation AIFServiceFactory

#pragma mark - life cycle
+ (instancetype)shareInstance{
    static AIFServiceFactory *serviceFactory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serviceFactory = [[AIFServiceFactory alloc] init];
    });
    return serviceFactory;
}
- (AIFService<AIFServiceProtocol> *)serviceWithIdentifier:(NSString *)identifier
{
    @synchronized(self.dataSource) {
        NSAssert(self.dataSource, @"必须提供dataSource绑定并实现servicesKindsOfServiceFactory方法，否则无法正常使用Service模块");
        
        if (self.serviceStorage[identifier] == nil) {
            self.serviceStorage[identifier] = [self newServiceWithIdentifier:identifier];
        }
        return self.serviceStorage[identifier];
    }
}
#pragma mark - private methods
- (AIFService<AIFServiceProtocol> *)newServiceWithIdentifier:(NSString *)identifier
{
    NSAssert([self.dataSource respondsToSelector:@selector(servicesKindsOfServiceFactory)], @"请实现AIFServiceFactoryDataSource的servicesKindsOfServiceFactory方法");
    if ([[self. dataSource servicesKindsOfServiceFactory] valueForKey:identifier]) {
        NSString *classStr = [[self.dataSource servicesKindsOfServiceFactory] valueForKey:identifier];
        id service = [[NSClassFromString(classStr) alloc] init];
        NSAssert(service, [NSString stringWithFormat:@"无法创建service，请检查servicesKindsOfServiceFactory提供的数据是否正确"],service);
        NSAssert([service conformsToProtocol:@protocol(AIFServiceProtocol)], @"你提供的Service没有遵循AIFServiceProtocol");
        return service;
    }else{
        NSAssert(NO, @"servicesKindsOfServiceFactory中无法找不到相匹配identifier");
    }
    return nil;
}


#pragma mark - getter & setter
- (NSMutableDictionary *)serviceStorage{
    if (!_serviceStorage) {
        _serviceStorage = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _serviceStorage;
}
@end
