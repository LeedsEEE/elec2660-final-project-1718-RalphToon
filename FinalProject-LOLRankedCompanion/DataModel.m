//
//  DataModel.m
//  FinalProject-LOLRankedCompanion
//
//  Created by Ralph Toon on 08/11/2017.
//  Copyright © 2017 University of Leeds. All rights reserved.
//

#import "DataModel.h"

@implementation DataModel

static DataModel *_sharedInstance;

#pragma mark Init methods
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.currentUserSummoner = [[Summoner alloc]init];
        self.currentUserLadder = [NSMutableArray array];
        self.liveGamePlayers = [NSMutableArray array];
        self.apiKey = @"RGAPI-6e3e6da8-2528-4c04-94f7-7b9632c9378a"; //ENTER API KEY HERE
    }
    return self;
}

+(DataModel *) sharedInstance { //This creates the shared data model if it doesnt exist
    if (!_sharedInstance) {
        _sharedInstance = [[DataModel alloc] init];
    }
    return _sharedInstance;
}


#pragma mark API data aquisition methods
- (void) getURLData:(NSString *)requestString //Everytime this is called 1 request is used (20/sec 100/2mins MAX)
            withKey:(NSString *)dataKey
           withData:(NSString *)keyData {
    
    self.completionFlag = NO;
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:requestString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ([[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil] isKindOfClass:[NSArray class]]) {
            //If data is in array format, we need to do some extra processing
            NSMutableArray *tempArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            BOOL dataNotFound = YES;
            int count = 0;
            while (dataNotFound) {
                NSMutableDictionary *selectedDict = tempArray[count];
                if ([[selectedDict objectForKey:dataKey] isEqual:keyData]) {
                    self.dataDict = selectedDict;
                    dataNotFound = NO;
                }
                else {
                    count++;
                }
            }
        }
        
        else {
            self.dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        }
        
        self.completionFlag = YES;
    }]resume];
    //Above method adapted from https://www.youtube.com/watch?v=kbNnQ6VV1zo
    //and using Apple Documentation tutorial https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/URLLoadingSystem/Articles/UsingNSURLSession.html#//apple_ref/doc/uid/TP40013509-SW1
}


- (BOOL) checkDataIntegrity:(NSMutableDictionary *)dataDict {
    BOOL correctData = YES;
    self.errorMessage = @"";
    NSArray *keys = [dataDict allKeys]; //We list all the keys in the Data Dictionary
    for (NSString* keyName in keys) {
        if ([keyName isEqualToString:@"status"]) { //Then check all the keys for "status" which indicates an error
            correctData = NO;
            NSDictionary *errorDict = [dataDict objectForKey:@"status"];
            self.errorMessage = [NSString stringWithFormat:@"Error %@: %@",[errorDict objectForKey:@"status_code"],[errorDict objectForKey:@"message"]];
            
            NSLog(@"Error Code = %@", [errorDict objectForKey:@"status_code"]); //Used to print error to console
        }
    }
    return correctData;
}


