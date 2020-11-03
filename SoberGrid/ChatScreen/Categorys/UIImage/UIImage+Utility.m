//
//  UIImage+Utility.m
//  XHImageViewer
//
//  Created by 曾 宪华 on 14-2-18.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "UIImage+Utility.h"
#import "User.h"
#import <AVFoundation/AVFoundation.h>

@implementation UIImage (Utility)

+ (UIImage *)decode:(UIImage *)image {
    if(image == nil) {
        return nil;
    }
    
    UIGraphicsBeginImageContext(image.size);
    
    {
        [image drawAtPoint:CGPointMake(0, 0)];
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)fastImageWithData:(NSData *)data {
    UIImage *image = [UIImage imageWithData:data];
    return [self decode:image];
}

+ (UIImage *)fastImageWithContentsOfFile:(NSString *)path {
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    return [self decode:image];
}
- (UIImage*) rotate {
    
    UIImageOrientation orientation = self.imageOrientation;
    
    UIGraphicsBeginImageContext(self.size);
    
    [self drawAtPoint:CGPointMake(0, 0)];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, [self radians:90]);
    } else if (orientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, [self radians:90]);
    } else if (orientation == UIImageOrientationDown) {
        // NOTHING
    } else if (orientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, [self radians:0]);
    }
    
    return UIGraphicsGetImageFromCurrentImageContext();
}
- (CGFloat) radians:(int)degrees {
    return (degrees/180)*(22/7);
}
- (void)saveToTempDirectoryofType:(BOOL)type withName:(NSString*)name{
   // NSString *strTempDirectoryPath = NSTemporaryDirectory();
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *strTempDirectoryPath = [paths objectAtIndex:0];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    //        int timestamp = timeInterval;
    NSNumber *timestamp = [NSNumber numberWithInt:timeInterval];
    NSString *sentImagePath =[NSString stringWithFormat:@"%@_sent_%@.png",timestamp,[User currentUser].struserId];
    NSString *recivedImagePath ;
    if (name) {
        name = [name stringByReplacingOccurrencesOfString:@".jpg" withString:@""];
        name = [name stringByReplacingOccurrencesOfString:@".png" withString:@""];
       recivedImagePath = [NSString stringWithFormat:@"%@_rec_%@.png",name,[User currentUser].struserId];
    }
    
    NSData *imageData = UIImagePNGRepresentation(self);
    

    strTempDirectoryPath = [strTempDirectoryPath stringByAppendingPathComponent:(type) ? sentImagePath : recivedImagePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:strTempDirectoryPath]) {
        [imageData writeToFile:strTempDirectoryPath atomically:YES];
    }
}
+ (UIImage *)thumbnailImageFromVideoUrl:(NSURL*)videourl{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videourl options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generate.appliesPreferredTrackTransform = true;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    UIImage *thumbnail = [UIImage imageWithCGImage:imgRef];
    return thumbnail;
}

@end
