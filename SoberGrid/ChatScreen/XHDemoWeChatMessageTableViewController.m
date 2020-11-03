//
//  XHDemoWeChatMessageTableViewController.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-4-27.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#define MESSAGE_TYPE_IMAGE      @"image"
#define MESSAGE_TYPE_TEXT       @"text"
#define MESSAGE_TYPE_VIDEO      @"video"
#define MESSAGE_TYPE_LOCATION   @"location"


#import "XHDemoWeChatMessageTableViewController.h"

#import "XHDisplayTextViewController.h"
#import "XHDisplayMediaViewController.h"
#import "XHDisplayLocationViewController.h"

#import "XHContactDetailTableViewController.h"

#import "XHAudioPlayerHelper.h"
#import "User.h"
#import "NSString+Utilities.h"
#import "XMPPMessage+XMPPMessageHelper.h"
#import "JSON.h"
#import "ApiClass.h"
#import "DatabaseManager.h"
#import "UIImage+Utility.h"
#import "NetworkListioner.h"
#import "UIImage+Resize.h"
#import "ProfileVC.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"


@interface XHDemoWeChatMessageTableViewController () <XHAudioPlayerHelperDelegate,ApiclassDelegate>

@property (nonatomic, strong) NSArray *emotionManagers;

@property (nonatomic, strong) XHMessageTableViewCell *currentSelectedCell;

@end

@implementation XHDemoWeChatMessageTableViewController

- (XHMessage *)getTextMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    XHMessage *textMessage = [[XHMessage alloc] initWithText:@"Call Me 15915895880. Hi man emergency call on this number" sender:@"Haresh" timestamp:[NSDate distantPast]];
    textMessage.avator = [UIImage imageNamed:@"2.jpg"];
    textMessage.avatorUrl = @"http://www.pailixiu.com/jack/meIcon@2x.png";
    textMessage.bubbleMessageType = bubbleMessageType;
    
    return textMessage;
}

- (XHMessage *)getPhotoMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    XHMessage *photoMessage = [[XHMessage alloc] initWithPhoto:[UIImage imageNamed:@"1.jpg"] thumbnailUrl:@"http://d.hiphotos.baidu.com/image/pic/item/30adcbef76094b361721961da1cc7cd98c109d8b.jpg" originPhotoUrl:nil sender:@"Jack" timestamp:[NSDate date]];
    photoMessage.avator = [UIImage imageNamed:@"1.jpg"];
    photoMessage.avatorUrl = @"http://www.pailixiu.com/jack/JieIcon@2x.png";
    photoMessage.bubbleMessageType = bubbleMessageType;
    
    return photoMessage;
}

- (XHMessage *)getVideoMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"IMG_1555.MOV" ofType:@""];
    XHMessage *videoMessage = [[XHMessage alloc] initWithVideoConverPhoto:[XHMessageVideoConverPhotoFactory videoConverPhotoWithVideoPath:videoPath] videoPath:videoPath videoUrl:nil sender:@"Jayson" timestamp:[NSDate date]];
    videoMessage.avator = [UIImage imageNamed:@"3.jpg"];
    videoMessage.avatorUrl = @"http://www.pailixiu.com/jack/JieIcon@2x.png";
    videoMessage.bubbleMessageType = bubbleMessageType;
    
    return videoMessage;
}

- (XHMessage *)getVoiceMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    XHMessage *voiceMessage = [[XHMessage alloc] initWithVoicePath:nil voiceUrl:nil voiceDuration:@"1" sender:@"Jayson" timestamp:[NSDate date]];
    voiceMessage.avator = [UIImage imageNamed:@"avator"];
    voiceMessage.avatorUrl = @"http://www.pailixiu.com/jack/JieIcon@2x.png";
    voiceMessage.bubbleMessageType = bubbleMessageType;
    
    return voiceMessage;
}

- (XHMessage *)getEmotionMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    XHMessage *emotionMessage = [[XHMessage alloc] initWithEmotionPath:[[NSBundle mainBundle] pathForResource:@"emotion1.gif" ofType:nil] sender:@"Jayson" timestamp:[NSDate date]];
    emotionMessage.avator = [UIImage imageNamed:@"Badge.png"];
    emotionMessage.avatorUrl = @"http://www.pailixiu.com/jack/JieIcon@2x.png";
    emotionMessage.bubbleMessageType = bubbleMessageType;
    
    return emotionMessage;
}

