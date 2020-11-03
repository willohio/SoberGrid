//
//  ContactPickerViewController.m
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import "THContactPickerViewController.h"
#import <AddressBook/AddressBook.h>
#import "THContact.h"
#import "PSTAlertController.h"
#import "DatabaseManager.h"
#import <MessageUI/MessageUI.h>

UIBarButtonItem *barButton;
UIBarButtonItem *leftBarButton;

@interface THContactPickerViewController ()<MFMessageComposeViewControllerDelegate>

@property (nonatomic, assign) ABAddressBookRef addressBookRef;

@end

//#define kKeyboardHeight 216.0
#define kKeyboardHeight 0.0

@implementation THContactPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
        [self setTitle:@"Select Contacts (0)"];

        CFErrorRef error;
        _addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    }
    return self;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        [self setTitle:@"Select Contacts (0)"];
        
        CFErrorRef error;
        _addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        [Localytics tagEvent:LLUserInInviteFriendScreen];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setTitle:@"Select Contacts (0)"];
    
    barButton = [[UIBarButtonItem alloc] initWithTitle:@"Invite" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    barButton.enabled = FALSE;
    self.navigationItem.rightBarButtonItem = barButton;
    if (!self.navigationItem.leftBarButtonItem) {
        leftBarButton  = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem  = leftBarButton;

    }
    
   
    
    // Initialize and add Contact Picker View
    self.contactPickerView = [[THContactPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    self.contactPickerView.delegate = self;
    [self.contactPickerView setPlaceholderString:@"Type contact name"];
    [self.contactPickerView setBubbleColor:[[THBubbleColor alloc] initWithGradientTop:[UIColor redColor] gradientBottom:[UIColor redColor] border:[UIColor redColor]] selectedColor:[[THBubbleColor alloc] initWithGradientTop:[UIColor redColor] gradientBottom:[UIColor redColor] border:[UIColor redColor]]];
    [self.view addSubview:self.contactPickerView];
    
    // Fill the rest of the view with the table view
    self.tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, self.contactPickerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.contactPickerView.frame.size.height - kKeyboardHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tintColor = [UIColor redColor];
    
    [self.view insertSubview:self.tableView belowSubview:self.contactPickerView];
    
    // SHOS HOOD
    ABAddressBookRequestAccessWithCompletion(self.addressBookRef, ^(bool granted, CFErrorRef error) {
        if (granted) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self getContactsFromAddressBook];
            });
        } else {
            // TODO: Show alert
        }
    });
}

