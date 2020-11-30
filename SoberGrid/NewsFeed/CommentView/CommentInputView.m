//
//  CommentInputView.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/22/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "CommentInputView.h"

@implementation CommentInputView
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self customize];
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)customize{
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                           self.bounds.size.height-40,
                                                           self.bounds.size.width,
                                                           40.0f)];
    _toolBar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_toolBar];
    //
    _textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(10.0f,
                                                                    6.0f,
                                                                    _toolBar.bounds.size.width - 15.0f - 68.0f,
                                                                    30.0f)];
    _textView.delegate=self;
    _textView.minNumberOfLines = 1;
    _textView.maxNumberOfLines = 6;
    _textView.placeholder=NSLocalizedString(@"Write Comment", nil);
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //    [textFieldComment becomeFirstResponder];
    [_toolBar addSubview:_textView];
    //
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.tag = 475;
    sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [sendButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendbutton_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    sendButton.autoresizingMask=(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin);
    sendButton.frame = CGRectMake(_toolBar.bounds.size.width - 68.0f,
                                  6.0f,
                                  58.0f,
                                  29.0f);
    [_toolBar addSubview:sendButton];
    
}
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    CGRect newframe =  self.frame;
    newframe.size.height = height + 10;
    newframe.origin.y = newframe.origin.y - (newframe.size.height-self.frame.size.height);
    self.frame = newframe;
    [_delegate commentInputViewHeightUpdatedwithHeight:self.frame.origin.y];
    
}
- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (growingTextView.text.length == 0 && [text isEqualToString:@"\n"]) {
        return false;
    }
    if (growingTextView.text.length == 0 && [text isEqualToString:@" "]) {
        return false;
    }
    const char * _char = [text cStringUsingEncoding:NSUTF8StringEncoding];
    int isBackSpace = strcmp(_char, "\b");
    
    if (isBackSpace == -8) {
        // is backspace
        return true;
    }
    if (growingTextView.text.length > LIMIT_CHARACTER) {
        return false;
    }
    return true;
}
- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView
{
    return YES;
    
}

- (BOOL)growingTextViewShouldEndEditing:(HPGrowingTextView *)growingTextView
{
    
    return YES;
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView{
    
    
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView{
    return YES;
}

-(IBAction)sendbutton_Clicked:(UIButton*)sender{
    [_delegate sendButtonClickedWithText:_textView.text];
    _textView.text = @"";
}

- (IBAction)cameraButton_Clicked:(UIButton*)sender{
    
}

@end
