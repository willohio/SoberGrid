//
//  NetworkListioner.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/7/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
@interface NetworkListioner : NSObject{
    Reachability*  reachability;
}
+ (NetworkListioner *)listner;
- (BOOL)isInternetAvailable;
@end
