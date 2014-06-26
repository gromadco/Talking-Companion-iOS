//
//  SpeedViewController.m
//  Talking Companion
//
//  Created by Sergey Butenko on 25.06.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

#import "SpeedViewController.h"

static const NSTimeInterval pronounceSpeedTimerInterval = 15;

@implementation SpeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    manager = [[CLLocationManager alloc] init];
    manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    [manager startUpdatingLocation];
    
    speechTimer = [NSTimer scheduledTimerWithTimeInterval:pronounceSpeedTimerInterval target:self selector:@selector(pronounceSpeed) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([speechTimer isValid]) {
        [speechTimer invalidate];
    }
}

- (void)pronounceSpeed
{
    NSString *string = [NSString stringWithFormat:@"%.2lf km per hour", currentSpeed];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:string];
    [synth speakUtterance:utterance];
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    currentSpeed = newLocation.speed *3.6;
    currentSpeed = currentSpeed > 0 ? currentSpeed : 0;
    _currentSpeedLabel.text = [NSString stringWithFormat:@"%.2lf km/h", currentSpeed];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"location status: %i", status);
    
    if (status == kCLAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Access denied" message:@"Please enable access to location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

@end
