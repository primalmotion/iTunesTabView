/*
 * TNiTunesTabView.j
 * AppKit
 *
 * Created by Francisco Tolmasky.
 * Copyright 2008, 280 North, Inc.
 *
 * Modified by Antoine Mercadal for the needs of Archipel Project
 * Copyright 2010 Antoine Mercadal
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

@import <AppKit/AppKit.j>

@import "TNiTunesTabViewItem.j"


/*
    Places tabs on top with a bezeled border.
    @global
    @group TNiTunesTabViewType
*/
TNTopTabsBezelBorder     = 0;

/*
    Displays no tabs and has a bezeled border.
    @global
    @group TNiTunesTabViewType
*/
TNNoTabsBezelBorder      = 4;
/*
    Has no tabs and displays a line border.
    @global
    @group TNiTunesTabViewType
*/
TNNoTabsLineBorder       = 5;
/*
    Displays no tabs and no border.
    @global
    @group TNiTunesTabViewType
*/
TNNoTabsNoBorder         = 6;

var TNiTunesTabViewBezelBorderLeftImage       = nil,
    TNiTunesTabViewBackgroundCenterImage      = nil,
    TNiTunesTabViewBezelBorderRightImage      = nil,
    TNiTunesTabViewBezelBorderColor           = nil,
    TNiTunesTabViewBezelBorderBackgroundColor = nil;

var LEFT_INSET  = 7.0,
    RIGHT_INSET = 7.0,
    TAB_WIDTH   = 95.0;

var TNiTunesTabViewDidSelectTabViewItemSelector           = 1,
    TNiTunesTabViewShouldSelectTabViewItemSelector        = 2,
    TNiTunesTabViewWillSelectTabViewItemSelector          = 4,
    TNiTunesTabViewDidChangeNumberOfTabViewItemsSelector  = 8;

/*!
    @ingroup appkit
    @class TNiTunesTabView

    This class represents a view that has multiple subviews (TNiTunesTabViewItem) presented as individual tabs.
    Only one TNiTunesTabViewItem is shown at a time, and other TNiTunesTabViewItems can be made visible
    (one at a time) by clicking on the TNiTunesTabViewItem's tab at the top of the tab view.

    THe currently selected TNiTunesTabViewItem is the view that is displayed.
*/
@implementation TNiTunesTabView : CPView
{
    CPView          _labelsView;
    CPView          _backgroundView;
    CPView          _separatorView;

    CPView          _auxiliaryView;
    CPView          _contentView;

    CPArray         _tabViewItems;
    TNiTunesTabViewItem   _selectedTabViewItem;

    TNiTunesTabViewType   _tabViewType;

    id              _delegate;
    unsigned        _delegateSelectors;
}

/*
    @ignore
*/
+ (CPColor)bezelBorderColor
{
    return TNiTunesTabViewBezelBorderColor;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        _tabViewType = TNTopTabsBezelBorder;
        _tabViewItems = [];
    }

    return self;
}

- (void)viewDidMoveToWindow
{
    if (_tabViewType != TNTopTabsBezelBorder || _labelsView)
        return;

    [self _createBezelBorder];
    [self layoutSubviews];
}

- (void)_createBezelBorder
{
    var bounds = [self bounds];
     bounds.size.width += LEFT_INSET;
     bounds.origin.x -= RIGHT_INSET;

    _labelsView = [[_TNiTunesTabLabelsView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(bounds), 0.0)];

     [_labelsView setTabView:self];
     [_labelsView setAutoresizingMask:CPViewWidthSizable];

     [self addSubview:_labelsView];

}


/*
    Lays out the subviews
    @ignore
*/
- (void)layoutSubviews
{
    if (_tabViewType == TNTopTabsBezelBorder)
    {
        var backgroundRect = [self bounds],
            labelsViewHeight = [_TNiTunesTabLabelsView height];

        backgroundRect.origin.y += labelsViewHeight;
        backgroundRect.size.height -= labelsViewHeight;

        [_backgroundView setFrame:backgroundRect];

        var auxiliaryViewHeight = 5.0;

        if (_auxiliaryView)
        {
            auxiliaryViewHeight = CGRectGetHeight([_auxiliaryView frame]);

            [_auxiliaryView setFrame:CGRectMake(LEFT_INSET, labelsViewHeight, CGRectGetWidth(backgroundRect) - LEFT_INSET - RIGHT_INSET, auxiliaryViewHeight)];
        }

        [_separatorView setFrame:CGRectMake(LEFT_INSET, labelsViewHeight + auxiliaryViewHeight, CGRectGetWidth(backgroundRect) - LEFT_INSET - RIGHT_INSET, 1.0)];
    }

    // TNNoTabsNoBorder
    [_contentView setFrame:[self contentRect]];
}

