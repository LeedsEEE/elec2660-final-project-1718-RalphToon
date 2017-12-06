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
        self.currentUserLadder = [NSMutableArray array];
        self.liveGamePlayers = [NSMutableArray array];
        self.dataDict = [[NSMutableDictionary alloc] init];
        
        //Define the static portions of the dataModel
        self.regions = @[@"ru", @"kr", @"br1", @"oc1", @"jp1", @"na1", @"eun1", @"euw1", @"tr1", @"la1", @"la2"];
        self.apiKey = @"RGAPI-f5c47663-9f6f-4a0c-8442-29834bc14ebd"; //ENTER API KEY HERE
        
        //Get the champion list
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



#pragma mark Class methods
+(DataModel *) sharedInstance { //This creates the shared data model if it doesnt exist
    if (!_sharedInstance) {
        _sharedInstance = [[DataModel alloc] init];
    }
    return _sharedInstance;
}



#pragma mark populatuing methods
/*
 The following populating methods seem sparse and unnecessary
 however have been included to allow for greater flexibility
 for adding extra features later
*/

- (void) populateSummoner:(NSString *)name { //METHOD API CALLS: 3
    self.currentUserSummoner = [[Summoner alloc]init]; //Create the new summoner    
    
    [self summonerByName:name];
    if (![self.errorMessage isEqualToString:@"Error: Data not found - summoner not found"]) { //If we have found a summoner with the above name
        [self championMasteryBySummoner:self.currentUserSummoner];
        [self leaguePositionsBySummoner:self.currentUserSummoner];
    }
    
    else {
        self.errorMessage = @"Summoner does not exist";
    }
}


-(void) populateLadder { //METHOD API CALLS: 1
    [self leagueByLeagueID:self.currentUserSummoner];
}


-(void) populatePlayers { //METHOD API CALLS: 11
    [self activeGameBySummoner:self.currentUserSummoner];
}



#pragma mark API data aquisition methods
/*
 NOTE ABOUT API CALLS:
 Everytime getURLData is called 1 request is used
 Max number of calls limited to 20/sec AND 100/2mins
 Everytime getData is pressed 15 calls are made
 */

- (void) getURLData:(NSString *)requestString
            withKey:(NSString *)dataKey
           withData:(NSString *)keyData {
    
    if ([[self.dataDict allKeys] count] > 0) {
        self.dataDict = NULL; //NULL the dictionary if it has data
    }
    self.completionFlag = NO;
    
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:requestString]
                                 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                     
                                     if (data != NULL) { //We can only use the data if we get a response
                                         
                                         if ([[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil] isKindOfClass:[NSArray class]]) {
                                             //If data is in array format, we need to do some extra processing
                                             NSMutableArray *tempArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                            
                                             BOOL dataNotFound = YES;
                                             if ([tempArray count] > 0) { //We search a populated array for our dataDict
                                                 int count = 0;
                                                 while (dataNotFound && ([tempArray count]>count)) {
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
                                                 //This situation where we have an array but with no data inside
                                                 //can only occur if the user is not yet ranked
                                                 self.errorMessage = @"Note: User is unranked and has no Ladder";
                                             }
                                             
                                             if (dataNotFound) { //If we cant find our dataDict in the array
                                                 self.errorMessage = @"Note: User is unranked and has no Ladder";
                                             }
                                         }
                                         
                                         else { //If the data is a dictionary, we can use it as is
                                             self.dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                         }
                                     }
                                     self.completionFlag = YES;
                                     /*
                                      Possible finish states for dataDict after above method:
                                      If nothing is returned: dataDict = NULL
                                      If dictionary is returned: dataDict is the response dict NO MATTER THE CONTENTS
                                      If array is returned: If array is populated, we select our dict;
                                      If our data is not present, then dataDict = NULL;
                                      If array is empty we update the error message and dataDict = NULL
                                     */
                                     
                                 }]resume];
    //Above method adapted from https://www.youtube.com/watch?v=kbNnQ6VV1zo
    //and using Apple Documentation tutorial https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/URLLoadingSystem/Articles/UsingNSURLSession.html#//apple_ref/doc/uid/TP40013509-SW1
}


