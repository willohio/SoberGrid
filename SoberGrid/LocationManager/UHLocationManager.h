//
//  UHLocationManager.h
//  customMarkerDemo
//
//  Created by agilepc-38 on 12/23/13.
//  Copyright (c) 2013 agilepc-38. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString *const UHLocationManagerErrorDomain;

/**
 *  FTLocationManagerErrorDomain custom error codes
 */
typedef NS_ENUM(NSInteger, UHLocationManagerErrorCode) {
    UHLocationManagerErrorCodeUnknown = 0,
    UHLocationManagerErrorCodeTimedOut
};

@protocol UHLocationManagerDelegate

- (void)gotLatLong:(CLLocation*)location;
-(void)GPSlocation;

@end
typedef void (^UHLocationManagerCompletionHandler)(CLLocation *location, NSError *error, BOOL locationServicesDisabled);
@interface UHLocationManager : NSObject <CLLocationManagerDelegate>{
    UIBackgroundTaskIdentifier bgTask;
    NSTimer *checkLocationTimer;
    int checkLocationInterval;
    NSTimer *waitForLocationUpdatesTimer;
    BOOL        _timeoutInProgress;

}
@property (nonatomic,strong)CLLocationManager *locationManager;
@property (nonatomic, assign) NSTimeInterval errorTimeout;

@property (assign)BOOL withTimer;
@property (assign) id <UHLocationManagerDelegate>delegate;
@property (nonatomic,copy)UHLocationManagerCompletionHandler completionblock;
+ (UHLocationManager *)sharedManager;
-(void)getUserLocationWithInterval:(int ) interval ;


- (void)getLocationWithCompletionHandler:(UHLocationManagerCompletionHandler)completion;
- (void)tearDown;
@end