- (XHMessage *)getGeolocationsMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    XHMessage *localPositionMessage = [[XHMessage alloc] initWithLocalPositionPhoto:[UIImage imageNamed:@"Fav_Cell_Loc"] geolocations:@"中国广东省广州市天河区东圃二马路121号" location:[[CLLocation alloc] initWithLatitude:23.110387 longitude:72.00] sender:@"Jack" timestamp:[NSDate date]];
    localPositionMessage.avator = [UIImage imageNamed:@"burning_fire.png"];
    localPositionMessage.avatorUrl = @"http://www.pailixiu.com/jack/meIcon@2x.png";
    localPositionMessage.bubbleMessageType = bubbleMessageType;
    
    return localPositionMessage;
}

- (NSMutableArray *)getTestMessages {
    NSMutableArray *messages = [[NSMutableArray alloc] init];
   // [[SGXMPP sharedInstance] fetchHistoryProgramatically];
    [[SGXMPP sharedInstance] fetchHistoryWithUserId:_otherSideUser.struserId withLimit:0 ascending:true  withCompletionHandler:^(NSArray *arrHistory) {
        @autoreleasepool {
            for (XMPPMessageArchiving_Message_CoreDataObject *message in arrHistory) {
                if ([message.message isMessageWithBody]) {
                    if ([message.message sendertype] == 0) {
                        if ([[message.message sendedTo] isEqualToString:[_otherSideUser.struserId userIdAddedSoberGrid]]) {
                        [messages addObject:[message.message messagefromUser:[User currentUser] atDate:message.timestamp]];
                        }
                    }
                    else
                    {
                        if ([[message.message sendedTo] isEqualToString:[[User currentUser].struserId userIdAddedSoberGrid]])
                        {
                            [messages addObject:[message.message messagefromUser:_otherSideUser atDate:message.timestamp]];
                        }
                        }
                    
                    }
                }
            }
        }

    ];

    
    // THIS WAS ONLY FOR TESTING
//    for (NSInteger i = 0; i < 2; i ++) {
//        [messages addObject:[self getPhotoMessageWithBubbleMessageType:(i % 5) ? XHBubbleMessageTypeSending : XHBubbleMessageTypeReceiving]];
//        
//        [messages addObject:[self getVideoMessageWithBubbleMessageType:(i % 6) ? XHBubbleMessageTypeSending : XHBubbleMessageTypeReceiving]];
//        
//        [messages addObject:[self getVoiceMessageWithBubbleMessageType:(i % 4) ? XHBubbleMessageTypeSending : XHBubbleMessageTypeReceiving]];
//        
//        [messages addObject:[self getEmotionMessageWithBubbleMessageType:(i % 2) ? XHBubbleMessageTypeSending : XHBubbleMessageTypeReceiving]];
//        
//        [messages addObject:[self getGeolocationsMessageWithBubbleMessageType:(i % 7) ? XHBubbleMessageTypeSending : XHBubbleMessageTypeReceiving]];
//        
//        [messages addObject:[self getTextMessageWithBubbleMessageType:(i % 2) ? XHBubbleMessageTypeSending : XHBubbleMessageTypeReceiving]];
//    }
    return messages;
}

- (void)loadDemoDataSource {
    WEAKSELF
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *messages = [weakSelf getTestMessages];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.messages = messages;
            [weakSelf.messageTableView reloadData];
            [weakSelf scrollToBottomAnimated:NO];
        });
    });
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_otherSideUser.isBlocked) {
        self.messageInputView.hidden = true;
        
    }
    
    [SGXMPP sharedInstance].delegate = self;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[XHAudioPlayerHelper shareInstance] stopAudio];
    [SGXMPP sharedInstance].delegate = nil;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Localytics tagEvent:LLUserInChatScreen];
    [SGXMPP sharedInstance].otherUser = _otherSideUser;
    // Do any additional setup after loading the view.
   // self.title = NSLocalizedString(@"Chat", nil);
    self.title = _otherSideUser.strName;
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear Chat" style:UIBarButtonItemStylePlain target:self action:@selector(actionButtonPressed:)];
 //   self.navigationItem.rightBarButtonItem = anotherButton;
    
    [[SGXMPP sharedInstance] allMessagesReadForUserid:_otherSideUser.struserId];
   
    // Custom UI
    [self setBackgroundColor:SG_BACKGROUD_COLOR];
