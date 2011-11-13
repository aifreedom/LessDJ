//
//  NSImageCache.m
//  LessDJ
//
//  Created by xu xhan on 11/13/11.
//  Copyright (c) 2011 xu han. All rights reserved.
//

#import "NSImageCache.h"

#define NSImageCacheMaxItem 10

@implementation NSImageCache

static NSImageCache* _gSharedInstance;

+ (NSImageCache*)sharedCache
{
    if (!_gSharedInstance){
        _gSharedInstance = [[self alloc] init];
    }
    return _gSharedInstance;
}

- (id)init
{
    self = [super init];
    dict = [[NSMutableDictionary alloc] init];
    array= [[NSMutableArray alloc] init];
    return self;
}

- (void)dealloc
{
    PLSafeRelease(dict);
    PLSafeRelease(array);
    [super dealloc];
}

- (NSImage*)imageForURL:(NSURL*)url
{
    NSString *key =[url absoluteString];
    if (![key isNonEmpty]) return nil;
    return [dict objectForKey:key];
}
- (void)setImage:(NSImage*)image forURL:(NSURL*)url
{
    NSString *key =[url absoluteString];
    if (![key isNonEmpty] || !image) return;
    
    [array addObject:key];
    [dict setObject:image forKey:key];
    
    // remove overloaded images
    while ([array count] > NSImageCacheMaxItem) {
        NSString* removedKey = [array objectAtIndex:0];
        [dict removeObjectForKey:removedKey];
        [array removeObjectAtIndex:0];
    }
}

@end
