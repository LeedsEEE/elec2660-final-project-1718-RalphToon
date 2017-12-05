//
//  PlayerDetailViewController.h
//  FinalProject-LOLRankedCompanion
//
//  Created by Ralph Toon on 03/11/2017.
//  Copyright © 2017 University of Leeds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"

@interface PlayerDetailViewController : UIViewController

@property NSInteger playerNumber; //We need this to determine the selected player in the table

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UILabel *lpLabel;
@property (weak, nonatomic) IBOutlet UILabel *winLabel;
@property (weak, nonatomic) IBOutlet UILabel *lossLabel;
@property (weak, nonatomic) IBOutlet UILabel *winPercentLabel;
@property (weak, nonatomic) IBOutlet UILabel *favChampLabel;
@property (weak, nonatomic) IBOutlet UILabel *champMasteryLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentChampLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rankImage;

- (void)updateView;

@end