// Adding and Removing Tabs
/*!
    Adds a TNiTunesTabViewItem to the tab view.
    @param aTabViewItem the item to add
*/
- (void)addTabViewItem:(TNiTunesTabViewItem)aTabViewItem
{
    [self insertTabViewItem:aTabViewItem atIndex:[_tabViewItems count]];
}

/*!
    Inserts a TNiTunesTabViewItem into the tab view
    at the specified index.
    @param aTabViewItem the item to insert
    @param anIndex the index for the item
*/
- (void)insertTabViewItem:(TNiTunesTabViewItem)aTabViewItem atIndex:(unsigned)anIndex
{
    if (!_labelsView)
        [self _createBezelBorder];

    [_tabViewItems insertObject:aTabViewItem atIndex:anIndex];

    [_labelsView tabView:self didAddTabViewItem:aTabViewItem];

    [aTabViewItem setTabView:self];

    if ([_tabViewItems count] == 1)
        [self selectFirstTabViewItem:self];

    if (_delegateSelectors & TNiTunesTabViewDidChangeNumberOfTabViewItemsSelector)
        [_delegate tabViewDidChangeNumberOfTabViewItems:self];
}

/*!
    Removes the specified tab view item from the tab view.
    @param aTabViewItem the item to remove
*/
- (void)removeTabViewItem:(TNiTunesTabViewItem)aTabViewItem
{
    var index = [self indexOfTabViewItem:aTabViewItem];

    [_tabViewItems removeObjectIdenticalTo:aTabViewItem];

    [_labelsView tabView:self didRemoveTabViewItemAtIndex:index];

    [aTabViewItem setTabView:nil];

    if (_delegateSelectors & TNiTunesTabViewDidChangeNumberOfTabViewItemsSelector)
        [_delegate tabViewDidChangeNumberOfTabViewItems:self];
}

// Accessing Tabs
/*!
    Returns the index of the specified item
    @param aTabViewItem the item to find the index for
*/
- (int)indexOfTabViewItem:(TNiTunesTabViewItem)aTabViewItem
{
    return [_tabViewItems indexOfObjectIdenticalTo:aTabViewItem];
}

/*!
    Returns the index of the TNiTunesTabViewItem with the specified identifier.
    @param anIdentifier the identifier of the item
*/
- (int)indexOfTabViewItemWithIdentifier:(CPString)anIdentifier
{
    var index = 0,
        count = [_tabViewItems count];

    for (; index < count; ++index)
        if ([[_tabViewItems[index] identifier] isEqual:anIdentifier])
            return index;

    return index;
}

/*!
    Returns the number of items in the tab view.
*/
- (unsigned)numberOfTabViewItems
{
    return [_tabViewItems count];
}

/*!
    Returns the TNiTunesTabViewItem at the specified index.
*/
- (TNiTunesTabViewItem)tabViewItemAtIndex:(unsigned)anIndex
{
    return _tabViewItems[anIndex];
}

/*!
    Returns the array of items that backs this tab view.
*/
- (CPArray)tabViewItems
{
    return _tabViewItems;
}

// Selecting a Tab
/*!
    Sets the first tab view item in the array to be displayed to the user.
    @param aSender the object making this request
*/
- (void)selectFirstTabViewItem:(id)aSender
{
    var count = [_tabViewItems count];

    if (count)
        [self selectTabViewItemAtIndex:0];
}

/*!
    Sets the last tab view item in the array to be displayed to the user.
    @param aSender the object making this request
*/
- (void)selectLastTabViewItem:(id)aSender
{
    var count = [_tabViewItems count];

    if (count)
        [self selectTabViewItemAtIndex:count - 1];
}

/*!
    Sets the next tab item in the array to be displayed.
    @param aSender the object making this request
*/
- (void)selectNextTabViewItem:(id)aSender
{
    if (!_selectedTabViewItem)
        return;

    var index = [self indexOfTabViewItem:_selectedTabViewItem],
        count = [_tabViewItems count];

    [self selectTabViewItemAtIndex:index + 1 % count];
}

