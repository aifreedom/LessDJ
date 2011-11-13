//
//  NSImageView+RemoteImage.h
//  LessDJ
//
//  Created by xu xhan on 11/13/11.
//  Copyright (c) 2011 xu han. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSImageView (RemoteImage)
- (void)loadImage:(NSURL*)url placeholder:(NSString*)imageName;
@end
