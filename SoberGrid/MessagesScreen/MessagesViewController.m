//
//  MessagesViewController.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/30/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import "MessagesViewController.h"
#import "MessageTableViewCell.h"
#import "SGXMPP.h"
#import "User.h"
#import "NSString+Utilities.h"
#import "XMPPMessage+XMPPMessageHelper.h"
#import "ApiClass.h"
#import "XHDemoWeChatMessageTableViewController.h"
#import "NSObject+ConvertingViewPixels.h"


@interface MessagesViewController () <ApiclassDelegate>

@end

@implementation MessagesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        [Localytics tagEvent:LLUserInMessageScreen];
    [self createTableView];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    self.title = NSLocalizedString(@"Message", nil);

    [self fetchMessages];
}

- (void)viewWillDisappear:(BOOL)animated{
    self.title = NSLocalizedString(@"", nil);

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Create tableview
- (void)createTableView
{
    tblView=[[UITableView alloc]initWithFrame:self.view.bounds];
    tblView.dataSource = self;
    tblView.delegate   = self;
    tblView.allowsMultipleSelectionDuringEditing = NO;
    [self.view addSubview:tblView];
    
}
#pragma mark - Tableview Datasource Delegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath { //implement the delegate method
    
    MessageTableViewCell *mCell = (MessageTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteMessages:[[mCell.dictInfo objectForKey:@"otherUser"] userIdByRemovingSoberGrid]];
        [_arrLastSentOrReceivedMessages removeObjectAtIndex:indexPath.row];
        [tblView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrLastSentOrReceivedMessages.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageTableViewCell *mcell = [tableView dequeueReusableCellWithIdentifier:@"messageCell"];
    if (mcell == nil) {
        mcell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"messageCell"];
    }
    [mcell customizewithData:[_arrLastSentOrReceivedMessages objectAtIndex:indexPath.row]];
    return mcell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self deviceSpesificValue:80];
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageTableViewCell *mcell = (MessageTableViewCell*)cell;
    [mcell unload];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // Call single user api to get its detail
   
    MessageTableViewCell *mCell = (MessageTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
  //  ApiClass *apiclass = [ApiClass sharedClass];
  //  apiclass.delegate = self;
    
    CommonApiCall *apicall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:[NSString stringWithFormat:@"%@get_user_details",baseUrl()] andDelegate:self];
    [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid": [[mCell.dictInfo objectForKey:@"otherUser"] userIdByRemovingSoberGrid],@"myuserid":[User currentUser].struserId} options:NSJSONWritingPrettyPrinted error:nil]];
    [appDelegate startLoadingview:@"Loading..."];
    
  //  [apiclass apiPostFunction:[NSURL URLWithString:[NSString stringWithFormat:@"%@get_user_details",baseUrl()]] withPostParameters:@{@"userid": [[mCell.dictInfo objectForKey:@"otherUser"] userIdByRemovingSoberGrid]} withRequestMethod:POST];
    
    
}
- (void)deleteMessages:(NSString*)otheruserid{
    


    [[SGXMPP sharedInstance] deleteHistoryWithUserId:otheruserid withCompletionHandler:nil];
}
- (void)fetchMessages{
   __block NSMutableArray *arrTotalMessages=[[NSMutableArray alloc]init];
    [[SGXMPP sharedInstance] fetchHistoryWithUserId:nil withLimit:0 ascending:false withCompletionHandler:^(NSArray *arrHistory) {
        for (int i = 0; i<arrHistory.count; i++) {
            if ([[arrHistory objectAtIndex:i] isKindOfClass:[XMPPMessageArchiving_Message_CoreDataObject class]]) {
                XMPPMessageArchiving_Message_CoreDataObject *message = (XMPPMessageArchiving_Message_CoreDataObject*)[arrHistory objectAtIndex:i];
                if ([message.message isMessageWithBody]) {
                    NSString *otherUser;
                    
                    if ([self isLastChatMessage:message.message forArray:arrTotalMessages]) {
                        if (![[message.message sender] isEqualToString:[[User currentUser].struserId userIdAddedSoberGrid]]) {
                            otherUser = [message.message sender];
                        }else{
                            otherUser = [message.message sendedTo];
                        }
                        NSDictionary *dictTemp = @{@"otherUser": otherUser,@"message":[message.message getmessage],@"timestamp":message.timestamp,@"senderid":[[message.message sender] userIdByRemovingSoberGrid]};
                        [arrTotalMessages addObject:dictTemp];
                        
                    }
                    
                }

            }
            _arrLastSentOrReceivedMessages = [arrTotalMessages mutableCopy];
            [tblView reloadData];
        }
    }];
}
- (BOOL)isLastChatMessage:(XMPPMessage*)message forArray:(NSMutableArray*)arrTemp{
   
    NSString *otherUser;
    if (![[message sender] isEqualToString:[[User currentUser].struserId userIdAddedSoberGrid]]) {
        otherUser = [message sender];
    }else{
        otherUser = [message sendedTo];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.otherUser == %@",otherUser];
    NSArray *ouputarray = [arrTemp filteredArrayUsingPredicate:predicate];
    if (ouputarray.count > 0) {
        return false;
    }
    else
        return true;
    
    return false;
}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    [appDelegate stopLoadingview];
    NSDictionary *dictResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    dictResponse = [dictResponse dictionaryByReplacingNullsWithBlanks];
    if ([requestedURL rangeOfString:@"get_user_details"].location != NSNotFound){
        if ([[dictResponse objectForKey:@"Type"] isEqualToString:@"OK"]) {
            User *userTemp = [[User alloc]init];
            [userTemp createUserWithDict:[[dictResponse objectForKey:@"Responce"] objectForKey:@"user"]];
            if (userTemp.struserId.length > 0) {
                XHDemoWeChatMessageTableViewController *demoWeChatMessageTableViewController = [[XHDemoWeChatMessageTableViewController alloc] init];
                demoWeChatMessageTableViewController.otherSideUser = userTemp;
                [self.navigationController pushViewController:demoWeChatMessageTableViewController animated:YES];
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"User no more exist in SoberGrid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            
            
        }else{
            
            
        }
    }
}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    [appDelegate stopLoadingview];
}
- (void)returnData:(id)data forUrl:(NSURL *)url withTag:(int)tag{
    
    NSDictionary *dictResponse = (NSDictionary*)data;
     if ([url.absoluteString rangeOfString:@"get_user_details"].location != NSNotFound){
    if ([[dictResponse objectForKey:@"Type"] isEqualToString:@"OK"]) {
        User *userTemp = [[User alloc]init];
        [userTemp createUserWithDict:[[dictResponse objectForKey:@"Responce"] objectForKey:@"user"]];
        XHDemoWeChatMessageTableViewController *demoWeChatMessageTableViewController = [[XHDemoWeChatMessageTableViewController alloc] init];
        demoWeChatMessageTableViewController.otherSideUser = userTemp;
        [self.navigationController pushViewController:demoWeChatMessageTableViewController animated:YES];
        
    }else{
       
        
    }
     }
    
}
- (void)failedData:(NSError *)error forUrl:(NSURL *)url withTag:(int)tag{
    
}
- (void)dealloc{
    tblView = nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
