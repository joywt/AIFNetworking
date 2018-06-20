//
//  NSString+AIFNetworkingMethods.m
//  bookclub
//
//  Created by tie wang on 2018/1/31.
//  Copyright © 2018年 tie wang. All rights reserved.
//

#import "NSString+AIFNetworkingMethods.h"
#include <CommonCrypto/CommonDigest.h>
@implementation NSString (AIFNetworkingMethods)
- (NSString *)AIF_md5
{
    NSData *inputData = [self dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char outputData[CC_MD5_DIGEST_LENGTH];
    CC_MD5([inputData bytes], (unsigned int)[inputData length], outputData);
    
    NSMutableString *hashStr = [NSMutableString string];
    int i = 0;
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [hashStr appendFormat:@"%02x", outputData[i]];
    }
    return hashStr;
}
@end
