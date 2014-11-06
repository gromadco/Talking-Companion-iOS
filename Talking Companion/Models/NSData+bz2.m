//
//  NSData+bz2.m
//  Talking Companion
//
//  Created by Sergey Butenko on 8/7/14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

#import "NSData+bz2.h"
#import "bzlib.h"

@implementation NSData (bz2)

+ (NSData *)bunzip2:(NSData*)data
{
    int bzret;
    bz_stream stream = { 0 };
    stream.next_in = (char*)[data bytes];
    stream.avail_in = (int)[data length];
    
    const int buffer_size = 10000;
    NSMutableData * buffer = [NSMutableData dataWithLength:buffer_size];
    stream.next_out = [buffer mutableBytes];
    stream.avail_out = buffer_size;
    
    NSMutableData * decompressed = [NSMutableData data];
    
    BZ2_bzDecompressInit(&stream, 0, NO);
    @try {
        do {
            bzret = BZ2_bzDecompress(&stream);
            if (bzret != BZ_OK && bzret != BZ_STREAM_END)
                @throw [NSException exceptionWithName:@"bzip2" reason:@"BZ2_bzDecompress failed" userInfo:nil];
            
            [decompressed appendBytes:[buffer bytes] length:(buffer_size - stream.avail_out)];
            stream.next_out = [buffer mutableBytes];
            stream.avail_out = buffer_size;
        } while(bzret != BZ_STREAM_END);
    }
    @finally {
        BZ2_bzDecompressEnd(&stream);
    }
    
    return decompressed;
}

- (NSData *)bunzip2
{
    return [NSData bunzip2:self];
}

@end
