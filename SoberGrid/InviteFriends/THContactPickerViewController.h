//
//  ContactPickerViewController.h
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "THContactPickerView.h"
#import "TPKeyboardAvoidingTableView.h"

@protocol THContactDelegate <NSObject>

- (void)thContacts:(NSMutableArray*)arrContacts;

@end

@interface THContactPickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, THContactPickerDelegate, ABPersonViewControllerDelegate>


@property (nonatomic,assign)  id<THContactDelegate>delegate;
@property (nonatomic,assign)  BOOL withoutWazobiaUser;
@property (nonatomic, strong) THContactPickerView *contactPickerView;
@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) NSArray *filteredContacts;

@end
