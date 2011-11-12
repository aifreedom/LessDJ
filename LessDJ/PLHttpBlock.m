//
//  PLHttpBlock.m
//  LessDJ
//
//  Created by xu xhan on 11/7/11.
//  Copyright (c) 2011 xu han. All rights reserved.
//

#import "PLHttpBlock.h"

#import "DBFM.h"

@implementation PLHttpBlock
- (void)get:(NSURL *)url ok:(PLBlockDict)blockOK fail:(PLBlockError)blockError
{
    [self _prepareBlock:blockOK fail:blockError];
    [super get:url];
}
- (void)post:(NSURL *)url body:(NSString *)body ok:(PLBlockDict)blockOK fail:(PLBlockError)blockError
{
    [self _prepareBlock:blockOK fail:blockError];
    [super post:url body:body];
}

- (void)_prepareBlock:(PLBlockDict)blockOK fail:(PLBlockError)blockError
{
    self.delegate = nil;
    [self _cleanBlock];    
    _blockDict = Block_copy(blockOK);
    _blockError= Block_copy(blockError);
    self.delegate = self;
}
- (void)_cleanBlock
{
    if (_blockDict) {
        Block_release(_blockDict), _blockDict = NULL;
    }
    if (_blockError) {
        Block_release(_blockError), _blockError = NULL;
    }
}
- (void)dealloc
{
    [self _cleanBlock];
    [super dealloc];
}
#pragma mark - delegate

- (void)httpClient:(PLHttpClient *)hc failed:(NSError *)error
{
    if (_blockError) {
        _blockError(error);
    }
    
    [self _cleanBlock];
}

- (void)httpClient:(PLHttpClient *)hc successed:(NSData *)data
{
    NSError* error;
    NSDictionary* dict = [DBFM parseContent:[hc stringValue] withError:&error];
    if (error) {
        [self httpClient:hc failed:error];
    }else{
        if (_blockDict) {
            _blockDict(dict);
        }        
        [self _cleanBlock];
    }
}

@end