-(void)getContactsFromAddressBook
{
    CFErrorRef error = NULL;
    NSMutableArray *arrTempContacts = [[NSMutableArray alloc]init];
    self.contacts = [[NSMutableArray alloc]init];
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (addressBook) {
        NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSMutableArray *mutableContacts = [NSMutableArray arrayWithCapacity:allContacts.count];
        
        NSUInteger i = 0;
        for (i = 0; i<[allContacts count]; i++)
        {
            
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];

           
            
            // Get mobile number
            ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            NSMutableArray *arrContacts =[self getMobilePhoneProperty:phonesRef];
            if (arrContacts) {
                for (NSString *strContact in arrContacts) {
                    THContact *contact = [[THContact alloc] init];
                    contact.recordId = ABRecordGetRecordID(contactPerson);

                    // Get first and last names
                    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
                    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
                    
                    // Set Contact properties
                    contact.firstName = firstName;
                    contact.lastName = lastName;
                    contact.phone = strContact;
                    // Get image if it exists
                    NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
                    contact.image = [UIImage imageWithData:imgData];
                    if (!contact.image) {
                        contact.image = [UIImage imageNamed:@"icon-avatar-60x60"];
                    }
                    if (contact.phone.length > 0) {
                        NSString *cleanedString = [[contact.phone componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
                        if (![arrTempContacts containsObject:cleanedString]) {
                            [arrTempContacts addObject:cleanedString];
                            [mutableContacts addObject:contact];
                        }
                        
                    }
                }
            }
            if(phonesRef) {
                CFRelease(phonesRef);
            }
    
        }
        
        if(addressBook) {
            CFRelease(addressBook);
        }
        
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName"
                                                     ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
         self.contacts  = [mutableContacts sortedArrayUsingDescriptors:sortDescriptors];
       
        
        self.selectedContacts = [NSMutableArray array];
        self.filteredContacts = self.contacts;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }
    else
    {
        NSLog(@"Error");
        dispatch_async(dispatch_get_main_queue(), ^{

        });
        
    }
}

//- (void) refreshContacts
//{
//    for (THContact* contact in self.contacts)
//    {
//        [self refreshContact:contact];
//    }
//    [self.tableView reloadData];
//}
//
//- (void) refreshContact:(THContact*)contact
//{
//    
//    ABRecordRef contactPerson = ABAddressBookGetPersonWithRecordID(self.addressBookRef, (ABRecordID)contact.recordId);
//    contact.recordId = ABRecordGetRecordID(contactPerson);
//    
//    // Get first and last names
//    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
//    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
//    
//    // Set Contact properties
//    contact.firstName = firstName;
//    contact.lastName = lastName;
//    
//    // Get mobile number
//    ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
//    contact.phone = [self getMobilePhoneProperty:phonesRef];
//    if(phonesRef) {
//        CFRelease(phonesRef);
//    }
//    
//    // Get image if it exists
//    NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
//    contact.image = [UIImage imageWithData:imgData];
//    if (!contact.image) {
//        contact.image = [UIImage imageNamed:@"icon-avatar-60x60"];
//    }
//}

- (NSMutableArray *)getMobilePhoneProperty:(ABMultiValueRef)phonesRef
{
    NSMutableArray *arrContacts = [[NSMutableArray alloc]init];
    for (int i=0; i < ABMultiValueGetCount(phonesRef); i++) {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if(currentPhoneLabel) {
            [arrContacts addObject:(__bridge  NSString *)currentPhoneValue];
        }
        if(currentPhoneLabel) {
            CFRelease(currentPhoneLabel);
        }
        if(currentPhoneValue) {
            CFRelease(currentPhoneValue);
        }
    }
    if (arrContacts.count > 0) {
        return arrContacts;
    }else
    return nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat topOffset = 0;
    if ([self respondsToSelector:@selector(topLayoutGuide)]){
        topOffset = self.topLayoutGuide.length;
    }
    CGRect frame = self.contactPickerView.frame;
    frame.origin.y = topOffset;
    self.contactPickerView.frame = frame;
    [self adjustTableViewFrame:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)adjustTableViewFrame:(BOOL)animated {
    CGRect frame = self.tableView.frame;
    // This places the table view right under the text field
    frame.origin.y = self.contactPickerView.frame.size.height;
    // Calculate the remaining distance
    frame.size.height = self.view.frame.size.height - self.contactPickerView.frame.size.height - kKeyboardHeight;
    
    if(animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0.1];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        self.tableView.frame = frame;
        
        [UIView commitAnimations];
    }
    else{
        self.tableView.frame = frame;
    }
}



#pragma mark - UITableView Delegate and Datasource functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredContacts.count;
}

