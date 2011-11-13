//
//  NSImageView+RemoteImage.m
//  LessDJ
//
//  Created by xu xhan on 11/13/11.
//  Copyright (c) 2011 xu han. All rights reserved.
//

#import "NSImageView+RemoteImage.h"
#import "NSImageLoader.h"
@implementation NSImageView (RemoteImage)

- (void)loadImage:(NSURL*)url placeholder:(NSString*)imageName
{
    NSImage* img = [NSImageLoader fetch:url view:self];
    if (!img) {
        img = [NSImage imageNamed:imageName];
    }
    self.image = img;
}

@end
