//
//  AIFUUIDGenerator.h
//  Pods
//
//  Created by wangtie on 16/11/18.
//
//

#import <Foundation/Foundation.h>

@interface AIFUUIDGenerator : NSObject

+ (instancetype)shareInstance;
- (NSString *)UUID;
- (void)saveUUID:(NSString *)uuid;
@end
