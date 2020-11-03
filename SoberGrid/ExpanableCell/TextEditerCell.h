//
//  TextEditerCell.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/13/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TextEditerCellDelegate <NSObject>
@optional
- (void)editingStartedForCell:(UITableViewCell*)cell;
- (void)editingEndedForCell:(UITableViewCell*)cell;
@end

@interface TextEditerCell : UITableViewCell <UITextFieldDelegate>{
    UILabel *lblAge;
  
}
@property (nonatomic,assign)int textLimit;
@property (nonatomic,strong)  UITextField *txtField;;
@property (nonatomic,assign)id<TextEditerCellDelegate>delegate;
@property (assign)BOOL isEditable;
- (CGFloat)totalHeight;
- (void)customizeWithText:(NSString*)text andPlaceHolder:(NSString*)strPlaceholder andAge:(NSString*)age isEditable:(BOOL)isEditable withTextLimit:(int)limit;

@end
