/*
 * TNiTunesTabViewItem.j
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

@import <Foundation/CPObject.j>

@import <AppKit/CPView.j>


/*
    The tab is currently selected.
    @global
    @group CPTabState
*/
TNSelectedTab   = 0;
/*
    The tab is currently in the background (not selected).
    @global
    @group CPTabState
*/
TNBackgroundTab = 1;
/*
    The tab of this item is currently being pressed by the user.
    @global
    @group CPTabState
*/
TNPressedTab    = 2;

/*! 
    @ingroup appkit
    @class TNiTunesTabViewItem

    The class representation of an item in a TNiTunesTabView. One tab view item
    can be shown at a time in a TNiTunesTabView.
*/
@implementation TNiTunesTabViewItem : CPObject
{
    id          _identifier @accessors(property=identifier);;
    CPString    _label @accessors(property=label);
    int         _tabState @accessors(getter=tabState);
    
    CPView      _view @accessors(property=view);
    CPView      _auxiliaryView @accessors(property=auxiliaryView);
    
    TNiTunesTabView   _tabView @accessors(property=tabView);;
}

- (id)init
{
    return [self initWithIdentifier:@""];
}

/*!
    Initializes the tab view item with the specified identifier.
    @return the initialized TNiTunesTabViewItem
*/
- (id)initWithIdentifier:(id)anIdentifier
{
    self = [super init];
    
    if (self)
        _identifier = anIdentifier;
        
    return self;
}
@end


var TNiTunesTabViewItemIdentifierKey  = "TNiTunesTabViewItemIdentifierKey",
    TNiTunesTabViewItemLabelKey       = "TNiTunesTabViewItemLabelKey",
    TNiTunesTabViewItemViewKey        = "TNiTunesTabViewItemViewKey",
    TNiTunesTabViewItemAuxViewKey     = "TNiTunesTabViewItemAuxViewKey";


@implementation TNiTunesTabViewItem (CPCoding)

- (id)initWithCoder:(CPCoder)aCoder
{
    self = [super init];
    
    if (self)
    {
        _identifier     = [aCoder decodeObjectForKey:TNiTunesTabViewItemIdentifierKey];
        _label          = [aCoder decodeObjectForKey:TNiTunesTabViewItemLabelKey];
        _view           = [aCoder decodeObjectForKey:TNiTunesTabViewItemViewKey];
        _auxiliaryView  = [aCoder decodeObjectForKey:TNiTunesTabViewItemAuxViewKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [aCoder encodeObject:_identifier    forKey:TNiTunesTabViewItemIdentifierKey];
    [aCoder encodeObject:_label         forKey:TNiTunesTabViewItemLabelKey];
    [aCoder encodeObject:_view          forKey:TNiTunesTabViewItemViewKey];
    [aCoder encodeObject:_auxiliaryView forKey:TNiTunesTabViewItemAuxViewKey];
}

@end