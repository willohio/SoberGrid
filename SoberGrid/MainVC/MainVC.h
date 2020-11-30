//
//  MainVC.h
//  SoberGrid
//
//  Created by William Santiago on 9/2/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "JASidePanelController.h"
#import "GridViewController.h"
#import "WelcomeViewController.h"

#import "LeftVC.h"
#import "User.h"

@interface MainVC : JASidePanelController
{
    SGNavigationController * LeftNC;
    SGNavigationController * centerNC;
    NSDictionary *notificationData;
}
@property(strong,nonatomic)LeftVC *leftVC;
- (void)moveToWelcomeScreen;
- (void)pushToScreenAccordingToPushDetail:(NSDictionary*)detail;
@end
