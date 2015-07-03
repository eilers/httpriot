//
//  HRRestModel.m
//  HTTPRiot
//
//  Created by Justin Palmer on 1/28/09.
//  Copyright 2009 LabratRevenge LLC.. All rights reserved.
//

#import "HRRestModel.h"
#import "HRRequestOperation.h"
#import "HRGlobal.h"
#import "HRRestWeakReferenceContainer.h"
#import "NSObject+InvocationUtils.h"

@interface HRRestModel (PrivateMethods)
+ (void)setAttributeValue:(id)attr forKey:(NSString *)key;
+ (NSMutableDictionary *)classAttributes;
+ (NSMutableDictionary *)mergedOptions:(NSDictionary *)options;
+ (NSOperation *)requestWithMethod:(HRRequestMethod)method path:(NSString *)path options:(NSDictionary *)options object:(id)obj;
@end

@implementation HRRestModel
static NSMutableDictionary *attributes;
+ (void)initialize {    
    if(!attributes)
        attributes = [[NSMutableDictionary alloc] init];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class Attributes

// Given that we want to allow classes to define default attributes we need to create 
// a classname-based dictionary store that maps a subclass name to a dictionary 
// containing its attributes.
+ (NSMutableDictionary *)classAttributes {
    NSString *className = NSStringFromClass([self class]);
    
    NSMutableDictionary *newDict;
    NSMutableDictionary *dict = [attributes objectForKey:className];
    
    if(dict) {
        return dict;
    } else {
        newDict = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:HRDataFormatJSON] forKey:@"format"];
        [attributes setObject:newDict forKey:className];
    }
    
    return newDict;
}

+ (NSObject *)delegate {
   return [[self classAttributes] objectForKey:kHRClassAttributesDelegateKey];
}

+ (void)setDelegate:(NSObject *)del {
    [self setAttributeValue:[NSValue valueWithNonretainedObject:del] forKey:kHRClassAttributesDelegateKey];
}

+ (NSURL *)baseURL {
   return [[self classAttributes] objectForKey:kHRClassAttributesBaseURLKey];
}

+ (void)setBaseURL:(NSURL *)uri {
    [self setAttributeValue:uri forKey:kHRClassAttributesBaseURLKey];
}

+ (NSDictionary *)headers {
    return [[self classAttributes] objectForKey:kHRClassAttributesHeadersKey];
}

+ (void)setHeaders:(NSDictionary *)hdrs {
    [self setAttributeValue:hdrs forKey:kHRClassAttributesHeadersKey];
}

+ (NSDictionary *)basicAuth {
    return [[self classAttributes] objectForKey:kHRClassAttributesBasicAuthKey];
}

+ (void)setBasicAuthWithUsername:(NSString *)username password:(NSString *)password {
    NSDictionary *authDict = [NSDictionary dictionaryWithObjectsAndKeys:username, kHRClassAttributesUsernameKey, password, kHRClassAttributesPasswordKey, nil];
    [self setAttributeValue:authDict forKey:kHRClassAttributesBasicAuthKey];
}

+ (void)setParentViewController:(UIViewController *)parentViewController
{
    HRRestWeakReferenceContainer* referenceContainer = [[HRRestWeakReferenceContainer alloc] init];
    referenceContainer.weakReference = parentViewController;
    [self setAttributeValue:referenceContainer forKey:kHRClassParentViewControllerKey];
}

+ (HRDataFormat)format {
    return [[[self classAttributes] objectForKey:kHRClassAttributesFormatKey] intValue];
}

+ (void)setFormat:(HRDataFormat)format {
    [[self classAttributes] setValue:[NSNumber numberWithInt:format] forKey:kHRClassAttributesFormatKey];
}

+ (void)setCache:(id<HRRequestCacheDelegate>)cache
{
    HRRestWeakReferenceContainer* referenceContainer = [[HRRestWeakReferenceContainer alloc] init];
    referenceContainer.weakReference = cache;
    [self setAttributeValue:referenceContainer forKey:kHRClassCacheImplementationKey];
}

+ (BOOL)useBodyAndUrl {
    return [[[self classAttributes] objectForKey:kHRClassAttributesUsingBodyAndUrlKey] boolValue];
}

+ (void)setUseBodyAndUrl:(BOOL)_useBodyAndUrl {
    [[self classAttributes] setValue:[NSNumber numberWithBool:_useBodyAndUrl] forKey:kHRClassAttributesUsingBodyAndUrlKey];
}

