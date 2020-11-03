//  ACEExpandableTextCell.m
//
// Copyright (c) 2014 Stefano Acerbetti
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "ACEExpandableTextCell.h"
#import "UIImageView+WebCache.h"

#define kPadding 5

@interface ACEExpandableTextCell ()<UITextViewDelegate>{
    UILabel *lblAbout;
}
@property (nonatomic, strong) SZTextView *textView;

@end

#pragma mark -

@implementation ACEExpandableTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.textView];
        
    }
    return self;
}
- (void)customizewithUser:(User*)user{
    _objUser = user;
    _imgViewProfile = [[UIImageView alloc]initWithFrame:CGRectMake(10, 7.5, 45, 45)];
    _imgViewProfile.clipsToBounds = YES;
    _imgViewProfile.layer.cornerRadius = _imgViewProfile.frame.size.width / 2;
    NSURL *urlImage;
    if (_objUser.strProfilePicThumb.length>0) {
        urlImage = [NSURL URLWithString:_objUser.strProfilePicThumb];
    }
    [_imgViewProfile sd_setImageWithURL:urlImage placeholderImage:[UIImage imageNamed:@"avator"] options:SDWebImageRetryFailed];
    [self.contentView addSubview:_imgViewProfile];
    
    CGRect cellFrame = _textView.frame;
    cellFrame.origin.x = 20+45;
    cellFrame.size.width = cellFrame.size.width - 10-10 - 45;

    _textView.frame=cellFrame;
    
    _textView.inputAccessoryView = [self accessoryViewWithCameraEnabled:true DoneEnabled:false];
    [_textView becomeFirstResponder];

}
- (void)customizeForAbout{
    lblAbout=[[UILabel alloc]initWithFrame:CGRectMake(12, 2, 100, 25)];
    lblAbout.text = NSLocalizedString(@"About", nil);
    lblAbout.font = SGREGULARFONT(17.0);
    lblAbout.textColor = [UIColor blackColor];
    [self.contentView addSubview:lblAbout];
    
    CGRect cellFrame = _textView.frame;
    cellFrame.origin.y = cellFrame.origin.y + 25;
    cellFrame.size.height = CGRectGetHeight(self.contentView.bounds) - 30;
    _textView.frame = cellFrame;
    
    _textView.inputAccessoryView = [self accessoryViewWithCameraEnabled:false DoneEnabled:true];
  }

- (SZTextView *)textView
{
    if (_textView == nil) {
        CGRect cellFrame = self.contentView.bounds;
        cellFrame.origin.y += kPadding;
        cellFrame.size.height -= kPadding;
        cellFrame.size.width = cellFrame.size.width - 10-10;
        cellFrame.origin.x = 12;

        
        _textView = [[SZTextView alloc] initWithFrame:cellFrame];
        
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.font = SGREGULARFONT(17.0);
        
        _textView.scrollEnabled = NO;
        _textView.showsVerticalScrollIndicator = NO;
        _textView.showsHorizontalScrollIndicator = NO;
        
        _textView.delegate = self;
       
    }
    return _textView;
}
#pragma mark - Accessory view methods

