//
//  NSDictionary+AIFNetworkingMethods.m
//  JKNetworking
//
//  Created by wangtie on 15/9/23.
//  Copyright © 2015年 wangtie. All rights reserved.
//

#import "NSDictionary+AIFNetworkingMethods.h"
#import "NSArray+AIFNetworkingMethod.h"
@implementation NSDictionary (AIFNetworkingMethods)
- (NSString *)AIF_urlParamsString{
    NSMutableString *string = [[NSMutableString alloc] init];
    NSMutableArray *array = [NSMutableArray array];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL * stop) {
        [array addObject:[NSString stringWithFormat:@"%@=%@",key,[self stringForValue:obj]]];
    }];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
        if (idx>0) {
            [string appendString:@"&"];
        }
        [string appendString:obj];
    }];
    return string;
}

- (NSString *)stringForValue:(id)value
{
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    } else if ([value respondsToSelector:@selector(description)]) {
        return [value description];
    }
    return nil;
}

/** 字符串前面是没有问号的，如果用于POST，那就不用加问号，如果用于GET，就要加个问号 */
- (NSString *)AIF_urlParamsStringSignature:(BOOL)isForSignature
{
    NSArray *sortedArray = [self AIF_transformedUrlParamsArraySignature:isForSignature];
    return [sortedArray AIF_paramsString];
}

/** 字典变json */
- (NSString *)AIF_jsonString
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:NULL];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

/** 转义参数 */
- (NSArray *)AIF_transformedUrlParamsArraySignature:(BOOL)isForSignature
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![obj isKindOfClass:[NSString class]]) {
            obj = [NSString stringWithFormat:@"%@", obj];
        }
        if (!isForSignature) {
            obj = [obj stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&;=+$,/?%#[]"]];
        }
        if ([obj length] > 0) {
            [result addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
        }
    }];
    NSArray *sortedResult = [result sortedArrayUsingSelector:@selector(compare:)];
    return sortedResult;
}

@end
