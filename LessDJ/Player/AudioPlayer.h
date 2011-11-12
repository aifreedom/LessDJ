//
//  AudioPlayer.h
//  LessDJ
//
//  Created by xu xhan on 11/7/11.
//  Copyright (c) 2011 xu han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioStreamer.h"

@class DBlist, DBItem;

@interface AudioPlayer : AudioStreamer
- (void)playItem:(DBItem*)item;
@end
