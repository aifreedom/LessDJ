//
//  DBFM.h
//  LessDJ
//
//  Created by xu xhan on 11/7/11.
//  Copyright (c) 2011 xu han. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
//    DBResponseTypeInvalid
    DBResponseTypeChannel,
    DBResponseTypeList
}DBResponseType;


@class DBChannel, DBList, DBItem;
@class PLHttpBlock;
@protocol DBFMDelegate;
@interface DBFM : NSObject
{
    DBList* _list;
    PLHttpBlock* _clientList;
    NSMutableArray* _channels;
    NSMutableArray* _history;
    
    DBChannel* _currentChannel;
    
    NSMutableArray* content;
    
    id _delegate;
}

@property(nonatomic,assign) id delegate;

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


@protocol DBFMDelegate <NSObject>
@optional
- (void)dbfmResponseReceived:(DBResponseType)type;
@end

