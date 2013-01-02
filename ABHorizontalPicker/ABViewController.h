//
//  ABViewController.h
//  ABHorizontalPicker
//
//  Created by Alex on 12/23/12.
//  Copyright (c) 2012 Alex Basson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABHorizontalPickerView.h"

@interface ABViewController : UIViewController <ABHorizontalPickerViewDataSource, ABHorizontalPickerViewDelegate>

@property (nonatomic, weak) IBOutlet ABHorizontalPickerView *pickerView;
@property (nonatomic, weak) IBOutlet UILabel *numbersLabel;
@property (nonatomic, weak) IBOutlet UILabel *lettersLabel;

@end