- (CGFloat)tableView: (UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath {
    
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get the desired contact from the filteredContacts array
    THContact *contact = [self.filteredContacts objectAtIndex:indexPath.row];
    
    // Initialize the table view cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactcell"];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"contactcell"];
        cell.contentView.clipsToBounds = YES;
    }

    
    // Assign values to to US elements
    cell.textLabel.font = SGREGULARFONT(16.0);
    cell.textLabel.textColor = [UIColor blackColor];
    
    cell.detailTextLabel.font = SGREGULARFONT(14.0);
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.textLabel.text = [contact fullName];
    cell.detailTextLabel.text = contact.phone;
//    if(contact.image) {
//        cell.imageView.image = contact.image;
//    }else
//        cell.imageView.image = [UIImage imageNamed:@"default_profile_pic"];

    // Set the checked state for the contact selection checkbox
   
    if ([self.selectedContacts containsObject:[self.filteredContacts objectAtIndex:indexPath.row]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Hide Keyboard
    [self.contactPickerView resignKeyboard];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // This uses the custom cellView
    // Set the custom imageView
    THContact *user = [self.filteredContacts objectAtIndex:indexPath.row];
    
    if ([self.selectedContacts containsObject:user]){ // contact is already selected so remove it from ContactPickerView
        //cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedContacts removeObject:user];
        [self.contactPickerView removeContact:user];
        // Set checkbox to "unselected"
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        // Contact has not been selected, add it to THContactPickerView
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedContacts addObject:user];
        [self.contactPickerView addContact:user withName:user.fullName];
        // Set checkbox to "selected"
         cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    // Enable Done button if total selected contacts > 0
    if(self.selectedContacts.count > 0) {
        barButton.enabled = TRUE;
    }
    else
    {
        barButton.enabled = FALSE;
    }
    
    // Update window title
    [self setTitle:[NSString stringWithFormat:@"Add Members (%lu)", (unsigned long)self.selectedContacts.count]];
    
    // Set checkbox image
    // Reset the filtered contacts
    self.filteredContacts = self.contacts;
    // Refresh the tableview
    [self.tableView reloadData];
}

#pragma mark - THContactPickerTextViewDelegate

- (void)contactPickerTextViewDidChange:(NSString *)textViewText {
    if ([textViewText isEqualToString:@""]){
        self.filteredContacts = self.contacts;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.%@ contains[cd] %@ OR self.%@ contains[cd] %@", @"firstName", textViewText, @"lastName", textViewText];
        self.filteredContacts = [self.contacts filteredArrayUsingPredicate:predicate];
    }
    [self.tableView reloadData];
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
    [self adjustTableViewFrame:YES];
}

- (void)contactPickerDidRemoveContact:(id)contact {
    [self.selectedContacts removeObject:contact];
    
    NSUInteger index = [self.contacts indexOfObject:contact];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    //cell.accessoryType = UITableViewCellAccessoryNone;
    
    // Enable Done button if total selected contacts > 0
    if(self.selectedContacts.count > 0) {
        barButton.enabled = TRUE;
    }
    else
    {
        barButton.enabled = FALSE;
    }
    
    // Set unchecked image
    UIImageView *checkboxImageView = (UIImageView *)[cell viewWithTag:104];
    UIImage *image;
    image = [UIImage imageNamed:@"chat_offline"];
    checkboxImageView.image = image;
    
    // Update window title
    [self setTitle:[NSString stringWithFormat:@"Add Members (%lu)", (unsigned long)self.selectedContacts.count]];
}

- (void)removeAllContacts:(id)sender
{
    [self.contactPickerView removeAllContacts];
    [self.selectedContacts removeAllObjects];
    self.filteredContacts = self.contacts;
    [self.tableView reloadData];
}
#pragma mark ABPersonViewControllerDelegate

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return YES;
}


// This opens the apple contact details view: ABPersonViewController
//TODO: make a THContactPickerDetailViewController
- (IBAction)viewContactDetail:(UIButton*)sender {
    ABRecordID personId = (ABRecordID)sender.tag;
    ABPersonViewController *view = [[ABPersonViewController alloc] init];
    view.addressBook = self.addressBookRef;
    view.personViewDelegate = self;
    view.displayedPerson = ABAddressBookGetPersonWithRecordID(self.addressBookRef, personId);

    
    [self.navigationController pushViewController:view animated:YES];
}

// TODO: send contact object
- (void)done:(id)sender
{
    
    if(![MFMessageComposeViewController canSendText]) {
        PSTAlertController *gotoPageController = [PSTAlertController alertWithTitle:@"Your device cannot send text messages" message:nil];
        
        [gotoPageController addAction:[PSTAlertAction actionWithTitle:@"OK" handler:nil]];
        [gotoPageController showWithSender:nil controller:self animated:YES completion:NULL];
        
        return;
    }
    
    //set receipients
    NSMutableArray *recipients = [[NSMutableArray alloc]init];
    for (THContact *contact in self.selectedContacts) {
        [recipients addObject:contact.phone];
    }
    
    //set message text
    NSString * message = @"“I’m staying sober with Sober Grid—a new free app for people in recovery. Go to http://goo.gl/NglQWa to check it out!”";
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipients];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}
#pragma mark - MFMailComposeViewControllerDelegate methods
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
        {
            NSLog(@"User has canceled the Compaseing");
        }
            break;
            
        case MessageComposeResultFailed:
        {
            PSTAlertController *gotoPageController = [PSTAlertController alertWithTitle:@"Fail to send SMS" message:nil];
            
            [gotoPageController addAction:[PSTAlertAction actionWithTitle:@"OK" handler:nil]];
            
            [gotoPageController showWithSender:nil controller:self animated:YES completion:NULL];
            break;
        }
            
        case MessageComposeResultSent:
        {
            NSLog(@"Ur message has been sent");
            [self.contactPickerView removeAllContacts];
            [self.selectedContacts removeAllObjects];
            self.filteredContacts = self.contacts;
            [self.tableView reloadData];

        }
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

}
- (void)cancel{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
  
}

- (void)dealloc{
    self.tableView = nil;
    barButton = nil;
}

@end
