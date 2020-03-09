//
//  AIFNetworkingConfigurationManager.h
//  bookclub
//
//  Created by tie wang on 2018/1/31.
//  Copyright © 2018年 tie wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIFAPIBaseManager.h"
@interface AIFNetworkingConfigurationManager : NSObject


+ (instancetype)sharedInstance;

@property (nonatomic, assign, readonly) BOOL isReachable;
// AIF 相关
@property (nonatomic, assign) BOOL shouldCache;
@property (nonatomic, assign) BOOL serviceIsOnline;
@property (nonatomic, assign) NSTimeInterval apiNetworkingTimeoutSeconds;
@property (nonatomic, assign) NSTimeInterval cacheOutdataTimeSeconds;
@property (nonatomic, assign) NSInteger cacheCountLimit;


// service 配置相关
@property (nonatomic, copy, readonly) NSString *serverConfigBaseUrl;
@property (nonatomic, copy, readonly) NSString *serverOfflineBaseUrl;
@property (nonatomic, copy, readonly) NSString *serverOnlineBaseUrl;

// 公共参数相关
@property (nonatomic, copy, readonly) NSString *appId;
@property (nonatomic, copy, readonly) NSString *locale;
@property (nonatomic, copy, readonly) NSString *format;
@property (nonatomic, copy, readonly) NSString *sercet;
@property (nonatomic, copy, readonly) NSString *appVersion;
@property (nonatomic, copy, readonly) NSString *appDownloadChannel;
@property (nonatomic, copy, readonly) NSString *deviceId;
@property (nonatomic, copy, readonly) NSString *deviceBrand;
@property (nonatomic, copy, readonly) NSString *deviceCarrier;
@property (nonatomic, copy, readonly) NSString *osName;
@property (nonatomic, copy, readonly) NSString *osVersion;
@property (nonatomic, copy, readonly) NSString *deviceModel;
@property (nonatomic, copy, readonly) NSString *devicelmei;

// 用户信息相关

@property (nonatomic, copy, readonly) NSString *userToken;


//默认值为NO，当值为YES时，HTTP请求除了GET请求，其他的请求都会将参数放到HTTPBody中，如下所示
//request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestParams options:0 error:NULL];
//@property (nonatomic, assign) BOOL shouldSetParamsInHTTPBodyButGET;

- (void)updateUserToken:(NSString *)userToken;
- (void)cleanUserInfo;



@end
