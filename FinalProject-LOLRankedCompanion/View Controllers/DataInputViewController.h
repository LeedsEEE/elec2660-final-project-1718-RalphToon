//
//  DataInputViewController.h
//  FinalProject-LOLRankedCompanion
//
//  Created by Ralph Toon on 08/11/2017.
//  Copyright © 2017 University of Leeds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"

@interface DataInputViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *showProfileButton;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *regionPicker;

- (IBAction)getDataPressed:(id)sender;
- (IBAction)showProfilePressed:(id)sender;
- (IBAction)backgroundPressed:(id)sender;

@end
