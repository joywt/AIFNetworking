//
//  AIFRequestGenerator.h
//  JKNetworking
//
//  Created by wangtie on 15/9/22.
//  Copyright © 2015年 wangtie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIFRequestGenerator : NSObject

+ (instancetype)shareInstance;

- (NSURLRequest *)generateGETRequestWithServiceIdentifier:(NSString *)serviceIdentifier
                                            requestParams:(id)requestParams
                                               moduleName:(NSString *)moduleName
                                               methodName:(NSString *)methodName;
- (NSURLRequest *)generatePOSTRequestWithServiceIdentifier:(NSString *)serviceIdentifier
                                             requestParams:(id)requestParams
                                                moduleName:(NSString *)moduleName
                                                methodName:(NSString *)methodName;

//Extension                                     requestWithMethod:(NSString *)method;

//- (NSURLRequest *)generateRequestWithServiceIdentifier:(NSString *)serviceIdentifier
//                                         requestParams:(NSDictionary *)requestParams
//                                            methodName:(NSString *)methodName

@end