+ (NSDictionary *)defaultParams {
    return [[self classAttributes] objectForKey:kHRClassAttributesDefaultParamsKey];
}

+ (void)setDefaultParams:(NSDictionary *)params {
    [self setAttributeValue:params forKey:kHRClassAttributesDefaultParamsKey];
}

+ (void)setAttributeValue:(id)attr forKey:(NSString *)key {
    [[self classAttributes] setObject:attr forKey:key];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - REST Methods

+ (NSOperation *)getPath:(NSString *)path withOptions:(NSDictionary *)options object:(id)obj {
    return [self requestWithMethod:HRRequestMethodGet path:path options:options object:obj];               
}

+ (NSOperation *)postPath:(NSString *)path withOptions:(NSDictionary *)options object:(id)obj {
    return [self requestWithMethod:HRRequestMethodPost path:path options:options object:obj];                
}

+ (NSOperation *)putPath:(NSString *)path withOptions:(NSDictionary *)options object:(id)obj {
    return [self requestWithMethod:HRRequestMethodPut path:path options:options object:obj];              
}

+ (NSOperation *)deletePath:(NSString *)path withOptions:(NSDictionary *)options object:(id)obj {
    return [self requestWithMethod:HRRequestMethodDelete path:path options:options object:obj];        
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

+ (NSOperation *)requestWithMethod:(HRRequestMethod)method path:(NSString *)path options:(NSDictionary *)options object:(id)obj {
    NSMutableDictionary *opts = [self mergedOptions:options];
    
    // Per default caching is enabled.
    BOOL enableCache = YES;
    
    NSNumber* enableCacheNumber = [opts objectForKey: kHRClassAttributesEnableCacheKey];
    if ( [enableCacheNumber isKindOfClass: [NSNumber class]] )
    {
        enableCache = [enableCacheNumber boolValue];
    }

    // Check whether we have a cache integrated.
    HRRestWeakReferenceContainer* weakContainer = (HRRestWeakReferenceContainer*) [opts objectForKey:kHRClassCacheImplementationKey];
    NSAssert(weakContainer.weakReference != nil ? [weakContainer.weakReference conformsToProtocol:@protocol(HRRequestCacheDelegate)] : YES, @"Container contains object that does not confirms to protocol HRRequestCacheDelegate");
    if ( weakContainer
         && weakContainer.weakReference
         && enableCache)
    {
        id<HRRequestCacheDelegate> cache = (id<HRRequestCacheDelegate>)weakContainer.weakReference;
        // Ask cache whether we already have the data and return immediately if yes. But we will still make the network
        // call in order to update with the latest information if they were received.
        id results = [cache resultForPath:(NSString*)path andOptions:(NSDictionary*)options];
        
        if (results)
        {
            // Transmit cached data immediately..
            NSObject<HRResponseDelegate>* delegate = [[opts valueForKey:kHRClassAttributesDelegateKey] nonretainedObjectValue];
            if([delegate respondsToSelector:@selector(restConnection:didReturnResource:object:)]) {
                [delegate performSelectorOnMainThread:@selector(restConnection:didReturnResource:object:) withObjects:[NSNull null], results, obj, nil];
            }
        }
    }
    
    return [HRRequestOperation requestWithMethod:method path:path options:opts object:obj];
}

+ (NSMutableDictionary *)mergedOptions:(NSDictionary *)options {
    NSMutableDictionary *defaultParams = [NSMutableDictionary dictionaryWithDictionary:[self defaultParams]];
    [defaultParams addEntriesFromDictionary:[options valueForKey:kHRClassAttributesParamsKey]];
    
    NSMutableDictionary * newOptions = [options mutableCopy];
    
    [newOptions setObject:defaultParams forKey:kHRClassAttributesParamsKey];
    NSMutableDictionary *opts = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[self classAttributes]];
    [opts addEntriesFromDictionary:(NSDictionary *)newOptions];
    [opts removeObjectForKey:kHRClassAttributesDefaultParamsKey];
    
    id parentViewController = [[self classAttributes] objectForKey:kHRClassParentViewControllerKey];
    if ( parentViewController )
    { [opts setObject:parentViewController forKey:kHRClassParentViewControllerKey]; }
    
    return opts;
}
@end
