//
//  XMPPMessage+XMPPMessageHelper.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/25/14.
//  Copyright (c) 2014 William Santiago All rights reserved.
//

#import "XMPPMessage+XMPPMessageHelper.h"
#import "XMPPRoom.h"
#import "UIImage+Utility.h"
#import "NSString+Utilities.h"
#import "XHMessage.h"
#import "SDWebImageManager.h"
#import "JSON.h"
@implementation XMPPMessage (XMPPMessageHelper)
- (NSString*)getmessage{
    NSString *msg =[NSString stringWithFormat:@"%@",[[self elementForName:@"body"] stringValue]];
    if([msg isEqualToString:@"This room is locked from entry until configuration is confirmed."] || [msg isEqualToString:@"This room is not anonymous."] || [msg isEqualToString:@"This room is now unlocked."])
    {
        
        return nil;
    }
    return msg;
}
- (NSString*)sender{
    NSString *from = [[self attributeForName:@"from"] stringValue];
    NSArray *arrayName = [from componentsSeparatedByString:@"/"];
    from = [NSString stringWithFormat:@"%@",[arrayName objectAtIndex:0]];
    from = [from stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"@%@", XMPPDomain()] withString:@""];
    return from;
  
}
- (NSString*)sendedTo{
    NSString *sendedto =[self.to.bare stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"@%@", XMPPDomain()] withString:@""];
    return sendedto;
}
- (int)sendertype{
    return ([[self sender] isEqualToString:[[User currentUser].struserId userIdAddedSoberGrid]]) ? 0 :1;
}
- (id)messagefromUser:(User*)sender atDate:(NSDate*)timeStamp{
    NSDictionary *dictMessage =(NSDictionary*) [[self getmessage] JSONValue];
    if (dictMessage) {
        // FOR TEXT MESSAGE
        if ([[dictMessage objectForKey:@"type"] intValue] == XHBubbleMessageMediaTypeText) {
            XHMessage *textMessage = [[XHMessage alloc] initWithText:[dictMessage objectForKey:@"message"] sender:sender.struserId timestamp:timeStamp];
            textMessage.avator = [UIImage imageNamed:@"avator"];
            
            if(sender.strProfilePicThumb.length > 0){
                textMessage.avatorUrl = sender.strProfilePicThumb ;
            }
            textMessage.bubbleMessageType = [self sendertype];
            return textMessage;
        }
        // FOR PHOTO MESSAGE
        else if ([[dictMessage objectForKey:@"type"] intValue] == XHBubbleMessageMediaTypePhoto){
           
            XHMessage *photoMessage;
            NSString *strJson = [dictMessage objectForKey:@"message"];
            NSDictionary *dictTemp = [strJson JSONValue];
            if (dictTemp) {
                photoMessage = [[XHMessage alloc] initWithPhoto:nil thumbnailUrl:[dictTemp objectForKey:@"thumburl_url"] originPhotoUrl:[dictTemp objectForKey:@"picture_url"] sender:sender.struserId timestamp:timeStamp];
            }else{
                photoMessage = [[XHMessage alloc] initWithPhoto:nil thumbnailUrl:[dictMessage objectForKey:@"message"] originPhotoUrl:[dictMessage objectForKey:@"message"] sender:sender.struserId timestamp:timeStamp];
            }
            
            photoMessage.avator = [UIImage imageNamed:@"avator"];
            if(sender.strProfilePicThumb.length > 0){
                photoMessage.avatorUrl = sender.strProfilePicThumb ;
            }
            photoMessage.bubbleMessageType = [self sendertype];
            return photoMessage;
            
        }
        // FOR VIDEO MESSAGE
        else if([[dictMessage objectForKey:@"type"] intValue] == XHBubbleMessageMediaTypeVideo){
            
        }
        // FOR VOICE MESSAGE
        else if([[dictMessage objectForKey:@"type"] intValue] == XHBubbleMessageMediaTypeVoice){
            
        }
        // FOR LOCATION MESSAGE
        else if([[dictMessage objectForKey:@"type"] intValue] == XHBubbleMessageMediaTypeLocalPosition){
            
            CLLocation *location = [[CLLocation alloc]initWithLatitude:[[[dictMessage objectForKey:@"message"]objectForKey:@"latitude"] floatValue] longitude:[[[dictMessage objectForKey:@"message"]objectForKey:@"longitude"] floatValue]];
            XHMessage *geoLocationsMessage = [[XHMessage alloc] initWithLocalPositionPhoto:[UIImage imageNamed:@"Fav_Cell_Loc"] geolocations:nil location:location sender:sender.struserId timestamp:timeStamp];
            geoLocationsMessage.avator = [UIImage imageNamed:@"avator"];
            if(sender.strProfilePicThumb.length > 0){
                geoLocationsMessage.avatorUrl = sender.strProfilePicThumb;
            }
            geoLocationsMessage.bubbleMessageType = [self sendertype];
            return geoLocationsMessage;

        }
        // FOR EMOTIONS MESSAGE
        else if([[dictMessage objectForKey:@"type"] intValue] == XHBubbleMessageMediaTypeEmotion){
            
        }else
            return nil;

    }else{
        XHMessage *textMessage = [[XHMessage alloc] initWithText:[self getmessage] sender:sender.struserId timestamp:timeStamp];
        textMessage.avator = [UIImage imageNamed:@"avator"];
        
        if(sender.strProfilePicThumb.length > 0){
            textMessage.avatorUrl = sender.strProfilePicThumb;
        }
        textMessage.bubbleMessageType = [self sendertype];
        return textMessage;

    }
        return nil;
    
}
- (NSString*)getMessageFormattedString{
    NSDictionary *dictMessage = [[self getmessage] JSONValue];
    if ([dictMessage[@"type"] intValue] == XHBubbleMessageMediaTypeText) {
        return dictMessage[@"message"];
    }else if ([dictMessage[@"type"] intValue] == XHBubbleMessageMediaTypeEmotion){
        return @"Sent you a sticker";
    }else if ([dictMessage[@"type"] intValue] == XHBubbleMessageMediaTypeLocalPosition){
        return @"Shared location with you";
    }else if ([dictMessage[@"type"] intValue] == XHBubbleMessageMediaTypePhoto){
        return @"Sent you a photo";
    }else if ([dictMessage[@"type"] intValue] == XHBubbleMessageMediaTypeVideo){
        return @"Sent you a video";
    }else{
        return @"Sent you an audio";
    }
    
}
@end
