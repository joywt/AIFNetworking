//
//  NSMutableString+AIFNetworkingMethods.m
//  JKNetworking
//
//  Created by wangtie on 15/9/24.
//  Copyright © 2015年 wangtie. All rights reserved.
//

#import "NSMutableString+AIFNetworkingMethods.h"
#import "NSObject+AIFNetworkingMethods.h"
@implementation NSMutableString (AIFNetworkingMethods)
- (void)appendURLRequest:(NSURLRequest *)request
{
    [self appendFormat:@"\n\nHTTP URL:\n\t%@", request.URL];
    [self appendFormat:@"\n\nHTTP Header:\n%@", request.allHTTPHeaderFields ? request.allHTTPHeaderFields : @"\t\t\t\t\tN/A"];
    [self appendFormat:@"\n\nHTTP Body:\n\t%@", [[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] AIF_defaultValue:@"\t\t\t\tN/A"]];
}
@end
