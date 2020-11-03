//
//  Filter.m
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/9/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//

#import "Filter.h"
#import "User.h"
#import "DatabaseManager.h"
#import "NSDate+Utilities.h"

@implementation Filter
static Filter *_sharedDelegate = nil;

+ (Filter *)sharedInstance {
    static dispatch_once_t pred;
    static id shared = nil;
    dispatch_once(&pred, ^{
        shared = [(Filter *) [super alloc] initUniqueInstance];
    });
    return shared;
}

- (instancetype)initUniqueInstance {
    self = [super init];
    
    if (self) {
        
        [self addOptions];
        
    }
    
    return self;
}
- (id)init{
    self = [super init];
    
    if (self) {
        
        [self addOptions];
        
    }
    
    return self;
}
- (void)addOptions{
    _arrOptionsForDistance = [[NSMutableArray alloc]initWithObjects:@"0",@"10",@"20",@"50",@"100",@"250",@"500", nil];
    _arrOptionsForGender = [[NSMutableArray alloc] initWithObjects:@"Female",@"Male", nil];
    _arrOptionsForOrientation = [[NSMutableArray alloc]initWithObjects:@"Straight",@"Gay",@"Lesbian",@"Bisexual",@"Questioning",nil];
    _arrOptionsForRStatus = [[NSMutableArray alloc] initWithObjects:@"Single",@"Dating",@"Committed",@"Open Relationship",@"Married", nil];
    _arrOptionsForSeeking=[[NSMutableArray alloc] initWithObjects:@"New Friends",@"Chat Buddy",@"Activity Partners", nil];
    _arrOptionsForSMotivation = [[NSMutableArray alloc] initWithObjects:@"12-Step",@"Religion",@"Health",@"Straight Edge",@"Fitness",@"Other", nil];
    //developer :- Agile
    // Date :- 4/5/2015
    // comment :- Change the "Yes" and "No" string capital to small
    
    _arrOptionsForAvailableToGiveRid =[[NSMutableArray alloc] initWithObjects:@"Yes",@"No", nil];
    //    _arrOptionsForFellowship= [[NSMutableArray alloc] initWithObjects:@"AA",@"NA",@"CA",@"CMA",@"HA",@"Other", nil];
    _arrOptionsForLMeetUp=[[NSMutableArray alloc] initWithObjects:@"Yes",@"No", nil];
}
- (void)copyToObject:(Filter*)filterObject{
    filterObject.arrSelectedAvailableToGiveRid = _arrSelectedAvailableToGiveRid;
    filterObject.arrSelectedDistance = _arrSelectedDistance  ;
    //     filterObject.arrSelectedFellowship = _arrSelectedFellowship;
    filterObject.arrSelectedGender = _arrSelectedGender;
    filterObject.arrSelectedLMeetUp = _arrSelectedLMeetUp;
    filterObject.arrSelectedOrientation = _arrSelectedOrientation;
    filterObject.arrSelectedRStatus = _arrSelectedRStatus;
    filterObject.arrSelectedSeeking = _arrSelectedSeeking;
    filterObject.arrSelectedSMotivation = _arrSelectedSMotivation;
    filterObject.onlyPhotoes = _onlyPhotoes;
    filterObject.onlyOnline  = _onlyOnline;
    filterObject.onlyRehabGroup = _onlyRehabGroup;
    filterObject.minimumAge = _minimumAge;
    filterObject.maximumAge = _maximumAge;
}

