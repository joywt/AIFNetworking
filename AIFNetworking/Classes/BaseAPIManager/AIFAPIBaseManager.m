//
//  AIFAPIBaseManager.m
//  AIFNetworking
//
//  Created by wangtie on 15/9/21.
//  Copyright © 2015年 wangtie. All rights reserved.
//

#import "AIFAPIBaseManager.h"
#import "AIFApiProxy.h"
#import "AIFNetworking.h"
#import "AIFCache.h"
#import "AIFLogger.h"
#import "AIFServiceFactory.h"
//#import "BCAIFSignatureGenerator.h"
//#import "BCAIFParamGenerator.h"
#define AIFCallAPI(REQUEST_METHOD, REQUEST_ID)                                          \
{                                                                                       \
    __weak typeof(self) weakSelf = self;                                                \
REQUEST_ID = [[AIFApiProxy sharedInstance] call##REQUEST_METHOD##WithParams:apiParams serviceIdentifier:self.child.serviceType moduleName:self.child.moduleName methodName:self.child.methodName success:^(AIFURLResponse *response) {          \
        __strong typeof(weakSelf) strongSelf = weakSelf;                                \
        [strongSelf successedOnCallingAPI:response];                                    \
    } fail:^(AIFURLResponse *response) {                                                \
        __strong typeof(weakSelf) strongSelf = weakSelf;                                \
        [strongSelf failedOnCallingAPI:response withErrorType:AIFAPIManagerErrorTypeDefault];  \
    }];                                                                                 \
    [self.requestIdList addObject:@(REQUEST_ID)];                                       \
}



@interface AIFAPIBaseManager ()
@property (nonatomic, strong, readwrite) id fetchedRawData;
@property (nonatomic, assign, readwrite) BOOL isLoading;
@property (nonatomic, assign) BOOL isNativeDataEmpty;

//@property (nonatomic, copy, readwrite) NSString *errorMessage;
@property (nonatomic, readwrite) AIFAPIManagerErrorType errorType;
@property (nonatomic, strong) NSMutableArray *requestIdList;
@property (nonatomic, strong) AIFCache *cache;
@property (nonatomic, copy) void(^successBlock)(AIFAPIBaseManager *manager);
@property (nonatomic, copy) void(^failedBlock)(AIFAPIBaseManager *manager);
@end

@implementation AIFAPIBaseManager

#pragma mark - life cycle

- (instancetype)init{
    self = [super init];
    if (self) {
        _delegate = nil;
        _validator = nil;
        _paramSource = nil;
        
        _fetchedRawData = nil;
        
        _errorMessage = nil;
        _errorType = AIFAPIManagerErrorTypeDefault;
        
        if ([self conformsToProtocol:@protocol(AIFAPIManager)]) {
            self.child = (id <AIFAPIManager>)self;
        }else {
            self.child = (id <AIFAPIManager>)self;
            NSException *exception = [[NSException alloc] initWithName:@"AIFAPIBaseManager提示" reason:[NSString stringWithFormat:@"%@没有遵循AIFAPIManager协议",self.child] userInfo:nil];
            @throw exception;
        }

    }
    return self;
}

- (void)dealloc{
    [self cancelAllRequests];
    self.requestIdList = nil;
    
    _successBlock = nil;
    _failedBlock = nil;
}



#pragma mark - public method
- (void)cancelRequestWithRequestId:(NSInteger)requestID
{
    [self removeRequestIdWithRequestID:requestID];
    [[AIFApiProxy sharedInstance] cancelRequestWithRequestID:@(requestID)];
}

- (void)cancelAllRequests{
    [[AIFApiProxy sharedInstance] cancelRequestWithRequestIDList:self.requestIdList];
    [self.requestIdList removeAllObjects];
}

- (id)fetchDataWithReformer:(id<AIFAPIManagerCallbackDataReformer>)reformer
{
    id resultData = nil;
    if ([reformer respondsToSelector:@selector(manager:reformData:)]) {
        resultData = [reformer manager:self reformData:self.fetchedRawData];
    }else{
        resultData = [self.fetchedRawData mutableCopy];
    }
    return resultData;
    
}

