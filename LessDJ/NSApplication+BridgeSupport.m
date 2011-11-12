//
//  NSApplication+BridgeSupport.m
//  LessDJ
//
//  Created by xu xhan on 11/11/11.
//  Copyright (c) 2011 xu han. All rights reserved.
//

#import "NSApplication+BridgeSupport.h"
#import "DBList.h"
#import "LessDJAppDelegate.h"

@implementation NSApplication (BridgeSupport)

//currentSongItem;
- (DBItem*)currentSongItem
{
    LessDJAppDelegate* delegate = (LessDJAppDelegate*)[NSApp delegate];
    return delegate.curItem;
}

- (CGFloat)currentLocation
{
    LessDJAppDelegate* delegate = (LessDJAppDelegate*)[NSApp delegate];
    return delegate.songLocation;    
}

- (NSScriptObjectSpecifier *)objectSpecifier
{
    return nil;
}
@end

