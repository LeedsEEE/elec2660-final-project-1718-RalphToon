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
        self.apiKey = @"RGAPI-7301f26b-d469-47f5-8584-314e646a77e7"; //ENTER API KEY HERE
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
            isArray:(BOOL)arrayFlag {
    self.completionFlag = NO;
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:requestString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (arrayFlag) { //If data is in array format, we need to do some extra processing
            NSMutableArray *tempArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            self.dataDict = tempArray[0];
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
    [self getURLData:requestString isArray:NO];  //Manually setting isArray is cumbersome, find a way to detect
    while (!self.completionFlag) { //Holds the program until data is recieved
    }                              //This is not best practice, update if time is left
    
    if ([self checkDataIntegrity:self.dataDict]){
        self.currentUserSummoner.summonerName = [self.dataDict objectForKey:@"name"];
        self.currentUserSummoner.summonerID = [self.dataDict objectForKey:@"id"];
        self.currentUserSummoner.accountID = [self.dataDict objectForKey:@"accountId"];
    }
    
    //CHAMPION MASTEREY V3 CALL
    requestString = [NSString stringWithFormat:@"https://euw1.api.riotgames.com/lol/champion-mastery/v3/champion-masteries/by-summoner/%@?api_key=%@", self.currentUserSummoner.summonerID, self.apiKey];
    [self getURLData:requestString isArray:YES];
    while (!self.completionFlag) {
    }
    
    if ([self checkDataIntegrity:self.dataDict]) {
        self.currentUserSummoner.champMastery = [[self.dataDict objectForKey:@"championPoints"] integerValue];
        requestString = [NSString stringWithFormat:@"https://euw1.api.riotgames.com/lol/static-data/v3/champions/%@?locale=en_US&api_key=%@", [self.dataDict objectForKey:@"championId"], self.apiKey];
        [self getURLData:requestString isArray:NO];
        while (!self.completionFlag) {
        }
        self.currentUserSummoner.favChamp = [self.dataDict objectForKey:@"name"];

    }
    
    //LEAGUE V3 CALL
    
}


-(void) populateLadder {
    [self.dataDict removeAllObjects]; //Clear the dictionary for the new data
    
}

-(void) populatePlayers {
    [self.dataDict removeAllObjects]; //Clear the dictionary for the new data
    
}


@end