#pragma mark populatuing methods
- (void) populateSummoner:(NSString *)name {
    NSString *requestString;
    
    //SUMMONER V3 CALL
    requestString = [NSString stringWithFormat:@"https://euw1.api.riotgames.com/lol/summoner/v3/summoners/by-name/%@?api_key=%@", name, self.apiKey];
    [self getURLData:requestString withKey:NULL withData:NULL]; //Arguments are NULL as no extra processing required
    while (!self.completionFlag) { //Holds the program until data is recieved
    }                              //This is not best practice, update if time is left
    
    if ([self checkDataIntegrity:self.dataDict]) { //If data is correct we update the summoner
        self.currentUserSummoner.summonerName = [self.dataDict objectForKey:@"name"];
        self.currentUserSummoner.summonerID = [self.dataDict objectForKey:@"id"];
        self.currentUserSummoner.accountID = [self.dataDict objectForKey:@"accountId"];
    }
    
    //CHAMPION MASTERY V3 CALL
    requestString = [NSString stringWithFormat:@"https://euw1.api.riotgames.com/lol/champion-mastery/v3/champion-masteries/by-summoner/%@?api_key=%@", self.currentUserSummoner.summonerID, self.apiKey];
    [self getURLData:requestString withKey:@"playerId" withData:self.currentUserSummoner.summonerID]; //Arguments needed as JSON data is array
    while (!self.completionFlag) {
    }
    
    if ([self checkDataIntegrity:self.dataDict]) {
        self.currentUserSummoner.champMastery = [[self.dataDict objectForKey:@"championPoints"] integerValue];
        
        requestString = [NSString stringWithFormat:@"https://euw1.api.riotgames.com/lol/static-data/v3/champions/%@?locale=en_US&api_key=%@", [self.dataDict objectForKey:@"championId"], self.apiKey];
        [self getURLData:requestString withKey:NULL withData:NULL];
        while (!self.completionFlag) {
        }
        self.currentUserSummoner.favChamp = [self.dataDict objectForKey:@"name"];

    }
    
    //LEAGUE V3 CALL
    requestString = [NSString stringWithFormat:@"https://euw1.api.riotgames.com/lol/league/v3/positions/by-summoner/%@?api_key=%@", self.currentUserSummoner.summonerID, self.apiKey];
    [self getURLData:requestString withKey:@"queueType" withData:@"RANKED_SOLO_5x5"];
    while (!self.completionFlag) {
    }
    
    if ([self checkDataIntegrity:self.dataDict]) {
        self.currentUserSummoner.rank = [self.dataDict objectForKey:@"rank"];
        self.currentUserSummoner.tier = [self.dataDict objectForKey:@"tier"];
        self.currentUserSummoner.leaguePoints = [[self.dataDict objectForKey:@"leaguePoints"] integerValue];
        self.currentUserSummoner.soloWins = [[self.dataDict objectForKey:@"wins"] floatValue];
        self.currentUserSummoner.soloLosses = [[self.dataDict objectForKey:@"losses"] floatValue];
        self.currentUserSummoner.soloLeagueID = [self.dataDict objectForKey:@"leagueId"];
        self.currentUserSummoner.soloWinrate = (self.currentUserSummoner.soloWins/(self.currentUserSummoner.soloLosses + self.currentUserSummoner.soloWins))*100;
    }
}


-(void) populateLadder {
    NSString *requestString;
    
    //LEAGUE V3 CALL
    requestString = [NSString stringWithFormat:@"https://euw1.api.riotgames.com/lol/league/v3/leagues/%@?api_key=%@", self.currentUserSummoner.soloLeagueID, self.apiKey];
    [self getURLData:requestString withKey:NULL withData:NULL];
    while (!self.completionFlag) {
    }
    //At this point, self.dataDict is a list of all players in the league that needs to be sorted
    
    if ([self checkDataIntegrity:self.dataDict]) { //If the self.dataDict is good, we can process it
        [self.currentUserLadder removeAllObjects]; //Clear the ladder entries for a new user
        NSMutableArray *tempArray = [self.dataDict objectForKey:@"entries"];
        
        for (NSDictionary *entry in tempArray) { //If the player is the same rank, we add them to the ladder
            if ([[entry objectForKey:@"rank"] isEqual:self.currentUserSummoner.rank]) {
                Summoner *ladderSummoner = [[Summoner alloc] init];
                ladderSummoner.summonerName = [entry objectForKey:@"playerOrTeamName"];
                ladderSummoner.summonerID = [entry objectForKey:@"playerOrTeamId"];
                ladderSummoner.rank = [entry objectForKey:@"rank"];
                ladderSummoner.tier = self.currentUserSummoner.tier;
                ladderSummoner.leaguePoints = [[entry objectForKey:@"leaguePoints"] integerValue];
                ladderSummoner.soloWins = [[entry objectForKey:@"wins"] floatValue];
                [self.currentUserLadder addObject:ladderSummoner]; //This builds an array of summoner objects
            }
        }

        //Now sort self.currentUserLadder so its in LP order
        //Using a bubble sort as its easy, we dont need a more efficient method as the list is small (<50)
        BOOL swapped = YES;
        while (swapped) {
            swapped = NO;
            for (int i = 1; i<[self.currentUserLadder count]; i++) {
                Summoner *player1 = self.currentUserLadder[i-1];
                Summoner *player2 = self.currentUserLadder[i];

                if (player1.leaguePoints>player2.leaguePoints) {
                    [self.currentUserLadder exchangeObjectAtIndex:i-1 withObjectAtIndex:i];
                    swapped = YES;
                }
            }
        }
    } //Closes check data integrity if statement

    
}

-(void) populatePlayers {
    [self.dataDict removeAllObjects]; //Clear the dictionary for the new data
    
}

 @end
