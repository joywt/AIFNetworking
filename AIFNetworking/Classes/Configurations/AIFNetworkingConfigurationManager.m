//
//  AIFNetworkingConfigurationManager.m
//  bookclub
//
//  Created by tie wang on 2018/1/31.
//  Copyright © 2018年 tie wang. All rights reserved.
//

#import "AIFNetworkingConfigurationManager.h"
#import <AFNetworking/AFNetworking.h>
#import "AIFUUIDGenerator.h"
#import "AIFTelephonyNetworkGenerator.h"
#import "UIDevice+Identifier.h"
@interface AIFNetworkingConfigurationManager()

@property (nonatomic, copy, readwrite) NSString *userToken;

// 服务相关
@property (nonatomic, strong) NSArray *serverConfigBaseUrlSource;
@property (nonatomic, strong) NSArray *serverOfflineBaseUrlSource;
@property (nonatomic, strong) NSArray *serverOnlineBaseUrlSource;
@property (nonatomic, assign) NSInteger serverConfigBaseUrlIndex;
@property (nonatomic, assign) NSInteger serverOfflineBaseUrlIndex;
@property (nonatomic, assign) NSInteger serverOnlineBaseUrlIndex;

@end

@implementation AIFNetworkingConfigurationManager

+ (instancetype)sharedInstance
{
    static AIFNetworkingConfigurationManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AIFNetworkingConfigurationManager alloc] init];
        sharedInstance.shouldCache = YES;
//        sharedInstance.serviceIsOnline = NO;
        sharedInstance.apiNetworkingTimeoutSeconds = 100.0f;
        sharedInstance.cacheOutdataTimeSeconds = 300;
        sharedInstance.cacheCountLimit = 1000;
//        sharedInstance.shouldSetParamsInHTTPBodyButGET = NO;
        
        // 服务相关
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"AIFNetworkingConfiguration" ofType:@"plist"];
        NSDictionary *configPlist = [NSDictionary dictionaryWithContentsOfFile:filePath];
        sharedInstance.serverConfigBaseUrlSource = [configPlist objectForKey:@"serverConfigBaseUrls"];
        sharedInstance.serviceIsOnline = [[configPlist objectForKey:@"isOnline"] boolValue];
        sharedInstance.serverConfigBaseUrlIndex = 0;
        sharedInstance.serverOfflineBaseUrlIndex = 0;
        sharedInstance.serverOnlineBaseUrlIndex = 0;
        
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    });
    return sharedInstance;
}

- (BOOL)isReachable
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown){
        return YES;
    } else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}


- (NSString *)appId
{
    return @"1001";
}
- (NSString *)locale
{
    return @"zh_CN";
}
- (NSString *)format
{
    return @"Json";
}
- (NSString *)sercet
{
    return @"0";
}
- (NSString *)appVersion
{
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
}
- (NSString *)appDownloadChannel
{
    return @"AppStore";
}
- (NSString *)deviceId
{
    return [[UIDevice currentDevice] dsuuid];
}
- (NSString *)deviceBrand
{
    return @"Apple";
}
- (NSString *)deviceCarrier
{
    return [[AIFTelephonyNetworkGenerator shareInstance] deviceCarrier];
}
- (NSString *)osName
{
    return @"ios";
}
- (NSString *)osVersion
{
    return [NSString stringWithFormat:@"%@%@",[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]];
}
- (NSString *)deviceModel
{
    return [[UIDevice currentDevice] model];
}
- (NSString *)devicelmei
{
    return @"";
}

- (NSString *)userToken
{
    if(!_userToken){
        NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"userToken"];
        if (!token) {
            _userToken = @"";
        }else{
            _userToken = token;
        }
    }
    return _userToken;
}

- (void)updateUserToken:(NSString *)userToken
{
    if (userToken) {
        self.userToken = userToken;
        [[NSUserDefaults standardUserDefaults] setObject:userToken forKey:@"userToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)cleanUserInfo
{
    self.userToken = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



//// 服务相关

- (NSString *)serverConfigBaseUrl
{
    return self.serverConfigBaseUrlSource[self.serverConfigBaseUrlIndex];
}

- (NSString *)serverOnlineBaseUrl
{
    if (self.serverOnlineBaseUrlSource.count > self.serverOnlineBaseUrlIndex) {
        return self.serverOnlineBaseUrlSource[self.serverOnlineBaseUrlIndex];
    }
    return @"";
}

- (NSString *)serverOfflineBaseUrl
{
    if (self.serverOfflineBaseUrlSource.count > self.serverOfflineBaseUrlIndex) {
        return self.serverOfflineBaseUrlSource[self.serverOfflineBaseUrlIndex];
    }
    return @"";
}


#pragma mark - public method
- (void)switchServerBaseUrl
{
    if (self.serviceIsOnline) {
        self.serverOnlineBaseUrlIndex += 1;
        if (self.serverOnlineBaseUrlIndex == self.serverOnlineBaseUrlSource.count) {
            self.serverOnlineBaseUrlIndex = 0;
        }
    }else{
        self.serverOfflineBaseUrlIndex += 1;
        if (self.serverOfflineBaseUrlIndex == self.serverOfflineBaseUrlSource.count) {
            self.serverOfflineBaseUrlIndex = 0;
        }
    }
}
- (void)switchServerConfigBaseUrl
{
    self.serverConfigBaseUrlIndex += 1;
    if (self.serverConfigBaseUrlIndex == self.serverConfigBaseUrlSource.count) {
        self.serverConfigBaseUrlIndex = 0;
    }
}

@end
