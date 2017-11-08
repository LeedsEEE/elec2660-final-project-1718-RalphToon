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
@property NSString *rank;
@property NSInteger leaguePoints;
@property NSInteger soloWins;         //This is only set up for solo q for the
@property NSInteger soloLosses;       //purposes of the app, flex can be added
@property float soloWinrate;
@property NSString *soloLeagueID;

@end
