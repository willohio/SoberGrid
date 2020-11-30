//
//  PopUpNotification.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/6/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "PopUpNotification.h"
@interface PopUpNotificationWindow : UIWindow
@end
@implementation PopUpNotificationWindow

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *superResult = [super hitTest:point withEvent:event];
    if (superResult == self) {
        return nil;
    }
    
    return superResult;
}

@end
@interface PopUpNotification ()
@property(strong, nonatomic) PopUpNotificationWindow *notificationWindow;
@end
@implementation PopUpNotification
+ (PopUpNotification *)sharedInstance{
    static dispatch_once_t pred;
    static id shared = nil;
    dispatch_once(&pred, ^{
        shared = [(PopUpNotification *) [super alloc] initUniqueInstance];
    });
    return shared;
}

#pragma mark -
- (instancetype)initUniqueInstance {
    self = [super init];
    
    if (self) {
        
        [self setupUi];
        
    }
    
    return self;
}


+ (instancetype)alloc {
    return nil;
}


- (instancetype)init {
    return nil;
}


+ (instancetype)new {
    return nil;
}
- (void)setupUi{
    
    _notificationWindow = [[PopUpNotificationWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    // _filterWindow.backgroundColor=[UIColor lightGrayColor];
    CGRect filterFrame = _notificationWindow.frame;
    filterFrame.origin.y = [UIScreen mainScreen].bounds.size.height;
    filterFrame.size.height = (isIPad)? 230 : 125;
    
    viewNotification=[[UIView alloc]initWithFrame:filterFrame];
    viewNotification.backgroundColor = [UIColor lightGrayColor] ;
    viewNotification.userInteractionEnabled = YES;
    
    UIImageView *imgConnectLost=[[UIImageView alloc]initWithImage:[UIImage imageNamed:(isIPad)?@"Connection_Lost~iPad":@"Connection_Lost"]];
    imgConnectLost.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, imgConnectLost.frame.size.height);
    [viewNotification addSubview:imgConnectLost];
    
    UITapGestureRecognizer * viewNotificationTapped=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
    viewNotificationTapped.numberOfTapsRequired=1.0;
    viewNotificationTapped.numberOfTouchesRequired=1.0;
    [viewNotification addGestureRecognizer:viewNotificationTapped];
    //    _filterview.arrayValues = [_arrTypes mutableCopy];
    [_notificationWindow addSubview:viewNotification];
   
}
- (void)show{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_notificationWindow.hidden){
            _notificationWindow.hidden=false;
            [UIView animateWithDuration:0.3 animations:^{
                CGRect filterFrame = viewNotification.frame;
                filterFrame.origin.y = filterFrame.origin.y-((isIPad)? 230 : 125);
                viewNotification.frame = filterFrame;
            } completion:^(BOOL finished) {
                
            }];
            _notificationWindow.hidden = false;
        }
        
    });
}
- (void)hide{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!_notificationWindow.hidden)
        {
            [UIView animateWithDuration:0.5 animations:^{
                CGRect filterFrame = viewNotification.frame;
                filterFrame.origin.y = [UIScreen mainScreen].bounds.size.height;
                viewNotification.frame = filterFrame;
                
            } completion:^(BOOL finished) {
                _notificationWindow.hidden = true;
            }];
        }
    });
    
}


@end
