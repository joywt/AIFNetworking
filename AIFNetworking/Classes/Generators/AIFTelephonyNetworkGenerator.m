//
//  AIFTelephonyNetworkGenerator.m
//  bookclub
//
//  Created by tie wang on 2018/1/31.
//  Copyright © 2018年 tie wang. All rights reserved.
//

#import "AIFTelephonyNetworkGenerator.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
@interface AIFTelephonyNetworkGenerator ()

@property (nonatomic, strong) CTTelephonyNetworkInfo *telephonyInfo;
@end

@implementation AIFTelephonyNetworkGenerator
#pragma mark - life cycle
+ (instancetype)shareInstance
{
    static AIFTelephonyNetworkGenerator *telephonyGenerator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        telephonyGenerator = [[AIFTelephonyNetworkGenerator alloc] init];
    });
    return telephonyGenerator;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
    }
    return self;
}
- (NSString *)deviceCarrier
{
    CTCarrier *carrier = [_telephonyInfo subscriberCellularProvider];
    NSString *carrierName = @"";
    if (carrier.isoCountryCode) {
        carrierName = [carrier carrierName];
    }
    return carrierName;
}
@end
