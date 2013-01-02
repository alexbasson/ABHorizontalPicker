//
//  ABViewController.m
//  ABHorizontalPicker
//
//  Created by Alex on 12/23/12.
//  Copyright (c) 2012 Alex Basson. All rights reserved.
//

#import "ABViewController.h"

typedef enum {
    NUMBERS_COMPONENT = 0,
    LETTERS_COMPONENT = 1
} components;

@interface ABViewController () {
    NSArray *_numbers;
    NSArray *_letters;
    NSArray *_components;
}

@end

@implementation ABViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _numbers = @[@0, @5, @10, @15, @20, @25, @30, @35, @40, @45, @50, @55, @60, @65, @70, @75, @80, @85, @90, @95, @100];
    _letters = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    _components = @[_numbers, _letters];
    
    for (NSInteger component = 0; component < [_components count]; component++) {
        [[self pickerView] selectColumn:0 inComponent:component animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ABHorizontalPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(ABHorizontalPickerView *)pickerView
{
    return 2;//[_components count];
}

- (NSInteger)pickerView:(ABHorizontalPickerView *)pickerView numberOfColumnsInComponent:(NSInteger)component
{
    return [_components[component] count];
}


#pragma mark - ABHorizontalPickerViewDelegate methods

- (CGFloat)pickerView:(ABHorizontalPickerView *)pickerView heightForComponent:(NSInteger)component
{
    return 44.f;
}

- (CGFloat)pickerView:(ABHorizontalPickerView *)pickerView columnWidthForComponent:(NSInteger)component
{
    return 60.f;
}

- (NSString *)pickerView:(ABHorizontalPickerView *)pickerView titleForColumn:(NSInteger)column forComponent:(NSInteger)component
{
    NSString *title;
    switch (component) {
        case NUMBERS_COMPONENT:
            title = [(NSNumber *)_components[component][column] stringValue];
            break;
        case LETTERS_COMPONENT:
            title = _components[component][column];
            break;
        default:
            title = @"";
            break;
    }
    return title;
}

- (void)pickerView:(ABHorizontalPickerView *)pickerView didSelectColumn:(NSInteger)column inComponent:(NSInteger)component
{
    switch (component) {
        case NUMBERS_COMPONENT:
            [[self numbersLabel] setText:[(NSNumber *)_numbers[column] stringValue]];
            break;
        case LETTERS_COMPONENT:
            [[self lettersLabel] setText:_letters[column]];
            break;
        default:
            break;
    }
}


@end