/*!
    Selects the previous item in the array for display.
    @param aSender the object making this request
*/
- (void)selectPreviousTabViewItem:(id)aSender
{
    if (!_selectedTabViewItem)
        return;

    var index = [self indexOfTabViewItem:_selectedTabViewItem],
        count = [_tabViewItems count];

    [self selectTabViewItemAtIndex:index == 0 ? count : index - 1];
}

/*!
    Displays the specified item in the tab view.
    @param aTabViewItem the item to display
*/
- (void)selectTabViewItem:(TNiTunesTabViewItem)aTabViewItem
{
    if ((_delegateSelectors & TNiTunesTabViewShouldSelectTabViewItemSelector) && ![_delegate tabView:self shouldSelectTabViewItem:aTabViewItem])
        return;

    if (_delegateSelectors & TNiTunesTabViewWillSelectTabViewItemSelector)
        [_delegate tabView:self willSelectTabViewItem:aTabViewItem];

    if (_selectedTabViewItem)
    {
        _selectedTabViewItem._tabState = TNBackgroundTab;
        [_labelsView tabView:self didChangeStateOfTabViewItem:_selectedTabViewItem];
    }
    _selectedTabViewItem = aTabViewItem;

    _selectedTabViewItem._tabState = TNSelectedTab;

    var _previousContentView = _contentView;
    _contentView = [_selectedTabViewItem view];

    if (_previousContentView !== _contentView)
    {
        [_previousContentView removeFromSuperview];
        [_contentView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        [self addSubview:_contentView];
    }

    var _previousAuxiliaryView = _auxiliaryView;
    _auxiliaryView = [_selectedTabViewItem auxiliaryView];

    if (_previousAuxiliaryView !== _auxiliaryView)
    {
        [_previousAuxiliaryView removeFromSuperview];
        [_auxiliaryView setAutoresizingMask:CPViewWidthSizable];
        [self addSubview:_auxiliaryView];
    }

    [_labelsView tabView:self didChangeStateOfTabViewItem:_selectedTabViewItem];

    [self layoutSubviews];

    if (_delegateSelectors & TNiTunesTabViewDidSelectTabViewItemSelector)
        [_delegate tabView:self didSelectTabViewItem:aTabViewItem];
}

/*!
    Selects the item at the specified index.
    @param anIndex the index of the item to display.
*/
- (void)selectTabViewItemAtIndex:(unsigned)anIndex
{
    [self selectTabViewItem:_tabViewItems[anIndex]];
}

/*!
    Returns the current item being displayed.
*/
- (TNiTunesTabViewItem)selectedTabViewItem
{
    return _selectedTabViewItem;
}

//
/*!
    Sets the tab view type.
    @param aTabViewType the view type
*/
- (void)setTabViewType:(TNiTunesTabViewType)aTabViewType
{
    if (_tabViewType == aTabViewType)
        return;

    _tabViewType = aTabViewType;

    if (_tabViewType == TNNoTabsBezelBorder || _tabViewType == TNNoTabsLineBorder || _tabViewType == TNNoTabsNoBorder)
        [_labelsView removeFromSuperview];
    else if (_labelsView && ![_labelsView superview])
        [self addSubview:_labelsView];

    if (_tabViewType == TNNoTabsLineBorder || _tabViewType == TNNoTabsNoBorder)
        [_backgroundView removeFromSuperview];
    else if (_backgroundView && ![_backgroundView superview])
        [self addSubview:_backgroundView];

    [self layoutSubviews];
}

/*!
    Returns the tab view type.
*/
- (TNiTunesTabViewType)tabViewType
{
    return _tabViewType;
}

// Determining the Size
/*!
    Returns the content rectangle.
*/
- (CGRect)contentRect
{
    var contentRect = CGRectMakeCopy([self bounds]);

    if (_tabViewType == TNTopTabsBezelBorder)
    {
        var labelsViewHeight = 33.0,
            auxiliaryViewHeight = _auxiliaryView ? CGRectGetHeight([_auxiliaryView frame]) : 0.0,
            separatorViewHeight = 0.0;

        contentRect.origin.y += labelsViewHeight + auxiliaryViewHeight + separatorViewHeight;
        contentRect.size.height -= labelsViewHeight + auxiliaryViewHeight + separatorViewHeight * 2.0;
    }

    return contentRect;
}

/*!
    Returns the receiver's delegate.
*/
- (id)delegate
{
    return _delegate;
}

/*!
    Sets the delegate for this tab view.
    @param aDelegate the tab view's delegate
*/
- (void)setDelegate:(id)aDelegate
{
    if (_delegate == aDelegate)
        return;

    _delegate = aDelegate;

    _delegateSelectors = 0;

    if ([_delegate respondsToSelector:@selector(tabView:shouldSelectTabViewItem:)])
        _delegateSelectors |= TNiTunesTabViewShouldSelectTabViewItemSelector;

    if ([_delegate respondsToSelector:@selector(tabView:willSelectTabViewItem:)])
        _delegateSelectors |= TNiTunesTabViewWillSelectTabViewItemSelector;

    if ([_delegate respondsToSelector:@selector(tabView:didSelectTabViewItem:)])
        _delegateSelectors |= TNiTunesTabViewDidSelectTabViewItemSelector;

    if ([_delegate respondsToSelector:@selector(tabViewDidChangeNumberOfTabViewItems:)])
        _delegateSelectors |= TNiTunesTabViewDidChangeNumberOfTabViewItemsSelector;
}

- (void)mouseDown:(CPEvent)anEvent
{
    var location = [_labelsView convertPoint:[anEvent locationInWindow] fromView:nil],
        tabViewItem = [_labelsView representedTabViewItemAtPoint:location];

    if (tabViewItem)
        [self selectTabViewItem:tabViewItem];
}

@end

var TNiTunesTabViewItemsKey               = "TNiTunesTabViewItemsKey",
    TNiTunesTabViewSelectedItemKey        = "TNiTunesTabViewSelectedItemKey",
    TNiTunesTabViewTypeKey                = "TNiTunesTabViewTypeKey",
    TNiTunesTabViewDelegateKey            = "TNiTunesTabViewDelegateKey";

@implementation TNiTunesTabView (CPCoding)

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        _tabViewType    = [aCoder decodeIntForKey:TNiTunesTabViewTypeKey];
        _tabViewItems   = [];

        // FIXME: this is somewhat hacky
        [self _createBezelBorder];

        var items = [aCoder decodeObjectForKey:TNiTunesTabViewItemsKey];
        for (var i = 0; items && i < items.length; i++)
            [self insertTabViewItem:items[i] atIndex:i];

        var selected = [aCoder decodeObjectForKey:TNiTunesTabViewSelectedItemKey];
        if (selected)
            [self selectTabViewItem:selected];

        [self setDelegate:[aCoder decodeObjectForKey:TNiTunesTabViewDelegateKey]];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    var actualSubviews = _subviews;
    _subviews = [];
    [super encodeWithCoder:aCoder];
    _subviews = actualSubviews;

    [aCoder encodeObject:_tabViewItems forKey:TNiTunesTabViewItemsKey];;
    [aCoder encodeObject:_selectedTabViewItem forKey:TNiTunesTabViewSelectedItemKey];

    [aCoder encodeInt:_tabViewType forKey:TNiTunesTabViewTypeKey];

    [aCoder encodeConditionalObject:_delegate forKey:TNiTunesTabViewDelegateKey];
}

