//
//  IAPHelper.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/27/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);
UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
UIKIT_EXTERN NSString *const kSubscriptionExpirationDateKey;


@interface IAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;
- (void)setTypeOfSubscription:(int)subscription;
- (int)getTypeOfSubsciption;


- (void)updatePremiumToServer;
- (void)updateBadgePurchaseToServer;
- (void)checkIfSubscriptionExpired;
@end

