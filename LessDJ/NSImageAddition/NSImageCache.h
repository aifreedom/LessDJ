//
//  NSImageCache.h
//  LessDJ
//
//  Created by xu xhan on 11/13/11.
//  Copyright (c) 2011 xu han. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSImageCache : NSObject
{
    NSMutableDictionary*    dict;       // stores image and the url
    NSMutableArray*         array;      // stores image sequence
}
- (NSImage*)imageForURL:(NSURL*)url;
- (void)setImage:(NSImage*)image forURL:(NSURL*)url;
+ (NSImageCache*)sharedCache;
@end