- (id)fetchFailedRequstMsg:(id<AIFAPIManagerCallbackDataReformer>)reformer
{
    id resultData = nil;
    if ([reformer respondsToSelector:@selector(manager:failedReform:)]) {
        resultData = [reformer manager:self failedReform:self.fetchedRawData];
    }else{
        resultData = [self.fetchedRawData mutableCopy];
    }
    return resultData;
}

#pragma mark - call api
- (NSInteger)loadData
{
    id params = [self.paramSource paramsForApi:self];
    NSAssert([params isKindOfClass:[NSDictionary class]] || [params isKindOfClass:[NSArray class]], @"Http 请求参数类型错误，请检查是否是 NSDictionary 或者 NSArray 类型");
    NSInteger requestId = [self loadDataWithParams:params];
    return requestId;
}
- (NSInteger)loadDataAPIDidSuccess:(void(^)(AIFAPIBaseManager * manager))successBlock didFailed:(void(^)(AIFAPIBaseManager *manager))failedBlock
{
    self.successBlock = successBlock;
    self.failedBlock = failedBlock;
    return [self loadData];
}
- (NSInteger)loadDataWithParams:(id)params
{
    NSInteger requestId = 0;
//    NSMutableDictionary *reformParams =[NSMutableDictionary dictionaryWithDictionary:[self reformParams:params]];
//    id <AIFCommonParamsGeneratorProtocol>commonParamsGenerator = [[AIFCommonParamsGeneratorFactory shareInstance] generatorWithIdentifier:self.child.commonParamsGeneratorType];
//    [reformParams addEntriesFromDictionary:[commonParamsGenerator commonParamsDictionary:self.child.serviceType]];
//    NSDictionary *apiParams = [reformParams copy];
    id apiParams = [self reformParams:params];
    if ([self shouldCallAPIWithParams:apiParams]) {
        if ([self.validator manager:self isCorrectWithParamsData:apiParams]) {
            if ([self.child shouldLoadFromNative]) {
                [self loadDataFromNative];
            }
            // 先检查一下是否有缓存
            if ([self shouldCache] && [self hasCacheWithParams:apiParams]) {
                return 0;
            }
            // 实际的网络请求
            if ([self isReachable]) {
                self.isLoading = YES;
                [self addLoadingView];
                switch (self.child.requestType)
                {
                    case AIFAPIManagerRequestTypeGet:
                        AIFCallAPI(GET, requestId);
                        break;
                    case AIFAPIManagerRequestTypePost:
                        AIFCallAPI(POST, requestId);
                        break;
                    default:
                        break;
                }
                
//                NSMutableDictionary *params = [apiParams mutableCopy];
//                params[kAIFAPIBaseManagerRequestID] = @(requestId);
                [self afterCallingAPIWithParams:params];
                
            }else{
                [self failedOnCallingAPI:nil withErrorType:AIFAPIManagerErrorTypeNoNetWork];
                return requestId;
            }
            
        }else{
            [self failedOnCallingAPI:nil withErrorType:AIFAPIManagerErrorTypeParamsError];
            return requestId;
        }
    }
    return requestId;
}


#pragma mark - API CallBack
- (void)successedOnCallingAPI:(AIFURLResponse *)response{
    self.isLoading = YES;
    self.response = response;
    
    if ([self.child shouldLoadFromNative]) {
        if (response.isCache == NO) {
            [[NSUserDefaults standardUserDefaults] setObject:response.responseData forKey:[self.child methodName]];
        }
    }
    if (response.content) {
        self.fetchedRawData = [response.content copy];
    }else {
        self.fetchedRawData = [response.responseData copy];
    }
    [self removeRequestIdWithRequestID:response.requestId];
    if ([self.validator manager:self isCorrectWithCallBackData:response.content]) {
        if ([self shouldCache] && !response.isCache) {
            [self.cache saveCacheWithData:response.responseData serviceIdentifier:self.child.serviceType methodName:self.child.methodName requestParams:response.requestParams];
        }
        if ([self beforePerformSuccessWithResponse:response]) {
            if ([self.child shouldLoadFromNative]) {
                if (response.isCache == YES) {
                    if (self.successBlock){
                        self.successBlock(self);
                    }
                    [self.delegate managerCallBackAPIDidSuccess:self];
                }
                if (self.isNativeDataEmpty) {
                    if (self.successBlock){
                        self.successBlock(self);
                    }
                    [self.delegate managerCallBackAPIDidSuccess:self];
                }
            } else {
                if (self.successBlock){
                    self.successBlock(self);
                }
                [self.delegate managerCallBackAPIDidSuccess:self];
            }
        }
        [self afterPerformSuccessWithResponse:response];
    }else{
        
        [self failedOnCallingAPI:response withErrorType:AIFAPIManagerErrorTypeNoContent];
    }
}

