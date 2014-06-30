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

@interface SpeedViewController : UIViewController <CLLocationManagerDelegate>
{
    CLLocationManager *manager;
    CLLocationSpeed currentSpeed;
    CLLocation *currentLocation;
    NSArray *nodes;
    
    AVSpeechSynthesizer *synth;
    NSTimer *speechTimer;
    
    NSTimer *announceDirectionTimer;
    CLLocation *previousLocation;
    CLLocation *closestPlaceLocation;
}

@property (weak, nonatomic) IBOutlet UILabel *currentSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *directionLabel;

@end
