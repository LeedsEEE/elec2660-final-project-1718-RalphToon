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

//Data Storage Properties
@property (nonatomic, strong) Summoner *currentUserSummoner;
@property (nonatomic, strong) NSMutableArray *currentUserLadder;
@property (nonatomic, strong) NSMutableArray *liveGamePlayers;
@property (nonatomic, strong) NSMutableArray *champList;
@property (nonatomic, strong) NSArray *regions;
@property NSInteger selectedRegion;

//API Manipulation Properties
@property (nonatomic, strong) NSMutableDictionary *dataDict;
@property (nonatomic, strong) NSString *errorMessage;   //Should only be displayed when len>0
@property (nonatomic, strong) NSString *apiKey;         //Find this in .m and update
@property BOOL completionFlag;


//CLASS METHODS
+ (DataModel *) sharedInstance; //This allows the data model to be accessed by all view controllers


//INSTANCE METHODS

//Population Methods
- (void) populateSummoner:(NSString *)name; //This must be called before the other populate methods
- (void) populateLadder;
- (void) populatePlayers;

//Data Retrieval Methods
- (void) getURLData:(NSString *)requestString withKey:(NSString *)dataKey withData:(NSString *)keyData;
- (BOOL) checkDataIntegrity:(NSMutableDictionary *)dataDict;
- (void) summonerByName:(NSString *)name;
- (void) championMasteryBySummoner:(Summoner *)summoner;
- (void) leaguePositionsBySummoner:(Summoner *)summoner;
- (void) leagueByLeagueID:(Summoner *)summoner;
- (void) activeGameBySummoner:(Summoner *)summoner;
- (NSString *) searchChampList:(NSInteger)champId;

@end