- (void)failedOnCallingAPI:(AIFURLResponse *)response withErrorType:(AIFAPIManagerErrorType)errorType
{
    NSString *serviceIdentifier = self.child.serviceType;
    AIFService *service = [[AIFServiceFactory shareInstance] serviceWithIdentifier:serviceIdentifier];
    
    self.isLoading = NO;
    self.response = response;
    BOOL needCallBack = YES;
    
    if ([service.child respondsToSelector:@selector(shouldCallBackByFailedOnCallingAPI:)]) {
        needCallBack = [service.child shouldCallBackByFailedOnCallingAPI:response];
    }
    
    // 由 service 决定是否结束回调
    if (!needCallBack) {
        return;
    }
    
    // 继续错误的处理
    if (response.error.code == -1001) { // 请求超时
        errorType = AIFAPIManagerErrorTypeTimeout;
    }else if (response.error.code == -1005){ // 网络连接中断
        errorType = AIFAPIManagerErrorTypeNoNetWork;
    }
    self.errorType = errorType;
    [self removeRequestIdWithRequestID:response.requestId];
    
    if (response.content) {
        self.fetchedRawData = [response.content copy];
    } else {
        self.fetchedRawData = [response.responseData copy];
    }
    if ([self beforePerformFailWithResponse:response]) {
        if (self.failedBlock) {
            self.failedBlock(self);
        }
        [self.delegate managerCallBackAPIDidFailed:self];
    }
    [self afterPerformFailWithResponse:response];
}
#pragma mark -  interceptor
/*
 拦截器的功能可以由子类通过继承实现，也可以由其它对象实现,两种做法可以共存
 当两种情况共存的时候，子类重载的方法一定要调用一下super
 然后它们的调用顺序是BaseManager会先调用子类重载的实现，再调用外部interceptor的实现
 
 notes:
 正常情况下，拦截器是通过代理的方式实现的，因此可以不需要以下这些代码
 但是为了将来拓展方便，如果在调用拦截器之前manager又希望自己能够先做一些事情，所以这些方法还是需要能够被继承重载的
 所有重载的方法，都要调用一下super,这样才能保证外部interceptor能够被调到
 这就是decorate pattern(装饰模式)
 */

- (BOOL)beforePerformSuccessWithResponse:(AIFURLResponse *)response
{
    BOOL result = YES;
    self.errorType = AIFAPIManagerErrorTypeSuccess;
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:beforePerformSuccessWithResponse:)]) {
       result = [self.interceptor manager:self beforePerformSuccessWithResponse:response];
    }
    return result;
}

- (void)afterPerformSuccessWithResponse:(AIFURLResponse *)response
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterPerformSuccessWithResponse:)]) {
        [self.interceptor manager:self afterPerformSuccessWithResponse:response];
    }
}

- (BOOL)beforePerformFailWithResponse:(AIFURLResponse *)response
{
    BOOL result = YES;
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:beforePerformFailWithResponse:)]) {
       result = [self.interceptor manager:self beforePerformFailWithResponse:response];
    }
    return result;
}

- (void)afterPerformFailWithResponse:(AIFURLResponse *)response
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterPerformFailWithResponse:)]) {
        [self.interceptor manager:self afterPerformFailWithResponse:response];
    }
}

- (void)afterCallingAPIWithParams:(id)params
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterCallingAPIWithParams:)]) {
        [self.interceptor manager:self afterCallingAPIWithParams:params];
    }
}
//只有返回YES才会继续调用API
- (BOOL)shouldCallAPIWithParams:(id)params
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:shouldCallAPIWithParams:)]) {
        return [self.interceptor manager:self shouldCallAPIWithParams:params];
    } else {
        return YES;
    }
}

