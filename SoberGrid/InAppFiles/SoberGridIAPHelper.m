//
//  SoberGridIAPHelper.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/27/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import "SoberGridIAPHelper.h"
#import "User.h"

@implementation SoberGridIAPHelper
+ (SoberGridIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static SoberGridIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      kSoberGridBadgeIdentifier,
                                      kSoberGrid1MonthIdentifier,
                                      kSoberGrid3MonthIdentifier,
                                      kSoberGrid12MonthIdentifier,
                                      nil];
//        NSSet * productIdentifiers = [NSSet setWithObjects:
//                                      kSoberGridBadgeIdentifier,
//                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
        
    });
    return sharedInstance;
}
- (void)fetchProducts{
    [self requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        _products = products;
    }];
}
- (void)buyBadge{
    for (SKProduct * product in _products) {
        if ([product.productIdentifier isEqualToString:kSoberGridBadgeIdentifier]) {
            [self buyProduct:product];
            return;

        }
    }

}
- (void)buy1MonthPack{
    for (SKProduct * product in _products) {
        if ([product.productIdentifier isEqualToString:kSoberGrid1MonthIdentifier]) {
            [self buyProduct:product];
            return;
            
        }
    }
    
}
- (void)buy3MonthPack{
    for (SKProduct * product in _products) {
        if ([product.productIdentifier isEqualToString:kSoberGrid3MonthIdentifier]) {
            [self buyProduct:product];
            return;
            
        }
    }
    
}
- (void)buy12MonthPack{
    for (SKProduct * product in _products) {
        if ([product.productIdentifier isEqualToString:kSoberGrid12MonthIdentifier]) {
            [self buyProduct:product];
            return;
            
        }
    }
    
}
- (void)showAlertForActivatePack{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Please be a support member to use this feature", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MOVETOMEMBEROPTION object:nil];
    }
}
@end