- (BOOL) checkDataIntegrity:(NSMutableDictionary *)dataDict {
    BOOL correctData = YES;
    
    if (dataDict == NULL) { //If we have no data
        if ([self.errorMessage length] == 0) { //If it wasn't empty array error
            self.errorMessage = @"Server did not respond. Please check the API status and try again";
        }
        correctData = NO;
    }
    
    else { //Check if a populated dictionary is an errorDict
        NSArray *keys = [dataDict allKeys]; //We list all the keys in the Data Dictionary
        for (NSString* keyName in keys) {
            if ([keyName isEqualToString:@"status"]) { //Then check all the keys for "status" which indicates an error
                correctData = NO;
                NSDictionary *errorDict = [dataDict objectForKey:@"status"];
                self.errorMessage = [NSString stringWithFormat:@"Error: %@",[errorDict objectForKey:@"message"]];
                
                //Print complete error to console for debugging
                NSLog(@"Error Code = %@ %@", [errorDict objectForKey:@"status_code"], [errorDict objectForKey:@"message"]);
                
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


- (void) summonerByName:(NSString *)name { //Summoner V3 Call
    //First we must format 'name' so it can be used in a URL
    NSString *formattedName = [name stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSString *requestString = [NSString stringWithFormat:@"https://%@.api.riotgames.com/lol/summoner/v3/summoners/by-name/%@?api_key=%@", self.regions[self.selectedRegion], formattedName, self.apiKey];
    [self getURLData:requestString withKey:NULL withData:NULL]; //Arguments are NULL as no extra processing required
    while (!self.completionFlag) { //Holds the program until data is recieved
    } 
    
    if ([self checkDataIntegrity:self.dataDict]) { //If data is correct we update the summoner
        //Method currently only used with UserSummoner so we change it directly
        self.currentUserSummoner.summonerName = [self.dataDict objectForKey:@"name"];
        self.currentUserSummoner.summonerID = [self.dataDict objectForKey:@"id"];
        self.currentUserSummoner.accountID = [self.dataDict objectForKey:@"accountId"];
    }
}


- (void) championMasteryBySummoner:(Summoner *)summoner { //Mastery V3 Call
    NSString *requestString = [NSString stringWithFormat:@"https://%@.api.riotgames.com/lol/champion-mastery/v3/champion-masteries/by-summoner/%@?api_key=%@", self.regions[self.selectedRegion], summoner.summonerID, self.apiKey];
    [self getURLData:requestString withKey:@"playerId" withData:summoner.summonerID]; //Arguments needed as JSON data is array
    while (!self.completionFlag) {
    }
    
    if ([self checkDataIntegrity:self.dataDict]) {
        summoner.champMastery = [[self.dataDict objectForKey:@"championPoints"] integerValue];
        summoner.favChamp = [self searchChampList:[[self.dataDict objectForKey:@"championId"] integerValue]];
    }
}


- (void) leaguePositionsBySummoner:(Summoner *)summoner { //League V3 Call
    NSString *requestString = [NSString stringWithFormat:@"https://%@.api.riotgames.com/lol/league/v3/positions/by-summoner/%@?api_key=%@",self.regions[self.selectedRegion], summoner.summonerID, self.apiKey];
    [self getURLData:requestString withKey:@"queueType" withData:@"RANKED_SOLO_5x5"];
    while (!self.completionFlag) {
    }
    
    if ([self checkDataIntegrity:self.dataDict]) {
        summoner.rank = [self.dataDict objectForKey:@"rank"];
        summoner.tier = [self.dataDict objectForKey:@"tier"];
        summoner.leaguePoints = [[self.dataDict objectForKey:@"leaguePoints"] integerValue];
        summoner.soloWins = [[self.dataDict objectForKey:@"wins"] floatValue];
        summoner.soloLosses = [[self.dataDict objectForKey:@"losses"] floatValue];
        summoner.soloLeagueID = [self.dataDict objectForKey:@"leagueId"];
        summoner.soloWinrate = (summoner.soloWins/(summoner.soloLosses + summoner.soloWins))*100;
    }
}


- (void) leagueByLeagueID:(Summoner *)summoner { //League V3 Call
    NSString *requestString = [NSString stringWithFormat:@"https://%@.api.riotgames.com/lol/league/v3/leagues/%@?api_key=%@",self.regions[self.selectedRegion], summoner.soloLeagueID, self.apiKey];
    [self getURLData:requestString withKey:NULL withData:NULL];
    while (!self.completionFlag) {
    }
    
    //At this point, self.dataDict is a list of all players in the summoner's league that needs to be sorted
    if ([self checkDataIntegrity:self.dataDict]) {
        NSMutableArray *tempArray = [self.dataDict objectForKey:@"entries"];
        
        for (NSDictionary *entry in tempArray) { //If the player is the same rank, we add them to the ladder
            if ([[entry objectForKey:@"rank"] isEqual:summoner.rank]) {
                Summoner *ladderSummoner = [[Summoner alloc] init];
                ladderSummoner.summonerName = [entry objectForKey:@"playerOrTeamName"];
                ladderSummoner.summonerID = [entry objectForKey:@"playerOrTeamId"];
                ladderSummoner.rank = [entry objectForKey:@"rank"];
                ladderSummoner.tier = summoner.tier;
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


- (void) activeGameBySummoner:(Summoner *)summoner { //Spectator V3 Call
    NSString *requestString = [NSString stringWithFormat:@"https://%@.api.riotgames.com/lol/spectator/v3/active-games/by-summoner/%@?api_key=%@", self.regions[self.selectedRegion], summoner.summonerID, self.apiKey];
    [self getURLData:requestString withKey:NULL withData:NULL]; //Already a dictionary so we NULL arguments
    while (!self.completionFlag) {
    }
    
    if ([self checkDataIntegrity:self.dataDict]) { //Data dict is a list of the current game data
        NSMutableArray *tempArray = [self.dataDict objectForKey:@"participants"];
        
        for (NSDictionary *entry in tempArray) {
            Summoner *gameSummoner = [[Summoner alloc] init];
            gameSummoner.summonerName = [entry objectForKey:@"summonerName"];
            gameSummoner.summonerID = [entry objectForKey:@"summonerId"];
            gameSummoner.currentChamp = [self searchChampList:[[entry objectForKey:@"championId"] integerValue]];
            [self championMasteryBySummoner:gameSummoner];
            [self leaguePositionsBySummoner:gameSummoner];
            
            [self.liveGamePlayers addObject:gameSummoner];
        }
    }
}

@end