@end


var _TNiTunesTabLabelsViewBackgroundColor = nil,
    _TNiTunesTabLabelsViewInsideMargin    = 10.0,
    _TNiTunesTabLabelsViewOutsideMargin   = 15.0;

/* @ignore */
@implementation _TNiTunesTabLabelsView : CPView
{
    TNiTunesTabView       _tabView @accessors(property=tabView);
    CPDictionary    _tabLabels;
}

+ (float)height
{
    return 26.0;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        _tabLabels = [];
        var bundle = [CPBundle bundleForClass:[self class]];

        [self setBackgroundColor:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"TNiTunesTabViewLabelBackground.png"]]]]

        [self setFrameSize:CGSizeMake(CGRectGetWidth(aFrame), 33.0)];
    }

    return self;
}

- (void)tabView:(TNiTunesTabView)aTabView didAddTabViewItem:(TNiTunesTabViewItem)aTabViewItem
{
    var label = [[_TNiTunesTabLabel alloc] initWithFrame:CGRectMakeZero()];

    [label setTabViewItem:aTabViewItem];

    _tabLabels.push(label);

    [self addSubview:label];

    [self layoutSubviews];
}

- (void)tabView:(TNiTunesTabView)aTabView didRemoveTabViewItemAtIndex:(unsigned)index
{
    var label = _tabLabels[index];

    [_tabLabels removeObjectAtIndex:index];

    [label removeFromSuperview];

    [self layoutSubviews];
}

