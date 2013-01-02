//
//  ABHorizontalPicker.m
//  ABHorizontalPicker
//
//  Created by Alex on 12/23/12.
//  Copyright (c) 2012 Alex Basson. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ABHorizontalPickerView.h"

#pragma mark - UICollectionView category
//================================
// UICollectionView category
//================================
@implementation UICollectionView (ABCollectionView)
- (NSIndexPath *)indexPathForItemInCenter
{
    CGFloat centerX = [self contentOffset].x + [self center].x;
    CGFloat centerY = [self bounds].origin.y + [self bounds].size.height/2.f;
    return [self indexPathForItemAtPoint:CGPointMake(centerX, centerY)];
}
@end


#pragma mark - ABHorizontalPicker implementation
//================================
// ABHorizontalPicker
//================================
@interface ABHorizontalPickerView () {
    CGFloat _columnWidth;
    CGFloat _componentHeight;
    NSMutableArray *_components;
    NSMutableArray *_numberOfBufferCellsForComponent;
    NSMutableArray *_cellIdentifiers;
    BOOL _scrolling;
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
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(numberOfComponentsInPickerView:)]) {
        _numberOfComponents = [_dataSource numberOfComponentsInPickerView:self];
    }

    _components = [NSMutableArray arrayWithCapacity:_numberOfComponents];
    _cellIdentifiers = [NSMutableArray arrayWithCapacity:_numberOfComponents];
    _numberOfBufferCellsForComponent = [NSMutableArray arrayWithCapacity:_numberOfComponents];
    _scrolling = NO;
    
    CGFloat ycoord = 0.f;
    for (NSInteger i = 0; i < _numberOfComponents; i++) {
        ycoord += 2.f;
        CGFloat componentHeight = 0.f;
        CGFloat columnWidth = 0.f;
        if (_delegate) {
            if ([_delegate respondsToSelector:@selector(pickerView:heightForComponent:)]) {
                componentHeight = [_delegate pickerView:self heightForComponent:i];
            } else {
                NSLog(@"Error: Delegate must implement pickerView:heightForComponent:");
            }
            if ([_delegate respondsToSelector:@selector(pickerView:columnWidthForComponent:)]) {
                columnWidth = [_delegate pickerView:self columnWidthForComponent:i];
                _numberOfBufferCellsForComponent[i] = @(floorf(([self bounds].size.width/2.f)/columnWidth) + 1.f);
            } else {
                NSLog(@"Error: Delegate must implement pickerView:columnWidthForComponent:");
            }
        }
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [flowLayout setItemSize:CGSizeMake(columnWidth, componentHeight)];
        [flowLayout setMinimumInteritemSpacing:0.f];
        [flowLayout setMinimumLineSpacing:0.f];

        CGRect componentFrame = CGRectMake([self bounds].origin.x, ycoord, [self bounds].size.width, componentHeight);
        UICollectionView *component = [[UICollectionView alloc] initWithFrame:componentFrame collectionViewLayout:flowLayout];
        NSString *cellIdentifier = [@"PickerCellForComponent" stringByAppendingFormat:@"%i", i];
        [component registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
        [component setDataSource:self];
        [component setDelegate:self];
        [component setShowsHorizontalScrollIndicator:NO];
        [component setBounces:NO];
        [self addSubview:component];
        
        if (_showsSelectionIndicator) {
            UIView *selectionIndicator = [[UIView alloc] initWithFrame:CGRectMake([self center].x - columnWidth/2.f, ycoord, columnWidth, componentHeight)];
            [selectionIndicator setBackgroundColor:[UIColor blueColor]];
            [selectionIndicator setAlpha:0.2f];
            [selectionIndicator setUserInteractionEnabled:NO];
            [selectionIndicator layer].borderWidth = 1.f;
            [selectionIndicator layer].borderColor = [UIColor darkGrayColor].CGColor;
            [self addSubview:selectionIndicator];
        }
        
        [_components addObject:component];
        [_cellIdentifiers addObject:cellIdentifier];
        ycoord += componentHeight;
    }
    CGRect pickerFrame = [self frame];
    pickerFrame.size.height = ycoord + 2.f;
    [self setFrame:pickerFrame];
    [self setBackgroundColor:[UIColor blackColor]];
}

#pragma mark - Column <-> Item conversions

- (NSInteger)itemForColumn:(NSInteger)column forComponent:(NSInteger)component
{
    return column + [(NSNumber *)_numberOfBufferCellsForComponent[component] integerValue];
}

