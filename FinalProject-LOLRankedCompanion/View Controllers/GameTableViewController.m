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
    //This can be updated to allow for different gamemodes with
    //different team sizes. By default we assume SR game for testing.
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gameTableCell" forIndexPath:indexPath];
    DataModel *dataModel = [DataModel sharedInstance];
    if (indexPath.section == 0) {
        Summoner *tempSummoner = dataModel.liveGamePlayers[indexPath.row];
        cell.textLabel.text = tempSummoner.summonerName;
        //cell.detailTextLabel.text = tempSummoner.currentChamp;
        //cell.imageView.image = [UIImage imageNamed:imageName];
    }
    
    else if (indexPath.section == 1) {
        Summoner *tempSummoner = dataModel.liveGamePlayers[(indexPath.row +5)];
        cell.textLabel.text = tempSummoner.summonerName;
        //cell.detailTextLabel.text = tempSummoner.currentChamp;
        //cell.imageView.image = [UIImage imageNamed:imageName];
    }
    cell.textLabel.textColor = [UIColor whiteColor];
    //cell.detailTextLabel.textColor = [UIColor colorWithRed:0.99 green:0.76 blue:0.0 alpha:0.9]; //Gold
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
