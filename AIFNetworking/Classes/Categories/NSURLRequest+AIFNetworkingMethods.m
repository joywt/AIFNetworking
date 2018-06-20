//
//  NSURLRequest+AIFNetworkingMethods.m
//  JKNetworking
//
//  Created by wangtie on 15/9/22.
//  Copyright © 2015年 wangtie. All rights reserved.
//

#import "NSURLRequest+AIFNetworkingMethods.h"
#import <objc/runtime.h>
static void *AIFNetworkingRequestParams;
@implementation NSURLRequest (AIFNetworkingMethods)
- (void)setRequestParams:(id)requestParams{
    objc_setAssociatedObject(self, &AIFNetworkingRequestParams, requestParams, OBJC_ASSOCIATION_COPY);
}

- (id)requestParams{
    return objc_getAssociatedObject(self, &AIFNetworkingRequestParams);
}
@end
