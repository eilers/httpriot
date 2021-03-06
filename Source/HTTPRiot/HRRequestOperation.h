//
//  HRRequestOperation.h
//  HTTPRiot
//
//  Created by Justin Palmer on 1/30/09.
//  Copyright 2009 LabratRevenge LLC.. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "HRGlobal.h"
#import "HRResponseDelegate.h"

#import "HRChallengeHandler.h"

/**
 * The object which all requests are routed through.  You shouldn't need to use 
 * this class directly, but instead use HRRestModel which wraps the method 
 * of this class neatly.
 */
@interface HRRequestOperation : NSOperation <HRChallengeHandlerDelegate> {
@private
    /// HRResponse Delegate
    NSObject        <HRResponseDelegate>*__weak _delegate;
    
    /// Connection object
    NSURLConnection *_connection;
    
    /// Data received from response
    NSMutableData   *_responseData;
    
    /// The path or URL to use in REST methods
    NSString        *_path;
    
    /// Contains all options used by the request.
    NSDictionary    *_options;
    
    /// How long before the request will timeout 
    NSTimeInterval  _timeout;
    
    /// The request method to use
    HRRequestMethod _requestMethod;
    
    /// The HRFormatter object
    id              _formatter;
    
    /// The object passed to all delegate methods
    id              _object;
    
    /// Determines whether the operation is finished
    BOOL _isFinished;
    
    /// Determines whether the operation is executing
    BOOL _isExecuting;
    
    /// Determines whether the connection is cancelled
    BOOL _isCancelled;
    
    /// The current challenge handler
    HRChallengeHandler *_currentChallenge;
    
    /// Parent view controller used as root for modal subviews
    UIViewController *__weak _parentViewController;
}

/// The HRResponseDelegate
/**
 * The HRResponseDelegate responsible for handling the success and failure of 
 * a request.
 */
@property (nonatomic, readonly, weak) NSObject <HRResponseDelegate>*delegate;
 
/// The lenght of time in seconds before the request times out.
/**
 * Sets the length of time in seconds before a request will timeout.
 * This defaults to <tt>30.0</tt>.
 */
@property (nonatomic, assign) NSTimeInterval timeout;

/// The REST method to use when performing a request
/**
 * This defaults to HRRequestMethodGet.  Valid options are ::HRRequestMethod.
 */
@property (nonatomic, assign) HRRequestMethod requestMethod;

/// The relative path or url string used in a request
/**
 If you provide a relative path here, you must set the baseURL option.
 If given a full url this will overide the baseURL option.
 */
@property (nonatomic, copy) NSString *path;

/// An NSDictionary containing all the options for a request.
/**
 This needs documented
 */
@property (nonatomic, strong) NSDictionary *options;

/// The formatter used to decode the response body.
/**
 Currently, only JSON is supported.
 */
@property (nonatomic, readonly, strong) id formatter;

/// This parent view controller
/**
 This view conttroller is used as root for modal subviews.
 */
@property (nonatomic, weak) UIViewController *parentViewController;

/**
 * Returns an HRRequestOperation
 */
+ (HRRequestOperation *)requestWithMethod:(HRRequestMethod)method path:(NSString*)urlPath options:(NSDictionary*)requestOptions object:(id)obj;
@end
