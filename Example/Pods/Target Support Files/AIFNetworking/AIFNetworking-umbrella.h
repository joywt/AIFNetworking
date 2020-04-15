#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AIFNetworking.h"
#import "AIFApiProxy.h"
#import "AIFAPIBaseManager.h"
#import "AIFCache.h"
#import "AIFCachedObject.h"
#import "NSArray+AIFNetworkingMethod.h"
#import "NSDictionary+AIFNetworkingMethods.h"
#import "NSMutableString+AIFNetworkingMethods.h"
#import "NSObject+AIFNetworkingMethods.h"
#import "NSString+AIFNetworkingMethods.h"
#import "NSURLRequest+AIFNetworkingMethods.h"
#import "UIDevice+Identifier.h"
#import "AIFNetworkingConfigurationManager.h"
#import "AIFRequestGenerator.h"
#import "AIFTelephonyNetworkGenerator.h"
#import "AIFUUIDGenerator.h"
#import "AIFLogger.h"
#import "AIFService.h"
#import "AIFServiceFactory.h"
#import "AIFURLResponse.h"

FOUNDATION_EXPORT double AIFNetworkingVersionNumber;
FOUNDATION_EXPORT const unsigned char AIFNetworkingVersionString[];

