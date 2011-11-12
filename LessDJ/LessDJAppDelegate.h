//
//  LessDJAppDelegate.h
//  LessDJ
//
//  Created by xu xhan on 9/29/11.
//  Copyright 2011 xu han. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBFM.h"
#import "AudioPlayer.h"
#import <AVFoundation/AVFoundation.h>


/*
 * TODO: fix freeze issue by :
    change to next track if (-isPlaying (add new state to observer) && stay in the same location >= 10 seconds)
 
    Theme select
    
    (default play at start)
 
    options to launch LL at startup
 */

@class AudioStreamer;
@class LastFMRadio, LastFMTrack;
@class DBItem;
@interface LessDJAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    DBFM* fm;
    AudioPlayer* player;
    
    LastFMRadio* radio;
    AudioStreamer *streamer;
	NSTimer *progressUpdateTimer;
    float volume;
    
    LastFMTrack* track;
    AVPlayer* avplayer;
    AVQueuePlayer* avqplayer;
    
    DBItem* curItem;
}

@property(retain)DBItem* curItem;

@property(nonatomic,retain)DBFM* fm;
@property (assign) IBOutlet NSWindow *window;

- (IBAction)playNext:(id)sender;
@property (assign) IBOutlet NSSlider *progressSlider;
- (IBAction)onBtnPlay:(id)sender;
- (IBAction)onBtnPause:(id)sender;
@property (assign) IBOutlet NSTextField *labelPosition;
@property (assign) IBOutlet NSTextField *labelTitle;
@property (assign) IBOutlet NSTextField *labelArtist;
- (IBAction)onVolumeChanged:(id)sender;
- (IBAction)onPopUpChanged:(id)sender;
- (void)destroyStreamer;
- (void)createStreamer;


@property(nonatomic,readonly) CGFloat songLocation;

@end
