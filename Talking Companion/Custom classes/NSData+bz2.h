//
//  NSData+bz2.h
//  Talking Companion
//
//  Created by Sergey Butenko on 8/7/14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (bz2)

+ (NSData *)bunzip2:(NSData*)data;
- (NSData *)bunzip2;

@end
