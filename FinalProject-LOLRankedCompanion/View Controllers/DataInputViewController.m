//
//  DataInputViewController.m
//  FinalProject-LOLRankedCompanion
//
//  Created by Ralph Toon on 08/11/2017.
//  Copyright © 2017 University of Leeds. All rights reserved.
//

#import "DataInputViewController.h"

@interface DataInputViewController ()

@end

@implementation DataInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.showProfileButton.enabled = NO;
    self.errorLabel.hidden = YES;
    self.regionPicker.delegate = self;
    self.regionPicker.dataSource = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark DataInput button methods
- (IBAction)getDataPressed:(id)sender { //This triggers the dataModel to populate itself
    DataModel *dataModel = [DataModel sharedInstance];
    dataModel.errorMessage = @"";
    [dataModel populateSummoner:self.nameField.text]; //Attempt to populate the summoner
    if ([dataModel.errorMessage isEqualToString:@"Empty data array returned"]) {
        dataModel.errorMessage = @"Note: User is unranked and has no Ladder";
    }
    
    if ([dataModel.errorMessage isEqualToString:@""] || [dataModel.errorMessage isEqualToString:@"Note: User is unranked and has no Ladder"]) {
        //If we have no error getting the summoner, we can get the other data
        if ([dataModel.currentUserSummoner.soloLeagueID length]>0) { //If the player has a league, we retrieve it
            [dataModel populateLadder];
        }
        
        /*
         We try to populate the game whether it exists or not
         As we have no test to see if one does.
         If the player is not in a game this simply returns an error message that we can ignore.
        */
        [dataModel populatePlayers];
        self.errorLabel.text = dataModel.errorMessage;
        self.errorLabel.hidden = NO;
        self.showProfileButton.enabled = YES;
        
    }
    
    else { //If we dont get valid summoner data, we dont let the user into the app
        self.showProfileButton.enabled = NO;
        self.errorLabel.text = dataModel.errorMessage;
        self.errorLabel.hidden = NO;
    }
}


- (IBAction)showProfilePressed:(id)sender {
}



#pragma mark RegionPicker delegate methods
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView
             attributedTitleForRow:(NSInteger)row
                      forComponent:(NSInteger)component {
    DataModel *dataModel = [DataModel sharedInstance];
    NSString *regionString = [NSString stringWithFormat:@"%@", dataModel.regions[row]];
    NSAttributedString *region = [[NSAttributedString alloc] initWithString:regionString attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //Above line adapted from https://stackoverflow.com/questions/19232817/how-do-i-change-the-color-of-the-text-in-a-uipickerview-under-ios-7
    return region;
}


- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    DataModel *dataModel = [DataModel sharedInstance];
    dataModel.selectedRegion = row; //Simply get the array index
}



#pragma mark RegionPicker data source methods
- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    NSInteger components = 1; //We only need to display 1 column of regions
    return components;
}


- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    NSInteger rows = 11; //We have 11 regions, this is fixed by riot
    return rows;
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
