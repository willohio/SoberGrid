//
//  RehabGroupViewController.m
//  SoberGrid
//
//  Created by agilepc-159 on 7/1/15.
//  Copyright (c) 2015 Agile Infoways Pvt. Ltd. All rights reserved.
//
static NSString *const kCellIdentifierGroupCell  = @"groupcell";
static NSInteger searchLimit = 20;
#import "RehabGroupViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "User.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "SGGroup.h"
@implementation RehabGroupCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    
        [self customise];
        
    }
    return self;
}
- (void)customise{
    detailLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    detailLable.font = [UIFont systemFontOfSize:14.0];
    detailLable.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:detailLable];
    
    textLable = [[UILabel alloc]initWithFrame:CGRectZero];
    textLable.numberOfLines = 0;
    textLable.font = [UIFont systemFontOfSize:17.0];
    [self.contentView addSubview:textLable];
}
- (void)setText:(NSString *)text withDetailText:(NSString*)detailText{
    CGFloat paddingFromLeft = 5;
    detailLable.text = detailText;
    [detailLable sizeToFit];
    detailLable.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - detailLable.frame.size.width - paddingFromLeft, 0, detailLable.frame.size.width, detailLable.frame.size.height);
   
    
    CGFloat textLableWidth = detailLable.frame.origin.x - (2*paddingFromLeft);
    CGRect textRect = [text boundingRectWithSize:CGSizeMake(textLableWidth, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17.0]} context:nil];
    textLable.frame = CGRectMake(paddingFromLeft, 5, textLableWidth, textRect.size.height);
    textLable.text = text;
    detailLable.center = CGPointMake(detailLable.center.x, textLable.center.y);
}
+ (CGFloat)cellHeightForText:(NSString*)text withDetailText:(NSString*)detailText{
    CGFloat paddingFromLeft = 5;

    CGRect detailTextRect = [detailText boundingRectWithSize:CGSizeMake(FLT_MAX, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:14.0] } context:nil];
    
    CGFloat textLableWidth = ([UIScreen mainScreen].bounds.size.width - detailTextRect.size.width - paddingFromLeft) - (2*paddingFromLeft);
    
    CGRect textRect = [text boundingRectWithSize:CGSizeMake(textLableWidth, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17.0]} context:nil];
    return textRect.size.height + 10;
    
}

- (void)dealloc{
    textLable = nil;
    detailLable = nil;
}
@end

@interface RehabGroupViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,CommonApiCallDelegate,UIAlertViewDelegate>
{
    UITableView *tblView;
    NSMutableArray *arrGroups;
    NSInteger offset;
    UISearchBar *searchBar;
}

@end

