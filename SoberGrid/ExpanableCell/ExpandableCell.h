//
//  ExpandableCell.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/9/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGButton.h"

@interface ExpandableCell : UITableViewCell{
    UILabel *lblSubtitle;
    UIView *viewDisclosure;
    UIViewController *_controller;
    NSMutableArray *_arrOptions;
}

@property (nonatomic,assign)BOOL            isExpanded;
@property (nonatomic,strong)NSMutableArray  *options;
@property (nonatomic,strong)UITableView     *tableView;
@property (nonatomic,strong)NSMutableArray  *selectedOptions;
@property (nonatomic,strong)NSString        *strTitle;
@property (nonatomic,strong)NSMutableArray  *arrExpandedOptionsViews;
@property (assign)BOOL isMultiSelectionSupported;
@property (assign)BOOL isOtherOptionSupported;
- (void)expand;
- (void)collapse;
- (void)unload;
- (CGFloat)totalHeight;
- (void)customizeWithOptions:(NSMutableArray*)arrOptions withselectedOptions:(NSMutableArray*)selectedOptions forTitle:(NSString*)strTitle Expand:(BOOL)status withMultipleSupport:(BOOL)mStatus withOtherOption:(BOOL)oStatus;
- (void)setController:(UIViewController*)controller;
@end



