//
//  DataModel.h
//  FinalProject-LOLRankedCompanion
//
//  Created by Ralph Toon on 08/11/2017.
//  Copyright © 2017 University of Leeds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Summoner.h"

@interface DataModel : NSObject

@property (nonatomic, strong) Summoner *currentUserSummoner;
@property (nonatomic, strong) NSMutableArray *currentUserLadder; //Obtained by League V3 (1 call)
@property (nonatomic, strong) NSMutableArray *liveGamePlayers; //Obtained by Spectator V3 (1 call)
@property (nonatomic, strong) NSString *apiKey; //Find this in .m and update

+ (DataModel *) sharedInstance; //This allows the data model to be accessed by all view controllers

//Following methods are used to populate the model
- (NSDictionary *) getURLData:(NSString *)requestString;
- (void) populateSummoner:(NSString *)name; //This must be called before the other populate methods
- (void) populateLadder;
- (void) populatePlayers;


@end