@implementation RehabGroupViewController
- (void)formatUI{
    self.navigationItem.hidesBackButton = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    tblView = [[TPKeyboardAvoidingTableView alloc]initWithFrame:self.view.bounds];
    tblView.dataSource = self;
    tblView.delegate = self;
    tblView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:tblView];
    [self addInfinitesScrollInTable:tblView];
    
    [self addSearchBarToNavigationView];
    
    arrGroups = [[NSMutableArray alloc]init];
}
- (void)addSearchBarToNavigationView{
    searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    searchBar.delegate = self;
    searchBar.barTintColor = [UIColor whiteColor];
    searchBar.backgroundColor = [UIColor whiteColor];
    searchBar.showsCancelButton = YES;
    searchBar.placeholder = @"Rehab Alumni Group";
    self.navigationItem.titleView = searchBar;
}
- (void) addInfinitesScrollInTable:(UITableView *)tableView {
    __weak RehabGroupViewController *weakSelf = self;
    __block UITableView *blockSafeTable  = tableView;
    
    [tableView addInfiniteScrollingWithActionHandler:^{
        //  [weakSelf fetchUserContactswithFirstTime:NO];
        blockSafeTable.showsInfiniteScrolling = YES;
        [weakSelf callApiWithText:searchBar.text];
    }];
    tableView.showsInfiniteScrolling = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self formatUI];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableview delegate and datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   return  arrGroups.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RehabGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifierGroupCell];
    if (cell == nil) {
        cell = [[RehabGroupCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierGroupCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    SGGroup *gp = [arrGroups objectAtIndex:indexPath.row];
    
    NSString *strDetailText;
    switch (gp.joinStatus.intValue) {
        case kSGGroupStatusNone:
        {
            strDetailText =@"Ask to Join";

        }
            break;
        case kSGGroupStatusAccepted:
        {
            strDetailText = @"Joined";

        }
            break;
        case kSGGroupStatusRequested:
        {
            strDetailText = @"Requested";

        }
            break;
        case kSGGroupStatusCancel:
        {
            strDetailText = @"Rejected";

        }
            break;
            
        default:
            break;
    }
    [cell setText:gp.strFullName withDetailText:strDetailText];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SGGroup *gp = [arrGroups objectAtIndex:indexPath.row];
    
    NSString *strDetailText;
    switch (gp.joinStatus.intValue) {
        case kSGGroupStatusNone:
        {
            strDetailText =@"Ask to Join";
            
        }
            break;
        case kSGGroupStatusAccepted:
        {
            strDetailText = @"Joined";
            
        }
            break;
        case kSGGroupStatusRequested:
        {
            strDetailText = @"Requested";
            
        }
            break;
        case kSGGroupStatusCancel:
        {
            strDetailText = @"Rejected";
            
        }
            break;
            
        default:
            break;
    }
    return [RehabGroupCell cellHeightForText:gp.strFullName withDetailText:strDetailText];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SGGroup *gp = [arrGroups objectAtIndex:indexPath.row];
    switch (gp.joinStatus.intValue) {
        case kSGGroupStatusNone:
        {
            MEAlertView *alertView = [[MEAlertView alloc]initWithTitle:@"Thank you" message:[NSString stringWithFormat:@"%@ group is a private group. A request will be generated to group admin for joining group. Would you like to join %@ group?",gp.strFullName,gp.strFullName] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            alertView.tag = indexPath.row;
            [alertView show];

            
        }
            break;
        case kSGGroupStatusAccepted:
        {
            MEAlertView *alertView = [[MEAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"You are already a member of %@ group",gp.strFullName] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alertView show];

            
        }
            break;
        case kSGGroupStatusRequested:
        {
            MEAlertView *alertView = [[MEAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"Your request to %@ group is pending",gp.strFullName] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alertView show];
            
        }
            break;
        case kSGGroupStatusCancel:
        {
            MEAlertView *alertView = [[MEAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"You can not send request to %@ group, You are rejected from this group",gp.strFullName] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alertView show];
            
        }
            break;
            
        default:
            break;
    }

    
    
}
- (void)alertView:(MEAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 5456) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if (buttonIndex == 1) {
        SGGroup *gp = [arrGroups objectAtIndex:alertView.tag];
        [self callApiToJoinForGroup:gp];
        gp.joinStatus = [NSNumber numberWithInteger:kSGGroupStatusRequested];
        [tblView reloadData];
    }
}
#pragma mark - Call Api To Join
- (void)callApiToJoinForGroup:(SGGroup *)gp{
    CommonApiCall *apiCall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"request_to_group") andDelegate:self];
    [apiCall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"groupid":gp.strGroupId,@"userid":[User currentUser].struserId} options:NSJSONWritingPrettyPrinted error:nil] withObject:gp];
    [appDelegate startLoadingview:@"Loading..."];

}

#pragma mark - UISearchBar Delegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)srchBar{
    [srchBar resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)srchBar{
    offset = 0;
    [srchBar resignFirstResponder];
    [self callApiWithText:srchBar.text];
}
- (void)callApiWithText:(NSString*)text{
    CommonApiCall *apicall=[[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"list_rehab_group") andDelegate:self];

    
    [apicall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid":[User currentUser].struserId,@"search":text,@"limit":[NSString stringWithFormat:@"%d",searchLimit],@"offset":[NSString stringWithFormat:@"%d",offset]} options:NSJSONWritingPrettyPrinted error:nil]];
}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo{
    [appDelegate stopLoadingview];

    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"Dict %@",dict);
    if ([requestedURL rangeOfString:@"request_to_group"].location != NSNotFound) {
        if ([[dict objectForKey:@"Type"] isEqualToString:@"OK"]) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Your request is generated to the group admin. You will be notified once it is approved by admin" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alertView.tag = 5456;
            [alertView show];
        }
    }else{
    if ([[dict objectForKey:@"Type"] isEqualToString:@"OK"]) {
        NSArray *arrReceivedGroups = [[dict objectForKey:@"Responce"] objectForKey:@"groups"];
        if (arrReceivedGroups.count < searchLimit) {
            tblView.infiniteScrollingView.enabled = NO;
           // tblView.showsInfiniteScrolling = NO;

        }else{
            tblView.infiniteScrollingView.enabled = YES;
           // tblView.showsInfiniteScrolling = YES;
        }
        if (offset == 0) {
            arrGroups = [[NSMutableArray alloc]init];
        }
        offset = offset + (NSInteger)arrReceivedGroups.count;
        
        
        for (NSDictionary *dictGroup in arrReceivedGroups) {
            SGGroup *grp =[SGGroup groupWithDetails:dictGroup];
            [arrGroups addObject:grp];
        }
        
        [tblView reloadData];
    }else{
        arrGroups = [[NSMutableArray alloc]init];
        [tblView reloadData];

    }
    }
    

}
- (void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    [appDelegate stopLoadingview];
     if ([requestedURL rangeOfString:@"request_to_group"].location != NSNotFound) {
         SGGroup *gp = (SGGroup*)userInfo;
         gp.joinStatus = [NSNumber numberWithInteger:kSGGroupStatusNone];
     }

}
- (void)dealloc{
    [SGGroup deleteUnwantedGroups];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
