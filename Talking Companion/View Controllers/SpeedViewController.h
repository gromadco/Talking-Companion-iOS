//
//  SpeedViewController.h
//  Talking Companion
//
//  Created by Sergey Butenko on 25.06.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import "Talking_Companion-Swift.h"

@class OSMTilesDownloader;

@interface SpeedViewController : UIViewController <CLLocationManagerDelegate, OSMTilesDownloaderDelegate>
{
    CLLocationManager *manager;
    CLLocationSpeed currentSpeed;
    CLLocation *currentLocation;
    NSArray *nodes;
    OSMTilesDownloader *tilesDownloader;
    
    AVSpeechSynthesizer *synth;
    NSTimer *speechTimer;
    NSTimer *tilesTimer;
    
    NSTimer *announceDirectionTimer;
    CLLocation *previousLocation;
    CLLocation *closestPlaceLocation;
    
    BOOL isLocationEnabled;
}

@property (weak, nonatomic) IBOutlet UILabel *currentSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *directionLabel;

@property (weak, nonatomic) IBOutlet UILabel *allowAccessLabel;

@end
