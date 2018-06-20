//
//  NSObject+AIFNetworkingMethods.m
//  JKNetworking
//
//  Created by wangtie on 15/9/22.
//  Copyright © 2015年 wangtie. All rights reserved.
//

#import "NSObject+AIFNetworkingMethods.h"

@implementation NSObject (AIFNetworkingMethods)
- (id)AIF_defaultValue:(id)defaultData
{
//    if (![defaultData isKindOfClass:[self class]]) {
//        return defaultData;
//    }
    
    if ([self AIF_isEmptyObject]) {
        return defaultData;
    }
    
    return self;
}

- (BOOL)AIF_isEmptyObject
{
    if ([self isEqual:[NSNull null]]) {
        return YES;
    }
    
    if ([self isKindOfClass:[NSString class]]) {
        if ([(NSString *)self length] == 0) {
            return YES;
        }
    }
    
    if ([self isKindOfClass:[NSArray class]]) {
        if ([(NSArray *)self count] == 0) {
            return YES;
        }
    }
    
    if ([self isKindOfClass:[NSDictionary class]]) {
        if ([(NSDictionary *)self count] == 0) {
            return YES;
        }
    }
    
    return NO;
}


@end
