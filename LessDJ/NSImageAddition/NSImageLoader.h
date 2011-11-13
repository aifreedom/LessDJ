//
//  NSImageLoader.h
//  LessDJ
//
//  Created by xu xhan on 11/13/11.
//  Copyright (c) 2011 xu han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLImageRequest.h"

@interface NSImageLoader : PLImageRequest<PLImageRequestDelegate>
{
//    NSImage* _image;
    NSImageView* _imageView;
}
// return nil if no cache founded and then fetch it online
+ (NSImage*)fetch:(NSURL*)url view:(NSImageView*)view;
- (void)_fetch:(NSURL*)url view:(NSImageView*)view;
@end
