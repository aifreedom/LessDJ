//
//  NSImageLoader.m
//  LessDJ
//
//  Created by xu xhan on 11/13/11.
//  Copyright (c) 2011 xu han. All rights reserved.
//

#import "NSImageLoader.h"
#import "NSImageCache.h"
#import "PLHttpQueue.h"

@implementation NSImageLoader

- (id)init
{
	if (self = [super init]) {
		self.delegate = self;
	}
	return self;
}

- (void)dealloc {
    [_imageView release];
	[super dealloc];
}

+ (NSImage*)fetch:(NSURL*)url view:(NSImageView*)view;
{
    NSImage* img = [[NSImageCache sharedCache] imageForURL:url];
    if(img){
        return img;
    }else{
        NSImageLoader* loader = [[NSImageLoader alloc] init];
        [loader _fetch:url view:view];
        [[PLHttpQueue sharedQueue] addQueueItem:loader];
		[loader release];	
        return nil;
    }
}

- (void)_fetch:(NSURL*)url view:(NSImageView*)view
{
    _imageView = [view retain];
    [super requestGet:[url absoluteString]];    
}

#pragma mark -
#pragma mark PLImageRequestDelegate
- (void)imageRequestFailed:(PLImageRequest*)request withError:(NSError*)error
{
	PLOGERROR(@"error on fetch image: %@, msg: %@",self.url,[error localizedDescription]);
	//we don't need clean stuffs bcz LoadInstance only works for one URL
}

- (void)imageRequestSucceeded:(PLImageRequest*)request
{
    NSImage* img = [[NSImage alloc] initWithData:request.imageData];
	if (!img) {
		return;
	}
	
	if (_imageView) {
		_imageView.image = img;
	}
	
	if(YES)
		[[NSImageCache sharedCache] setImage:img forURL:self.url];
	[img release];
    /*
	[self.info setObject:img forKey:PLINFO_HC_IMAGE];
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_IMAGE_LOADER_SUCCEEDED object:_imageView userInfo:self.info];
    
	if (_fetcherObject!= nil && [_fetcherObject respondsToSelector:@selector(fetchedSuccessed:userInfo:)]) {
		[_fetcherObject fetchedSuccessed:img userInfo:self.info];
	}
     */
}

@end