-(UIView *)accessoryViewWithCameraEnabled:(BOOL)cameraEnabled DoneEnabled:(BOOL)doneEnalble{
    UIView *transparentBlackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 40)];
    transparentBlackView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.6f];
    
    
    UIView*   _acView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 40)];
    [_acView addSubview:transparentBlackView];
    if (cameraEnabled) {
        UIButton* btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCamera.frame = CGRectMake(10, 2, 60, 36);
        [btnCamera setImage:[UIImage imageNamed:imageNameRefToDevice(@"Camera")] forState:UIControlStateNormal];
        [btnCamera addTarget:self action:@selector(btnCameraAccessoryViewButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_acView addSubview:btnCamera];

    }
    if (doneEnalble) {
        UIButton* btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
        btnDone.frame = CGRectMake(CGRectGetWidth(_acView.frame)-63, 2, 60, 36);
        [btnDone setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
        [btnDone addTarget:self action:@selector(btnDone_Clicked:) forControlEvents:UIControlEventTouchUpInside];
        [_acView addSubview:btnDone];
    }
    
    return _acView;
}

- (IBAction)btnCameraAccessoryViewButtonTapped:(UIButton*)sender{
    
    if ([self.expandableTableView.delegate respondsToSelector:@selector(btnCameraAccessoryBtn_Clicked:)]) {
        [(id<ACEExpandableTableViewDelegate>)self.expandableTableView.delegate btnCameraAccessoryBtn_Clicked:sender];
    }
}
- (IBAction)btnDone_Clicked:(UIBarButtonItem*)sender{
    [_textView resignFirstResponder];
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    // update the UI and the cell size with a delay to allow the cell to load
    self.textView.text = text;
    [self performSelector:@selector(textViewDidChange:)
               withObject:self.textView
               afterDelay:0.1];
}

- (CGFloat)cellHeight
{
    return [self.textView sizeThatFits:CGSizeMake(self.textView.frame.size.width, FLT_MAX)].height + self.textView.frame.origin.y + kPadding;
}

- (void)updateTextViewHeight {
    [self textViewDidChange:self.textView];
}

#pragma mark - Text View Delegate

-(void)textViewDidEndEditing:(UITextView *)textView{
    if ([self.expandableTableView.delegate respondsToSelector:@selector(tableView:textViewDidEndEditing:)]) {
        [(id<ACEExpandableTableViewDelegate>)self.expandableTableView.delegate tableView:self.expandableTableView textViewDidEndEditing:self.textView];
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if ([self.expandableTableView.delegate respondsToSelector:@selector(tableView:textViewDidChangeSelection:)]) {
        [(id<ACEExpandableTableViewDelegate>)self.expandableTableView.delegate tableView:self.expandableTableView textViewDidChangeSelection:self.textView];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([self.expandableTableView.delegate respondsToSelector:@selector(tableView:textView:shouldChangeTextInRange:replacementText:)]) {
        id<ACEExpandableTableViewDelegate> delegate = (id<ACEExpandableTableViewDelegate>)self.expandableTableView.delegate;
        return [delegate tableView:self.expandableTableView
                          textView:textView
           shouldChangeTextInRange:range
                   replacementText:text];
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    // make sure the cell is at the top
    [self.expandableTableView scrollToRowAtIndexPath:[self.expandableTableView indexPathForCell:self]
                                    atScrollPosition:UITableViewScrollPositionTop
                                            animated:YES];
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.expandableTableView.delegate respondsToSelector:@selector(textViewDidBeginEditing:)]) {
        [(id<ACEExpandableTableViewDelegate>)self.expandableTableView.delegate textViewDidBeginEditing:textView];
    }
}

- (void)textViewDidChange:(UITextView *)theTextView
{
    if ([self.expandableTableView.delegate conformsToProtocol:@protocol(ACEExpandableTableViewDelegate)]) {
        
        id<ACEExpandableTableViewDelegate> delegate = (id<ACEExpandableTableViewDelegate>)self.expandableTableView.delegate;
        NSIndexPath *indexPath = [self.expandableTableView indexPathForCell:self];
        
        // update the text
        _text = self.textView.text;
        
        [delegate tableView:self.expandableTableView
                updatedText:_text
                atIndexPath:indexPath];
        
        CGFloat newHeight = [self cellHeight];
        CGFloat oldHeight = [delegate tableView:self.expandableTableView heightForRowAtIndexPath:indexPath];
        if (fabs(newHeight - oldHeight) > 0.01) {
            
            // update the height
            if ([delegate respondsToSelector:@selector(tableView:updatedHeight:atIndexPath:)]) {
                [delegate tableView:self.expandableTableView
                      updatedHeight:newHeight
                        atIndexPath:indexPath];
            }
            
            // refresh the table without closing the keyboard
            [self.expandableTableView beginUpdates];
            [self.expandableTableView endUpdates];
        }
    }
}
- (void)unload{
    [lblAbout removeFromSuperview];
    lblAbout = nil;
  
    self.expandableTableView = nil;
    [_textView resignFirstResponder];
    _textView.delegate = nil;
    [_textView removeFromSuperview];
    _textView = nil;
    [lblAbout removeFromSuperview];
    lblAbout = nil;
}
- (void)dealloc{
    _textView.delegate = nil;
    _textView = nil;
    lblAbout = nil;
}
@end

#pragma mark -

@implementation UITableView (ACEExpandableTextCell)

- (ACEExpandableTextCell *)expandableTextCellWithId:(NSString *)cellId
{
    ACEExpandableTextCell *cell = [self dequeueReusableCellWithIdentifier:cellId];
        cell = [[ACEExpandableTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.expandableTableView = self;
    
    return cell;
}

@end

