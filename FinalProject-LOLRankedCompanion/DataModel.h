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

//Summoner Data Properties
@property (nonatomic, strong) Summoner *currentUserSummoner;
@property (nonatomic, strong) NSMutableArray *currentUserLadder; //Obtained by League V3 (1 call)
@property (nonatomic, strong) NSMutableArray *liveGamePlayers; //Obtained by Spectator V3 (1 call)
@property (nonatomic, strong) NSMutableArray *champList;
@property (nonatomic, strong) NSArray *regions;
@property NSInteger selectedRegion;

//API Manipulation Properties
@property (nonatomic, strong) NSMutableDictionary *dataDict;
@property (nonatomic, strong) NSString *errorMessage; //Should only be displayed when len>0
@property (nonatomic, strong) NSString *apiKey; //Find this in .m and update
@property BOOL completionFlag;

+ (DataModel *) sharedInstance; //This allows the data model to be accessed by all view controllers

//Following methods are used to populate the model
- (void) getURLData:(NSString *)requestString withKey:(NSString *)dataKey withData:(NSString *)keyData;
- (BOOL) checkDataIntegrity:(NSMutableDictionary *)dataDict;
- (void) populateSummoner:(NSString *)name; //This must be called before the other populate methods
- (void) populateLadder;
- (void) populatePlayers;
- (NSString *) searchChampList:(NSInteger)champId;

//NEW POPULATING METHODS HERE
- (void) summonerByName:(NSString *)name;
- (void) championMasteryBySummoner:(Summoner *)summoner;
- (void) leaguePositionsBySummoner:(Summoner *)summoner;
- (void) leagueByLeagueID:(Summoner *)summoner;
- (void) activeGameBySummoner:(Summoner *)summoner;




@end
