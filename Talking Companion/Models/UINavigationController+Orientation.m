//
//  UINavigationController+Orientation.m
//  Talking Companion
//
//  Created by Sergey Butenko on 1/22/15.
//  Copyright (c) 2015 serejahh inc. All rights reserved.
//

#import "UINavigationController+Orientation.h"

@implementation UINavigationController (Orientation)

- (NSUInteger)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return  UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}

@end
