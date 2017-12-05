//
//  PlayerDetailViewController.m
//  FinalProject-LOLRankedCompanion
//
//  Created by Ralph Toon on 03/11/2017.
//  Copyright © 2017 University of Leeds. All rights reserved.
//

#import "PlayerDetailViewController.h"

@interface PlayerDetailViewController ()

@end

@implementation PlayerDetailViewController

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
    Summoner *selectedSummoner = dataModel.liveGamePlayers[self.playerNumber];
    
    self.nameLabel.text = selectedSummoner.summonerName;
    self.rankLabel.text = [NSString stringWithFormat:@"Rank = %@ %@", selectedSummoner.tier, selectedSummoner.rank];
    self.lpLabel.text = [NSString stringWithFormat:@"LP = %ld", selectedSummoner.leaguePoints];
    
    self.winLabel.text = [NSString stringWithFormat:@"Wins = %.0f", selectedSummoner.soloWins];
    self.lossLabel.text = [NSString stringWithFormat:@"Losses = %.0f", selectedSummoner.soloLosses];
    self.winPercentLabel.text = [NSString stringWithFormat:@"Win Percentage = %.1f", selectedSummoner.soloWinrate];
    
    self.favChampLabel.text = [NSString stringWithFormat:@"Favourite Champion = %@", selectedSummoner.favChamp];
    self.currentChampLabel.text = [NSString stringWithFormat:@"Current Champion = %@", selectedSummoner.currentChamp];
    self.champMasteryLabel.text = [NSString stringWithFormat:@"Mastery = %ld", selectedSummoner.champMastery];
    
    NSString *imageName = [NSString stringWithFormat:@"%@.png", [selectedSummoner.tier lowercaseString]];
    self.rankImage.image = [UIImage imageNamed:imageName];
}

@end
