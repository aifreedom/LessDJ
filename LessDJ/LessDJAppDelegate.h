//
//  LessDJAppDelegate.h
//  LessDJ
//
//  Created by xu xhan on 9/29/11.
//  Copyright 2011 xu han. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBFM.h"
#import <AVFoundation/AVFoundation.h>


/*
 * TODO: fix freeze issue by :
    change to next track if (-isPlaying (add new state to observer) && stay in the same location >= 10 seconds)
 
    Theme select
    
    (default play at start)
 
    options to launch LL at startup
 */

//the delay operations
typedef enum {
    OperationNone = 0,
    OperationNext,
    OperationChangeChannel
}DJOperation;


@class DBItem;
@interface LessDJAppDelegate : NSObject <NSApplicationDelegate, DBFMDelegate> {
    NSWindow *window;
    
    DBFM*       fm;
	NSTimer*    progressUpdateTimer;
    float       volume;    
    AVPlayer*   avplayer;       //using avqueuePlayer -insertItem will freeze app in a while(by placing it on background it not works at all)
    DBItem*     curItem;
    
    DJOperation delayOperation; //some operation need callback to handle delay responses
}

@property(nonatomic,retain)DBFM* fm;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSSlider *progressSlider;
@property (assign) IBOutlet NSTextField *labelPosition;
@property (assign) IBOutlet NSTextField *labelTitle;
@property (assign) IBOutlet NSTextField *labelArtist;

- (IBAction)playNext:(id)sender;
- (IBAction)onBtnPlay:(id)sender;
- (IBAction)onBtnPause:(id)sender;
- (IBAction)onVolumeChanged:(id)sender;
- (IBAction)onPopUpChanged:(id)sender;
- (IBAction)onProgressChanged:(id)sender;

@property(nonatomic,readonly) CGFloat songLocation;
@property(retain)DBItem* curItem;

- (void)updateProgressTimerState:(BOOL)isOn;
- (void)addAVPlayerNotifyCallBack;

@end
