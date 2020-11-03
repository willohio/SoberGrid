//
//  XHLocationHelper.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-5-8.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHLocationHelper.h"

@interface XHLocationHelper () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, copy) DidGetGeolocationsCompledBlock didGetGeolocationsCompledBlock;

@end

@implementation XHLocationHelper

- (void)setup {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 5.0;
    
    
}

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)dealloc {
    self.locationManager.delegate = nil;
    self.locationManager = nil;
    self.didGetGeolocationsCompledBlock = nil;
}

- (void)getCurrentGeolocationsCompled:(DidGetGeolocationsCompledBlock)compled {
    isWithPlaceMark = false;
    self.didGetGeolocationsCompledBlock = compled;
        // iOS 8
        if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [_locationManager requestAlwaysAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    
}
- (void)getCurrentGeolocationsWithPlaceMarkCompled:(DidGetGeolocationsCompledBlock)compled{
    isWithPlaceMark = true;
    self.didGetGeolocationsCompledBlock = compled;
        // iOS 8
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
}

#pragma mark - CLLocationManager Delegate

// 代理方法实现
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = locations.lastObject;

    if (isWithPlaceMark) {
        CLGeocoder* geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:newLocation completionHandler:
         ^(NSArray* placemarks, NSError* error) {
             if (self.didGetGeolocationsCompledBlock) {
                 self.didGetGeolocationsCompledBlock(placemarks,newLocation);
               //  self.didGetGeolocationsCompledBlock = nil;
             }
         }];
    }else{
        if (self.didGetGeolocationsCompledBlock) {
            self.didGetGeolocationsCompledBlock(nil,newLocation);
          //  self.didGetGeolocationsCompledBlock = nil;
        }
    }
   
    [manager stopUpdatingLocation];


}
//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
//    CLGeocoder* geocoder = [[CLGeocoder alloc] init];
//    
//   }

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {

    if (self.didGetGeolocationsCompledBlock) {
        self.didGetGeolocationsCompledBlock(nil,nil);
       // self.didGetGeolocationsCompledBlock = nil;
    }

    [manager stopUpdatingLocation];
}

@end
