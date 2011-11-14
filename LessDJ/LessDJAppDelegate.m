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
@synthesize viewChannels;
@synthesize labelAlbum;
@synthesize btnPlayState;
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
    isStatePlaying = YES;
    
    [self addAVPlayerNotifyCallBack];
    [self updateProgressTimerState:YES];
    
#ifdef DEBUG
    window.level = NSStatusWindowLevel;
#endif    
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    [window orderFront:nil];
    return YES;
}
//- (void)application

- (void)awakeFromNib
{
    CGSize windowSize = [window frame].size;
    [viewChannels setAutoresizingMask:NSViewMinXMargin|NSViewMinYMargin];
    [viewChannels setFrameOrigin:CGPointMake(windowSize.width - 80, windowSize.height - 20)];
    [[[window contentView] superview] addSubview:viewChannels];
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
    
    [progressSlider setDoubleValue:0];
    
    DBItem* item = [fm.list nextItem];
    if (!item) {
        NSLog(@"no play item founded");
        delayOperation = OperationNext;
        return;
    }
    delayOperation = OperationNone;
    self.curItem = item;
    
    // update player button
    isStatePlaying = YES;
    [btnPlayState setImage:[NSImage imageNamed:!isStatePlaying?@"play":@"pause"]];
    
    [labelTitle setStringValue:item.title];
    [labelArtist setStringValue:item.artist];
    [labelAlbum  setStringValue:[NSString stringWithFormat:@"< %@ > %@",item.album,item.publicTime]];
    
//    [labelTitle sizeToFit];
//    [labelAlbum sizeToFit];
//    [labelArtist sizeToFit];
    
    [viewArtwork loadImage:item.albumArtworkLargeURL
               placeholder:@"default_cover"];
    
    [window setTitle:[NSString stringWithFormat:@"%@ - %@",item.title,@"LessDJ"]];
    
    avplayer = [[AVPlayer alloc] initWithURL:item.songURL];
    avplayer.volume = volume;
    [avplayer play];

    
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.xhan.LessDJ.songchanged"
                                                                   object:@"com.xhan.LessDJ"
                                                                 userInfo:nil
                                                       deliverImmediately:YES];

    
}

- (IBAction)onTogglePlay:(id)sender
{
    isStatePlaying = !isStatePlaying;
    [btnPlayState setImage:[NSImage imageNamed:!isStatePlaying?@"play":@"pause"]];
    if (isStatePlaying) {
        [avplayer play];
    }else{
        [avplayer pause];
    }
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

- (IBAction)onGetLL:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:URL(@"http://ixhan.com/lesslyrics")];
}

- (void)updateProgress:(NSTimer *)updatedTimer
{
    
    if (avplayer.status == AVPlayerStatusReadyToPlay) {
        CMTime ctime_ = avplayer.currentTime;
        double duration = self.curItem.length;
        if (CMTIME_IS_VALID(ctime_)) {
            Float64 t = CMTimeGetSeconds(ctime_);

			[progressSlider setDoubleValue:100 * t / duration];            
            
            int playerLocation = (int)[self songLocation];
            int min = playerLocation / 60;
            int sec = playerLocation % 60;
            [labelPosition setStringValue:[NSString stringWithFormat:@"%d:%02d",min,sec]];
        }else{
            [labelPosition setStringValue:@"loading..."];
        }
        
    }else{
        [labelPosition setStringValue:@"loading..."];
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
