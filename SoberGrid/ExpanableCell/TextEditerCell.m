//
//  TextEditerCell.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/13/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import "TextEditerCell.h"
#import "CustomPickerView.h"
#import "CustomDatePicker.h"

@implementation TextEditerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor =[UIColor clearColor];
        self.clipsToBounds=YES;
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
- (void)customizeWithText:(NSString*)text andPlaceHolder:(NSString*)strPlaceholder andAge:(NSString*)age isEditable:(BOOL)isEditable withTextLimit:(int)limit {
    _textLimit = limit;
    if ([text isEqualToString:NSLocalizedString(@"No Answer", nil)]) {
        text = @"";
    }
    _isEditable=isEditable;
    
    _txtField=[[UITextField alloc]initWithFrame:CGRectMake(12, 5, 320-24, 30)];
    _txtField.placeholder=strPlaceholder;
    _txtField.delegate=self;
    _txtField.text = text;
    _txtField.textColor=[UIColor blackColor];
    _txtField.font=SGREGULARFONT(17.0);
    _txtField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    [self.contentView addSubview:_txtField];
    
//    [_txtField setValue:[UIColor blackColor]
//             forKeyPath:@"_placeholderLabel.textColor"];
    
//    lblAge=[[UILabel alloc]initWithFrame:CGRectMake(163, 5, 30, 20)];
//    lblAge.text=[NSString stringWithFormat:@"(%@)",age];
//    lblAge.textColor=[UIColor whiteColor];
//    lblAge.font =[UIFont boldSystemFontOfSize:17.0];
//    [self.contentView addSubview:lblAge];
    
}

- (CGFloat)totalHeight
{
    return 90;
}
- (void)unload{
    for (UIView *view in [self.contentView subviews]) {
        [view removeFromSuperview];
    }
}
#pragma mark- UITextfield Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (_isEditable) {
        textField.borderStyle = UITextBorderStyleRoundedRect;
        return true;
    }else
        return false;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [_delegate editingStartedForCell:self];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    textField.borderStyle = UITextBorderStyleNone;
    [_delegate editingEndedForCell:self];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField.text.length == 0 && [string isEqualToString:@" "]) {
        return false;
    }
    const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
        int isBackSpace = strcmp(_char, "\b");
        
        if (isBackSpace == -8) {
            // is backspace
            return true;
        }
        if (textField.text.length > _textLimit) {
            return false;
        }
    return true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
