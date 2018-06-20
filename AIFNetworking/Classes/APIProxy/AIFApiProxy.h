//
//  AIFApiProxy.h
//  JKNetworking
//
//  Created by wangtie on 15/9/22.
//  Copyright © 2015年 wangtie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIFURLResponse.h"

typedef void(^AIFCallAPI)(AIFURLResponse *response);
@interface AIFApiProxy : NSObject

+ (instancetype)sharedInstance;

- (NSInteger)callGETWithParams:(id)params
             serviceIdentifier:(NSString *)servieIdentifier
                    moduleName:(NSString *)moduleName
                    methodName:(NSString *)methodName
                       success:(AIFCallAPI)success
                          fail:(AIFCallAPI)fail;
- (NSInteger)callPOSTWithParams:(id)params
              serviceIdentifier:(NSString *)servieIdentifier
                     moduleName:(NSString *)moduleName
                     methodName:(NSString *)methodName
                        success:(AIFCallAPI)success
                           fail:(AIFCallAPI)fail;


- (NSNumber *)callApiWithRequest:(NSURLRequest *)request success:(AIFCallAPI)success fail:(AIFCallAPI)fail;
- (void)cancelRequestWithRequestID:(NSNumber *)requestID;
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;
@end