- (NSInteger)columnForItem:(NSInteger)item forComponent:(NSInteger)component
{
    NSInteger bufferCells = [(NSNumber *)_numberOfBufferCellsForComponent[component] integerValue];
    NSInteger numberOfItems = [self collectionView:_components[component] numberOfItemsInSection:0];
    if (item < bufferCells) {
        item = bufferCells;
    } else if (item > numberOfItems - bufferCells - 1) {
        item = numberOfItems - bufferCells - 1;
    }
    return item - bufferCells;
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
    UICollectionView *componentView = (UICollectionView *)_components[component];
    NSInteger selectedItem = [[componentView indexPathsForSelectedItems][0] row];
    return [self columnForItem:selectedItem forComponent:component];
}

- (void)selectColumn:(NSInteger)column inComponent:(NSInteger)component animated:(BOOL)animated
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self itemForColumn:column forComponent:component] inSection:0];
    [(UICollectionView *)_components[component] scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
    if (_delegate && [_delegate respondsToSelector:@selector(pickerView:didSelectColumn:inComponent:)]) {
        [_delegate pickerView:self didSelectColumn:column inComponent:component];
    }
}

#pragma mark - Returning the View for a Column and Component

- (UIView *)viewForColumn:(NSInteger)column forComponent:(NSInteger)component
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self itemForColumn:column forComponent:component] inSection:0];
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
            numberOfItems = [_dataSource pickerView:self numberOfColumnsInComponent:component] + 2*[(NSNumber *)_numberOfBufferCellsForComponent[component] integerValue];
        }
    }
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = _cellIdentifiers[[_components indexOfObject:collectionView]];
    NSInteger component = [_components indexOfObject:collectionView];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    NSInteger bufferCellsForComponent = [(NSNumber *)_numberOfBufferCellsForComponent[component] integerValue];
    NSInteger numberOfItems = [self collectionView:collectionView numberOfItemsInSection:[indexPath section]];
    if ([indexPath row] >= bufferCellsForComponent && [indexPath row] < numberOfItems - bufferCellsForComponent) {
        if (_delegate) {
            if ([_delegate respondsToSelector:@selector(pickerView:viewForColumn:forComponent:reusingView:)]) {
                for (UIView *subview in [[cell contentView] subviews]) {
                    [subview removeFromSuperview];
                }
                [[cell contentView] addSubview:[_delegate pickerView:self
                                                       viewForColumn:[indexPath row] - bufferCellsForComponent
                                                        forComponent:component
                                                         reusingView:[cell contentView]]];
            } else {
                for (UIView *subview in [[cell contentView] subviews]) {
                    [subview removeFromSuperview];
                }
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:[[cell contentView] bounds]];
                [titleLabel setTextAlignment:NSTextAlignmentCenter];
                NSInteger column = [indexPath row] - bufferCellsForComponent;
                if ([_delegate respondsToSelector:@selector(pickerView:attributedTitleForColumn:forComponent:)]) {
                    [titleLabel setAttributedText:[_delegate pickerView:self attributedTitleForColumn:column forComponent:component]];
                } else if ([_delegate respondsToSelector:@selector(pickerView:titleForColumn:forComponent:)]) {
                    [titleLabel setText:[_delegate pickerView:self titleForColumn:column forComponent:component]];
                } else {
                    NSLog(@"Error: Delegate must implement either pickerView:viewForColumn:forComponent:reusingView: or pickerView:titleForColumn:forComponent:");
                }
                [[cell contentView] addSubview:titleLabel];
            }
        }
    } else {
        for (UIView *subView in [[cell contentView] subviews]) {
            [subView removeFromSuperview];
        }
        [[cell contentView] setBackgroundColor:[UIColor whiteColor]];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger component = [_components indexOfObject:collectionView];
    NSInteger column = [self columnForItem:[indexPath row] forComponent:component];
    [self selectColumn:column inComponent:component animated:YES];
}

#pragma mark - UIScrollViewDelegate methods

- (void)snapToGrid:(UIScrollView *)scrollView
{
    [self collectionView:(UICollectionView *)scrollView didSelectItemAtIndexPath:[(UICollectionView *)scrollView indexPathForItemInCenter]];
    _scrolling = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger component = [_components indexOfObject:scrollView];
    NSInteger column = [self columnForItem:[[(UICollectionView *)scrollView indexPathForItemInCenter] row] forComponent:component];
    [_delegate pickerView:self didSelectColumn:column inComponent:component];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self snapToGrid:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self snapToGrid:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _scrolling = YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    _scrolling = NO;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
