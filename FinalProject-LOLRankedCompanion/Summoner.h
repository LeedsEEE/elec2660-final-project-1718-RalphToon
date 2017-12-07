//
//  Summoner.h
//  FinalProject-LOLRankedCompanion
//
//  Created by Ralph Toon on 08/11/2017.
//  Copyright © 2017 University of Leeds. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Summoner : NSObject

//Obtained by Summoner V3 OR Spectator V3 (1 call)
@property NSString *summonerName;
@property NSString *summonerID;
@property NSString *accountID;

//Obtained by League V3 (1 call)
@property NSString *rank;             //e.g. II, III
@property NSString *tier;             //e.g. BRONZE, GOLD
@property NSString *soloLeagueName;   //e.g. Lulu's Heroes
@property NSInteger leaguePoints;
@property float soloWins;         //This is only set up for solo q for the
@property float soloLosses;       //purposes of the app
@property float soloWinrate;
@property NSString *soloLeagueID;

//Obtained by Champion Masterey V3 (1 call)
@property NSString *favChamp;
@property NSInteger champMastery;

//Obtained by Spectator V3 (1 call)
@property NSString *currentChamp;

@end