- (void)tabView:(TNiTunesTabView)aTabView didChangeStateOfTabViewItem:(TNiTunesTabViewItem)aTabViewItem
{
    [_tabLabels[[aTabView indexOfTabViewItem:aTabViewItem]] setTabState:[aTabViewItem tabState]];
}

- (TNiTunesTabViewItem)representedTabViewItemAtPoint:(CGPoint)aPoint
{
    var index = 0,
        count = _tabLabels.length;

    for (; index < count; ++index)
    {
        var label = _tabLabels[index];

        if (CGRectContainsPoint([label frame], aPoint))
            return [label tabViewItem];
    }

    return nil;
}

- (void)layoutSubviews
{
    var count = _tabLabels.length,
        width = TAB_WIDTH,
        x = 15;

    for (var i = 0; i < count; i++)
    {
        var label = _tabLabels[i];
        width = MAX([[label stringValue] sizeWithFont:[label font]].width, width);
    }

    for (var i = 0; i < count; i++)
    {
        var label = _tabLabels[i],
            frame = CGRectMake(x, 15.0, width, 20.0);

        [label setFrame:frame];
        x = CGRectGetMaxX(frame);
        x += 1.0;
    }
}

- (void)setFrameSize:(CGSize)aSize
{
    if (CGSizeEqualToSize([self frame].size, aSize))
        return;

    [super setFrameSize:aSize];

    [self layoutSubviews];
}

@end

var _TNiTunesTabLabelBackgroundColor          = nil,
    _TNiTunesTabLabelSelectedBackgroundColor  = nil;

/* @ignore */
@implementation _TNiTunesTabLabel : CPView
{
    TNiTunesTabViewItem     _tabViewItem;
    CPTextField             _labelField;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        _labelField = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];

        [_labelField setAlignment:CPCenterTextAlignment];
        [_labelField setFrame:CGRectMake(5.0, 0.0, CGRectGetWidth(aFrame) - 10.0, 20.0)];
        [_labelField setAutoresizingMask:CPViewWidthSizable];
        [_labelField setFont:[CPFont boldSystemFontOfSize:11.0]];

        [self addSubview:_labelField];

        [self setTabState:TNBackgroundTab];
    }

    return self;
}

- (void)setTabState:(CPTabState)aTabState
{
    var bundle = [CPBundle bundleForClass:[self class]];

    _TNiTunesTabLabelBackgroundColor = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:
     [
         [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"TNiTunesTabLabelBackgroundLeft.png"] size:CGSizeMake(6.0, 18.0)],
         [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"TNiTunesTabLabelBackgroundCenter.png"] size:CGSizeMake(1.0, 18.0)],
         [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"TNiTunesTabLabelBackgroundRight.png"] size:CGSizeMake(6.0, 18.0)]
     ] isVertical:NO]];

    _TNiTunesTabLabelSelectedBackgroundColor = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:
     [
         [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"TNiTunesTabLabelSelectedLeft.png"] size:CGSizeMake(3.0, 18.0)],
         [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"TNiTunesTabLabelSelectedCenter.png"] size:CGSizeMake(1.0, 18.0)],
         [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"TNiTunesTabLabelSelectedRight.png"] size:CGSizeMake(3.0, 18.0)]
     ] isVertical:NO]];

     [self setBackgroundColor:aTabState == TNSelectedTab ? _TNiTunesTabLabelSelectedBackgroundColor :_TNiTunesTabLabelBackgroundColor];
     [_labelField setTextColor:aTabState == TNSelectedTab ? [CPColor blackColor] : [CPColor whiteColor]];
}

- (void)setTabViewItem:(TNiTunesTabViewItem)aTabViewItem
{
    _tabViewItem = aTabViewItem;

    [self update];
}

- (TNiTunesTabViewItem)tabViewItem
{
    return _tabViewItem;
}

- (void)update
{
    [_labelField setStringValue:[_tabViewItem label]];
}

- (CPString)stringValue
{
    return [_labelField stringValue];
}

- (CPString)font
{
    return [_labelField font];
}

@end