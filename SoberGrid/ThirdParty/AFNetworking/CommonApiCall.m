//
//  CommonApiCall.m
//  customMarkerDemo
//
//  Created by agilepc-38 on 12/26/13.
//  Copyright (c) 2013 agilepc-38. All rights reserved.
//

#import "CommonApiCall.h"
#import "Global.h"
#import "NetworkListioner.h"
#import "UpdateAppNotification.h"

@implementation CommonApiCall
- (id)initWithRequestMethod:(NSString *)strRequsetMethod andRequestURL:(NSString *)strRequestURL andDelegate:(id<CommonApiCallDelegate>)delegate
{
    self = [super init];
    if (self) {
        _strRequestMethod = strRequsetMethod;
        _strRequestURL = strRequestURL;
        _delegate = delegate;
        _client = [UHClient sharedClient];
    }
    return self;
}
- (void)startAPICallWithJSON:(NSData *)jsonData withObject:(id)object{
    if (![[NetworkListioner listner] isInternetAvailable]) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Internet not available" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError  *error = [NSError errorWithDomain:@"com.sobergrid.sobergrid" code:200 userInfo:details];
        [_delegate didFailWithError:error.localizedDescription withURL:_strRequestURL forObject:_userInfo];
        return;
        
    }
    self.userInfo = object;
    
    _operation = nil;
    
    NSDictionary *jsonDict = nil;
    //  [_client setParameterEncoding:(jsonData) ? AFJSONParameterEncoding : AFFormURLParameterEncoding];
    if (jsonData)
        jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    
    NSString * path = [_strRequestURL substringFromIndex:[_strRequestURL rangeOfString:baseUrl()].length];
    
    NSMutableURLRequest *request = [_client requestWithMethod:_strRequestMethod path:path parameters:jsonDict];
    
    [_client registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    [request setHTTPMethod:_strRequestMethod];
    
    if([_strRequestMethod isEqualToString:GET] && jsonData)
    {
        if(jsonData != nil)
        {
            NSError *error = nil;
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: jsonData options: NSJSONReadingMutableContainers error: &error];
            
            NSString *url = [_strRequestURL stringByAppendingString:@"?"];
            //NSArray *allKeys = [JSON allKeys];
            NSArray *allKeys = [[JSON allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            for (int i=0; i<[allKeys count]; i++) {
                NSString *key = [allKeys objectAtIndex:i];
                url = [url stringByAppendingFormat:@"%@=%@",key,[JSON objectForKey:key]];
                if(i != [allKeys count]-1){
                    url = [url stringByAppendingString:@"&"];
                    
                }
            }
            NSURL *URL = nil;
            id URLObject = url;
            if ([URLObject isKindOfClass:[NSString class]] && [URLObject length] > 0) {
                URLObject = [URLObject stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                URLObject = [URLObject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                URL = [NSURL URLWithString:URLObject];
            }
            _strRequestURL = URL.absoluteString;
        }
        
    }
  //  NSLog(@"API URL %@",_strRequestURL);
  //  NSLog(@"Jsondict %@",jsonDict);
    [request setURL:[NSURL URLWithString:_strRequestURL]];
    
    id<CommonApiCallDelegate> weakDelegate = _delegate;
    _operation = [_client HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dictTemp = [operation.responseString JSONValue];
       // NSLog(@"response Success %@",operation.responseString);
        
        [self checkApiVersionWithResponse:dictTemp];
        [weakDelegate didSucceedCallWithResponse:operation.responseData withURL:[[operation.request URL] absoluteString] forObject:_userInfo];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(operation.responseData != nil)
        {
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: operation.responseData options: NSJSONReadingMutableContainers error: &error];
            
            if (operation.responseString.length > 0) {
                NSDictionary *dict = [operation.responseString JSONValue];
               // NSLog(@"response failed %@",dict);
                if (dict) {
                    [weakDelegate didSucceedCallWithResponse:[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil] withURL:[[operation.request URL] absoluteString] forObject:_userInfo];
                }
                
            }
            else if([JSON objectForKey:@"error_type"])
                [weakDelegate didFailWithError:[JSON objectForKey:@"error_type"] withURL:[[operation.request URL] absoluteString] forObject:_userInfo];
            else
                [weakDelegate didFailWithError:[JSON objectForKey:@"errors"] withURL:[[operation.request URL] absoluteString] forObject:_userInfo];
        }
        else
        {
            [weakDelegate didFailWithError:[error localizedDescription] withURL:[[operation.request URL] absoluteString] forObject:_userInfo];
        }
        
    }];
    [_operation start];

}

- (void)checkApiVersionWithResponse:(NSDictionary*)response {
    if (response[kKeyVersion]) {
        NSString *buildversionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *strUpdatedbuildVersion = response[kKeyVersion];
        //NSLog(@"strUpdatedbuildVersion %@ \n buildversionString = %@",strUpdatedbuildVersion,buildversionString);
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
- (void)startAPICallWithJSON:(NSData *)jsonData
{
    [self startAPICallWithJSON:jsonData withObject:nil];
}
- (void)uploadImageToUrl:(NSURL*)url withPostParameters:(NSDictionary *)dictParameters ofImage:(UIImage*)image inKey:(NSString*)key withName:(NSString*)name withobject:(id)object{
    
    if (![[NetworkListioner listner] isInternetAvailable]) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Internet not available" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError  *error = [NSError errorWithDomain:@"com.sobergrid.sobergrid" code:200 userInfo:details];
        [_delegate didFailWithError:error.localizedDescription withURL:_strRequestURL forObject:_userInfo];
        return;
        
    }
    apiQueue = dispatch_queue_create("callApi", 0);
    dispatch_async(apiQueue, ^{
        
        self.userInfo = object;
        CGFloat compression = 0.9f;
        CGFloat maxCompression = 0.1f;
        int maxFileSize = 250*1024;
        
        NSData *imgData = UIImageJPEGRepresentation(image, compression);
        
        while ([imgData length] > maxFileSize && compression > maxCompression)
        {
            compression -= 0.1;
            imgData = UIImageJPEGRepresentation(image, compression);
        }
        
        NSString * path = [_strRequestURL substringFromIndex:[_strRequestURL rangeOfString:baseUrl()].length];
        NSMutableURLRequest *request = [_client requestWithMethod:_strRequestMethod path:path parameters:dictParameters];
        [request setHTTPMethod:_strRequestMethod];
        [request setURL:[NSURL URLWithString:_strRequestURL]];
       
        request = [_client multipartFormRequestWithMethod:_strRequestMethod path:_strRequestURL parameters:dictParameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                  [formData appendPartWithFileData:imgData name:key fileName:name mimeType:@"image/jpeg"];
        }];
        
        id<CommonApiCallDelegate> weakDelegate = _delegate;
        _operation = [_client HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *dictTemp = [operation.responseString JSONValue];
            [self checkApiVersionWithResponse:dictTemp];

            [weakDelegate didSucceedCallWithResponse:operation.responseData withURL:[[operation.request URL] absoluteString] forObject:_userInfo];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if(operation.responseData != nil)
            {
                NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: operation.responseData options: NSJSONReadingMutableContainers error: &error];
                
                if (operation.responseString.length > 0) {
                    NSDictionary *dict = [operation.responseString JSONValue];
                    [weakDelegate didSucceedCallWithResponse:[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil] withURL:[[operation.request URL] absoluteString] forObject:_userInfo];
                }
                else if([JSON objectForKey:@"error_type"])
                    [weakDelegate didFailWithError:[JSON objectForKey:@"error_type"] withURL:[[operation.request URL] absoluteString] forObject:_userInfo];
                else
                    [weakDelegate didFailWithError:[JSON objectForKey:@"errors"] withURL:[[operation.request URL] absoluteString] forObject:_userInfo];
            }
            else
            {
                [weakDelegate didFailWithError:[error localizedDescription] withURL:[[operation.request URL] absoluteString] forObject:_userInfo];
            }
            
        }];
        
        [_operation start];


        
    });

    
}






@end
