//
//  UserChoicesView.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/26/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApiClass.h"
#import "CommonApiCall.h"

@protocol UserChoicesViewDelegate <NSObject>
@optional
- (void)userStateChanged;

@end

@interface UserChoicesView : UIView <ApiclassDelegate,UIAlertViewDelegate,CommonApiCallDelegate>
- (void)customizewithChoiceTitlesAndImagesDict:(NSDictionary*)dictChoices;
@property (nonatomic,assign)NSArray *arrChoiceImages;
@property (nonatomic,assign)NSArray *arrChoicesName;
@property (nonatomic,assign)id <UserChoicesViewDelegate>delegate;
@end
