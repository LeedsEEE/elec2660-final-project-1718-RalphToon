//
//  CustomTabBarViewController.m
//  FinalProject-LOLRankedCompanion
//
//  Created by Ralph Toon on 27/11/2017.
//  Copyright © 2017 University of Leeds. All rights reserved.
//

#import "CustomTabBarViewController.h"

@interface CustomTabBarViewController ()

@end

@implementation CustomTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    DataModel *dataModel = [DataModel sharedInstance];
    
    if ([dataModel.currentUserLadder count] == 0) { //Disable ladder tab if the user is unranked
        self.tabBar.items[2].enabled = NO;
    }
    if ([dataModel.liveGamePlayers count] == 0) { //Disable live game tab if the user is not in a game
        self.tabBar.items[1].enabled = NO;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
