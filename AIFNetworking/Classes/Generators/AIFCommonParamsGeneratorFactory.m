//
//  AIFCommonParamsGeneratorFactory.m
//  Modular
//
//  Created by tie wang on 2018/6/19.
//  Copyright © 2018年 tie wang. All rights reserved.
//

#import "AIFCommonParamsGeneratorFactory.h"

@interface AIFCommonParamsGeneratorFactory ()
@property (nonatomic, strong) NSMutableDictionary *generatorStorage; // 生成器存储器
@end

@implementation AIFCommonParamsGeneratorFactory


#pragma mark - life cycle
+ (instancetype)shareInstance
{
    static AIFCommonParamsGeneratorFactory *generatorFactory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        generatorFactory = [[AIFCommonParamsGeneratorFactory alloc] init];
    });
    return generatorFactory;
}

- (id <AIFCommonParamsGeneratorProtocol>)generatorWithIdentifier:(NSString *)identifier
{
    
    /**
     防止多线程资源共享互相覆盖的问题
     */
    @synchronized(self.dataSource) {
        NSAssert(self.dataSource, @"必须提供dataSource绑定并实现generatorsKindsOfCommonParamsFactory方法，否则无法正常使用CommonParams模块");
        if (self.generatorStorage[identifier] == nil) {
            self.generatorStorage[identifier] = [self newGeneratorWithIdentifier:identifier];
        }
        return self.generatorStorage[identifier];
    }
}


#pragma mark - private methods

- (id <AIFCommonParamsGeneratorProtocol>)newGeneratorWithIdentifier:(NSString *)identifier
{
    NSAssert([self.dataSource respondsToSelector:@selector(generatorsKindsOfCommonParamsFactory)], @"请实现generatorsKindsOfCommonParamsFactory方法");
    if ([[self.dataSource generatorsKindsOfCommonParamsFactory] objectForKey:identifier]) {
        NSString *classStr = [[self.dataSource generatorsKindsOfCommonParamsFactory] objectForKey:identifier];
        id generator = [[NSClassFromString(classStr) alloc] init];
        NSAssert(generator, [NSString stringWithFormat:@"无法创建generator，请检查generatorsKindsOfCommonParamsFactory提供的数据是否正确"],generator);
        NSAssert([generator conformsToProtocol:@protocol(AIFCommonParamsGeneratorProtocol)], @"你提供的Generator没有遵循AIFCommonParamsGeneratorProtocol");
        return generator;
    } else {
        NSAssert(NO, @"generatorsKindsOfCommonParamsFactory中无法找不到相匹配identifier");
    }
    return nil;
}


#pragma mark - getter & setter

- (NSMutableDictionary *)generatorStorage
{
    if (!_generatorStorage) {
        _generatorStorage = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _generatorStorage;
}

@end