//    [self setBackgroundImage:[UIImage imageNamed:@"TableViewBackgroundImage"]];
    
    // 设置自身用户名
    self.messageSender = [User currentUser].strName;
    
    // 添加第三方接入数据
    NSMutableArray *shareMenuItems = [NSMutableArray array];
    NSArray *plugIcons = @[@"send_photo", @"pictures", @"photos", @"location",@"saved_phrases"];
//    //NSArray *plugTitle = @[@"Photos", @"Shooting", @"Location", @"Business Card" ];
    for (NSString *plugIcon in plugIcons) {
        XHShareMenuItem *shareMenuItem = [[XHShareMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:plugIcon] title:nil];
        [shareMenuItems addObject:shareMenuItem];
    }
//
//    NSMutableArray *emotionManagers = [NSMutableArray array];
//    for (NSInteger i = 0; i < 10; i ++) {
//        XHEmotionManager *emotionManager = [[XHEmotionManager alloc] init];
//        emotionManager.emotionName = [NSString stringWithFormat:@"表情%ld", (long)i];
//        NSMutableArray *emotions = [NSMutableArray array];
//        for (NSInteger j = 0; j < 18; j ++) {
//            XHEmotion *emotion = [[XHEmotion alloc] init];
//            NSString *imageName = [NSString stringWithFormat:@"section%ld_emotion%ld", (long)i , (long)j % 16];
//            emotion.emotionPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"emotion%ld.gif", (long)j] ofType:@""];
//            emotion.emotionConverPhoto = [UIImage imageNamed:imageName];
//            [emotions addObject:emotion];
//        }
//        emotionManager.emotions = emotions;
//        
//        [emotionManagers addObject:emotionManager];
//    }
//    
//    self.emotionManagers = emotionManagers;
//    [self.emotionManagerView reloadData];
//    
    self.shareMenuItems = shareMenuItems;
    [self.shareMenuView reloadData];
    
    [self loadDemoDataSource];
    if (_otherSideUser.isBlocked) {
        self.messageInputView.hidden = true;

    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.emotionManagers = nil;
    [[XHAudioPlayerHelper shareInstance] setDelegate:nil];
}

/*
 [self removeMessageAtIndexPath:indexPath];
 [self insertOldMessages:self.messages];
 */

#pragma mark - XHMessageTableViewCell delegate

- (void)multiMediaMessageDidSelectedOnMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath onMessageTableViewCell:(XHMessageTableViewCell *)messageTableViewCell {
    if(self.photoesController || self.topViewController){
        NSLog(@"Photoescontroller is there no need to push");
        return;
    }
    UIViewController *disPlayViewController;
    switch (message.messageMediaType) {
        case XHBubbleMessageMediaTypeVideo:
        case XHBubbleMessageMediaTypePhoto: {
            DLog(@"message : %@", message.photo);
            DLog(@"message : %@", message.videoConverPhoto);
            XHDisplayMediaViewController *messageDisplayTextView = [[XHDisplayMediaViewController alloc] init];
            messageDisplayTextView.message = message;
            disPlayViewController = messageDisplayTextView;
            break;
        }
            break;
        case XHBubbleMessageMediaTypeVoice: {
            DLog(@"message : %@", message.voicePath);
           // [[XHAudioPlayerHelper shareInstance] setDelegate:self];
            if (_currentSelectedCell) {
                [_currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
            }
            if (_currentSelectedCell == messageTableViewCell) {
                [messageTableViewCell.messageBubbleView.animationVoiceImageView stopAnimating];
                [[XHAudioPlayerHelper shareInstance] stopAudio];
                self.currentSelectedCell = nil;
            } else {
                self.currentSelectedCell = messageTableViewCell;
                [messageTableViewCell.messageBubbleView.animationVoiceImageView startAnimating];
                [[XHAudioPlayerHelper shareInstance] managerAudioWithFileName:message.voicePath toPlay:YES];
            }
            break;
        }
        case XHBubbleMessageMediaTypeEmotion:
            DLog(@"facePath : %@", message.emotionPath);
            break;
        case XHBubbleMessageMediaTypeLocalPosition: {
            DLog(@"facePath : %@", message.localPositionPhoto);
            XHDisplayLocationViewController *displayLocationViewController = [[XHDisplayLocationViewController alloc] init];
            displayLocationViewController.message = message;
            disPlayViewController = displayLocationViewController;
            break;
        }
        default:
            break;
    }
    if (disPlayViewController) {
        [self.navigationController pushViewController:disPlayViewController animated:YES];
    }
}

- (void)didDoubleSelectedOnTextMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
    DLog(@"text : %@", message.text);
    XHDisplayTextViewController *displayTextViewController = [[XHDisplayTextViewController alloc] init];
    displayTextViewController.message = message;
    [self.navigationController pushViewController:displayTextViewController animated:YES];
}

