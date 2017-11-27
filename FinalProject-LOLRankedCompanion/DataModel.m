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
- (instancetype)init {
    self = [super init];
    if (self) {
        self.currentUserSummoner = [[Summoner alloc]init];
        self.currentUserLadder = [NSMutableArray array];
        self.liveGamePlayers = [NSMutableArray array];
        self.regions = @[@"ru", @"kr", @"br1", @"oc1", @"jp1", @"na1", @"eun1", @"euw1", @"tr1", @"la1", @"la2"];
        self.apiKey = @"RGAPI-75720ebd-8e24-49f8-bb98-bd0760f36b4c"; //ENTER API KEY HERE
        
        //Get the champ list
        NSString *requestString = [NSString stringWithFormat:@"https://%@.api.riotgames.com/lol/static-data/v3/champions?locale=en_US&dataById=false&api_key=%@", self.regions[self.selectedRegion], self.apiKey];
        [self getURLData:requestString withKey:NULL withData:NULL];
        while (!self.completionFlag) {
        }
        
        if ([self checkDataIntegrity:self.dataDict]) {
            NSMutableDictionary *tempDict = [self.dataDict objectForKey:@"data"];
            self.champList = [[NSMutableArray alloc] initWithArray:[tempDict allValues]];
        }
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
/*
 NOTE ABOUT API CALLS:
 Everytime getURLData is called 1 request is used, except for staticData calls
 Max number of calls limited to 20/sec AND 100/2mins
 Everytime getData is pressed 15 calls are made
*/

- (void) getURLData:(NSString *)requestString
            withKey:(NSString *)dataKey
           withData:(NSString *)keyData {
    
    self.completionFlag = NO;
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:requestString]
                                 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                     
        if (data != NULL) {
        //We can only use the data if we get a response
            if ([[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil] isKindOfClass:[NSArray class]]) {
            //If data is in array format, we need to do some extra processing
                NSMutableArray *tempArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                if ([tempArray count] == 0) {
                //If array is empty due to error
                    self.errorMessage = @"Empty data array returned";
                }
                else {
                //We search a populated array for our dataDict
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
            }
            else {
                self.dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            }
        }
        else { //If the API fails to return data, we let the user know
            self.errorMessage = @"No data recieved, try again";
        }
        
        self.completionFlag = YES;
    }]resume];
    //Above method adapted from https://www.youtube.com/watch?v=kbNnQ6VV1zo
    //and using Apple Documentation tutorial https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/URLLoadingSystem/Articles/UsingNSURLSession.html#//apple_ref/doc/uid/TP40013509-SW1
}


- (BOOL) checkDataIntegrity:(NSMutableDictionary *)dataDict {
    BOOL correctData = YES;
    
    if ([self.errorMessage  isEqual:@"No data recieved, try again"]) { //If the API doesnt respond
        correctData = NO;
    }
    else if ([self.errorMessage  isEqual:@"Empty data array returned"]) { //If the API responds but gives an empty array
        correctData = NO;
    }
    else { //If the API returns an Error dictionary
        NSArray *keys = [dataDict allKeys]; //We list all the keys in the Data Dictionary
        for (NSString* keyName in keys) {
            if ([keyName isEqualToString:@"status"]) { //Then check all the keys for "status" which indicates an error
                correctData = NO;
                NSDictionary *errorDict = [dataDict objectForKey:@"status"];
                self.errorMessage = [NSString stringWithFormat:@"Error: %@",[errorDict objectForKey:@"message"]];
            
                NSLog(@"Error Code = %@", [errorDict objectForKey:@"status_code"]); //Used to print error to console for debugging
        
            }
        }
    }
    return correctData;
}


- (NSString *) searchChampList:(NSInteger)champId { //This is a place to improve efficiency by improving the search algorithm
    NSString *champName;
    for (NSDictionary *champion in self.champList) {
        if (champId == [[champion objectForKey:@"id"] integerValue]) {
            champName = [champion objectForKey:@"name"];
        }
    }
    return champName;
}



