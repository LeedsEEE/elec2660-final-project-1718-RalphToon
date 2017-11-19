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
        self.apiKey = @"RGAPI-2222e3eb-4927-43b9-aa34-9806bdf786d4"; //ENTER API KEY HERE
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

- (void) getURLData:(NSString *)requestString { //Everytime this is called 1 request is used (20/sec 100/2mins MAX)
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:requestString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        self.dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];

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
    //Generate the request string
    NSString *requestString = [NSString stringWithFormat:@"https://euw1.api.riotgames.com/lol/summoner/v3/summoners/by-name/%@?api_key=%@", name, self.apiKey];
    self.completionFlag = NO;
    [self getURLData:requestString];
    while (!self.completionFlag) {
    }
    
    if ([self checkDataIntegrity:self.dataDict]){
        self.currentUserSummoner.summonerName = [self.dataDict objectForKey:@"name"];
        self.currentUserSummoner.summonerID = [self.dataDict objectForKey:@"id"];
        self.currentUserSummoner.accountID = [self.dataDict objectForKey:@"accountId"];
    }
}

-(void) populateLadder {
    [self.dataDict removeAllObjects]; //Clear the dictionary for the new data
    
}

-(void) populatePlayers {
    [self.dataDict removeAllObjects]; //Clear the dictionary for the new data
    
}


@end
