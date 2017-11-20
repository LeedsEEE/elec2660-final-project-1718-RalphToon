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
    [self updateView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateView {
    DataModel *dataModel = [DataModel sharedInstance]; //This allows us to use the DataModel
    self.nameLabel.text = dataModel.currentUserSummoner.summonerName;
    self.favChampLabel.text = [NSString stringWithFormat:@"Favourite Champion = %@", dataModel.currentUserSummoner.favChamp];
    self.masteryLabel.text = [NSString stringWithFormat:@"Mastery = %ld", dataModel.currentUserSummoner.champMastery];
    
    /*
    self.rankLabel.text = [NSString stringWithFormat:@"Rank = %@ %@", dataModel.currentUserSummoner.tier, dataModel.currentUserSummoner.rank];
    self.lpLabel.text = [NSString stringWithFormat:@"LP = %ld", dataModel.currentUserSummoner.leaguePoints];
    
    self.winLabel.text = [NSString stringWithFormat:@"Wins = %ld", dataModel.currentUserSummoner.soloWins];
    self.lossLabel.text = [NSString stringWithFormat:@"Losses = %ld", dataModel.currentUserSummoner.soloLosses];
    self.winPercentLabel.text = [NSString stringWithFormat:@"Win Percentage = %.1f", dataModel.currentUserSummoner.soloWinrate];
    
    self.favChampLabel.text = [NSString stringWithFormat:@"Favourite Champion = %@", dataModel.currentUserSummoner.favChamp];
    self.masteryLabel.text = [NSString stringWithFormat:@"Mastery = %ld", dataModel.currentUserSummoner.champMastery];
    
    NSString *imageName = [NSString stringWithFormat:@"%@ .png", [dataModel.currentUserSummoner.tier lowercaseString]];
    self.rankImage.image = [UIImage imageNamed:imageName];
    */
}

@end
