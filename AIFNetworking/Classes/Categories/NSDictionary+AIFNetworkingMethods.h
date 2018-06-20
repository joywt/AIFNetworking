//
//  NSDictionary+AIFNetworkingMethods.h
//  JKNetworking
//
//  Created by wangtie on 15/9/23.
//  Copyright © 2015年 wangtie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (AIFNetworkingMethods)

- (NSString *)AIF_urlParamsString;
- (NSString *)AIF_urlParamsStringSignature:(BOOL)isForSignature;
- (NSString *)AIF_jsonString;
- (NSArray *)AIF_transformedUrlParamsArraySignature:(BOOL)isForSignature;
@end
