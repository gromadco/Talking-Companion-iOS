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
    
    AVSpeechSynthesizer *synth;
    NSTimer *speechTimer;
}

@property (weak, nonatomic) IBOutlet UILabel *currentSpeedLabel;

@end