- (void)didSelectedAvatorOnMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
    DLog(@"indexPath : %@", indexPath);
    if (_otherSideUser.isBlocked) {
        return;
    }
    if ([[message sender] isEqualToString:_otherSideUser.struserId]) {
        for (UIViewController *viewControllers in self.navigationController.viewControllers) {
            if ([viewControllers isKindOfClass:[ProfileVC class]]) {
                [self.navigationController popToViewController:viewControllers animated:YES];
                return;
            }
        }
        ProfileVC *profileVC=[SGstoryBoard() instantiateViewControllerWithIdentifier:@"ProfileVC"];
        // profileVC.pUser = [User currentUser];
        [profileVC setUsers:[@[_otherSideUser]mutableCopy] withShowIndex:0];
         SGNavigationController *temNc=(SGNavigationController*)self.sidePanelController.centerPanel;
        [temNc pushViewController:profileVC animated:YES];
        

    }
    
//    XHContact *contact = [[XHContact alloc] init];
//    contact.contactName = [message sender];
//    contact.contactIntroduction = @"Custom describe this need and business logic hooks";
//    XHContactDetailTableViewController *contactDetailTableViewController = [[XHContactDetailTableViewController alloc] initWithContact:contact];
//    [self.navigationController pushViewController:contactDetailTableViewController animated:YES];
}

- (void)menuDidSelectedAtBubbleMessageMenuSelecteType:(XHBubbleMessageMenuSelecteType)bubbleMessageMenuSelecteType {
    
}

#pragma mark - XHAudioPlayerHelper Delegate

- (void)didAudioPlayerStopPlay:(AVAudioPlayer *)audioPlayer {
    if (!_currentSelectedCell) {
        return;
    }
    [_currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
    self.currentSelectedCell = nil;
}

#pragma mark - XHEmotionManagerView DataSource

- (NSInteger)numberOfEmotionManagers {
    return self.emotionManagers.count;
}

- (XHEmotionManager *)emotionManagerForColumn:(NSInteger)column {
    return [self.emotionManagers objectAtIndex:column];
}

- (NSArray *)emotionManagersAtManager {
    return self.emotionManagers;
}

#pragma mark - XHMessageTableViewController Delegate

- (BOOL)shouldLoadMoreMessagesScrollToTop {
    return YES;
}

- (void)loadMoreMessagesScrollTotop {
//    if (!self.loadingMoreMessage) {
//        self.loadingMoreMessage = YES;
//        
//        WEAKSELF
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            NSMutableArray *messages = [weakSelf getTestMessages];
//            sleep(2);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakSelf insertOldMessages:messages];
//                weakSelf.loadingMoreMessage = NO;
//            });
//        });
//    }
}

/**
 *  发送文本消息的回调方法
 *
 *  @param text   目标文本字符串
 *  @param sender 发送者的名字
 *  @param date   发送时间
 */
- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    if (text.length == 0 || ![[NetworkListioner listner] isInternetAvailable]) {
        return;
    }
    
 
    //[self sendPushtoUserid:@"93" andName:_otherSideUser.strName];
    NSDictionary *dictText=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)XHBubbleMessageMediaTypeText],@"type",text,@"message",[User currentUser].strName,@"sender",_otherSideUser.strName,@"to", nil];
    NSString *jsonString = [dictText JSONRepresentation];
    
    
    
    [[SGXMPP sharedInstance] sendMessage:_otherSideUser.struserId Groupname:nil Message:jsonString isPhoto:false photo:nil];
    
    XHMessage *textMessage = [[XHMessage alloc] initWithText:text sender:[User currentUser].struserId timestamp:date];
    textMessage.avator = [UIImage imageNamed:@"avator"];
    if([User currentUser].strProfilePicThumb.length>0){
        textMessage.avatorUrl = [User currentUser].strProfilePicThumb;
    }
    [self addMessage:textMessage];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText];
}
- (void)didReceiveMessage:(XMPPMessage *)message From:(NSString *)user ofType:(int)type{
    if (type == 0) {
        [self addMessage:[message messagefromUser:[User currentUser] atDate:[NSDate date]]];
    }else{
        [self addMessage:[message messagefromUser:_otherSideUser atDate:[NSDate date]]];
    }
}

