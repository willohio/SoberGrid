//
//  UpdateAppNotification.m
//  SoberGrid
//
//  Created by agilepc-159 on 4/18/15.
//  Copyright (c) 2015 William Santiago All rights reserved.
//

#import "UpdateAppNotification.h"


@interface UpdateNotificationWindow : UIWindow
@end
@implementation UpdateNotificationWindow

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *superResult = [super hitTest:point withEvent:event];
    if (superResult == self) {
        return nil;
    }
    
    return superResult;
}

@end
@interface UpdateAppNotification ()
@property(strong, nonatomic) UpdateNotificationWindow *notificationWindow;
@end


@implementation UpdateAppNotification
+ (UpdateAppNotification *)sharedInstance{
    static dispatch_once_t pred;
    static id shared = nil;
    dispatch_once(&pred, ^{
        shared = [(UpdateAppNotification *) [super alloc] initUniqueInstance];
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
    
    _notificationWindow = [[UpdateNotificationWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    // _filterWindow.backgroundColor=[UIColor lightGrayColor];
    CGRect filterFrame = _notificationWindow.bounds;
    viewUpdation=[[UIView alloc]initWithFrame:filterFrame];
    viewUpdation.userInteractionEnabled = YES;
    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:viewUpdation.bounds];
    imgView.image = [UIImage imageNamed:@"Login_BG_Screen"];
    [viewUpdation addSubview:imgView];
    
    
    UILabel *lblUpdateMessage = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height/2)];
    lblUpdateMessage.text = NSLocalizedString(@"Sober Grid has released new version. We request you to update Sober Grid  app version.", nil);
    lblUpdateMessage.font = SGBOLDFONT(20.0);
    lblUpdateMessage.textColor = [UIColor whiteColor];
    lblUpdateMessage.numberOfLines = 0;
    lblUpdateMessage.textAlignment = NSTextAlignmentCenter;
    lblUpdateMessage.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    [viewUpdation addSubview:lblUpdateMessage];
    
    
    UIView *viewGray = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height/2, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height/2)];
    viewGray.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    [viewUpdation addSubview:viewGray];
    
    UIButton *iTunesRedirectButton = [[UIButton alloc]initWithFrame:CGRectMake(0, viewGray.frame.size.height - 100, [UIScreen mainScreen].bounds.size.width - 100, 40)];
    iTunesRedirectButton.layer.cornerRadius = iTunesRedirectButton.frame.size.height/2;
    [iTunesRedirectButton setTitle:@"Update" forState:UIControlStateNormal];
    iTunesRedirectButton.backgroundColor = [UIColor redColor];
    [iTunesRedirectButton addTarget:self action:@selector(btnUpdate_Clicked) forControlEvents:UIControlEventTouchUpInside];
    [viewGray addSubview:iTunesRedirectButton];
    iTunesRedirectButton.center = CGPointMake(viewGray.frame.size.width/2, iTunesRedirectButton.center.y);
    
    //    _filterview.arrayValues = [_arrTypes mutableCopy];
    [_notificationWindow addSubview:viewUpdation];
    
}

- (void)show{
    dispatch_async(dispatch_get_main_queue(), ^{
        _notificationWindow.hidden = false;
    });
}
- (void)hide{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!_notificationWindow.hidden)
        {
            [UIView animateWithDuration:0.5 animations:^{
                CGRect filterFrame = viewUpdation.frame;
                filterFrame.origin.y = [UIScreen mainScreen].bounds.size.height;
                viewUpdation.frame = filterFrame;
                
            } completion:^(BOOL finished) {
                _notificationWindow.hidden = true;
            }];
        }
    });
    
}
- (void)btnUpdate_Clicked{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/sober-grid/id912632260?ls=1&mt=8"]];
}


@end

