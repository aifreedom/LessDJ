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

@implementation LessDJAppDelegate
@synthesize labelPosition;
@synthesize labelTitle;
@synthesize labelArtist;
@synthesize progressSlider;

@synthesize window, fm;
@synthesize curItem;



/* about application terminate
  callback on applicationWillTerminate and then sleep thread not works (seems like it will be killed by app)
 */
- (void)killApp
{
//    NSLog(@"should kill end");
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


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.fm = [[[DBFM alloc] init] autorelease];
    [fm reloadList];
    volume = 1;
    
    [self addAVPlayerNotifyCallBack];
    [self updateProgressTimerState:YES];            
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
    self.curItem = item;
    
    
    [labelTitle setStringValue:item.title];
    [labelArtist setStringValue:item.artist];
    

    
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


#pragma mark -


@end
