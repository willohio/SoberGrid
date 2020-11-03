//
//  ViewController.m
//  JFDepthVewExample
//
//  Created by Jeremy Fox on 10/17/12.
//  Copyright (c) 2012 Jeremy Fox. All rights reserved.

//  Chuck Norris Picture Credit: http://www.reactionface.info/sites/default/files/images/1313574161997.jpg

#define KEY_SAVED_PHRASE @"savedphrase"

#import "SavedPhraseController.h"
#import "User.h"


@interface SavedPhraseController ()
{
    UIButton *sendButton;
}
@end

@implementation SavedPhraseController

- (void)viewDidLoad
{
    [super viewDidLoad];
     arrMainPhrase = [[self getSavedPhrase] mutableCopy];
    [self createTable];

}
- (void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}
- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = toolBar.frame;
 //   containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + toolBar.frame.size.height);
    containerFrame.origin.y = (self.view.bounds.size.height - ((isIPad) ? 30 : 50)-40) - keyboardBounds.size.height;
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    toolBar.frame = containerFrame;
    CGRect tblFrame = tblView.frame;
    tblFrame.size.height = toolBar.frame.origin.y;
    tblView.frame = tblFrame;
    
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = toolBar.frame;
    containerFrame.origin.y = self.view.bounds.size.height - ((isIPad) ? 30 : 50)-40;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    toolBar.frame = containerFrame;
    CGRect tblFrame = tblView.frame;
    tblFrame.size.height = toolBar.frame.origin.y;
    tblView.frame = tblFrame;
    
    // commit animations
    [UIView commitAnimations];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - iOS 5 Rotation Support
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"Top View Controller Received didRotateFromInterfaceOrientation: event from JFDepthView");
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"Top View Controller Received willRotateToInterfaceOrientation:duration: event from JFDepthView");
}

#pragma mark - iOS 6 Rotation Support

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return (UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight | UIInterfaceOrientationPortraitUpsideDown);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (IBAction)closeView:(id)sender {
    
    [self.depthViewReference dismissPresentedViewInView:self.presentedInView animated:YES];
}
#pragma mark - Create Table view with options
- (void)createTable{
    tblView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,(isIPad) ? 600 : CGRectGetWidth(self.view.bounds) - 30 , CGRectGetHeight(self.view.bounds)-40- ((isIPad) ? 30 : 50)) style:UITableViewStylePlain];
    tblView.delegate = self;
    tblView.dataSource = self;
    [self.view addSubview:tblView];
    
    
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                                     self.view.bounds.size.height - ((isIPad) ? 30 : 50)-40,
                                                                     self.view.bounds.size.width,
                                                                     40.0f)];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:toolBar];
//
    textFieldComment = [[UITextField alloc] initWithFrame:CGRectMake(10.0f,
                                                                     6.0f,
                                                                     toolBar.bounds.size.width - 20.0f - 68.0f,
                                                                     30.0f)];
    textFieldComment.delegate=self;
    textFieldComment.placeholder=@"Write phrase";
    textFieldComment.borderStyle = UITextBorderStyleRoundedRect;
    textFieldComment.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    [textFieldComment becomeFirstResponder];
    [toolBar addSubview:textFieldComment];
//
    sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [sendButton setTitle:@"Save" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(savebutton_Clicked:) forControlEvents:UIControlEventTouchUpInside];
    sendButton.frame = CGRectMake(toolBar.bounds.size.width - 68.0f,
                                  6.0f,
                                  58.0f,
                                  29.0f);
    [toolBar addSubview:sendButton];

}

#pragma mark - Tableview Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrMainPhrase.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedPhraseCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"savedPhraseCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [arrMainPhrase objectAtIndex:indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UITableViewCell *cell = [tblView cellForRowAtIndexPath:indexPath];
        [self deletePhrase:cell.textLabel.text];

    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
    
    
}


-(BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([_delegate respondsToSelector:@selector(didSelectedPhrase:)]) {
        [_delegate didSelectedPhrase:cell.textLabel.text];
    }
    [self.depthViewReference dismissPresentedViewInView:self.presentedInView animated:YES];

}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *viewHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 40)];
    viewHeader.backgroundColor = [UIColor whiteColor];
    // Create header lable
    UILabel *lblHeader = [[UILabel alloc]initWithFrame:viewHeader.bounds];
    lblHeader.userInteractionEnabled = false;
    lblHeader.font = [UIFont boldSystemFontOfSize:17.0];
    lblHeader.textColor = [UIColor redColor];
    lblHeader.text = @"Saved Phrase";
    lblHeader.textAlignment = NSTextAlignmentCenter;
    [viewHeader addSubview:lblHeader];
    lblHeader = nil;
    
    // Create cancel button
    UIButton *btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(viewHeader.bounds) - 55, 0, 50, 40)];
    [btnCancel setTitle:@"Close" forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [btnCancel setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnCancel];
    btnCancel = nil;
    
    
    UIButton *btnEdit = [[UIButton alloc]initWithFrame:CGRectMake(5, 0, 50, 40)];
    [btnEdit setTitle:@"Edit" forState:UIControlStateNormal];
    [btnEdit setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateSelected];
    btnEdit.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [btnEdit setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btnEdit addTarget:self action:@selector(edit_clicked:) forControlEvents:UIControlEventTouchUpInside];
    btnEdit.selected = tblView.editing;
    [viewHeader addSubview:btnEdit];
    btnEdit = nil;
    
    return viewHeader;
}
#pragma mark - Texfield delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.text.length == 0 && [string isEqualToString:@" "]) {
        return false;
    }
    return true;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textFieldComment resignFirstResponder];
    return true;
}
- (IBAction)savebutton_Clicked:(UIBarButtonItem*)sender{
    if (textFieldComment.text.length > 0) {
        [self savePhrase:textFieldComment.text];
    }
}
- (IBAction)edit_clicked:(UIButton*)sender{
    sender.selected = !sender.selected;
    tblView.editing = sender.selected;
}
- (NSArray *)getSavedPhrase{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",[User currentUser].struserId,KEY_SAVED_PHRASE]]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",[User currentUser].struserId,KEY_SAVED_PHRASE]];
    }
    else
        return nil;
}
- (void)savePhrase:(NSString*)phrase{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",[User currentUser].struserId,KEY_SAVED_PHRASE]]) {
        NSMutableArray *arrPhrase= [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",[User currentUser].struserId,KEY_SAVED_PHRASE]] mutableCopy];
        [arrPhrase addObject:phrase];
        [self savePhraseArray:arrPhrase];
        arrPhrase = nil;
    }else{
        NSMutableArray *arrPhrase=[[NSMutableArray alloc]init];
        [arrPhrase addObject:phrase];
        [self savePhraseArray:arrPhrase];
        arrPhrase = nil;
    }
    arrMainPhrase = [[self getSavedPhrase] mutableCopy];
    [tblView reloadData];
    [textFieldComment resignFirstResponder];
    textFieldComment.text = @"";
    
    
}
- (void)savePhraseArray:(id)array{
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:[NSString stringWithFormat:@"%@_%@",[User currentUser].struserId,KEY_SAVED_PHRASE]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)deletePhrase:(NSString*)strPhrase{
    [arrMainPhrase removeObject:strPhrase];
    [self savePhraseArray:arrMainPhrase];
    [tblView reloadData];
}
- (void)dealloc{
    NSLog(@"Dealloc from SavedPharse");
    _delegate = nil;
    tblView = nil;
    textFieldComment.delegate = nil;
    textFieldComment = nil;
    sendButton = nil;
    toolBar = nil;
}
@end
