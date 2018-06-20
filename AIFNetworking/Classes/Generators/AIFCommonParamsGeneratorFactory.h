//
//  AIFCommonParamsGeneratorFactory.h
//  Modular
//
//  Created by tie wang on 2018/6/19.
//  Copyright © 2018年 tie wang. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol AIFCommonParamsGeneratorProtocol <NSObject>

/**
 返回公共参数，根据不同的serviceType

 @param serviceType 服务类型
 @return 返回公共参数，根据不同的serviceType
 */
- (NSDictionary *)commonParamsDictionary:(NSString *)serviceType;

/**
 返回公共参数用于打印，根据不同的serviceType

 @param serviceType 服务类型
 @return 返回公共参数用于打印，根据不同的serviceType
 */
- (NSDictionary *)commonParamsDictionaryForLog:(NSString *)serviceType;

@end




@protocol AIFCommonParamsGeneratorFactoryDataSource <NSObject>


/**
 公共参数生成器类型

 key 为 generator 的 identifier
 value 为 generator 的 Class 字符串

 @return 返回公共参数生成器类型集合
 */
- (NSDictionary <NSString *, NSString *> *)generatorsKindsOfCommonParamsFactory;
@end
@interface AIFCommonParamsGeneratorFactory : NSObject

@property (nonatomic, weak) id <AIFCommonParamsGeneratorFactoryDataSource> dataSource;

+ (instancetype)shareInstance;
- (id <AIFCommonParamsGeneratorProtocol>)generatorWithIdentifier:(NSString *)identifier;
@end
