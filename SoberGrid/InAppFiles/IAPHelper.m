//
//  IAPHelper.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 10/27/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#define kKeyForDate @"lastSeenDate"

#import "IAPHelper.h"
#import "CommonApiCall.h"
#import "User.h"
#import "NSDate+Utilities.h"

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

NSString *const kSubscriptionExpirationDateKey = @"ExpirationDate";
@interface IAPHelper () <SKProductsRequestDelegate,SKPaymentTransactionObserver,CommonApiCallDelegate>
@end

@implementation IAPHelper
{
    // 3
    SKProductsRequest * _productsRequest;
    // 4
    RequestProductsCompletionHandler _completionHandler;
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
            }
        }
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    // 1
    _completionHandler = [completionHandler copy];
    
    // 2
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    
    [appDelegate startLoadingview:@"Purchasing..."];
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [appDelegate stopLoadingview];
    //NSLog(@"\n\n In APPPUrchase Complete Transcation %@",transaction.payment.productIdentifier);
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    [appDelegate stopLoadingview];
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
    
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}
- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    
    [_purchasedProductIdentifiers addObject:productIdentifier];
    if ([productIdentifier isEqualToString:kSoberGridBadgeIdentifier]) {
        [User currentUser].isBadgePurchased =true;
        [self updateBadgePurchaseToServer:productIdentifier];
        [[User currentUser] updateGoldBadge:true];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GOLDBADGE_PURCHASED object:nil];
        return;
    }
    if ([productIdentifier isEqualToString:kSoberGrid1MonthIdentifier]) {
        [self setTypeOfSubscription:kSGSubscriptionType1Month];
    }
    if ([productIdentifier isEqualToString:kSoberGrid3MonthIdentifier]) {

        [self setTypeOfSubscription:kSGSubscriptionType3Month];
    }
    if ([productIdentifier isEqualToString:kSoberGrid12MonthIdentifier]) {
        [self setTypeOfSubscription:kSGSubscriptionType12Month];
    }
    //NSLog(@"\n\n\n InAPP Purchase provideContentForProductIdentifier %d",[self getTypeOfSubsciption]);
    
    [[User currentUser] upatePremiumwithType:[self getTypeOfSubsciption]];
    [self updatePremiumToServer];
    
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


- (void)setTypeOfSubscription:(int)subscription
{
    [[NSUserDefaults standardUserDefaults] setInteger:subscription forKey:SGSubscriptionPack];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
- (int)getTypeOfSubsciption{
    
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:SGSubscriptionPack];
}
- (void)updatePremiumToServer
{
    CommonApiCall *apiCall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"inAppPurchase") andDelegate:self];
    //NSLog(@"/n/n/nINAPP Purchase %@",@{@"subscription":[NSNumber numberWithInt:[self getTypeOfSubsciption]],@"type":@"receipt",@"userid":[User currentUser].struserId});
    
    [apiCall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"subscription":[NSNumber numberWithInt:[self getTypeOfSubsciption]],@"type":@"receipt",@"userid":[User currentUser].struserId} options:NSJSONWritingPrettyPrinted error:nil]];
    
}
- (void)updateBadgePurchaseToServer:(NSString *)strProductIdentifier
{
    
    /////*********************** URVISH **************************************
    ///commet :- here we need to change month subscription dynamically.Right now we are passing static
    ///date :- 6/5/2015
    
    CommonApiCall *apiCall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"inAppPurchase") andDelegate:self];
    
    [apiCall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"subscription":[NSNumber numberWithInt:1],@"type":@"Gold_badgePurchased",@"userid":[User currentUser].struserId} options:NSJSONWritingPrettyPrinted error:nil]];

    ////**********************************************************************
    /*
     
     NSString *strSubscription =@"";
     if ([strProductIdentifier isEqualToString:kSoberGrid1MonthIdentifier]) {
     strSubscription=@"1";
     }
     if ([strProductIdentifier isEqualToString:kSoberGrid3MonthIdentifier]) {
     
     strSubscription=@"3";
     }
     if ([strProductIdentifier isEqualToString:kSoberGrid12MonthIdentifier]) {
     strSubscription=@"12";
     }
     
     */
}
- (void)checkIfSubscriptionExpired{
    if (![[User currentUser]isLogin]) {
        return;
    }
    if([[NSUserDefaults standardUserDefaults]objectForKey:kKeyForDate]){
        NSDate *lastDate=(NSDate*)[[NSUserDefaults standardUserDefaults]objectForKey:kKeyForDate];
        if ([lastDate isTodayDate]) {
          //  return;
        }

    }
    CommonApiCall *apiCall = [[CommonApiCall alloc]initWithRequestMethod:POST andRequestURL:createurlFor(@"isSubscriptionActive") andDelegate:self];
    
    [apiCall startAPICallWithJSON:[NSJSONSerialization dataWithJSONObject:@{@"userid":[User currentUser].struserId} options:NSJSONWritingPrettyPrinted error:nil]];
}
- (void)didSucceedCallWithResponse:(id)data withURL:(NSString *)requestedURL forObject:(id)userInfo
{
    NSDictionary *dictResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    dictResponse = [dictResponse dictionaryByReplacingNullsWithBlanks];
    //NSLog(@"/n/n/nINAPP Purchase Response %@ ",dictResponse);
    
    if ([requestedURL rangeOfString:@"isSubscriptionActive"].location != NSNotFound) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kKeyForDate];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[User currentUser] upatePremiumwithType:[[[dictResponse objectForKey:RESPONSE] objectForKey:@"premium"] intValue]];
    }
    
}
-(void)didFailWithError:(NSString *)error withURL:(NSString *)requestedURL forObject:(id)userInfo{
    
}


@end
