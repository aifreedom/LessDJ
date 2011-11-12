//
//  DBFM.h
//  LessDJ
//
//  Created by xu xhan on 11/7/11.
//  Copyright (c) 2011 xu han. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBChannel, DBList, DBItem;
@class PLHttpBlock;
@interface DBFM : NSObject
{
    DBList* _list;
    PLHttpBlock* _clientList;
    NSMutableArray* _channels;
    NSMutableArray* _history;
    
    DBChannel* _currentChannel;
    
    NSMutableArray* content;
}



@property(nonatomic,retain) NSMutableArray* channels;
@property(nonatomic,readonly) DBChannel* currentChannel;
// recently played history list
@property(nonatomic,readonly) DBList* list;

- (void)reloadList;

- (void)_updateList:(NSDictionary*)dict;

- (void)setChannelAtIndex:(int)index;
@end




////////////////////////////////////////////////////////////////////////////////////
@interface DBFM (APIService)
+ (NSDictionary*)parseContent:(NSString*)responseContent withError:(NSError**)error;
@end