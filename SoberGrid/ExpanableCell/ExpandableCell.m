//
//  ExpandableCell.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/9/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "ExpandableCell.h"
#import "SGButton.h"
#import "NSObject+ConvertingViewPixels.h"
#import "PSTAlertController.h"
#define  otherOptionTag 542
#define lblOptionTag 478
#define buttonTag 479
@implementation ExpandableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (void)customizeWithOptions:(NSMutableArray*)arrOptions withselectedOptions:(NSMutableArray*)selectedOptions forTitle:(NSString*)strTitle Expand:(BOOL)status withMultipleSupport:(BOOL)mStatus withOtherOption:(BOOL)oStatus {
    _arrOptions =arrOptions;
    _isOtherOptionSupported = oStatus;
    _isMultiSelectionSupported=mStatus;
    _options = arrOptions;
    if (selectedOptions) {
        _selectedOptions =[[NSMutableArray alloc]initWithArray:selectedOptions copyItems:YES];
        
    }else
        _selectedOptions = [[NSMutableArray alloc] init];
    UILabel *lblTitle=[[UILabel alloc]initWithFrame:CGRectMake(12, 5, self.frame.size.width-50, [self deviceSpesificValue:20])];
    lblTitle.text=NSLocalizedString(strTitle, nil);
    lblTitle.font = SGREGULARFONT(17.0);
    lblTitle.textColor=[UIColor blackColor];
    [self.contentView addSubview:lblTitle];
    NSString *strTextForSubtitle = @"";
    if (arrOptions) {
        if(selectedOptions.count > 0){
            NSMutableArray *arrTEmp=[[NSMutableArray alloc]init];
            for (NSString *strTemp in selectedOptions) {
                [arrTEmp addObject:NSLocalizedString(strTemp, nil)];
            }
            strTextForSubtitle = [arrTEmp componentsJoinedByString:@","];
            

        }
        
    }
    
    lblSubtitle = [[UILabel alloc]initWithFrame:CGRectMake(12, lblTitle.frame.origin.y+lblTitle.frame.size.height, lblTitle.frame.size.width, 15)];
    lblSubtitle.text=NSLocalizedString(strTextForSubtitle, nil);
    lblSubtitle.textColor=[UIColor blackColor];
    lblSubtitle.font = SGREGULARFONT(12.0);
    [self.contentView addSubview:lblSubtitle];
    
    
    viewDisclosure=[[UIView alloc]initWithFrame:CGRectMake(lblTitle.frame.origin.x+lblTitle.frame.size.width+5, 0, 40, 40)];
    viewDisclosure.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
    viewDisclosure.backgroundColor=[UIColor clearColor];
    
    UIImageView *imgDisclosure=[[UIImageView alloc]initWithFrame:CGRectMake(13, 13, 15, 15)];
    imgDisclosure.image=[UIImage imageNamed:@"disclosure_closed.png"];
    
    imgDisclosure.contentMode=UIViewContentModeScaleAspectFill;
    [viewDisclosure addSubview:imgDisclosure];
    [self.contentView addSubview:viewDisclosure];
    
    
    CGFloat yPoint = [self deviceSpesificValue:40];
    _arrExpandedOptionsViews = [[NSMutableArray alloc] init];
    for (int i = 0; i<arrOptions.count; i++) {
        UIView *viewTemp=[self createViewforOption:[arrOptions objectAtIndex:i] withYpoint:yPoint WithOther:NO];
        
        [self.contentView addSubview:viewTemp];
        [_arrExpandedOptionsViews addObject:viewTemp];
        yPoint = yPoint + [self deviceSpesificValue:30];
    }
    if (_isOtherOptionSupported) {
        NSString *strExtraOption;
        for (NSString *strOption in selectedOptions) {
            if (![[arrOptions valueForKey:@"lowercaseString"] containsObject:[strOption lowercaseString]] && ![[strOption lowercaseString] isEqualToString:[@"No Answer" lowercaseString]]) {
                strExtraOption =  strOption;
                break;
            }
        }
        if (strExtraOption.length == 0) {
            strExtraOption = @"Other";
        }
        UIView *viewTemp = [self createViewforOption:strExtraOption withYpoint:yPoint WithOther:YES];
        viewTemp.tag = otherOptionTag;
        [self.contentView addSubview:viewTemp];
        [_arrExpandedOptionsViews addObject:viewTemp];
    }
    
    
}
- (UIView*)createViewforOption:(NSString*)strOption withYpoint:(CGFloat)yPoint WithOther:(BOOL)oStatus{
    UIView *viewOption=[[UIView alloc]initWithFrame:CGRectMake(0, yPoint, [UIScreen mainScreen].bounds.size.width, [self deviceSpesificValue:30])];
    //viewOption.backgroundColor = [UIColor colorWithRed:48.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1];
    viewOption.userInteractionEnabled = YES;
    
    UILabel *lblLine=[[UILabel alloc]initWithFrame:CGRectMake(12, viewOption.frame.size.height-0.5, viewOption.frame.size.width-5, 0.5)];
    lblLine.backgroundColor = [UIColor lightGrayColor];
    [viewOption addSubview:lblLine];
    
    
    UILabel *lblOption=[[UILabel alloc]initWithFrame:CGRectMake(12, 5, self.frame.size.width-50, [self deviceSpesificValue:30])];
    lblOption.font=SGREGULARFONT(14.0);
    lblOption.textColor = [UIColor darkGrayColor];
    if (oStatus) {
        lblOption.text = [NSString stringWithFormat:@"%@(✏️)",NSLocalizedString(strOption, nil)];
    }else
    lblOption.text = NSLocalizedString(strOption, nil);
    [lblOption sizeToFit];
    lblOption.userInteractionEnabled = YES;
    lblOption.tag = lblOptionTag;
    [viewOption addSubview:lblOption];
 
    
    SGButton *btnOption=[[SGButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 35, 5, 25, [self deviceSpesificValue:25])];
    // [btnOption addTarget:self action:@selector(btnOption_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    [btnOption setImage:[UIImage imageNamed:@"checkmark.png"] forState:UIControlStateSelected];
    btnOption.userInfo = strOption;
    btnOption.tag = buttonTag;
    [viewOption addSubview:btnOption];
    if ([[_selectedOptions valueForKey:@"lowercaseString"] containsObject:[strOption lowercaseString]]) {
        btnOption.selected = true;
    }
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(btnOption_Clicked:)];
    
    tapGesture.numberOfTapsRequired=1.0;
    tapGesture.numberOfTouchesRequired=1.0;
    [viewOption addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *tapOnLable = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lblTapped:)];
    tapOnLable.numberOfTapsRequired=1.0;
    tapOnLable.numberOfTouchesRequired=1.0;
    [lblOption addGestureRecognizer:tapOnLable];

    return viewOption;
    
}
- (IBAction)lblTapped:(UITapGestureRecognizer*)sender{
    UIView *viewoption =(UILabel*) sender.view.superview;
    if (_isOtherOptionSupported) {
        if (viewoption.tag == otherOptionTag) {
            [self showEditor];
            return;
        }
    }
}
- (IBAction)btnOption_Clicked:(UITapGestureRecognizer*)sender{
    UIView *viewoption = sender.view;
    for (UIView *view in [viewoption subviews]) {
       
        if ([view isKindOfClass:[SGButton class]]) {
            SGButton *tempButton=(SGButton*)view;
            NSString *strOption=(NSString*)tempButton.userInfo;
            
            if (_isOtherOptionSupported) {
                if (viewoption.tag == otherOptionTag) {
                    if ([tempButton.userInfo isEqualToString:@"Other"]) {
                        return;
                    }
                }
            }
            
            if ([[_selectedOptions valueForKey:@"lowercaseString"] containsObject:[strOption lowercaseString]]) {
                NSInteger index = [[_selectedOptions valueForKey:@"lowercaseString"] indexOfObject:[strOption lowercaseString]];
                [_selectedOptions removeObjectAtIndex:index];
                if (_selectedOptions.count == 0) {
                    [_selectedOptions addObject:@"No Answer"];
                }
                tempButton.selected = false;
            }else{
                if(!_isMultiSelectionSupported){
                    [_selectedOptions removeAllObjects];
                    [_selectedOptions addObject:strOption];
                }else{
                    if ([[_selectedOptions valueForKey:@"lowercaseString"] containsObject:[@"No Answer" lowercaseString]]) {
                        NSInteger index = [[_selectedOptions valueForKey:@"lowercaseString"] indexOfObject:[@"No Answer" lowercaseString]];
                        [_selectedOptions removeObjectAtIndex:index];
                    }
                    [_selectedOptions addObject:strOption];
                    
                }
                tempButton.selected = true;
            }
            
            break;
        }
    }
    NSString *strTextForSubtitle = @"";
    if (_options.count == _selectedOptions.count) {
        
        NSMutableArray *arrTEmp=[[NSMutableArray alloc]init];
        for (NSString *strTemp in _selectedOptions) {
            [arrTEmp addObject:NSLocalizedString(strTemp, nil)];
        }
        strTextForSubtitle = [arrTEmp componentsJoinedByString:@","];

        
    }else if(_selectedOptions.count > 0){
        if (!_isMultiSelectionSupported) {
            strTextForSubtitle = [_selectedOptions objectAtIndex:0];
            for (UIView *subview in _arrExpandedOptionsViews) {
                for (UIView *btnView in [subview subviews]) {
                    if ([btnView isKindOfClass:[SGButton class]]) {
                        SGButton *btn=(SGButton*)btnView;
                        if (![btn.userInfo isEqualToString:strTextForSubtitle]) {
                            btn.selected = false;
                        }
                    }
                }
                
                
            }
        }else{
            NSMutableArray *arrTEmp=[[NSMutableArray alloc]init];
            for (NSString *strTemp in _selectedOptions) {
                [arrTEmp addObject:NSLocalizedString(strTemp, nil)];
            }
            strTextForSubtitle = [arrTEmp componentsJoinedByString:@","];
        }
    }
    lblSubtitle.text=NSLocalizedString(strTextForSubtitle, nil);
}
- (void)showEditor{
    PSTAlertController *gotoPageController = [PSTAlertController alertWithTitle:@"Add extra option" message:nil];
    
    [gotoPageController addAction:[PSTAlertAction actionWithTitle:@"Add" handler:^(PSTAlertAction *action) {
        if (action.alertController.textField.text.length > 0) {
            NSString *strExtraOption;
            for (NSString *strOption in _selectedOptions) {
                if (![[_arrOptions valueForKey:@"lowercaseString"] containsObject:[strOption lowercaseString]]) {
                    strExtraOption =  strOption;
                    break;
                }
            }
            [_selectedOptions removeObject:strExtraOption];

            [_selectedOptions addObject:action.alertController.textField.text];
            for (UIView *viewOption in _arrExpandedOptionsViews) {
                if (viewOption.tag == otherOptionTag) {
                    UILabel *lbl = (UILabel*)[viewOption viewWithTag:lblOptionTag];
                    lbl.text = [NSString stringWithFormat:@"%@(✏️)",action.alertController.textField.text];
                    SGButton *btn = (SGButton*)[viewOption viewWithTag:buttonTag];
                    btn.userInfo = action.alertController.textField.text;
                    [lbl sizeToFit];
                }
            }
        }else{
            [self removeExtraOption];
            
            for (UIView *viewOption in _arrExpandedOptionsViews) {
                if (viewOption.tag == otherOptionTag) {
                    UILabel *lbl = (UILabel*)[viewOption viewWithTag:lblOptionTag];
                    lbl.text = [NSString stringWithFormat:@"Other(✏️)"];
                    [lbl sizeToFit];
                    SGButton *btn = (SGButton*)[viewOption viewWithTag:buttonTag];
                    btn.selected = NO;
                    btn.userInfo = [NSString stringWithFormat:@"Other"];

                }
            }
        }
    }]];
    [gotoPageController addAction:[PSTAlertAction actionWithTitle:@"Cancel" style:PSTAlertActionStyleCancel handler:nil]];
    [gotoPageController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//        NSString *strExtraOption;
//        for (NSString *strOption in _selectedOptions) {
//            if (![[_arrOptions valueForKey:@"lowercaseString"] containsObject:[strOption lowercaseString]] && ![[strOption lowercaseString] isEqualToString:[@"No Answer" lowercaseString]]) {
//                strExtraOption =  strOption;
//                break;
//            }
//        }
//        textField.text = strExtraOption;
        textField.placeholder = @"Write option";
        
    }];
    [gotoPageController showWithSender:nil controller:_controller animated:YES completion:NULL];
}
- (void)removeExtraOption{
    NSString *strExtraOption;
    for (NSString *strOption in _selectedOptions) {
        if (![[_selectedOptions valueForKey:@"lowercaseString"] containsObject:[strOption lowercaseString]]) {
            strExtraOption =  strOption;
            break;
        }
    }
    [_selectedOptions removeObject:strExtraOption];
}
- (CGFloat)totalHeight{
    int count = (int)_options.count;
    if (_isOtherOptionSupported) {
        count = count +1;
    }
    CGFloat padding = 5;
    CGFloat titlesize = 40;
    CGFloat optionsSize = count * ([self deviceSpesificValue:30]);
    return (2*padding) + (titlesize) + optionsSize ;
}
- (void)expand{
    _isExpanded = true;
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGAffineTransform transform = CGAffineTransformMakeRotation((CGFloat) M_PI_2);
                         viewDisclosure.transform = transform;
                     }
                     completion:nil];
    
    
}
- (void)collapse{
    _isExpanded = false;
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGAffineTransform transform = CGAffineTransformMakeRotation(0);
                         viewDisclosure.transform = transform;
                     }
                     completion:nil];
    
    
}
- (void)setController:(UIViewController *)controller{
    _controller = controller;
}
- (void)unload{
    for (UIView *view in [self.contentView subviews]) {
        [view removeFromSuperview];
    }
}


- (void)dealloc{
    lblSubtitle = nil;
    viewDisclosure = nil;
    
    _tableView = nil;
    _arrExpandedOptionsViews = nil;
    
}
@end
