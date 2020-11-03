//
//  UHClient.h
//  customMarkerDemo
//
//  Created by agilepc-38 on 12/26/13.
//  Copyright (c) 2013 agilepc-38. All rights reserved.
//

#import "AFHTTPClient.h"

@interface UHClient : AFHTTPClient
+ (UHClient *)sharedClient;
- (id)initWithBaseURL:(NSURL *)url;
@end
