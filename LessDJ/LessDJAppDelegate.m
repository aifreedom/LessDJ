//
//  LessDJAppDelegate.m
//  LessDJ
//
//  Created by xu xhan on 9/29/11.
//  Copyright 2011 xu han. All rights reserved.
//

#import "LessDJAppDelegate.h"

#import "AudioPlayer.h"
#import "DBFM.h"
#import "DBList.h"
#import "DBChannel.h"



@implementation LessDJAppDelegate
@synthesize labelPosition;
@synthesize labelTitle;
@synthesize labelArtist;
@synthesize progressSlider;

@synthesize window, fm;
@synthesize curItem;



#define LastFMRadio NSObject

/*  If an application delegate returns NSTerminateLater from -applicationShouldTerminate:, -replyToApplicationShouldTerminate: must be called with YES or NO once the application decides if it can terminate */
//- (void)replyToApplicationShouldTerminate:(BOOL)shouldTerminate;

//- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender


- (void)applicationWillTerminate:(NSNotification *)notification
{
    /*
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.xhan.LessDJ.willTerminate"
                                                                   object:@"com.xhan.LessDJ"
                                                                 userInfo:nil
                                                       deliverImmediately:YES];
     */
//    usleep(20000);    //0.2s
//    sleep(1);
//    NSLog(@"will end");
}
// */

- (void)killApp
{
    NSLog(@"should kill end");
    [NSApp replyToApplicationShouldTerminate:YES];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    NSLog(@"ask kill ");
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.xhan.LessDJ.willTerminate"
                                                                   object:@"com.xhan.LessDJ"
                                                                 userInfo:nil
                                                       deliverImmediately:YES];
    [self performSelector:@selector(killApp) withObject:nil afterDelay:0.3 inModes:[NSArray arrayWithObject:NSModalPanelRunLoopMode]];
    
//    self.timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(closeWindow:) userInfo:nil
//										repeats:NO];
//	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSModalPanelRunLoopMode];
    return NSTerminateLater;
}


- (void)dealloc
{
	[self destroyStreamer];
	if (progressUpdateTimer)
	{
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
	}
	[super dealloc];
}





- (void)setupRadio
{
//    radio = [[LastFMRadio alloc] init];
    /*
    progressUpdateTimer = [NSTimer
     scheduledTimerWithTimeInterval:0.1
     target:self
     selector:@selector(updateProgress:)
     userInfo:nil
     repeats:YES];
     */
    /*
    [[NSNotificationCenter defaultCenter] addObserverForName:kTrackDidBecomeAvailable
                                                      object:radio
                                                       queue:nil
                                                  usingBlock:^(NSNotification*s){
                                                      NSLog(@"");
                                                  }];
     */
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
//    [[LastFMRadio sharedInstance] play];
    volume = 1;
    self.fm = [[[DBFM alloc] init] autorelease];
    [fm reloadList];
    
//    radio = [[LastFMRadio alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(avplayerItemDidEnded:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(avplayerItemDidEnded:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification
                                               object:nil];
    
    avplayer = [[AVPlayer alloc] init];
    avqplayer = [[AVQueuePlayer alloc] init];
    
    progressUpdateTimer =
    [NSTimer
     scheduledTimerWithTimeInterval:0.1
     target:self
     selector:@selector(updateProgress:)
     userInfo:nil
     repeats:YES];
                 
}

- (void)avplayerItemDidEnded:(NSNotification*)notify
{
    [self playNext:nil];
}


- (IBAction)playNext:(id)sender {
    
    
//    [self destroyStreamer];
//    [self createStreamer];
//    [streamer start];
    

    [avplayer pause];
    [avplayer release];

    

    DBItem* item = [fm.list nextItem];
    if (!item) {
        NSLog(@"no play item founded");
        return;
    }
    self.curItem = item;
    [labelTitle setStringValue:item.title];
    [labelArtist setStringValue:item.artist];
    
//    [radio playTrackURL:item.songURL];
    
    avplayer = [[AVPlayer alloc] initWithURL:item.songURL];
 
//    [avplayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:item.songURL]];
    [avplayer play];

//    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.xhan.LessDJ.songchanged" object:@"com.xhan.LessDJ"];
    
    /*
     
     [[NSDistributedNotificationCenter defaultCenter] addObserver:self
     selector:@selector(_notifyTrackDidChanged:)
     name:@"com.xhan.LessDJ.songchanged" 
     object:@"com.xhan.LessDJ"];
     
     object string have to be matched
     */
    
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.xhan.LessDJ.songchanged"
                                                                   object:@"com.xhan.LessDJ"
                                                                 userInfo:nil
                                                       deliverImmediately:YES];
    
