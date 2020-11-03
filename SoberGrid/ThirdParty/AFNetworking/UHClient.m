//
//  UHClient.m
//  customMarkerDemo
//
//  Created by agilepc-38 on 12/26/13.
//  Copyright (c) 2013 agilepc-38. All rights reserved.
//

#import "UHClient.h"
#import "Global.h"
#import "AFNetworking.h"

@implementation UHClient
+ (UHClient *)sharedClient
{
    static dispatch_once_t pred;
    static UHClient *_sharedWeatherHTTPClient = nil;
    
    dispatch_once(&pred, ^{ _sharedWeatherHTTPClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:baseUrl()]]; });
    return _sharedWeatherHTTPClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        
    }
    return self;
}


@end
