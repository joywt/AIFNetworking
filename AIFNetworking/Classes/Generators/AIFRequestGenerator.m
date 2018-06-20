//
//  AIFRequestGenerator.m
//  JKNetworking
//
//  Created by wangtie on 15/9/22.
//  Copyright © 2015年 wangtie. All rights reserved.
//

#import "AIFRequestGenerator.h"
#import "AFNetworking.h"
#import "AIFServiceFactory.h"
#import "AIFService.h"
#import "NSURLRequest+AIFNetworkingMethods.h"
#import "NSDictionary+AIFNetworkingMethods.h"
#import "AIFLogger.h"
#import <AFNetworking/AFNetworking.h>
#import "AIFNetworkingConfigurationManager.h"
@interface AIFRequestGenerator ()
@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;
@property (nonatomic, strong) AFJSONRequestSerializer *httpJsonRequestSerializer;
@end
@implementation AIFRequestGenerator
#pragma mark - life cycle
+ (instancetype)shareInstance{
    static AIFRequestGenerator *requestGenerator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requestGenerator = [[AIFRequestGenerator alloc] init];
    });
    return requestGenerator;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialRequestGenerator];
    }
    return self;
}

- (void)initialRequestGenerator
{
    
    _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
    _httpRequestSerializer.timeoutInterval = [[AIFNetworkingConfigurationManager sharedInstance] apiNetworkingTimeoutSeconds];
    _httpRequestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    
    _httpJsonRequestSerializer = [AFJSONRequestSerializer serializer];
    _httpJsonRequestSerializer.timeoutInterval = [[AIFNetworkingConfigurationManager sharedInstance] apiNetworkingTimeoutSeconds];
    _httpJsonRequestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
}
#pragma mark - public method


- (NSURLRequest *)generateGETRequestWithServiceIdentifier:(NSString *)serviceIdentifier
                                            requestParams:(id)requestParams
                                               moduleName:(NSString *)moduleName
                                               methodName:(NSString *)methodName{
    return [self generateRequestWithServiceIdentifier:serviceIdentifier requestParams:requestParams moduleName:moduleName methodName:methodName requestWithMethod:@"GET"];
}

- (NSURLRequest *)generatePOSTRequestWithServiceIdentifier:(NSString *)serviceIdentifier
                                             requestParams:(id)requestParams
                                                moduleName:(NSString *)moduleName
                                                methodName:(NSString *)methodName{
    
    return [self generateRequestWithServiceIdentifier:serviceIdentifier requestParams:requestParams moduleName:moduleName methodName:methodName requestWithMethod:@"POST"];
}


- (NSURLRequest *)generateRequestWithServiceIdentifier:(NSString *)serviceIdentifier requestParams:(id)requestParams moduleName:(NSString *)moduleName methodName:(NSString *)methodName requestWithMethod:(NSString *)method
{
    AIFService *service = [[AIFServiceFactory shareInstance] serviceWithIdentifier:serviceIdentifier];
    NSString *urlString = [service urlGeneratingRuleByModuleName:moduleName methodName:methodName];
    
    id totalRequestParams = [self totalRequestParamsByService:service requestParams:requestParams];
    
    NSMutableURLRequest *request = nil;
    
    if ([service.child respondsToSelector:@selector(extraHttpHeadParmasWithMethodName:)]) {
        NSDictionary *dict = [service.child extraHttpHeadParmasWithMethodName:methodName];
        if (dict) {
            if ([[dict objectForKey:@"Content-Type"] hasPrefix:@"application/json"]) {
                request = [self.httpJsonRequestSerializer requestWithMethod:method URLString:urlString parameters:totalRequestParams error:NULL];
            }else{
                request = [self.httpRequestSerializer requestWithMethod:method URLString:urlString parameters:totalRequestParams error:NULL];
            }
            [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [request setValue:obj forHTTPHeaderField:key];
            }];
        }
    }else{
        request = [self.httpRequestSerializer requestWithMethod:method URLString:urlString parameters:totalRequestParams error:NULL];
    }
    request.requestParams = totalRequestParams;
    request.timeoutInterval = [[AIFNetworkingConfigurationManager sharedInstance] apiNetworkingTimeoutSeconds];
    [AIFLogger logDebugInfoWithRequest:request apiName:methodName service:service requestParams:totalRequestParams httpMethod:method];
    return request;
}

- (id)totalRequestParamsByService:(AIFService *)service requestParams:(id)requestParams
{
    
    if ([service.child respondsToSelector:@selector(extraParmas)]){
        NSMutableDictionary *totalRequestParams = [NSMutableDictionary dictionaryWithDictionary:requestParams];
        if  ([service.child extraParmas]) {
            [[service.child extraParmas] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [totalRequestParams setObject:obj forKey:key];
            }];
        }
        return [totalRequestParams copy];
    }
    return requestParams;
}



@end

