//
//  DBChannel.m
//  LessDJ
//
//  Created by xu xhan on 11/7/11.
//  Copyright (c) 2011 xu han. All rights reserved.
//

#import "DBChannel.h"

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

//@implementation DBChannelItem
//@end