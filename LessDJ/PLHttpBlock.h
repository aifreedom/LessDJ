//
//  PLHttpBlock.h
//  LessDJ
//
//  Created by xu xhan on 11/7/11.
//  Copyright (c) 2011 xu han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLHttpClient.h"

typedef void (^PLBlockDict)(NSDictionary*);
typedef void (^PLBlockError)(NSError*);

@interface PLHttpBlock : PLHttpClient<PLHttpClientDelegate>
{
    PLBlockDict _blockDict;
    PLBlockError _blockError;
}
- (void)get:(NSURL *)url ok:(PLBlockDict)blockOK fail:(PLBlockError)blockError;
- (void)post:(NSURL *)url body:(NSString *)body ok:(PLBlockDict)blockOK fail:(PLBlockError)blockError;

- (void)_prepareBlock:(PLBlockDict)blockOK fail:(PLBlockError)blockError;
- (void)_cleanBlock;
@end
