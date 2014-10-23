//
//  HRRequestCacheDelegate.h
//  HTTPRiot
//
//  Created by Stefan on 23.10.14.
//
//

#import <Foundation/Foundation.h>

@protocol HRRequestCacheDelegate <NSObject>
/**
 *  Get cached data.
 *  This call returns cached data for a given path and options.
 *
 *  @param path    The path of the REST call.
 *  @param options Options given by the caller
 *
 *  @return Returns the result object or nil if nothing was cached.
 */
- (id)resultForPath:(NSString*)path andOptions:(NSDictionary*)options;

/**
 *  Save data to cache.
 *  The cache implementation decides how to handle all the parameters or whether it ignores some of them.
 *
 *  @param result      The data returned from the server.
 *  @param aConnection The connection that was used. The data might be necessary if server-side cache information should 
 *                     be taken into consideration.
 *  @param aPath       The REST path.
 *  @param options     Options given by the caller.
 */
- (void)setResult:(id)result forConnection:(NSURLConnection*)aConnection path:(NSString*)aPath andOptions:(NSDictionary*)options;
@end
