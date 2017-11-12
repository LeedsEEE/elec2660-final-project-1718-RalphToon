//
//  ProfileViewController.m
//  FinalProject-LOLRankedCompanion
//
//  Created by Ralph Toon on 03/11/2017.
//  Copyright © 2017 University of Leeds. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    DataModel *dataModel = [DataModel sharedInstance]; //This allows us to use the DataModel
    self.nameLabel.text = dataModel.currentUserSummoner.summonerName;
    self.rankLabel.text = [NSString stringWithFormat:@"Rank = %@", dataModel.currentUserSummoner.rank];
    self.lpLabel.text = [NSString stringWithFormat:@"LP = %ld", dataModel.currentUserSummoner.leaguePoints];
    self.winLabel.text = [NSString stringWithFormat:@"text", dataModel.currentUserSummoner.soloWins];
    self.lossLabel.text = dataModel.currentUserSummoner.summonerName;
    self.winPercentLabel.text = dataModel.currentUserSummoner.summonerName;
    self.favChampLabel.text = dataModel.currentUserSummoner.summonerName;
    self.mastereyLabel.text = dataModel.currentUserSummoner.summonerName;
    //self.rankImage.image = ;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
