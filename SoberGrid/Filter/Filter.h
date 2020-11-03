//
//  Filter.h
//  SoberGrid
//
//  Created by Haresh Kalyani on 9/9/14.
//  Copyright (c) 2014 Agile Infoways Pvt. Ltd. All rights reserved.
//


typedef void (^FilterCompletion)(NSMutableArray *arrFilteredObjects);
#import <Foundation/Foundation.h>

@interface Filter : NSObject
+ (Filter *)sharedInstance;

@property (copy,nonatomic)FilterCompletion completionblock;

#pragma mark NEWSFEED Filter

// For My Posts
@property (assign)BOOL  myPosts;


// For Posts i have commented
@property (assign)BOOL  mySubscribed;

#pragma mark GRID Filter

//For online users
@property (assign)BOOL  onlyOnline;

// For Photos
@property (assign)BOOL  onlyPhotoes;

// For Rehab Group
@property (assign)BOOL  onlyRehabGroup;

// For age
@property (assign)int minimumAge;
@property (assign)int maximumAge;

// For Gender
@property (nonatomic,strong)NSMutableArray *arrOptionsForGender;
@property (nonatomic,strong)NSMutableArray *arrSelectedGender;

// For Orientation
@property (nonatomic,strong)NSMutableArray *arrOptionsForOrientation;
@property (nonatomic,strong)NSMutableArray *arrSelectedOrientation;

// For Distance
@property (nonatomic,strong)NSMutableArray *arrOptionsForDistance;
@property (nonatomic,strong)NSMutableArray *arrSelectedDistance;

// For relationship status
@property (nonatomic,strong)NSMutableArray *arrOptionsForRStatus;
@property (nonatomic,strong)NSMutableArray *arrSelectedRStatus;

// For Seeking
@property (nonatomic,strong)NSMutableArray *arrOptionsForSeeking;
@property (nonatomic,strong)NSMutableArray *arrSelectedSeeking;

// For Motivaiton
@property (nonatomic,strong)NSMutableArray *arrOptionsForSMotivation;
@property (nonatomic,strong)NSMutableArray *arrSelectedSMotivation;

// Available to give a ride
@property (nonatomic,strong)NSMutableArray *arrOptionsForAvailableToGiveRid;
@property (nonatomic,strong)NSMutableArray *arrSelectedAvailableToGiveRid;

//Fellowship type
//@property (nonatomic,strong)NSMutableArray *arrOptionsForFellowship;
//@property (nonatomic,strong)NSMutableArray *arrSelectedFellowship;

//Looking to meetup
@property (nonatomic,strong)NSMutableArray *arrOptionsForLMeetUp;
@property (nonatomic,strong)NSMutableArray *arrSelectedLMeetUp;

- (void)copyToObject:(Filter*)filterObject;
- (void)filteredArray:(NSMutableArray*)arr withCompletion:(FilterCompletion)completion;
- (void)clearFilter;
@end
