//
//  HRRestWeakReferenceContainer.h
//  HTTPRiot
//
//  Created by Stefan on 13.05.14.
//
//

#import <Foundation/Foundation.h>

@interface HRRestWeakReferenceContainer : NSObject
@property (nonatomic, weak) id<NSObject> weakReference;
@end
