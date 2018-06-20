//
//  AIFService.h
//  JKNetworking
//
//  Created by wangtie on 15/9/22.
//  Copyright © 2015年 wangtie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIFURLResponse.h"
// 所有AIFService的派生类都要符合这个protocal
@protocol AIFServiceProtocol <NSObject>

@property (nonatomic, readonly) BOOL isOnline;

@property (nonatomic, readonly) NSString *offlineApiBaseUrl;
@property (nonatomic, readonly) NSString *onlineApiBaseUrl;

@property (nonatomic, readonly) NSString *offlineApiVersion;
@property (nonatomic, readonly) NSString *onlineApiVersion;

//@property (nonatomic, readonly) NSString *onlinePublicKey;
//@property (nonatomic, readonly) NSString *offlinePublicKey;
//
//@property (nonatomic, readonly) NSString *onlinePrivateKey;
//@property (nonatomic, readonly) NSString *offlinePrivateKey;

@optional

// 为某些 Service 需要拼凑额外字段到 URL 处
- (NSDictionary *)extraParmas;

// 为某些 Service 需要拼凑额外的 HTTPToken，如 accessToken
- (NSDictionary *)extraHttpHeadParmasWithMethodName:(NSString *)method;

/*
 * 因为考虑到每家公司的拼凑逻辑都有或多或少不同，
 * 如有的公司为http://abc.com/v2/api/login或者http://v2.abc.com/api/login
 * 所以将默认的方式，有versioin时，则为http://abc.com/v2/api/login
 * 否则，则为http://abc.com/v2/api/login
 */
- (NSString *)urlGeneratingRuleByModuleName:(NSString *)moduleName methodName:(NSString *)method;

//提供拦截器集中处理 Service 错误问题，比如 token 失效要抛通知等
- (BOOL)shouldCallBackByFailedOnCallingAPI:(AIFURLResponse *)response;

@end

@interface AIFService : NSObject

//@property (nonatomic, strong, readonly) NSString *publicKey;
//@property (nonatomic, strong, readonly) NSString *privateKey;
@property (nonatomic, strong, readonly) NSString *apiBaseUrl;
@property (nonatomic, strong, readonly) NSString *apiVersion;

@property (nonatomic, weak, readonly) id<AIFServiceProtocol> child;

- (NSString *)urlGeneratingRuleByModuleName:(NSString *)moduleName methodName:(NSString *)method;
@end
