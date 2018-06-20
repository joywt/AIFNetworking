//
//  AIFApiProxy.m
//  JKNetworking
//
//  Created by wangtie on 15/9/22.
//  Copyright © 2015年 wangtie. All rights reserved.
//

#import "AIFApiProxy.h"
#import "AFNetworking.h"
#import "AIFRequestGenerator.h"
#import "AIFLogger.h"

static NSString * const kAIFApiProxyDispatchItemKeyCallbackSuccess = @"kAIFApiProxyDispatchItemKeyCallbackSuccess";
static NSString * const kAIFApiProxyDispatchItemKeyCallbackFail = @"kAIFApiProxyDispatchItemKeyCallbackFail";


@interface AIFApiProxy ()

@property (nonatomic, strong) NSMutableDictionary *dispatchTable;
@property (nonatomic, strong) NSNumber *recordedRequestId;
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@end
@implementation AIFApiProxy

#pragma mark - life cycle
+ (instancetype)sharedInstance{
    static AIFApiProxy *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[AIFApiProxy alloc] init];
    });
    
    return shareInstance;
}

#pragma mark - public method
- (NSInteger)callGETWithParams:(id)params
             serviceIdentifier:(NSString *)servieIdentifier
                    moduleName:(NSString *)moduleName
                    methodName:(NSString *)methodName
                       success:(AIFCallAPI)success
                          fail:(AIFCallAPI)fail{
    NSURLRequest *request = [[AIFRequestGenerator shareInstance] generateGETRequestWithServiceIdentifier:servieIdentifier
                                                                                           requestParams:params
                                                                                              moduleName:moduleName
                                                                                              methodName:methodName];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return [requestId integerValue];
}
- (NSInteger)callPOSTWithParams:(id)params
              serviceIdentifier:(NSString *)servieIdentifier
                     moduleName:(NSString *)moduleName
                     methodName:(NSString *)methodName
                        success:(AIFCallAPI)success
                           fail:(AIFCallAPI)fail{
    NSURLRequest *request = [[AIFRequestGenerator shareInstance] generatePOSTRequestWithServiceIdentifier:servieIdentifier
                                                                                            requestParams:params
                                                                                               moduleName:moduleName
                                                                                               methodName:methodName];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return [requestId integerValue];
}

- (void)cancelRequestWithRequestID:(NSNumber *)requestID{
    NSURLSessionDataTask *requestOperation = self.dispatchTable[requestID];
    [requestOperation cancel];
    [self.dispatchTable removeObjectForKey:requestID];
}
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList{
    for (NSNumber *requestID in requestIDList) {
        [self cancelRequestWithRequestID:requestID];
    }
}


#pragma mark - private methods
/** 这个函数存在的意义在于，如果将来要把AFNetworking换掉，只要修改这个函数的实现即可。 */
- (NSNumber *)callApiWithRequest:(NSURLRequest *)request
                         success:(AIFCallAPI)success
                            fail:(AIFCallAPI)fail{
    __block NSURLSessionTask *dataTask = nil;
    dataTask = [self.sessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSNumber *requestID = @([dataTask taskIdentifier]);
        [self.dispatchTable removeObjectForKey:requestID];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSData *responseData =  responseObject;
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        if (error) {
            [AIFLogger logDebugInfoWithResponse:httpResponse resposeString:responseString request:request error:error];
            AIFURLResponse *aifResponse = [[AIFURLResponse alloc] initWithResponseString:responseString requestId:requestID request:request responseData:responseData error:error];
            fail?fail(aifResponse):nil;
        }else {
            [AIFLogger logDebugInfoWithResponse:response resposeString:responseString request:request error:NULL];
            AIFURLResponse *sresponse = [[AIFURLResponse alloc] initWithResponseString:responseString requestId:requestID request:request responseData:responseData error:error];
            success?success(sresponse):nil;
        }
    }];
    NSNumber *requestId = @([dataTask taskIdentifier]);
    self.dispatchTable[requestId] = dataTask;
    [dataTask resume];
    return requestId;
}

#pragma mark  - getter & setter 
- (AFHTTPSessionManager *)sessionManager{
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
//        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//        policy.allowInvalidCertificates = YES;
//        policy.validatesDomainName = NO;
        _sessionManager.securityPolicy.allowInvalidCertificates = YES;
        _sessionManager.securityPolicy.validatesDomainName = NO;
    }
    return _sessionManager;
}
//- (AFHTTPSessionManager *)sessionManager
//{
//    if (_sessionManager == nil) {
//        _sessionManager = [AFHTTPSessionManager manager];
//        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
//        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:[AFSecurityPolicy certificatesInBundle:[NSBundle mainBundle]]];
//        policy.allowInvalidCertificates = YES;
//        policy.validatesDomainName = NO;
//        _sessionManager.securityPolicy = policy;
//        
////        _sessionManager.securityPolicy.pinnedCertificates = [AFSecurityPolicy certificatesInBundle:[NSBundle mainBundle]];
//    }
//    return _sessionManager;
//}

- (NSMutableDictionary *)dispatchTable{
    if (!_dispatchTable) {
       _dispatchTable = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _dispatchTable;
}
@end
