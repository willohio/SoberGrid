//
//  ApiClass.h
//  Tfick
//
//  Created by agilepc97 on 7/13/13.
//  Copyright (c) 2013 Agile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

typedef void (^ ApiClassComletionHandler)(id result,NSString* strError,NSString *url);
//Delegate
@protocol ApiclassDelegate <NSObject>

@optional
-(void)returnData:(id)data forUrl:(NSURL*)url withTag:(int)tag;
-(void)failedData:(NSError*)error forUrl:(NSURL*)url withTag:(int)tag;


@end


@interface ApiClass : NSObject<ASIHTTPRequestDelegate>
{
    //Delegate
    dispatch_queue_t callQueue;
    dispatch_queue_t apiQueue;
}
+ (ApiClass *)sharedClass;
// set delegate
@property (nonatomic, assign) id <ApiclassDelegate>delegate;

// API function - with Parameter
// URL
// arrayKey
// arrayValue
-(void)apiPostFunction:(NSURL *)Url withPostParameters:(NSDictionary*)dictParameter withRequestMethod:(NSString*)rMethod;

- (void)uploadImageToUrl:(NSURL*)url withPostParameters:(NSDictionary *)dictParameters ofImage:(UIImage*)image inKey:(NSString*)key withName:(NSString*)name withTag:(int)tag;



- (void)uploadVideoToUrl:(NSURL*)url withthumbImage:(UIImage*)image withPostParameters:(NSDictionary *)dictParameters videoAtPath:(NSString*)filePath inKey:(NSString*)key;

@property (nonatomic,copy)ApiClassComletionHandler completionBlock;

@end
