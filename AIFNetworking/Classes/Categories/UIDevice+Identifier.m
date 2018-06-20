//
//  UIDevice+Identifier.m
//  Pods
//
//  Created by wangtie on 16/11/18.
//
//

#import "UIDevice+Identifier.h"
#import "AIFUUIDGenerator.h"
@implementation UIDevice (Identifier)
- (NSString *)dsuuid{
    NSString *uuid = [[AIFUUIDGenerator shareInstance] UUID];
    if (uuid.length == 0) {
        uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [[AIFUUIDGenerator shareInstance] saveUUID:uuid];
    }
    return uuid;
}
@end
