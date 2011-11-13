//
//  LessDJAppDelegate.m
//  LessDJ
//
//  Created by xu xhan on 9/29/11.
//  Copyright 2011 xu han. All rights reserved.
//

#import "LessDJAppDelegate.h"


#import "DBFM.h"
#import "DBList.h"
#import "NSImageLoader.h"
#import "NSImageView+RemoteImage.h"

@implementation LessDJAppDelegate
@synthesize labelPosition;
@synthesize labelTitle;
@synthesize labelArtist;
@synthesize viewArtwork;
@synthesize progressSlider;

@synthesize window, fm;
@synthesize curItem;


#pragma mark - App Life Cycle

- (void)killApp
{
    /* Note: application terminate
     callback on applicationWillTerminate and then sleep thread not works (seems like it will be killed by app)
     */
    [NSApp replyToApplicationShouldTerminate:YES];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    //注意：这里系统runroop变成modal panel了，需要设置timer的runloop 否者无法生效
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.xhan.LessDJ.willTerminate"
                                                                   object:@"com.xhan.LessDJ"
                                                                 userInfo:nil
                                                       deliverImmediately:YES];
    [self performSelector:@selector(killApp) withObject:nil afterDelay:0.3 inModes:[NSArray arrayWithObject:NSModalPanelRunLoopMode]];
    return NSTerminateLater;
}


- (void)dealloc
{
    [self updateProgressTimerState:NO];
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    self.fm = [[[DBFM alloc] init] autorelease];
    fm.delegate = self;
    delayOperation = OperationNext;
    [fm reloadList];
    volume = 1;
    
    [self addAVPlayerNotifyCallBack];
    [self updateProgressTimerState:YES];
}

#pragma mark - methods

- (void)updateProgressTimerState:(BOOL)isOn
{
    if (isOn) {
        [self updateProgressTimerState:NO];
        progressUpdateTimer =
        [NSTimer
         scheduledTimerWithTimeInterval:0.1
                                 target:self
                               selector:@selector(updateProgress:)
                               userInfo:nil
                                repeats:YES];
    }else{
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;        
    }
}

- (void)addAVPlayerNotifyCallBack
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(avplayerItemDidEnded:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(avplayerItemDidEnded:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification
                                               object:nil];    
}

- (void)avplayerItemDidEnded:(NSNotification*)notify
{
    [self playNext:nil];
}







- (IBAction)playNext:(id)sender {
    [avplayer pause];
    PLSafeRelease(avplayer);

    DBItem* item = [fm.list nextItem];
    if (!item) {
        NSLog(@"no play item founded");
        delayOperation = OperationNext;
        return;
    }
    delayOperation = OperationNone;
    self.curItem = item;
    
    
    [labelTitle setStringValue:item.title];
    [labelArtist setStringValue:item.artist];    
    [viewArtwork loadImage:item.albumArtworkLargeURL
               placeholder:@"default_cover"];
    
    avplayer = [[AVPlayer alloc] initWithURL:item.songURL];
    avplayer.volume = volume;
    [avplayer play];

    
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.xhan.LessDJ.songchanged"
                                                                   object:@"com.xhan.LessDJ"
                                                                 userInfo:nil
                                                       deliverImmediately:YES];

    
}
- (IBAction)onBtnPlay:(id)sender {
    [avplayer play];
}

- (IBAction)onBtnPause:(id)sender {
    [avplayer pause];
}

- (IBAction)onVolumeChanged:(NSSlider*)sender {
    volume = [sender doubleValue];
    [avplayer setVolume:volume];
}

- (IBAction)onPopUpChanged:(NSPopUpButton*)sender {
    delayOperation = OperationNext;
    [fm setChannelAtIndex:[sender indexOfSelectedItem]];
}

- (IBAction)onProgressChanged:(id)sender
{
    float desireSeconds = [progressSlider doubleValue]*self.curItem.length/100;
    CMTime ctime_ = avplayer.currentTime;
    [avplayer seekToTime:CMTimeMakeWithSeconds(desireSeconds, ctime_.timescale)];
}

- (void)updateProgress:(NSTimer *)updatedTimer
{
    
    if (avplayer.status == AVPlayerStatusReadyToPlay) {
        CMTime ctime_ = avplayer.currentTime;
        double duration = self.curItem.length;
        if (CMTIME_IS_VALID(ctime_)) {
            Float64 t = CMTimeGetSeconds(ctime_);
			[labelPosition setStringValue:
             [NSString stringWithFormat:@"%.1f/%.1f seconds",
              t,
              duration]];
//            [progressSlider setEnabled:NO];
			[progressSlider setDoubleValue:100 * t / duration];            
        }else{
            [labelPosition setStringValue:@"invalid time"];
        }
        
    }else{
        [labelPosition setStringValue:@"buffing..."];
    }
}


- (CGFloat) songLocation
{
    CGFloat location = 0;
    CMTime ctime_ = avplayer.currentTime;
    if (CMTIME_IS_VALID(ctime_)) {
        location = CMTimeGetSeconds(ctime_);
    }
    return MAX(0, location);
}


#pragma mark - FM Service Delegate

- (void)dbfmResponseReceived:(DBResponseType)type state:(BOOL)isSuccess
{
    switch (type) {
        case DBResponseTypeChannel:{
            static int listRetryCount = 0;
            if (isSuccess) {
                listRetryCount = 0;
                //TODO: should select desire item
                delayOperation = OperationNext;
                [fm setChannelAtIndex:0];   // test mode : select first item
                
                
            }else{
                listRetryCount += 1;
                if (listRetryCount > 3) {
                    PLOGERROR(@"fetch List failed ,try it later");
                }else{
                    [fm reloadList];
                }                
            }
        }break;
        case DBResponseTypeSongList:{
            if (isSuccess && (delayOperation != OperationNone)) {
                delayOperation = OperationNone;
                [self playNext:nil];
            }
            if (isSuccess) {
                // precache images
                
                int size = MIN([fm.list.items count], 4);
                for (int i = 0; i < size; i++) {
                    DBItem* item = [fm.list.items objectAtIndex:i];
                    [NSImageLoader fetch:item.albumArtworkLargeURL view:nil];
                }
            }
        }break;
    }
}

@end
