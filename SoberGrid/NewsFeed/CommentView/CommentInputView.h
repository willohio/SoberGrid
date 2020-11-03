//
//  CommentInputView.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/22/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
@protocol CommentInputViewDelegate <NSObject>

@optional
- (void)sendButtonClickedWithText:(NSString*)text;
- (void)commentInputViewHeightUpdatedwithHeight:(CGFloat)height;
@end

@interface CommentInputView : UIView <HPGrowingTextViewDelegate>

@property (nonatomic,strong)HPGrowingTextView *textView;
@property (nonatomic,strong)UIToolbar *toolBar;
@property (nonatomic,assign)id<CommentInputViewDelegate>delegate;
@end
