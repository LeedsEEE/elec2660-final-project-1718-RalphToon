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

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.apiKey = @""; //ENTER API KEY HERE
    }
    return self;
}

+(DataModel *) sharedInstance { //This creates the shared data model if it doesnt exist
    if (!_sharedInstance) {
        _sharedInstance = [[DataModel alloc] init];
    }
    return _sharedInstance;
}


#pragma mark api data aquisition methods
//CHECK HOW TO GET RESPONSE USING THIS
- (NSDictionary *) getURLData:(NSString *)requestString { //Everytime this is called 1 request is used (20/sec 100/2mins MAX)
    //Following code adapted from https://www.codementor.io/rheller/getting-reading-json-data-from-url-objective-c-du107s5mf
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:requestString]];
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    return dataDict;
}


- (void) populateSummoner:(NSString *)name {
    //Generate the request string
    NSString *requestString = [NSString stringWithFormat:@"https://euw1.api.riotgames.com/lol/summoner/v3/summoners/by-name/%@?api_key=%@", name, self.apiKey];
    NSDictionary *dataDict = [self getURLData:requestString];
    
    self.currentUserSummoner.summonerName = [dataDict objectForKey:@"name"];
    self.currentUserSummoner.summonerID = [dataDict objectForKey:@"id"];
    self.currentUserSummoner.accountID = [dataDict objectForKey:@"accountId"];
}

-(void) populateLadder {
    
}

-(void) populatePlayers {
    
}


@end
