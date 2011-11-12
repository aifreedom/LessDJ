//
//  DBList.m
//  LessDJ
//
//  Created by xu xhan on 11/7/11.
//  Copyright (c) 2011 xu han. All rights reserved.
//

#import "DBList.h"

@implementation DBChannel

- (id)initWithDict:(NSDictionary*)dict
{
    self = [super init];
    _dict = [dict retain];
    return self;
}

- (void)dealloc
{
    PLSafeRelease(_dict);
    [super dealloc];
}

- (NSString*)nameCN{
    return PLHashV(_dict, @"name");
}

- (NSString*)nameEN{
    return PLHashV(_dict, @"name_en");
}

- (int)mid{
    return [PLHashV(_dict, @"channel_id") intValue];
}
- (NSURL*)url{
    NSString* str = [NSString stringWithFormat:@"http://douban.fm/j/mine/playlist?type=n&channel=%d",self.mid];
    return URL(str);    
}
@end


#define kDBListMinSize 7
#define kDBListADLength 30

@implementation DBList

- (void)dealloc
{
    PLSafeRelease(_channel);
    PLSafeRelease(_items);
    PLCleanRelease(_client);
    [super dealloc];     
}

- (id)init
{
    self = [super init];
    _items = [[NSMutableArray alloc] init];
    _client = [[PLHttpBlock alloc] init];
    
    flag.skipAD = YES;
    
    return self;
}

- (void)reset
{
    [_items removeAllObjects];
    [self loadMore];
}

- (void)loadMore
{
    NSLog(@"load more");
    [_client get:_channel.url
              ok:^(NSDictionary*d){[self _parseResponseDict:d];}
            fail:^(NSError*e){NSLog(@"list items failed %@",e);}];
}

- (void)updateWithChannelItem:(DBChannel*)channel
{
    if (channel.mid != _channel.mid) {
        [_channel release];
        _channel = [channel retain];
        [self reset];
    }
}

- (DBItem*)nextItem
{
    return [self selectItemAtIndex:0];
}

- (DBItem*)selectItemAtIndex:(int)index
{
    if (index >= [_items count] ) {
        //TODO: should load more
        [self loadMore];
        return nil;
    }else{
        DBItem* item = [[_items objectAtIndex:index] retain]; 
        [_items removeObjectsInRange:NSMakeRange(0, index+1)];
        [self _checkListSize];
        // todo: update list ui
        return [item autorelease];
    }
    
}

- (void)_checkListSize
{
    if ([_items count] < kDBListMinSize) {
        [self loadMore];
    }
}

- (void)_parseResponseDict:(NSDictionary*)dict
{
    NSArray* songs = PLHashV(dict, @"song");
    if ([songs isKindOfClass:NSArray.class] && [songs count] >0) {
        for (NSDictionary* itemDict in songs) {
            DBItem* item = [[DBItem alloc] initWithDict:itemDict];
            if (!(flag.skipAD && item.length < kDBListADLength)) {
                [_items addObject:item];
            }            
            [item release];
        }
        NSLog(@"songs loaded %lu",[_items count]);
        //todo: update UI -- more items loaded
    }
}

@end

@implementation DBItem

- (id)initWithDict:(NSDictionary*)dict
{
    self = [super init];
    _dict = [dict retain];
    return self;
}

- (void)dealloc
{
    PLSafeRelease(_dict);
    [super dealloc];
}
/*
 @property(readonly) NSString* album;
 @property(readonly) NSString* artist;
 @property(readonly) NSString* title;
 @property(readonly) NSURL*    albumArtworkURL;
 @property(readonly) NSURL*    songURL;
 @property(readonly) int       length;
 */

- (NSString*)album{
    return PLHashV(_dict, @"albumtitle");
}
- (NSString*)artist{
    return PLHashV(_dict, @"artist");
}
- (NSString*)title{
    return PLHashV(_dict, @"title");
}
- (NSURL*)albumArtworkURL{
    return URL(PLHashV(_dict, @"picture"));
}
- (NSURL*)songURL{
    return URL(PLHashV(_dict, @"url"));
}
- (int)length{
    return [PLHashV(_dict, @"length") intValue];
}
@end