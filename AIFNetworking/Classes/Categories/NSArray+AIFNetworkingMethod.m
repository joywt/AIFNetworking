//
//  NSArray+AIFNetworkingMethod.m
//  JKNetworking
//
//  Created by wangtie on 15/9/24.
//  Copyright © 2015年 wangtie. All rights reserved.
//

#import "NSArray+AIFNetworkingMethod.h"

@implementation NSArray (AIFNetworkingMethod)
- (NSString *)AIF_paramsString{
    NSMutableString *paramString = [[NSMutableString alloc] init];
    
    NSArray *sortedParams = [self sortedArrayUsingSelector:@selector(compare:)];
    [sortedParams enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([paramString length] == 0) {
            [paramString appendFormat:@"%@", obj];
        } else {
            [paramString appendFormat:@"&%@", obj];
        }
    }];
    
    return paramString;
}
- (NSString *)AIF_jsonString{
    NSError *error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        return @"";
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