#pragma mark populatuing methods
- (void) populateSummoner:(NSString *)name { //METHOD API CALLS: 3
    NSString *requestString;
    
    //SUMMONER V3 CALL
    requestString = [NSString stringWithFormat:@"https://%@.api.riotgames.com/lol/summoner/v3/summoners/by-name/%@?api_key=%@", self.regions[self.selectedRegion], name, self.apiKey];
    [self getURLData:requestString withKey:NULL withData:NULL]; //Arguments are NULL as no extra processing required
    while (!self.completionFlag) { //Holds the program until data is recieved
    }                              //This is not best practice, update if time is left
    
    if ([self checkDataIntegrity:self.dataDict]) { //If data is correct we update the summoner
        self.currentUserSummoner.summonerName = [self.dataDict objectForKey:@"name"];
        self.currentUserSummoner.summonerID = [self.dataDict objectForKey:@"id"];
        self.currentUserSummoner.accountID = [self.dataDict objectForKey:@"accountId"];
    }
    
    //CHAMPION MASTERY V3 CALL
    requestString = [NSString stringWithFormat:@"https://%@.api.riotgames.com/lol/champion-mastery/v3/champion-masteries/by-summoner/%@?api_key=%@", self.regions[self.selectedRegion], self.currentUserSummoner.summonerID, self.apiKey];
    [self getURLData:requestString withKey:@"playerId" withData:self.currentUserSummoner.summonerID]; //Arguments needed as JSON data is array
    while (!self.completionFlag) {
    }
    
    if ([self checkDataIntegrity:self.dataDict]) {
        self.currentUserSummoner.champMastery = [[self.dataDict objectForKey:@"championPoints"] integerValue];
        self.currentUserSummoner.favChamp = [self searchChampList:[[self.dataDict objectForKey:@"championId"] integerValue]];
    }
    
    //LEAGUE V3 CALL
    requestString = [NSString stringWithFormat:@"https://%@.api.riotgames.com/lol/league/v3/positions/by-summoner/%@?api_key=%@",self.regions[self.selectedRegion], self.currentUserSummoner.summonerID, self.apiKey];
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


-(void) populateLadder { //METHOD API CALLS: 1
    NSString *requestString;
    
    //LEAGUE V3 CALL
    requestString = [NSString stringWithFormat:@"https://%@.api.riotgames.com/lol/league/v3/leagues/%@?api_key=%@",self.regions[self.selectedRegion], self.currentUserSummoner.soloLeagueID, self.apiKey];
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

        //Now sort self.currentUserLadder so its in LP (ladder) order
        //Using a bubble sort as its easy, we dont need a more efficient method as the list is small (<50)
        //Improving this sort can help efficiency if time is left
        BOOL swapped = YES;
        while (swapped) {
            swapped = NO;
            for (int i = 1; i<[self.currentUserLadder count]; i++) {
                Summoner *player1 = self.currentUserLadder[i-1];
                Summoner *player2 = self.currentUserLadder[i];

                if (player1.leaguePoints<player2.leaguePoints) {
                    [self.currentUserLadder exchangeObjectAtIndex:i-1 withObjectAtIndex:i];
                    swapped = YES;
                }
            }
        }
    }
}


-(void) populatePlayers { //METHOD API CALLS: 11
    //The following method contains a lot of copy paste from populateSummoner
    //This is poor practice and the structure of the class needs to be improved if time allows
    [self.liveGamePlayers removeAllObjects];
    NSString *requestString;
    
    //SPECTATOR V3 CALL
    requestString = [NSString stringWithFormat:@"https://%@.api.riotgames.com/lol/spectator/v3/active-games/by-summoner/%@?api_key=%@", self.regions[self.selectedRegion], self.currentUserSummoner.summonerID, self.apiKey];
    [self getURLData:requestString withKey:NULL withData:NULL]; //Already a dictionary so we NULL arguments
    while (!self.completionFlag) {
    }
    
    if ([self checkDataIntegrity:self.dataDict]) {
        NSMutableArray *tempArray = [self.dataDict objectForKey:@"participants"];
        
        for (NSDictionary *entry in tempArray) {
            Summoner *gameSummoner = [[Summoner alloc] init];
            gameSummoner.summonerName = [entry objectForKey:@"summonerName"];
            gameSummoner.summonerID = [entry objectForKey:@"summonerId"];
            gameSummoner.currentChamp = [self searchChampList:[[entry objectForKey:@"championId"] integerValue]];

            //CHAMPION MASTERY V3 CALL
            requestString = [NSString stringWithFormat:@"https://%@.api.riotgames.com/lol/champion-mastery/v3/champion-masteries/by-summoner/%@?api_key=%@", self.regions[self.selectedRegion], gameSummoner.summonerID, self.apiKey];
            [self getURLData:requestString withKey:@"playerId" withData:gameSummoner.summonerID]; //Arguments needed as JSON data is array
            while (!self.completionFlag) {
            }
            
            if ([self checkDataIntegrity:self.dataDict]) {
                gameSummoner.champMastery = [[self.dataDict objectForKey:@"championPoints"] integerValue];
                gameSummoner.favChamp = [self searchChampList:[[self.dataDict objectForKey:@"championId"] integerValue]];
            }
            
            //LEAGUE V3 CALL
            requestString = [NSString stringWithFormat:@"https://%@.api.riotgames.com/lol/league/v3/positions/by-summoner/%@?api_key=%@",self.regions[self.selectedRegion], gameSummoner.summonerID, self.apiKey];
            [self getURLData:requestString withKey:@"queueType" withData:@"RANKED_SOLO_5x5"];
            while (!self.completionFlag) {
            }
            
            if ([self checkDataIntegrity:self.dataDict]) {
                gameSummoner.rank = [self.dataDict objectForKey:@"rank"];
                gameSummoner.tier = [self.dataDict objectForKey:@"tier"];
                gameSummoner.leaguePoints = [[self.dataDict objectForKey:@"leaguePoints"] integerValue];
                gameSummoner.soloWins = [[self.dataDict objectForKey:@"wins"] floatValue];
                gameSummoner.soloLosses = [[self.dataDict objectForKey:@"losses"] floatValue];
                gameSummoner.soloLeagueID = [self.dataDict objectForKey:@"leagueId"];
                gameSummoner.soloWinrate = (gameSummoner.soloWins/(gameSummoner.soloLosses + gameSummoner.soloWins))*100;
            }
            
            [self.liveGamePlayers addObject:gameSummoner];
        }
    }
}


 @end
