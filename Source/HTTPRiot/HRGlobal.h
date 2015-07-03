/**
 * @file HRGlobal.h Shared types and constants.
 */
#import <Foundation/Foundation.h>

/// Key for delgate
extern NSString * kHRClassAttributesDelegateKey;
/// Key for base url
extern NSString * kHRClassAttributesBaseURLKey;
/// Key for headers
extern NSString * kHRClassAttributesHeadersKey;
/// Key for basic auth
extern NSString * kHRClassAttributesBasicAuthKey;
/// Key for username
extern NSString * kHRClassAttributesUsernameKey;
/// Key for password
extern NSString * kHRClassAttributesPasswordKey;
/// Key for format
extern NSString * kHRClassAttributesFormatKey;
/// Key for default params
extern NSString * kHRClassAttributesDefaultParamsKey;
/// Key for params
extern NSString * kHRClassAttributesParamsKey;
/// Key for body
extern NSString * kHRClassAttributesBodyKey;
/// Key for parent view controller
extern NSString * kHRClassParentViewControllerKey;
/// Key for using body- and url-queries
extern NSString * kHRClassAttributesUsingBodyAndUrlKey;
/// Key for storing a cache implementation
extern NSString * kHRClassCacheImplementationKey;
/// Key for explicitly setting whether or not to cache a request (With no value set caching is enabled).
extern NSString * kHRClassAttributesEnableCacheKey;
 
/**
 * Supported REST methods.
 * @see HRRequestOperation
 */
typedef enum {
    /// Unknown [NOT USED]
    HRRequestMethodUnknown = -1,
    /// GET
    HRRequestMethodGet,
    /// POST
    HRRequestMethodPost,
    /// PUT
    HRRequestMethodPut,
    /// DELETE
    HRRequestMethodDelete
} HRRequestMethod;

/**
 Supported formats.
 @see HRRestModel#setFormat
 */
typedef enum {
    /// Unknown [NOT USED]
    HRDataFormatUnknown = -1,
    /// JSON Format
    HRDataFormatJSON,
    /// XML Format
    HRDataFormatXML
} HRDataFormat;

/// HTTPRiot's error domain
#define HTTPRiotErrorDomain @"com.labratrevenge.HTTPRiot.ErrorDomain"

#ifdef DEBUG
/// Logging Helper
#define HRLOG NSLog
#else
/// Logging Helper
#define HRLOG    
#endif