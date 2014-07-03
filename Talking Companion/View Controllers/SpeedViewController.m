//
//  SpeedViewController.m
//  Talking Companion
//
//  Created by Sergey Butenko on 25.06.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

#import "SpeedViewController.h"
#import "Talking_Companion-Swift.h"

static const NSTimeInterval pronounceSpeedTimeInterval = 15;
static const NSTimeInterval announceDirectionTimeInterval = 2;
static const double kKilometersPerHour = 3.6;

static const NSTimeInterval downloadTilesTimeInterval = 60;
static const NSInteger kDefaultZoom = 16;
static const CLLocationDegrees kDefaulLatitude = 47.817997;
static const CLLocationDegrees kDefaulLongitude = 35.19622;

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

@implementation SpeedViewController

#pragma mark - View Methonds

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    OSMElementsParser *parser = [[OSMElementsParser alloc] init];
    [parser initialize];
    nodes = [parser nodesWithProperty:@"name"];
    
    [self loadLocationManager];
    [self neighboringTilesForCoordinates:CLLocationCoordinate2DMake(kDefaulLatitude, kDefaulLongitude)];
    
    speechTimer = [NSTimer scheduledTimerWithTimeInterval:pronounceSpeedTimeInterval target:self selector:@selector(pronounceSpeed) userInfo:nil repeats:YES];
    tilesTimer = [NSTimer scheduledTimerWithTimeInterval:downloadTilesTimeInterval target:self selector:@selector(downloadTiles) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([speechTimer isValid]) {
        [speechTimer invalidate];
    }
    if ([tilesTimer isValid]) {
        [tilesTimer invalidate];
    }
}

#pragma mark -

- (void)downloadTiles
{
    [self neighboringTilesForCoordinates:currentLocation.coordinate];
}

- (void)neighboringTilesForCoordinates:(CLLocationCoordinate2D)coordinates
{
    OSMTile *centerTile = [[OSMTile alloc] initWithLatitude:coordinates.latitude longitude:coordinates.longitude zoom:kDefaultZoom];

    OSMTilesDownloader *downloader = [[OSMTilesDownloader alloc] init];
    [downloader downloadNeighboringTilesForTile:centerTile];
}

#pragma mark - Place details

#pragma mark Speed

- (void)pronounceSpeed
{
    NSString *string = [NSString stringWithFormat:@"%.2lf km per hour", currentSpeed];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:string];
    [synth speakUtterance:utterance];
}

#pragma mark Closest place

- (void)speakPlace:(OSMNode*)place distance:(CLLocationDistance)distance
{
    NSString *string = [NSString stringWithFormat:@"Closest plase is %@ with distance %li m", place.name, (long)distance];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:string];
    [synth speakUtterance:utterance];
    [place announce];
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
        [self speakPlace:closestPlace distance:minDistance];
    }
    _nameLabel.text = closestPlace.name;
    _distanceLabel.text = [NSString stringWithFormat:@"%li m.", (long)minDistance];
    closestPlaceLocation = closestPlace.location;
}

#pragma mark Direction

- (void)announceDirection
{
    double phi1, phi2;
    
    double y1 = sin(currentLocation.coordinate.longitude - previousLocation.coordinate.longitude) * cos(currentLocation.coordinate.latitude);
    double x1 = cos(previousLocation.coordinate.latitude) * sin(currentLocation.coordinate.latitude) - sin(previousLocation.coordinate.latitude)*cos(currentLocation.coordinate.latitude);
    phi1 = atan2(y1, x1);
    phi1 = RADIANS_TO_DEGREES(phi1);
    
    double y2 = sin(currentLocation.coordinate.longitude - closestPlaceLocation.coordinate.longitude) * cos(currentLocation.coordinate.latitude);
    double x2 = cos(closestPlaceLocation.coordinate.latitude) * sin(currentLocation.coordinate.latitude) - sin(closestPlaceLocation.coordinate.latitude)*cos(currentLocation.coordinate.latitude);
    phi2 = atan2(y2, x2);
    phi2 = RADIANS_TO_DEGREES(phi2);
    
    int theta = abs((int)(phi2 - phi1) % 360);
    [self updateDirectionWithAngle:theta];

    previousLocation = currentLocation;
}

- (void)updateDirectionWithAngle:(int)angle
{
    NSString *direction = @"cannot detect";
    if (angle >=0 && angle < 45) {
        direction = @"in front";
    }
    else if (angle >=45 && angle < 135) {
        direction = @"right";
    }
    else if (angle >=135 && angle < 225) {
        direction = @"back";
    }
    else if (angle >=225 && angle < 315) {
        direction = @"left";
    }
    else if (angle >=315 && angle <= 360) {
        direction = @"in front";
    }
    _directionLabel.text = [NSString stringWithFormat:@"%@ (%i degree)", direction, angle];
}

#pragma mark - CLLocationManager Delegate

- (void)loadLocationManager
{
    manager = [[CLLocationManager alloc] init];
    manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    [manager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    currentSpeed = newLocation.speed * kKilometersPerHour;
    currentSpeed = currentSpeed > 0 ? currentSpeed : 0;
    _currentSpeedLabel.text = [NSString stringWithFormat:@"%.2lf km/h", currentSpeed];
    
    currentLocation = newLocation;
    [self announceClosestPlace];
    
    if (previousLocation == nil) {
        previousLocation = newLocation;
        announceDirectionTimer = [NSTimer scheduledTimerWithTimeInterval:announceDirectionTimeInterval target:self selector:@selector(announceDirection) userInfo:nil repeats:YES];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Access denied" message:@"Please enable access to location services" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

@end
