//
//  CommonApiCall.h
//  customMarkerDemo
//
//  Created by agilepc-38 on 12/26/13.
//  Copyright (c) 2013 agilepc-38. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "UHClient.h"

@protocol CommonApiCallDelegate <NSObject>

-(void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo;
-(void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo;

@end
@interface CommonApiCall : NSObject{
    dispatch_queue_t apiQueue;

}
@property (nonatomic,strong)id  userInfo;
@property (nonatomic,strong) AFHTTPRequestOperation * operation;
@property (nonatomic,strong) UHClient * client;
@property (nonatomic,assign) id<CommonApiCallDelegate>delegate;
@property (nonatomic, strong) NSString *strRequestURL;
@property (nonatomic, strong) NSString *strRequestMethod;

- (id)initWithRequestMethod:(NSString *)strRequsetMethod andRequestURL:(NSString *)strRequestURL andDelegate:(id<CommonApiCallDelegate>)delegate;
- (void)startAPICallWithJSON:(NSData *)jsonData;
- (void)startAPICallWithJSON:(NSData *)jsonData withObject:(id)object;
- (void)uploadImageToUrl:(NSURL*)url withPostParameters:(NSDictionary *)dictParameters ofImage:(UIImage*)image inKey:(NSString*)key withName:(NSString*)name withobject:(id)object;


@end