/**
 *  发送图片消息的回调方法
 *
 *  @param photo  目标图片对象，后续有可能会换
 *  @param sender 发送者的名字
 *  @param date   发送时间
 */
- (void)didSendPhoto:(UIImage *)photo fromSender:(NSString *)sender onDate:(NSDate *)date fromSentList:(BOOL)status{
    if (![[NetworkListioner listner] isInternetAvailable]) {
        return;
    }
    
   
    if (!status) {
        [photo saveToTempDirectoryofType:true withName:nil];
    }
   
    XHMessage *photoMessage = [[XHMessage alloc] initWithPhoto:photo thumbnailUrl:nil originPhotoUrl:nil sender:[User currentUser].struserId timestamp:date];
    photoMessage.avator = [UIImage imageNamed:@"avator"];
    if([User currentUser].strProfilePicThumb.length > 0){
        photoMessage.avatorUrl = [User currentUser].strProfilePicThumb;
    }
    [self addMessage:photoMessage];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypePhoto];
    [[SGXMPP sharedInstance]sendMessage:nil Groupname:nil Message:nil isPhoto:YES photo:photo];

}

/**
 *  发送视频消息的回调方法
 *
 *  @param videoPath 目标视频本地路径
 *  @param sender    发送者的名字
 *  @param date      发送时间
 */
- (void)didSendVideoConverPhoto:(UIImage *)videoConverPhoto videoPath:(NSString *)videoPath fromSender:(NSString *)sender onDate:(NSDate *)date {
    XHMessage *videoMessage = [[XHMessage alloc] initWithVideoConverPhoto:videoConverPhoto videoPath:videoPath videoUrl:nil sender:sender timestamp:date];
    videoMessage.avator = [UIImage imageNamed:@"avator"];
    videoMessage.avatorUrl = @"http://www.pailixiu.com/jack/meIcon@2x.png";
    [self addMessage:videoMessage];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeVideo];
}

/**
 *  发送语音消息的回调方法
 *
 *  @param voicePath        目标语音本地路径
 *  @param voiceDuration    目标语音时长
 *  @param sender           发送者的名字
 *  @param date             发送时间
 */
- (void)didSendVoice:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration fromSender:(NSString *)sender onDate:(NSDate *)date {
    XHMessage *voiceMessage = [[XHMessage alloc] initWithVoicePath:voicePath voiceUrl:nil voiceDuration:voiceDuration sender:sender timestamp:date];
    voiceMessage.avator = [UIImage imageNamed:@"avator"];
    voiceMessage.avatorUrl = @"http://www.pailixiu.com/jack/meIcon@2x.png";
    [self addMessage:voiceMessage];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeVoice];
}

/**
 *  发送第三方表情消息的回调方法
 *
 *  @param facePath 目标第三方表情的本地路径
 *  @param sender   发送者的名字
 *  @param date     发送时间
 */
- (void)didSendEmotion:(NSString *)emotionPath fromSender:(NSString *)sender onDate:(NSDate *)date {
    XHMessage *emotionMessage = [[XHMessage alloc] initWithEmotionPath:emotionPath sender:sender timestamp:date];
    emotionMessage.avator = [UIImage imageNamed:@"avator"];
    emotionMessage.avatorUrl = @"http://www.pailixiu.com/jack/meIcon@2x.png";
    [self addMessage:emotionMessage];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeEmotion];
}

/**
 *  有些网友说需要发送地理位置，这个我暂时放一放
 */
