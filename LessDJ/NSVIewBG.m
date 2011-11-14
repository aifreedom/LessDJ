//
//  NSVIewBG.m
//  LessDJ
//
//  Created by xu xhan on 11/13/11.
//  Copyright (c) 2011 xu han. All rights reserved.
//

#import "NSVIewBG.h"

@implementation NSViewBG
- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
}
@end


@implementation NSWindowBtn



@end