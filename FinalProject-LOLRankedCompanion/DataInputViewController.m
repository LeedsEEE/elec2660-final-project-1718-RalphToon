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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)populateDataModel:(NSString *)name {
    DataModel *dataModel = [DataModel sharedInstance];
    [dataModel populateSummoner:name];
    //[dataModel populatePlayers];
    [dataModel populateLadder];
    
    if ([dataModel.errorMessage length]>0){
        self.errorLabel.text = dataModel.errorMessage;
    }
    
    else { //If we get valid data, we allow the user to the rest of the app
        self.showProfileButton.enabled = YES;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)getDataPressed:(id)sender {
    //For the following 2 lines:
    //top for UI testing, bottom for API testing.
    //Comment out as appropriate
    //self.showProfileButton.enabled = YES;
    [self populateDataModel:self.nameField.text];
}

- (IBAction)showProfilePressed:(id)sender {
}
@end
