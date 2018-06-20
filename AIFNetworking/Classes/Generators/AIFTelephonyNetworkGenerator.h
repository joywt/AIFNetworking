//
//  AIFTelephonyNetworkGenerator.h
//  bookclub
//
//  Created by tie wang on 2018/1/31.
//  Copyright © 2018年 tie wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIFTelephonyNetworkGenerator : NSObject
+ (instancetype)shareInstance;
- (NSString *)deviceCarrier;
@end
