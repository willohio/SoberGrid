//  ApiClass.m
//  Tfick
//  Created by agilepc97 on 7/13/13.
//  Copyright (c) 2013 Agile. All rights reserved.

#import "ApiClass.h"
#import "AppDelegate.h"
#import "NetworkListioner.h"
#import "UpdateAppNotification.h"

#define MAXPIXELS 30000
@implementation ApiClass
@synthesize delegate;

+ (ApiClass *)sharedClass
{
    static ApiClass *SharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[ApiClass alloc] init];
        
    });
    
    return SharedInstance;
}

// Common POST function for API

-(void)apiPostFunction:(NSURL *)Url withPostParameters:(NSDictionary*)dictParameter withRequestMethod:(NSString*)rMethod
{
        if (![[NetworkListioner listner] isInternetAvailable]) {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"Internet not available" forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError  *error = [NSError errorWithDomain:@"com.sobergrid.sobergrid" code:200 userInfo:details];
            [delegate failedData:error forUrl:Url withTag:0];
            return;
            
        }
        @try
        {
            ASIFormDataRequest *request =[ASIFormDataRequest requestWithURL:Url];
            [request setRequestMethod:@"POST"];
            //[request setDelegate:self];
            NSArray *arrKeys=[dictParameter allKeys];
            // Add all key - Value as post parameter
            for (NSString *str in arrKeys)
            {
                [request setPostValue:(id)[dictParameter objectForKey:str] forKey:str];
            }
            [request setRequestMethod:rMethod];
            request.delegate = self;
            [request setShouldContinueWhenAppEntersBackground:YES];
            [request setTimeOutSeconds:600.0f];
            [request setDidFinishSelector:@selector(returnApiData:)];
            [request setDidFailSelector:@selector(failedApiData:)];
            [request startAsynchronous];
         
            
        }
        @catch (NSException *exception)
        {
            @throw exception ;
        }

    
}
- (void)uploadImageToUrl:(NSURL*)url withPostParameters:(NSDictionary *)dictParameters ofImage:(UIImage*)image inKey:(NSString*)key withName:(NSString*)name withTag:(int)tag{
    apiQueue = dispatch_queue_create("callApi", 0);
    dispatch_async(apiQueue, ^{
        CGFloat compression = 0.9f;
        CGFloat maxCompression = 0.1f;
        int maxFileSize = 250*1024;
        
        NSData *imgData = UIImageJPEGRepresentation(image, compression);
        
        while ([imgData length] > maxFileSize && compression > maxCompression)
        {
            compression -= 0.1;
            imgData = UIImageJPEGRepresentation(image, compression);
        }
    
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        request.tag = tag;
        //[request addFile:app.cropedImage forKey:@"file"];
        //[request addData:_dataImage forKey:@"file"];
        [request setData:imgData withFileName:name andContentType:@"image/jpeg" forKey:key];
        NSArray *arrKeys=[dictParameters allKeys];
        // Add all key - Value as post parameter
        for (NSString *str in arrKeys)
        {
            [request setPostValue:(id)[dictParameters objectForKey:str] forKey:str];
        }
        //[request setDidFinishSelector:@selector(sendToPhotosFinished:)];
        [request setDelegate:self];
        [request setShouldContinueWhenAppEntersBackground:YES];

        [request setDidFinishSelector:@selector(returnApiData:)];
        [request setDidFailSelector:@selector(failedApiData:)];
        [request setTimeOutSeconds:600.0f];
        [request startAsynchronous];
    });
    
}
- (void)uploadVideoToUrl:(NSURL*)url withthumbImage:(UIImage*)image withPostParameters:(NSDictionary *)dictParameters videoAtPath:(NSString*)filePath inKey:(NSString*)key{
    apiQueue = dispatch_queue_create("callApi", 0);
    dispatch_async(apiQueue, ^{
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        //[request addFile:app.cropedImage forKey:@"file"];
        //[request addData:_dataImage forKey:@"file"];
        //[request setData:imgData withFileName:name andContentType:@"video/quicktime" forKey:key];
        [request setFile:filePath forKey:key];
        CGFloat compression = 0.9f;
        CGFloat maxCompression = 0.1f;
        int maxFileSize = 250*1024;
        
        NSData *imgData = UIImageJPEGRepresentation(image, compression);
        
        while ([imgData length] > maxFileSize && compression > maxCompression)
        {
            compression -= 0.1;
            imgData = UIImageJPEGRepresentation(image, compression);
        }
        [request setData:imgData withFileName:@"video_thumb.png" andContentType:@"image/jpeg" forKey:@"video_thumb"];
        // [request setPostBodyFilePath:filePath];
        NSArray *arrKeys=[dictParameters allKeys];
        // Add all key - Value as post parameter
        for (NSString *str in arrKeys)
        {
            [request setPostValue:(id)[dictParameters objectForKey:str] forKey:str];
        }
        //[request setDidFinishSelector:@selector(sendToPhotosFinished:)];
        [request setDelegate:self];
        [request setShouldContinueWhenAppEntersBackground:YES];
        
        [request setDidFinishSelector:@selector(returnApiData:)];
        [request setDidFailSelector:@selector(failedApiData:)];
        [request setTimeOutSeconds:600];
        [request startAsynchronous];
    });
    
}
- (void)uploadImageToUrl:(NSURL *)url withPostParameters:(NSDictionary *)dictParameters ofImage:(UIImage *)image withCompletionHandler:(ApiClassComletionHandler)completion withTag:(int)tag{
    
    callQueue = dispatch_queue_create("imageUpload", 0);

    dispatch_async(callQueue, ^(void){
        // do actual processing here
        _completionBlock = completion;
        NSData *imgData = UIImagePNGRepresentation(image);
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        request.tag = tag;
        //[request addFile:app.cropedImage forKey:@"file"];
        //[request addData:_dataImage forKey:@"file"];
        [request setData:imgData withFileName:@"chat_img.jpg" andContentType:@"image/jpeg" forKey:@"chat_img"];
        NSArray *arrKeys=[dictParameters allKeys];
        // Add all key - Value as post parameter
        for (NSString *str in arrKeys)
        {
            [request setPostValue:(id)[dictParameters objectForKey:str] forKey:str];
        }
        //[request setDidFinishSelector:@selector(sendToPhotosFinished:)];
        [request setDelegate:self];
        [request setShouldContinueWhenAppEntersBackground:YES];
        [request setDidStartSelector:@selector(requestDidStarted:)];
        [request setDidFinishSelector:@selector(returnApiData:)];
        [request setDidFailSelector:@selector(failedApiData:)];
        [request setTimeOutSeconds:600.0f];
        [request startAsynchronous];
        

    });
}