- (void)didSendGeoLocationsPhoto:(UIImage *)geoLocationsPhoto geolocations:(NSString *)geolocations location:(CLLocation *)location fromSender:(NSString *)sender onDate:(NSDate *)date {
    if (![[NetworkListioner listner] isInternetAvailable]) {
        return;
    }
    NSDictionary *dictLocation=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)XHBubbleMessageMediaTypeLocalPosition],@"type",@{@"latitude": [NSNumber numberWithFloat:location.coordinate.latitude],@"longitude":[NSNumber numberWithFloat:location.coordinate.longitude]},@"message",[User currentUser].strName,@"sender",_otherSideUser.strName,@"to", nil];
    NSString *jsonString = [dictLocation JSONRepresentation];
    [[SGXMPP sharedInstance] sendMessage:_otherSideUser.struserId Groupname:nil Message:jsonString isPhoto:false photo:nil];

    XHMessage *geoLocationsMessage = [[XHMessage alloc] initWithLocalPositionPhoto:geoLocationsPhoto geolocations:nil location:location sender:[User currentUser].struserId timestamp:date];
    geoLocationsMessage.avator = [UIImage imageNamed:@"avator"];
    if([User currentUser].strProfilePicThumb.length > 0){
        geoLocationsMessage.avatorUrl = [User currentUser].strProfilePicThumb ;
    }
    [self addMessage:geoLocationsMessage];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeLocalPosition];
}
- (void)didSendSavedPhrase:(NSString *)phrase fromSender:(NSString *)sender onDate:(NSDate *)date{
    if (![[NetworkListioner listner] isInternetAvailable]) {
        return;
    }
    
    NSDictionary *dictText=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)XHBubbleMessageMediaTypeText],@"type",phrase,@"message",[User currentUser].strName,@"sender",_otherSideUser.strName,@"to", nil];
    NSString *jsonString = [dictText JSONRepresentation];
    
    [[SGXMPP sharedInstance] sendMessage:_otherSideUser.struserId Groupname:nil Message:jsonString isPhoto:false photo:nil];
    
    XHMessage *textMessage = [[XHMessage alloc] initWithText:phrase sender:[User currentUser].struserId timestamp:date];
    textMessage.avator = [UIImage imageNamed:@"avator"];
    if([User currentUser].strProfilePicThumb.length > 0){
        textMessage.avatorUrl = [User currentUser].strProfilePicThumb ;
    }
    [self addMessage:textMessage];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText];
}

/**
 *  是否显示时间轴Label的回调方法
 *
 *  @param indexPath 目标消息的位置IndexPath
 *
 *  @return 根据indexPath获取消息的Model的对象，从而判断返回YES or NO来控制是否显示时间轴Label
 */
- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2)
        return YES;
    else
        return NO;
}

/**
 *  配置Cell的样式或者字体
 *
 *  @param cell      目标Cell
 *  @param indexPath 目标Cell所在位置IndexPath
 */
- (void)configureCell:(XHMessageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

}

/**
 *  协议回掉是否支持用户手动滚动
 *
 *  @return 返回YES or NO
 */
- (BOOL)shouldPreventScrollToBottomWhileUserScrolling {
    return YES;
}

- (void)returnData:(id)data forUrl:(NSURL *)url withTag:(int)tag{
    
    if ([url.absoluteString rangeOfString:@"chat_img"].location != NSNotFound){
                         NSDictionary *dictUser=(NSDictionary*)data;
                        NSLog(@"dictuser ---> %@",dictUser);
                         if ([[dictUser objectForKey:@"Type"] isEqualToString:@"OK"]) {
                             NSDictionary *dictPhoto=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)XHBubbleMessageMediaTypePhoto],@"type",[[dictUser objectForKey:@"Responce"]    objectForKey:@"picture_url"],@"message",[User currentUser].strName,@"sender",_otherSideUser.strName,@"to", nil];
                             NSString *jsonString = [dictPhoto JSONRepresentation];
                             [[SGXMPP sharedInstance] sendMessage:_otherSideUser.struserId Groupname:nil Message:jsonString isPhoto:false photo:nil];
        
                            }else{
                             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[dictUser objectForKey:@"Error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                             [alert show];
                         }
                }
    if ([url.absoluteString rangeOfString:@"send_push_notification"].location != NSNotFound) {
        
    }
}
- (void)failedData:(NSError *)error forUrl:(NSURL *)url withTag:(int)tag{
    if ([url.absoluteString rangeOfString:@"chat_img"].location != NSNotFound){
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    }


}


@end
