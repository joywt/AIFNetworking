//
//  AIFUUIDGenerator.m
//  Pods
//
//  Created by wangtie on 16/11/18.
//
//

#import "AIFUUIDGenerator.h"
#import <UIKit/UIKit.h>
@implementation AIFUUIDGenerator


#define kAIFUUIDName @"kAIFUUIDName_dushu"
#define kAIFKeyChainServiceName @"kAIFKeyChainServiceName_dushu"
#define kAIFPasteboardTypeName @"kAIFPasteboardTypeName_dushu"
+ (instancetype)shareInstance{
    static AIFUUIDGenerator * shareInstance  = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[AIFUUIDGenerator alloc] init];
    });
    return shareInstance;
}
- (NSString *)UUID{
    NSData *uuidData = [self searchKeychainCopyMatching:kAIFUUIDName];
    NSString *uuid = nil;
    if (uuidData != nil) {
        NSString *temp = [[NSString alloc] initWithData:uuidData encoding:NSUTF8StringEncoding];
        uuid = [NSString stringWithFormat:@"%@", temp];
    }
    if (uuid.length == 0) {
        uuid = [self readPasteBoradforIdentifier:kAIFUUIDName];
    }
    return uuid;
}
- (void)saveUUID:(NSString *)uuid{
    BOOL saveOk = NO;
    NSData *uuidData = [self searchKeychainCopyMatching:kAIFUUIDName];
    if (uuidData == nil) {
        saveOk = [self createKeychainValue:uuid forIdentifier:kAIFUUIDName];
    }else{
        saveOk = [self updateKeychainValue:uuid forIdentifier:kAIFUUIDName];
    }
    if (!saveOk) {
        [self createPasteBoradValue:uuid forIdentifier:kAIFUUIDName];
    }
}

- (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier{
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
    [searchDictionary setObject:kAIFKeyChainServiceName forKey:(__bridge id)kSecAttrService];
    
    return searchDictionary;
}
- (NSData *)searchKeychainCopyMatching:(NSString *)identifier{
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    
    // Add search attributes
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    // Add search return types
    [searchDictionary setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
    CFDataRef result = nil;
    SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary,
                        (CFTypeRef *)&result);
    
    return (__bridge NSData *)result;

}

- (BOOL)createKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier
{
    NSMutableDictionary *dictionary = [self newSearchDictionary:identifier];
    
    NSData *passwordData = [value dataUsingEncoding:NSUTF8StringEncoding];
    [dictionary setObject:passwordData forKey:(__bridge id)kSecValueData];
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
    
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}

- (BOOL)updateKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier
{
    
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    NSData *passwordData = [value dataUsingEncoding:NSUTF8StringEncoding];
    [updateDictionary setObject:passwordData forKey:(__bridge id)kSecValueData];
    
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary,
                                    (__bridge CFDictionaryRef)updateDictionary);
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}

- (void)deleteKeychainValue:(NSString *)identifier
{
    
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    SecItemDelete((__bridge CFDictionaryRef)searchDictionary);
}

- (void)createPasteBoradValue:(NSString *)value forIdentifier:(NSString *)identifier
{
    UIPasteboard *pb = [UIPasteboard pasteboardWithName:kAIFKeyChainServiceName create:YES];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:value forKey:identifier];
    NSData *dictData = [NSKeyedArchiver archivedDataWithRootObject:dict];
    [pb setData:dictData forPasteboardType:kAIFPasteboardTypeName];
}

- (NSString *)readPasteBoradforIdentifier:(NSString *)identifier
{
    
    UIPasteboard *pb = [UIPasteboard pasteboardWithName:kAIFKeyChainServiceName create:YES];
    NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:[pb dataForPasteboardType:kAIFPasteboardTypeName]];
    return [dict objectForKey:identifier];
}

@end
