//
//  ContactUsViewController.m
//  SoberGrid
//
//  Created by agilepc-159 on 11/22/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

typedef enum {
    kContactUsTypeSober=0,
    kContactUsTypeFacebook,
    kContactUsTypeTwitter,
    kContactUsTypeLinkdin,
    kContactUsTypeInstagram,
    kContactUsTypePrivacyPolicy,
    kContactUsTypeTermsofUse,
    kContactUsTypeWebsite,
}kContactUsType;

static NSString *const kContactUsCellIdentifier = @"contactUsCell";
#import "ContactUsViewController.h"
#import "WebViewController.h"
#import "AppMailComposerViewController.h"
#import <MessageUI/MessageUI.h>

@interface ContactUsViewController ()<UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate>{
    UITableView *tblView;
}

@end

@implementation ContactUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Localytics tagEvent:LLUserInContactUsScreen];
    self.title = NSLocalizedString(@"Contact Us", nil);
    [self createTable];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}
- (void)createTable{
    tblView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tblView.dataSource = self;
    tblView.delegate   = self;
    [self.view addSubview:tblView];
}
#pragma mark - UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 8;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kContactUsCellIdentifier];
    if (cell ==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kContactUsCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = SGREGULARFONT(17.0);
    }
    switch (indexPath.row) {
        case kContactUsTypeSober:
            cell.textLabel.text = NSLocalizedString(@"Reach out to us at contact@sobergrid.com", nil);
            break;
        case kContactUsTypeFacebook:
            cell.textLabel.text = NSLocalizedString(@"Like us on Facebook", nil);
            break;
        case kContactUsTypeTwitter:
            cell.textLabel.text = NSLocalizedString(@"Follow us on Twitter", nil);

            break;
        case kContactUsTypeLinkdin:
            cell.textLabel.text = NSLocalizedString(@"Connect with us on LinkedIn", nil);

            break;
        case kContactUsTypeInstagram:
            cell.textLabel.text = NSLocalizedString(@"Follow us on Instagram", nil);
            break;
        case kContactUsTypePrivacyPolicy:
            cell.textLabel.text = NSLocalizedString(@"Privacy Policy", nil);

            break;
        case kContactUsTypeTermsofUse:
            cell.textLabel.text = NSLocalizedString(@"Terms of Use", nil);

            break;
            
        case kContactUsTypeWebsite:
            cell.textLabel.text = NSLocalizedString(@"Check us out on our website - www.sobergridapp.com", nil);
            break;
            
        default:
            break;
    }
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *strUrl;
    switch (indexPath.row) {
        case kContactUsTypeSober:
            [AppMailComposerViewController showMailComposerInController:self withEmailSubject:nil withMessageBody:nil withReciepts:@[@"contact@sobergrid.com"] withCompletionBlock:^(MFMailComposeResult MFMailComposeResult) {
                switch (MFMailComposeResult)
                {
                    case MFMailComposeResultCancelled:
                        break;
                    case MFMailComposeResultSaved:
                        break;
                    case MFMailComposeResultSent:
                        break;
                    case MFMailComposeResultFailed:
                        break;
                    default:
                        break;
                }
            }];
            return;
            break;
            
        case kContactUsTypeFacebook:
            strUrl = @"https://www.facebook.com/sobergrid";
            break;
            
        case kContactUsTypeTwitter:
            strUrl = @"https://twitter.com/SoberGridApp";
            break;
            
        case kContactUsTypeLinkdin:
            strUrl = @"https://www.linkedin.com/company/5388181?trk=tyah&trkInfo=tarId%3A1416636353697%2Ctas%3Asober%20grid%2Cidx%3A2-1-5";
            break;
            
        case kContactUsTypeInstagram:
            strUrl = @"http://instagram.com/sobergrid";
            break;
            
        case kContactUsTypeWebsite:
            strUrl = @"http://www.sobergridapp.com";
            break;
        case kContactUsTypePrivacyPolicy:
            strUrl = @"http://www.sobergridapp.com/#!privacy/cudd";
            break;
        case kContactUsTypeTermsofUse:
            strUrl = @"http://www.sobergridapp.com/#!terms-of-use/c5dv";
            break;
            
        default:
            break;
    }
    WebViewController *webVC = [[WebViewController alloc]init];
    webVC.webViewType = kWebViewTypeGeneral;
  
    [self.navigationController pushViewController:webVC animated:YES];
    [webVC setUrl:[NSURL URLWithString:strUrl]];


}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    tblView = nil;
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
