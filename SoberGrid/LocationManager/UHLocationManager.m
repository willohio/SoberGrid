//
//  UHLocationManager.m
//  customMarkerDemo
//
//  Created by agilepc-38 on 12/23/13.
//  Copyright (c) 2013 agilepc-38. All rights reserved.
//

int const kMaxBGTime = 170; //3 min - 10 seconds (as bg task is killed faster)
int const kTimeToGetLocations = 3;

NSString *const UHLocationManagerErrorDomain = @"UHLocationManagerErrorDomain";



#import "UHLocationManager.h"
@implementation UHLocationManager
- (id)init
{
    self = [super init];
    if (self)
    {
        _errorTimeout = 3.0;
       
       // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
       // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
    }
    return self;
}
+ (UHLocationManager *)sharedManager
{
    static UHLocationManager *SharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedInstance = [[UHLocationManager alloc] init];
    });
    
    return SharedInstance;
}

#pragma mark - Public interface

- (void)getLocationWithCompletionHandler:(UHLocationManagerCompletionHandler)completion
{
    NSAssert(completion, @"You have to provide non-NULL completion handler to [FTLocationManager updateLocationWithCompletionHandler:]");
    
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
            // iOS 8
        if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [_locationManager requestAlwaysAuthorization];
        }
    }

//    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    //   locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
//    _locationManager.distanceFilter = 5.0;
    
    _completionblock = completion;
    
    //  Start new errors counting
   // _errorsCount = 0;
    
    [_locationManager startUpdatingLocation];
}

-(void)updatelocationManager:(int)accuratekm
{
    
    [_locationManager stopUpdatingLocation];
    [self stopCheckLocationTimer];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 5.0;
        // iOS 8
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_locationManager requestAlwaysAuthorization];
    }
    [_locationManager startUpdatingLocation];
    [self startCheckLocationTimer];
    
    
}

//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
//    [manager stopUpdatingLocation];
//
//}
//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
//
//}
-(void)getUserLocationWithInterval:(int ) interval
{
    _withTimer = true;
    checkLocationInterval = (interval > kMaxBGTime)? kMaxBGTime : interval;
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    _locationManager.delegate=self;
    // iOS 8
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_locationManager requestAlwaysAuthorization];
    }
    [_locationManager startUpdatingLocation];
}

- (void)timerEvent:(NSTimer*)theTimer
{
    [self stopCheckLocationTimer];
    [_locationManager startUpdatingLocation];
    
    // in iOS 7 we need to stop background task with delay, otherwise location service won't start
    [self performSelector:@selector(stopBackgroundTask) withObject:nil afterDelay:1];
    
}


-(void)startCheckLocationTimer
{
    [self stopCheckLocationTimer];
    checkLocationTimer = [NSTimer scheduledTimerWithTimeInterval:checkLocationInterval target:self selector:@selector(timerEvent:) userInfo:NULL repeats:NO];
}

-(void)stopCheckLocationTimer
{
    if(checkLocationTimer){
        [checkLocationTimer invalidate];
        checkLocationTimer=nil;
    }
}

-(void)startBackgroundTask
{
    
    [self stopBackgroundTask];
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        //in case bg task is killed faster than expected, try to start Location Service
        [self timerEvent:checkLocationTimer];
    }];
}

-(void)stopBackgroundTask
{
    if(bgTask!=UIBackgroundTaskInvalid){
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }
}

-(void)stopWaitForLocationUpdatesTimer
{
    if(waitForLocationUpdatesTimer){
        [waitForLocationUpdatesTimer invalidate];
        waitForLocationUpdatesTimer =nil;
    }
}

-(void)startWaitForLocationUpdatesTimer
{
    [self stopWaitForLocationUpdatesTimer];
   // dispatch_async(dispatch_get_main_queue(), ^{
        waitForLocationUpdatesTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeToGetLocations target:self selector:@selector(waitForLoactions:) userInfo:NULL repeats:NO];
        // [waitForLocationUpdatesTimer fire];
        
   // });
}

