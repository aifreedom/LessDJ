//
//  DBChannel.h
//  LessDJ
//
//  Created by xu xhan on 11/7/11.
//  Copyright (c) 2011 xu han. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBChannel : NSObject{
    NSDictionary* _dict;
}
- (id)initWithDict:(NSDictionary*)dict;
@property(readonly) NSString* nameCN;
@property(readonly) NSString* nameEN;
@property(readonly) int       mid;
@property(readonly) NSURL     *url;
@end

/// 
//@interface DBChannelItem : NSObject {
//    
//}
//@end