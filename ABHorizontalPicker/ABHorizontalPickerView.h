//
//  ABHorizontalPicker.h
//  ABHorizontalPicker
//
//  Created by Alex on 12/23/12.
//  Copyright (c) 2012 Alex Basson. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ABHorizontalPickerView;

#pragma mark - ABHorizontalPickerViewDataSource protocol
@protocol ABHorizontalPickerViewDataSource <NSObject>

@required
// Providing Counts for the ABHorizontalPicker View
- (NSInteger)numberOfComponentsInPickerView:(ABHorizontalPickerView *)pickerView;
- (NSInteger)pickerView:(ABHorizontalPickerView *)pickerView numberOfColumnsInComponent:(NSInteger)component;

@end



#pragma mark - ABHorizontalPickerViewDelegate protocol
@protocol ABHorizontalPickerViewDelegate <NSObject>

@required
// Setting the Dimensions of the ABHorizontalPicker View
- (CGFloat)pickerView:(ABHorizontalPickerView *)pickerView columnWidthForComponent:(NSInteger)component;
- (CGFloat)pickerView:(ABHorizontalPickerView *)pickerView heightForComponent:(NSInteger)component;

@optional
// Setting the Content of Component Columns
- (NSAttributedString *)pickerView:(ABHorizontalPickerView *)pickerView attributedTitleForColumn:(NSInteger)column forComponent:(NSInteger)component;
- (NSString *)pickerView:(ABHorizontalPickerView *)pickerView titleForColumn:(NSInteger)column forComponent:(NSInteger)component;
- (UIView *)pickerView:(ABHorizontalPickerView *)pickerView viewForColumn:(NSInteger)column forComponent:(NSInteger)component reusingView:(UIView *)view;

// Responding to Column Selection
- (void)pickerView:(ABHorizontalPickerView *)pickerView didSelectColumn:(NSInteger)column inComponent:(NSInteger)component;

@end




#pragma mark - ABHorizontalPickerView @interface
@interface ABHorizontalPickerView : UIView

@property (nonatomic, assign) id<ABHorizontalPickerViewDataSource> dataSource;
@property (nonatomic, assign) id<ABHorizontalPickerViewDelegate> delegate;
@property (nonatomic, readonly) NSInteger numberOfComponents;
@property (nonatomic) BOOL showsSelectionIndicator;

- (NSInteger)numberOfColumnsInComponent:(NSInteger)component;
- (CGSize)columnSizeForComponent:(NSInteger)component;

- (void)reloadAllComponents;
- (void)reloadComponent:(NSInteger)component;

- (NSInteger)selectedColumnInComponent:(NSInteger)component;
- (void)selectColumn:(NSInteger)column inComponent:(NSInteger)component animated:(BOOL)animated;

- (UIView *)viewForColumn:(NSInteger)column forComponent:(NSInteger)component;

@end