- (void)waitForLoactions:(NSTimer*)theTimer
{
    [self stopWaitForLocationUpdatesTimer];
    
    if(([[UIApplication sharedApplication ]applicationState]==UIApplicationStateBackground ||
        [[UIApplication sharedApplication ]applicationState]==UIApplicationStateInactive) &&
       bgTask==UIBackgroundTaskInvalid){
        [self startBackgroundTask];
    }
    
    [self startCheckLocationTimer];
    [_locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [_locationManager stopUpdatingLocation];
    CLLocation  *newLocation=[locations lastObject];
    CLLocation  *currentLatLong = (CLLocationCoordinate2DIsValid(newLocation.coordinate) ? newLocation : nil);
    if (_completionblock) {
        _completionblock(currentLatLong,nil,NO);
        _completionblock = nil;
    }
    [self stopErrorTimeout];
    
    if (_withTimer) {
        if(checkLocationTimer){
            //sometimes it happens that location manager does not stop even after stopUpdationLocations
            return;
        }
        // [locationManager stopUpdatingLocation];
        [_delegate gotLatLong:currentLatLong];
        //TODO: save locations
        
        if(waitForLocationUpdatesTimer==nil){
            [self startWaitForLocationUpdatesTimer];
        }

    }
}
- (void)locationUpdatingFailedWithError:(NSError *)error locationServicesDisabled:(BOOL)locationServicesDisabled
{
    [self.locationManager stopUpdatingLocation];
    
    //  Cancel previous error timeouts
   [self stopErrorTimeout];
    
    //  Report error with block
    if (_completionblock) {
        _completionblock(nil, error, locationServicesDisabled);
    }
    
    //  Reset errors count
}




#pragma mark - UIAplicatin notifications

- (void)applicationDidEnterBackground:(NSNotification *) notification
{
    if([self isLocationServiceAvailable]==YES){
            [self startBackgroundTask];
    }
    
}

- (void)applicationDidBecomeActive:(NSNotification *) notification
{
    [_delegate GPSlocation];
if([self isLocationServiceAvailable]==NO){
        //TODO: handle error
    }
}

#pragma mark - Helpers

-(BOOL)isLocationServiceAvailable
{
    if([CLLocationManager locationServicesEnabled]==NO ||
       [CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied ||
       [CLLocationManager authorizationStatus]==kCLAuthorizationStatusRestricted){
        return NO;
    }else{
        return YES;
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if(error.domain == kCLErrorDomain && error.code == kCLErrorDenied)
    {
        [self locationUpdatingFailedWithError:error locationServicesDisabled:YES];
        return;
    }
    
    [self startErrorTimeout];
    [self locationUpdatingFailedWithError:error locationServicesDisabled:NO];
}
- (void)locationUpdatingTimedOut
{
    //  Create custom error
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to get current location.", @"FTLocationManager - Localized description of the error sent if the location request times out"),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Request on getting a current location timed out.", @"FTLocationManager - Localized failure reason of the error sent if the location request times out")
                               };
    
    NSError *error = [NSError errorWithDomain:UHLocationManagerErrorDomain code:UHLocationManagerErrorCodeTimedOut userInfo:userInfo];
    
    [self locationUpdatingFailedWithError:error locationServicesDisabled:NO];
}

- (void)startErrorTimeout
{
    //  Start timeout if the timeout is not already in progress
    if (!_timeoutInProgress)
    {
        [self performSelector:@selector(locationUpdatingTimedOut) withObject:nil afterDelay:_errorTimeout];
        _timeoutInProgress = YES;
    }
}

- (void)stopErrorTimeout
{
    //  Cancel previous "performSelector" requests
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locationUpdatingTimedOut) object:nil];
    _timeoutInProgress = NO;
}

- (void)tearDown{
    [self stopCheckLocationTimer];
    [self stopErrorTimeout];
    [self stopWaitForLocationUpdatesTimer];
    [self stopBackgroundTask];
    _locationManager.delegate = nil;
    _locationManager = nil;
    
}



@end
