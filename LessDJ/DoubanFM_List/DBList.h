//
//  DBList.h
//  LessDJ
//
//  Created by xu xhan on 11/7/11.
//  Copyright (c) 2011 xu han. All rights reserved.
//

#import "Element.h"

#import <Foundation/Foundation.h>
#import "PLHttpClient.h"
#import "PLHttpBlock.h"

@interface DBChannel : NSObject{
    NSDictionary* _dict;
}
- (id)initWithDict:(NSDictionary*)dict;
@property(readonly) NSString* nameCN;
@property(readonly) NSString* nameEN;
@property(readonly) int       mid;
@property(readonly) NSURL     *url;
@end

@class DBItem, DBFM;
@interface DBList : NSObject
{
    DBFM*     _fm;          // weak linked
    DBChannel* _channel;
    NSMutableArray* _items;
    PLHttpBlock* _client;
    struct{
        BOOL skipAD;
    }flag;
}
- (void)setFM:(DBFM*)fm;
- (void)reset;
- (void)loadMore;

- (void)updateWithChannelItem:(DBChannel*)channel;
- (DBItem*)nextItem;
- (DBItem*)selectItemAtIndex:(int)index;
// check and load more items in need
- (void)_checkListSize;
- (void)_parseResponseDict:(NSDictionary*)dict;
@end

@interface DBItem : Element {
    NSDictionary* _dict;
}
- (id)initWithDict:(NSDictionary*)dict;
@property(readonly) NSString* album;
@property(readonly) NSString* artist;
@property(readonly) NSString* title;
@property(readonly) NSURL*    albumArtworkURL;
@property(readonly) NSURL*    albumArtworkLargeURL;
@property(readonly) NSURL*    songURL;
@property(readonly) int       length;
//- (NSScriptObjectSpecifier *)objectSpecifier;
@end