//
//  SpeedViewController.m
//  Talking Companion
//
//  Created by Sergey Butenko on 25.06.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

#import "SpeedViewController.h"
#import "Talking_Companion-Swift.h"

static const NSTimeInterval pronounceSpeedTimerInterval = 15;
static const CLLocationDistance thresholdDistance = 200;

@implementation SpeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    OSMElementsParser *parser = [[OSMElementsParser alloc] init];
    [parser initialize];
    nodes = [parser nodesWithProperty:@"name"];
    
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

- (void)announceClosestPlace
{
    OSMNode *closestPlace;
    CLLocationDistance minDistance = INT_MAX;
    
    for (OSMNode *node in nodes) {
        CLLocationDistance distance = [currentLocation distanceFromLocation:node.location];

        if (minDistance > distance) {
            minDistance = distance;
            closestPlace = node;
        }
    }
    
    if (!closestPlace.isAnnounced) {
        [closestPlace announce];
        [self speakPlace:closestPlace distance:minDistance];
    }
    _nameLabel.text = closestPlace.name;
    _distanceLabel.text = [NSString stringWithFormat:@"%li m.", (long)minDistance];
}

- (void)speakPlace:(OSMNode*)place distance:(CLLocationDistance)distance
{
    NSString *string = [NSString stringWithFormat:@"Closest plase is %@ with distance %li m", place.name, (long)distance];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:string];
    [synth speakUtterance:utterance];
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    currentSpeed = newLocation.speed *3.6;
    currentSpeed = currentSpeed > 0 ? currentSpeed : 0;
    _currentSpeedLabel.text = [NSString stringWithFormat:@"%.2lf km/h", currentSpeed];
    
    currentLocation = newLocation;
    [self announceClosestPlace];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    //NSLog(@"location status: %i", status);
    
    if (status == kCLAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Access denied" message:@"Please enable access to location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

@end
