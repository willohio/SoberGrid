//
//  UserChoicesView.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/26/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "UserChoicesView.h"
#import "User.h"
#include "MEAlertView.h"
#import "SoberGridIAPHelper.h"


@implementation UserChoicesView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)customizewithChoiceTitlesAndImagesDict:(NSDictionary*)dictChoices{
    
    NSArray *arrAllChoices = [dictChoices allKeys];
    
    CGFloat paddingX = 0;
    
    for (NSString *strChoice in arrAllChoices) {
        
        UIView *viewImageHolder=[[UIView alloc]initWithFrame:CGRectMake(paddingX, 0,[UIScreen mainScreen].bounds.size.width /arrAllChoices.count, self.frame.size.height)];
        UIImage *image = [UIImage imageNamed:[dictChoices objectForKey:strChoice]];;
        UIImage *imgSelected = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",[dictChoices objectForKey:strChoice]]];
        UIButton *btnChoice = [[UIButton alloc]initWithFrame:CGRectMake(0, 5, image.size.width, image.size.height)];
        [btnChoice setImage:image forState:UIControlStateNormal];
        [btnChoice setImage:imgSelected forState:UIControlStateSelected];
        
        [btnChoice addTarget:self action:@selector(btnChoice_Clicked:) forControlEvents:UIControlEventTouchUpInside];
        btnChoice.tag = (int)[arrAllChoices indexOfObject:strChoice];
        if ([strChoice isEqualToString:@"Burning Desire"]) {
            btnChoice.selected = [[User currentUser].strBurningDesire boolValue];
        }
        if ([strChoice isEqualToString:@"Need a Ride"]) {
            btnChoice.selected = [[User currentUser].strNeedRide boolValue];
        }
        if ([strChoice isEqualToString:@"Pro"]) {
            if ([[SoberGridIAPHelper sharedInstance] getTypeOfSubsciption] != kSGSubscriptionTypeNone) {
                btnChoice.selected = true;
            }
        }
        [viewImageHolder addSubview:btnChoice];
        btnChoice.center = CGPointMake(viewImageHolder.frame.size.width/2, btnChoice.center.y);
        
        CGRect lblframe =CGRectMake(0, btnChoice.frame.origin.y+btnChoice.frame.size.height + 2, CGRectGetWidth(viewImageHolder.bounds), (CGRectGetHeight(viewImageHolder.bounds)-(btnChoice.frame.origin.y+btnChoice.frame.size.height + 2)));
        UILabel *lblText=[[UILabel alloc]initWithFrame:lblframe];
        lblText.textAlignment=NSTextAlignmentCenter;
        lblText.font = SGREGULARFONT(14.0);
        lblText.text = strChoice;
        lblText.adjustsFontSizeToFitWidth = YES;
        lblText.textColor =[UIColor blackColor];
        [viewImageHolder addSubview:lblText];
        lblText = nil;
        paddingX = paddingX +viewImageHolder.frame.size.width;
        [self addSubview:viewImageHolder];
        
        viewImageHolder = nil;
    }
    
}
- (IBAction)btnChoice_Clicked:(UIButton*)sender{
    
    
    
    NSString *strMessage;
    
   
    if (sender.tag == 0) {
       
        if (sender.selected) {
            return;
        }
        
      //  strMessage =  @"Please be a support member to use this feature";
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MOVETOMEMBEROPTION object:nil];
        return;
        // Form Pro
    }
    if (sender.tag == 1) {
        // For burning desire
        strMessage = (sender.selected) ?  NSLocalizedString(@"Would you like to turn it off ?", nil):NSLocalizedString(@"Do you think you may use? Allow others to reach out to you. You will be highlighted in red on The Grid.", nil);
           }
    if (sender.tag == 2) {
        // For Need a ride
        strMessage = (sender.selected) ?  NSLocalizedString(@"Would you like to turn it off ?", nil):NSLocalizedString(@"Do you need a ride to a meeting? Your profile picture on The Grid will be outlined in blue.", nil);
        }
    MEAlertView *alert = [[MEAlertView alloc]initWithTitle:nil message:strMessage delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    alert.controller = sender;
    [alert show];
    
   // [_delegate didSelectedChoiceWithChoiceNumber:(int)sender.tag];
}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    if ([requestedURL rangeOfString:@"update_gridStatus"].location != NSNotFound) {
        
        NSDictionary *dictTemp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        dictTemp = [dictTemp dictionaryByReplacingNullsWithBlanks];
        if ([[dictTemp objectForKey:@"Type"] isEqualToString:@"OK"]) {
            [_delegate userStateChanged];
            
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[dictTemp objectForKey:@"Error"] delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
            [alert show];
        }
    }

}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    if ([requestedURL rangeOfString:@"update_gridStatus"].location != NSNotFound) {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:error delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
        [alert show];
    }

}
- (void)returnData:(id)data forUrl:(NSURL *)url withTag:(int)tag{
    if ([url.absoluteString rangeOfString:@"update_gridStatus"].location != NSNotFound) {
        
    NSDictionary *dictTemp = (NSDictionary*)data;
    if ([[dictTemp objectForKey:@"Type"] isEqualToString:@"OK"]) {
        [_delegate userStateChanged];
        
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[dictTemp objectForKey:@"Error"] delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
        [alert show];
    }
    }
    
}
- (void)failedData:(NSError *)error forUrl:(NSURL *)url withTag:(int)tag{
    if ([url.absoluteString rangeOfString:@"update_gridStatus"].location != NSNotFound) {

        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
        [alert show];
    }

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    MEAlertView *meAlert = (MEAlertView*)alertView;
    if(buttonIndex == 1){
        UIButton *sender = (UIButton*)meAlert.controller;
      //  ApiClass *apiclass=[ApiClass sharedClass];
      //  apiclass.delegate = self;
        if (sender.tag == 0) {
            
        }
        if(sender.tag == 1){
                    
            CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@update_gridStatus",baseUrl()] andDelegate:self];

            sender.selected = !sender.selected;
            [User currentUser].strBurningDesire = [NSString stringWithFormat:@"%d",sender.selected];
            [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": [User currentUser].struserId,@"type":@"burning",@"status":[NSNumber numberWithBool:sender.selected]} options:NSJSONWritingPrettyPrinted error:nil]];
           // [apiclass apiPostFunction:[NSURL URLWithString:[NSString stringWithFormat:@"%@update_gridStatus",baseUrl()]] withPostParameters:@{@"userid": [User currentUser].struserId,@"type":@"burning",@"status":[NSNumber numberWithBool:sender.selected]} withRequestMethod:POST];


        }
        if(sender.tag == 2){
            CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@update_gridStatus",baseUrl()] andDelegate:self];
            sender.selected = !sender.selected;
            [User currentUser].strNeedRide = [NSString stringWithFormat:@"%d",sender.selected];
            [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": [User currentUser].struserId,@"type":@"ride",@"status":[NSNumber numberWithBool:sender.selected]} options:NSJSONWritingPrettyPrinted error:nil]];
        //    [apiclass apiPostFunction:[NSURL URLWithString:[NSString stringWithFormat:@"%@update_gridStatus",baseUrl()]] withPostParameters:@{@"userid": [User currentUser].struserId,@"type":@"ride",@"status":[NSNumber numberWithBool:sender.selected]} withRequestMethod:POST];

        }
            
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