// Api function to upload Image -  if not needed then comment this function.

- (void)requestDidStarted:(ASIHTTPRequest*)requestor{
    NSLog(@"requestDidStarted");
}
-(void)returnApiData:(ASIHTTPRequest*)requestor
{
    @try
    {
      
        NSString *strResponse = [requestor responseString];

        //NSLog(@"Response String %@",strResponse);
        [delegate returnData:[strResponse JSONValue] forUrl:requestor.url withTag:(int)requestor.tag];
        NSDictionary *dictTemp = [strResponse JSONValue];
        [self checkApiVersionWithResponse:dictTemp];

       
        if (_completionBlock) {
            dispatch_async(callQueue, ^(void){
                _completionBlock ([strResponse JSONValue],nil,requestor.url.absoluteString);

            });
        }
        //callDelegate
        
    }
    @catch (NSException *exception)
    {
         @throw exception ;
    }
}

-(void)failedApiData:(ASIHTTPRequest*)requestor
{
    
    @try
    {
        if (_completionBlock) {
            dispatch_async(callQueue, ^(void){
                _completionBlock (nil,requestor.error.localizedDescription,requestor.url.absoluteString);
                
            });
            
        }
                if([delegate respondsToSelector:@selector(failedData:forUrl:withTag:)])
                {
                    // return back to
                    [delegate failedData:requestor.error forUrl:requestor.url withTag:(int)requestor.tag];
                }
        
    }
    @catch (NSException *exception)
    {
         @throw exception ;
    }
}
- (void)checkApiVersionWithResponse:(NSDictionary*)response{
    if (response[kKeyVersion]) {
        NSString *buildversionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *strUpdatedbuildVersion = response[kKeyVersion];
        if ([buildversionString compare:strUpdatedbuildVersion options:NSNumericSearch] == NSOrderedAscending) {
            [[UpdateAppNotification sharedInstance] show];
        }
    }
#ifndef DEBUG
    if (response[kKeyApiUrl]) {
        NSString *apiVersion =GET_VERSION;
        NSString *updatedApiversion = response[kKeyApiUrl];
        if (![apiVersion isEqualToString:updatedApiversion]) {
            SET_VERSION(updatedApiversion);
            SYNCHRONIZE_DEFAULTS;
        }
    }
#endif
}


@end
