//
//  HTTPRiotTestHelper.m
//  HTTPRiot
//
//  Created by Justin Palmer on 2/11/09.
//  Copyright 2009 Alternateidea. All rights reserved.
//

#import "HTTPRiotTestHelper.h"

@implementation HRTestPerson
+ (void)initialize { 
    [self setBaseURI:[NSURL URLWithString:HTTPRiotTestServer]];
    [self setBasicAuthWithUsername:@"user" password:@"pass"]; 
}
@end

@implementation HRTestPerson2 
+ (void)initialize 
{ 
    NSString *server = [HTTPRiotTestServer stringByAppendingString:@"/people"];
    [self setBaseURI:[NSURL URLWithString:server]]; 
}
@end

@implementation HRTestPerson3
+ (void)initialize 
{ 
    [self setBaseURI:[NSURL URLWithString:HTTPRiotTestServer]]; 
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"bar", @"foo", @"bing", @"bada", nil];
    [self setHeaders:params];
    [self setDefaultParams:params];
}
@end