- (void)filteredArray:(NSMutableArray*)arr withCompletion:(FilterCompletion)completion{
    _completionblock = completion;
    if (arr.count == 0) {
        _completionblock (nil);
        _completionblock = nil;
        return;
    }
    __block  NSMutableArray *filteredArray=[[NSMutableArray alloc]initWithArray:arr copyItems:YES];
    
    
    [filteredArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(User* tempUser, NSUInteger idx, BOOL *stop) {
        
        // Check for fellowshiptype
        BOOL satisFies = false;
        
        if (_minimumAge !=0 && _maximumAge !=0) {
            if (tempUser.birthDate) {
                int age=(int)[tempUser.birthDate getAge];
                if (age >= _minimumAge && age<= _maximumAge) {
                    satisFies = true;
                }else
                {
                    satisFies = false;
                }
            }else{
                satisFies = false;
                
            }
        }else{
            satisFies = true;
        }
        
        if (!satisFies) {
            [filteredArray removeObject:tempUser];
            
        }
        if ([_arrSelectedDistance containsObject:@"No Answer"]) {
            [_arrSelectedDistance removeObject:@"No Answer"];
        }
        for (NSString *distance in _arrSelectedDistance) {
            if ([tempUser.strDistance intValue] <= [distance intValue]) {
                satisFies = true;
            }else
                satisFies = false;
        }
        
        if (_arrSelectedDistance.count == 0) {
            satisFies = true;
        }
        if (!satisFies) {
            [filteredArray removeObject:tempUser];
            
        }
        // Filter based on fellowship type
        // Client dont need it any more
        //        if ([_arrSelectedFellowship containsObject:@"No Answer"]) {
        //            [_arrSelectedFellowship removeObject:@"No Answer"];
        //        }
        
        //        for (NSString *str in _arrSelectedFellowship) {
        //            if ([tempUser.arrfellowShipType containsObject:NSLocalizedString(str, nil)]) {
        //                satisFies = true;
        //                break;
        //            }else
        //                satisFies = false;
        //        }
        //        if (_arrSelectedFellowship.count == 0) {
        //            satisFies = true;
        //        }
        //        if (!satisFies) {
        //            [filteredArray removeObject:tempUser];
        //
        //        }
        // For Gender
        if ([_arrSelectedGender containsObject:@"No Answer"]) {
            [_arrSelectedGender removeObject:@"No Answer"];
        }
        for (NSString *str in _arrSelectedGender) {
            if (![str isEqualToString:NSLocalizedString(tempUser.strGender, nil)]) {
                satisFies = false;
            }else{
                satisFies = true;
                break;
                
            }
            
        }
        if (_arrSelectedGender.count == 0) {
            satisFies = true;
        }
        if (!satisFies) {
            [filteredArray removeObject:tempUser];
            
        }
        // For Looking to meet up
        if ([_arrSelectedLMeetUp containsObject:@"No Answer"]) {
            [_arrSelectedLMeetUp removeObject:@"No Answer"];
        }
        for (NSString *str in _arrSelectedLMeetUp) {
            if (![str isEqualToString:NSLocalizedString(tempUser.strLookingToMeetUP, nil)]) {
                satisFies = false;
            }else{
                satisFies = true;
                break;
                
            }
        }
        if (_arrSelectedLMeetUp.count == 0) {
            satisFies = true;
        }
        if (!satisFies) {
            [filteredArray removeObject:tempUser];
            
        }
        // For Orientation
        if ([_arrSelectedOrientation containsObject:@"No Answer"]) {
            [_arrSelectedOrientation removeObject:@"No Answer"];
        }
        for (NSString *str in _arrSelectedOrientation) {
            if (![str isEqualToString:NSLocalizedString(tempUser.strOrientation, nil)]) {
                satisFies = false;
            }else{
                satisFies = true;
                break;
            }
            
        }
        if (_arrSelectedOrientation.count == 0) {
            satisFies = true;
        }
        if (!satisFies) {
            [filteredArray removeObject:tempUser];
            
        }
        // For Relationship status
        if ([_arrSelectedRStatus containsObject:@"No Answer"]) {
            [_arrSelectedRStatus removeObject:@"No Answer"];
        }
        for (NSString *str in _arrSelectedRStatus) {
            if (![str isEqualToString:NSLocalizedString(tempUser.strRelStatus, nil)]) {
                satisFies = false;
            }else
            {
                satisFies = true;
                break;
            }
        }
        if (_arrSelectedRStatus.count == 0) {
            satisFies = true;
        }
        if (!satisFies) {
            [filteredArray removeObject:tempUser];
            
        }
        // For Relationship status
        if ([tempUser.strName rangeOfString:@"tuser"].location !=NSNotFound) {
            NSLog(@"found");
        }
        if ([_arrSelectedSeeking containsObject:@"No Answer"]) {
            [_arrSelectedSeeking removeObject:@"No Answer"];
        }
        for (NSString *str in _arrSelectedSeeking) {
            if ([tempUser.arrSeekingType containsObject:NSLocalizedString(str, nil)]) {
                satisFies = true;
                break;
            }else
                satisFies = false;
            
        }
        if (_arrSelectedSeeking.count == 0) {
            satisFies = true;
        }
        if (!satisFies) {
            [filteredArray removeObject:tempUser];
            
        }
        // For online
        // Now from server side
        //        if (self.onlyOnline) {
        //             BOOL isOnline = [[DatabaseManager sharedInstance] getPresenceRepostForUserId:tempUser.struserId];
        //            if (isOnline) {
        //                satisFies = true;
        //            }else
        //                satisFies = false;
        //            if (!satisFies) {
        //                [filteredArray removeObject:tempUser];
        //            }
        //        }
        if (self.onlyPhotoes) {
            if (tempUser.strProfilePicThumb.length>0) {
                satisFies = true;
            }else
                satisFies =  false;
            if (!satisFies) {
                [filteredArray removeObject:tempUser];
            }
        }
        
        tempUser = nil;
        if (idx == 0) {
            if (_completionblock) {
                _completionblock (filteredArray);
                _completionblock = nil;
                filteredArray = nil;
            }
        }
    }];
    
}

- (void)clearNewsFeedFilter{
    _myPosts = false;
    _mySubscribed = false;
}


- (void)clearFilter{
    _arrSelectedSeeking = [[NSMutableArray alloc]init];
    _arrSelectedSMotivation = [[NSMutableArray alloc]init];
    _arrSelectedRStatus = [[NSMutableArray alloc]init];
    _arrSelectedOrientation = [[NSMutableArray alloc] init];
    _arrSelectedLMeetUp = [[NSMutableArray alloc] init];
    _arrSelectedGender = [[NSMutableArray alloc]init];
    //    _arrSelectedFellowship = [[NSMutableArray alloc]init];
    _arrSelectedDistance = [[NSMutableArray alloc]init];
    _arrSelectedAvailableToGiveRid = [[NSMutableArray alloc]init];
    _onlyOnline = false;
    _onlyPhotoes = false;
    _onlyRehabGroup = false;
    _minimumAge = 0;
    _maximumAge = 0;
    
}
@end
