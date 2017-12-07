//
//  LadderTableViewController.m
//  FinalProject-LOLRankedCompanion
//
//  Created by Ralph Toon on 08/11/2017.
//  Copyright © 2017 University of Leeds. All rights reserved.
//

#import "LadderTableViewController.h"

@interface LadderTableViewController ()

@end

@implementation LadderTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DataModel *dataModel = [DataModel sharedInstance];
    
    //Programatically create the overall table header
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    
    [headerLabel setTextColor:[UIColor colorWithRed:0.99 green:0.76 blue:0.0 alpha:0.9]];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    [headerLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 26.0f]];
    headerLabel.text = [NSString stringWithFormat:@"%@ %@: %@", dataModel.currentUserSummoner.tier, dataModel.currentUserSummoner.rank, dataModel.currentUserSummoner.soloLeagueName];
    headerLabel.clipsToBounds = YES;
    headerLabel.textAlignment = 1;
    
    //Above code adapted from: https://stackoverflow.com/questions/3209803/how-to-programmatically-add-text-to-a-uiview
    self.tableView.tableHeaderView = headerLabel;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - LadderTableView data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1; //We only have 1 section, the list of ranked players
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    DataModel *dataModel = [DataModel sharedInstance];
    NSInteger numberOfRows = [dataModel.currentUserLadder count]; //Make rows for each player in the ladder
    return numberOfRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {   //This method configures cell contents
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ladderTableCell" forIndexPath:indexPath];
    DataModel *dataModel = [DataModel sharedInstance];
    Summoner *tempSummoner = dataModel.currentUserLadder[indexPath.row];
    cell.textLabel.text = tempSummoner.summonerName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ldLP", tempSummoner.leaguePoints];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.99 green:0.76 blue:0.0 alpha:0.9]; //Gold

    return cell;
}

@end
