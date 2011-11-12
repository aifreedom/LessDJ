//
//  NSApplication+BridgeSupport.h
//  LessDJ
//
//  Created by xu xhan on 11/11/11.
//  Copyright (c) 2011 xu han. All rights reserved.
//

#import <AppKit/AppKit.h>
@class DBItem;
@interface NSApplication (BridgeSupport)

@property(readonly)DBItem* currentSongItem;
@property(readonly)CGFloat   currentLocation;


- (NSScriptObjectSpecifier *)objectSpecifier;
@end
