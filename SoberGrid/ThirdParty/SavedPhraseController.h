//
//  ViewController.h
//  JFDepthVewExample
//
//  Created by Jeremy Fox on 10/17/12.
//  Copyright (c) 2012 Jeremy Fox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFDepthView.h"
@protocol SavedPhraseControllerDelegate <NSObject>
- (void)didSelectedPhrase:(NSString*)strPhrase;
@end
@interface SavedPhraseController : UIViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    NSMutableArray *arrMainPhrase;
    UITableView *tblView;
    UITextField   *textFieldComment;
    UIToolbar *toolBar;
}

@property (strong, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) JFDepthView* depthViewReference;
@property (weak, nonatomic) UIView* presentedInView;
@property (nonatomic,assign) id<SavedPhraseControllerDelegate>delegate;
- (IBAction)closeView:(id)sender;
@end