//    [avqplayer pause];
//    [avqplayer removeAllItems];

    
    /*
    // 这个会卡下
//    NSLog(@"0");
    AVPlayerItem* aitem = [AVPlayerItem playerItemWithURL:item.songURL];
//    NSLog(@"1");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"11");
        [avqplayer insertItem:aitem afterItem:nil];
        NSLog(@"12");
        [avqplayer play]; // necessary to call play :D
//        dispatch_async(dispatch_get_main_queue(), ^(){
//          [avqplayer play];  
//        });
    });    
//    NSLog(@"2");
     */

    /*
    [track stop];
    [track release];
    
     
    
     
    
    track = [[LastFMTrack alloc] initWithTrackInfo: [NSDictionary dictionaryWithObject:[item.songURL absoluteString]
                                                                                forKey:@"location"] ];
     */
    
}
- (IBAction)onBtnPlay:(id)sender {
//    [avqplayer play];
    [avplayer play];
//    [streamer start];
//    [radio play];
//    [track play];
}

- (IBAction)onBtnPause:(id)sender {
//    [avqplayer pause];
    [avplayer pause];
//    [streamer pause];
//    [radio pause];
    
//    [track pause];
}



- (void)destroyStreamer
{
	if (streamer)
	{
        [streamer pause];
		[streamer stop];
        
		[[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ASStatusChangedNotification
         object:streamer];
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;

		[streamer release];
		streamer = nil;
	}
}
- (void)createStreamer
{
    // 快速的换歌曲会有问题
	if (streamer)
	{
		return;
	}
    
	[self destroyStreamer];
	
    DBItem* item = [fm.list nextItem];
    if (!item) {
        NSLog(@"no play item founded");
        return;
    }
    [labelTitle setStringValue:item.title];
    [labelArtist setStringValue:item.artist];
    
    /*
	NSString *escapedValue =
    [(NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                         nil,
                                                         (CFStringRef)[downloadSourceField stringValue],
                                                         NULL,
                                                         NULL,
                                                         kCFStringEncodingUTF8)
     autorelease];
    
	NSURL *url = [NSURL URLWithString:escapedValue];
     */
	streamer = [[AudioStreamer alloc] initWithURL:item.songURL];
	[streamer setVolume:volume];
	progressUpdateTimer =
    [NSTimer
     scheduledTimerWithTimeInterval:0.1
     target:self
     selector:@selector(updateProgress:)
     userInfo:nil
     repeats:YES];
	[[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playbackStateChanged:)
     name:ASStatusChangedNotification
     object:streamer];
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
            [progressSlider setEnabled:NO];
			[progressSlider setDoubleValue:100 * t / duration];            
        }else{
            [labelPosition setStringValue:@"invalid time"];
        }
        
    }else{
        [labelPosition setStringValue:@"buffing..."];
    }
    return;
    
    
	if (streamer.bitRate != 0.0)
	{
		double progress = streamer.progress;
		double duration = streamer.duration;
		
		if (duration > 0)
		{
			[labelPosition setStringValue:
             [NSString stringWithFormat:@"Time Played: %.1f/%.1f seconds",
              progress,
              duration]];
//			[progressSlider setEnabled:YES];
            [progressSlider setEnabled:NO];
			[progressSlider setDoubleValue:100 * progress / duration];
		}
		else
		{
			[progressSlider setEnabled:NO];
		}
	}
	else
	{
		[labelPosition setStringValue:@"Time Played:"];
	}
}

/*
- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([streamer isWaiting])
	{
//		[self setButtonImage:[NSImage imageNamed:@"loadingbutton"]];
//        NSLog(@"loading");
	}
	else if ([streamer isPlaying])
	{
//		[self setButtonImage:[NSImage imageNamed:@"stopbutton"]];
//        NSLog(@"playing");
	}
	else if (streamer.state == AS_STOPPED)
	{

//		[self setButtonImage:[NSImage imageNamed:@"playbutton"]];
	}else if ([streamer isIdle]){
//        NSLog(@"idle");
//        NSLog(@"play next by get state stoped");
        if (streamer.duration > 0 && (streamer.progress / streamer.duration) <0.8) {
//            NSLog(@"")
            [NSAlert alertWithError:[NSError errorWithDomain:@"nn" code:0 userInfo:nil]];
        }
        [self playNext:nil];
    }
}
 */


- (CGFloat) songLocation
{
    CGFloat location = 0;
    CMTime ctime_ = avplayer.currentTime;
    if (CMTIME_IS_VALID(ctime_)) {
        location = CMTimeGetSeconds(ctime_);
    }
    return MAX(0, location);
}


- (IBAction)onVolumeChanged:(NSSlider*)sender {
    volume = [sender doubleValue];
//    [streamer setVolume:volume];
    [avplayer setVolume:volume];
}

- (IBAction)onPopUpChanged:(NSPopUpButton*)sender {
//    NSLog(@"%d %@",[sender indexOfSelectedItem],[sender titleOfSelectedItem]);
    [fm setChannelAtIndex:[sender indexOfSelectedItem]];
}
@end
