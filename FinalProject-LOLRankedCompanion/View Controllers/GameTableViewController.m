//
//  GameTableViewController.m
//  FinalProject-LOLRankedCompanion
//
//  Created by Ralph Toon on 08/11/2017.
//  Copyright © 2017 University of Leeds. All rights reserved.
//

#import "GameTableViewController.h"

@interface GameTableViewController ()

@end

@implementation GameTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - GameTableView data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2; //Sections will always be 2 as there are always 2 teams
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return 5; //LOL games are always 5v5
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gameTableCell" forIndexPath:indexPath];
    DataModel *dataModel = [DataModel sharedInstance];
    
    if (indexPath.section == 0) {
        Summoner *tempSummoner = dataModel.liveGamePlayers[indexPath.row];
        cell.textLabel.text = tempSummoner.summonerName;
        cell.detailTextLabel.text = tempSummoner.currentChamp;
        NSString *champName = [tempSummoner.currentChamp stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSString *imageName = [NSString stringWithFormat:@"%@Square.png", champName];
        cell.imageView.image = [UIImage imageNamed:imageName];
    }
    else if (indexPath.section == 1) {
        Summoner *tempSummoner = dataModel.liveGamePlayers[(indexPath.row +5)];
        cell.textLabel.text = tempSummoner.summonerName;
        cell.detailTextLabel.text = tempSummoner.currentChamp;
        NSString *champName = [tempSummoner.currentChamp stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSString *imageName = [NSString stringWithFormat:@"%@Square.png", champName];
        cell.imageView.image = [UIImage imageNamed:imageName];
    }
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.99 green:0.76 blue:0.0 alpha:0.9]; //Gold
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    NSString *headerName;
    
    if (section == 0) {
        headerName = @"Blue Team";
    }
    else if (section == 1) {
        headerName = @"Red Team";
    }
    
    return headerName;
}


- (void)tableView:(UITableView *)tableView
willDisplayHeaderView:(UIView *)view
       forSection:(NSInteger)section {
    // Background color
    view.tintColor = [UIColor lightGrayColor];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    if (section == 0) {
        [header.textLabel setTextColor:[UIColor blueColor]];
    }
    else if (section == 1) {
        [header.textLabel setTextColor:[UIColor redColor]];
    }
    
    //Adapted from https://happyteamlabs.com/blog/ios-how-to-customize-table-view-header-and-footer-colors/
}



#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PlayerDetailViewController *destinationViewController = [segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow]; //gets co-ord of cell

    if ([[segue identifier]isEqualToString:@"showPlayerDetails"]) {
        if (indexPath.section == 0) {
            destinationViewController.playerNumber = indexPath.row;
        }
        else {
            destinationViewController.playerNumber = (indexPath.row +5);
        }
    }
}

@end
