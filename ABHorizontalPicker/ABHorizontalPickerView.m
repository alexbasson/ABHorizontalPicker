//
//  ABHorizontalPicker.m
//  ABHorizontalPicker
//
//  Created by Alex on 12/23/12.
//  Copyright (c) 2012 Alex Basson. All rights reserved.
//

#import "ABHorizontalPickerView.h"

@interface ABHorizontalPickerView () {
    NSMutableArray *_components;
    NSMutableArray *_numberOfBufferCells;
}
@end

@implementation ABHorizontalPickerView

@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize numberOfComponents = _numberOfComponents;
@synthesize showsSelectionIndicator = _showsSelectionIndicator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    [self setBackgroundColor:[UIColor blackColor]];
    CGFloat ycoord = 0.f;
    for (NSInteger i = 0; i < [self numberOfComponents]; i++) {
        ycoord += 1.f;
        CGFloat height = 0.f;
        CGFloat columnWidth = 0.f;
        if (_delegate) {
            if ([_delegate respondsToSelector:@selector(pickerView:heightForComponent:)]) {
                height = [_delegate pickerView:self heightForComponent:i];
            } else {
                NSLog(@"Error: Delegate must implement pickerView:heightForComponent:");
            }
            if ([_delegate respondsToSelector:@selector(pickerView:columnWidthForComponent:)]) {
                columnWidth = [_delegate pickerView:self columnWidthForComponent:i];
            } else {
                NSLog(@"Error: Delegate must implement pickerView:columnWidthForComponent:");
            }
        }
        CGRect frame = CGRectMake([self bounds].origin.x, ycoord, [self bounds].size.width, height);
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setMinimumInteritemSpacing:0.f];
        [flowLayout setMinimumLineSpacing:0.f];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [flowLayout setItemSize:CGSizeMake(columnWidth, height)];
        UICollectionView *component = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
        [component setDataSource:self];
        [component setDelegate:self];
        [component registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ABHoriontalPickerViewCell"];
        [component setShowsHorizontalScrollIndicator:NO];
        [component setShowsVerticalScrollIndicator:NO];
        [_components addObject:component];
        [self addSubview:component];
    }
}

#pragma mark - Column <-> Item conversions

- (NSInteger)itemForColumn:(NSInteger)column
{
    return column;
}

- (NSInteger)columnForItem:(NSInteger)item
{
    return item;
}

#pragma mark - property accessors

- (NSInteger)numberOfComponents
{
    if (_numberOfComponents) {
        return _numberOfComponents;
    }
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(numberOfComponentsInPickerView:)]) {
        _numberOfComponents = [_dataSource numberOfComponentsInPickerView:self];
    } else {
        NSLog(@"Error: No dataSource set for ABHorizontalPickerView: %p", self);
    }
    return _numberOfComponents;
}

- (BOOL)showsSelectionIndicator
{
    if (_showsSelectionIndicator) {
        return _showsSelectionIndicator;
    } else {
        return NO;
    }
}

#pragma mark - Getting the Dimensions of the View Picker

- (NSInteger)numberOfColumnsInComponent:(NSInteger)component
{
    NSInteger numberOfColumns = 0;
    if (_dataSource && [_dataSource respondsToSelector:@selector(pickerView:numberOfColumnsInComponent:)]) {
        numberOfColumns = [_dataSource pickerView:self numberOfColumnsInComponent:component];
    }
    return numberOfColumns;
}

- (CGSize)columnSizeForComponent:(NSInteger)component
{
    CGFloat height = 0.f;
    CGFloat width = 0.f;
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(pickerView:heightForComponent:)]) {
            height = [_delegate pickerView:self heightForComponent:component];
        }
        
        if ([_delegate respondsToSelector:@selector(pickerView:columnWidthForComponent:)]) {
            width = [_delegate pickerView:self columnWidthForComponent:component];
        }
    }
    return CGSizeMake(width, height);
}

#pragma mark - Reloading the View Picker

- (void)reloadAllComponents
{
    for (UICollectionView *component in _components) {
        [component reloadData];
    }
}

- (void)reloadComponent:(NSInteger)component
{
    [(UICollectionView *)_components[component] reloadData];
}

#pragma mark - Selecting Columns in the View Picker

- (NSInteger)selectedColumnInComponent:(NSInteger)component
{
    NSInteger selectedColumn = 0;
    return selectedColumn;
}

- (void)selectColumn:(NSInteger)column inComponent:(NSInteger)component animated:(BOOL)animated
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self itemForColumn:column] inSection:0];
    [(UICollectionView *)_components[component] selectItemAtIndexPath:indexPath animated:animated scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

#pragma mark - Returning the View for a Column and Component

- (UIView *)viewForColumn:(NSInteger)column forComponent:(NSInteger)component
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self itemForColumn:column] inSection:0];
    UICollectionViewCell *cell = [(UICollectionView *)_components[component] cellForItemAtIndexPath:indexPath];
    UIView *view = [cell contentView];
    if (!view && _delegate && [_delegate respondsToSelector:@selector(pickerView:viewForColumn:forComponent:reusingView:)]) {
        view = [_delegate pickerView:self viewForColumn:column forComponent:component reusingView:view];
    }
    return view;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfItems = 0;
    if (section == 0) {
        NSInteger component = [_components indexOfObject:collectionView];
        if (_dataSource && [_dataSource respondsToSelector:@selector(pickerView:numberOfColumnsInComponent:)]) {
            numberOfItems = [_dataSource pickerView:self numberOfColumnsInComponent:component] + 2*[(NSNumber *)_numberOfBufferCells[component] integerValue];
        }
    }
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger component = [_components indexOfObject:collectionView];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ABHorizontalPickerViewCell" forIndexPath:indexPath];
    
    if ([self columnForItem:[indexPath row]] < 0 || [self columnForItem:[indexPath row]] > [_dataSource pickerView:self numberOfColumnsInComponent:component]) {
        return cell;
    }

    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(pickerView:viewForColumn:forComponent:reusingView:)]) {
            UIView *view = [[cell contentView] subviews][0];
            if (!view) {
                view = [_delegate pickerView:self viewForColumn:[self columnForItem:[indexPath row]] forComponent:component reusingView:view];
            }
            [[cell contentView] addSubview:view];
        } else {
            UILabel *contentLabel = [[UILabel alloc] initWithFrame:[[cell contentView] bounds]];
            if ([_delegate respondsToSelector:@selector(pickerView:attributedTitleForColumn:forComponent:)]) {
                [contentLabel setAttributedText:[_delegate pickerView:self attributedTitleForColumn:[self columnForItem:[indexPath row]] forComponent:component]];
            } else if ([_delegate respondsToSelector:@selector(pickerView:titleForColumn:forComponent:)]) {
                [contentLabel setText:[_delegate pickerView:self titleForColumn:[self columnForItem:[indexPath row]] forComponent:component]];
            } else {
                NSLog(@"Error: Delegate must implement either pickerView:viewForColumn:forComponent:reusingView: or pickerView:titleForColumn:forComponent:");
            }
            [[cell contentView] addSubview:contentLabel];
        }
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate methods




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