#pragma mark - method for child

- (void)cleanData
{
    [self.cache clean];
    self.fetchedRawData = nil;
    self.errorType = AIFAPIManagerErrorTypeDefault;
    self.errorMessage  = nil;
}
//如果需要在调用API之前额外添加一些参数，比如pageNumber和pageSize之类的就在这里添加
//子类中覆盖这个函数的时候就不需要调用[super reformParams:params]了
- (id)reformParams:(id)params
{
    IMP childIMP = [self.child methodForSelector:@selector(reformParams:)];
    IMP selfIMP = [self methodForSelector:@selector(reformParams:)];
    
    if (childIMP == selfIMP) {
        return params;
    } else {
        // 如果child是继承得来的，那么这里就不会跑到，会直接跑子类中的IMP。
        // 如果child是另一个对象，就会跑到这里
        id result = nil;
        result = [self.child reformParams:params];
        if (result) {
            return result;
        } else {
            return params;
        }
    }
}

- (BOOL)shouldCache{
    return [[AIFNetworkingConfigurationManager sharedInstance] shouldCache];
}
#pragma mark - private method
- (void)removeRequestIdWithRequestID:(NSInteger)requestId
{
    NSNumber *requestIDToRemove = nil;
    for (NSNumber *storedRequestId in self.requestIdList) {
        if ([storedRequestId integerValue] == requestId) {
            requestIDToRemove = storedRequestId;
        }
    }
    if (requestIDToRemove) {
        [self.requestIdList removeObject:requestIDToRemove];
    }
}
- (BOOL)hasCacheWithParams:(id)params
{
    NSString *serviceIdentifier = self.child.serviceType;
    NSString *methodName = self.child.methodName;
    NSData *result = [self.cache fetchCachedDataWithServiceIdentifier:serviceIdentifier methodName:methodName requestParams:params];
    if (result == nil) {
        return NO;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof (weakSelf) strongSelf = weakSelf;
        AIFURLResponse *response = [[AIFURLResponse alloc] initWithData:result];
        response.requestParams = params;
        [AIFLogger logDebugInfoWithCachedResponse:response methodName:methodName serviceIdentifier:[[AIFServiceFactory shareInstance] serviceWithIdentifier:serviceIdentifier]];
        [strongSelf successedOnCallingAPI:response];
    });

    return YES;
}
- (void)loadDataFromNative
{
    NSString *methodName = self.child.methodName;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[[NSUserDefaults standardUserDefaults] dataForKey:methodName] options:0 error:NULL];
    
    if (result) {
        self.isNativeDataEmpty = NO;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            AIFURLResponse *response = [[AIFURLResponse alloc] initWithData:[NSJSONSerialization dataWithJSONObject:result options:0 error:NULL]];
            [strongSelf successedOnCallingAPI:response];
        });
    } else {
        self.isNativeDataEmpty = YES;
    }
}

- (void)addLoadingView{
    if (self.showLoadingView && [self.showLoadingView respondsToSelector:@selector(showLoadingView:)]) {
        [self.showLoadingView showLoadingView:self];
    }
}


#pragma mark  - getter & setter

- (BOOL)isReachable{
    BOOL isReachability = [AIFNetworkingConfigurationManager sharedInstance].isReachable;
    if (!isReachability) {
        self.errorType = AIFAPIManagerErrorTypeNoNetWork;
    }
    return isReachability;
}

- (AIFCache *)cache
{
    if (_cache == nil) {
        _cache = [AIFCache sharedInstance];
    }
    return _cache;
}

- (NSMutableArray *)requestIdList
{
    if (_requestIdList == nil) {
        _requestIdList = [[NSMutableArray alloc] init];
    }
    return _requestIdList;
}


- (BOOL)isLoading
{
    if (self.requestIdList.count == 0) {
        _isLoading = NO;
    }
    return _isLoading;
}

- (BOOL)shouldLoadFromNative
{
    return NO;
}
@end
