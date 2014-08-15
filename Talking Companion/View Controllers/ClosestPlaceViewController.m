//
//  ClosestPlaceViewController.m
//  Talking Companion
//
//  Created by Sergey Butenko on 25.06.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

#import "ClosestPlaceViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import "Talking_Companion-Swift.h"

#warning set default
static const NSTimeInterval downloadTilesTimeInterval = 5; // 60
static const NSInteger kDefaultZoom = 16;
static const int KILOMETER = 1000;
static const CLLocationDistance maxDistance = 10 * KILOMETER;

@interface ClosestPlaceViewController () <CLLocationManagerDelegate, OSMTilesDownloaderDelegate>
{
    BOOL isLocationEnabled;
    CLLocation *currentLocation;
    NSArray *nodes;
    OSMTilesDownloader *tilesDownloader;
    NSTimer *tilesTimer;
    
    NSTimeInterval announceDistanceTimeInterval;
    NSTimer *announceDistanceTimer;
    CLLocation *previousLocation;
    CLLocation *closestPlaceLocation;
}

@property (nonatomic, strong) AVSpeechSynthesizer *synth;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UILabel *allowAccessLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

@end

@implementation ClosestPlaceViewController

#pragma mark - View Methonds

- (void)viewWillAppear:(BOOL)animated
{
    [self updateNodesFromDB];
    
    previousLocation = nil;
    [self.locationManager startUpdatingLocation];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    tilesDownloader = [[OSMTilesDownloader alloc] init];
    tilesDownloader.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatingIntervalChanged) name:@"UpdatingIntervalNotification" object:nil];
    
    NSLog(@"path to documents: %@", NSHomeDirectory());
}

- (IBAction)showSettingsViewController:(id)sender
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        [self performSegueWithIdentifier:@"Popover Settings" sender:sender];
    }
    else {
        [self performSegueWithIdentifier:@"Push Settings" sender:sender];
    }
}

- (void)updatingIntervalChanged
{
    if ([announceDistanceTimer isValid]) {
        [announceDistanceTimer invalidate];
    }
    
    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"UpdatingInterval"];
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"]];
    announceDistanceTimeInterval = [settings[@"Durations"][index] doubleValue];
    announceDistanceTimer = [NSTimer scheduledTimerWithTimeInterval:announceDistanceTimeInterval target:self selector:@selector(announceClosestPlace) userInfo:nil repeats:YES];
}


#pragma mark - Lazy Instantiation

- (AVSpeechSynthesizer *)synth
{
    if (!_synth) {
        _synth = [[AVSpeechSynthesizer alloc] init];
    }
    return _synth;
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return _locationManager;
}

#pragma mark - Fetching Nodes

- (void)updateNodesFromDB
{
    OSMTile *centerTile = [[OSMTile alloc] initWithLatitude:currentLocation.coordinate.latitude
                                                  longitude:currentLocation.coordinate.longitude zoom:kDefaultZoom];
    
    NSMutableArray *tmpNodes = [NSMutableArray array];
    NSArray *neighboringTiles = [centerTile neighboringTiles];
    for (OSMTile *currentTile in neighboringTiles) {
        [tmpNodes addObjectsFromArray:[SQLAccess nodesForTile:currentTile]];
    }
    nodes = [tmpNodes copy];
    NSLog(@"received nodes from db: %li", nodes.count);
}

- (void)downloadNeighboringTiles
{
    OSMTile *centerTile = [[OSMTile alloc] initWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude zoom:kDefaultZoom];
    [tilesDownloader downloadNeighboringTilesForTile:centerTile];
    //NSLog(@"downloading neighboring tiles for tile(%lf; %lf) @ %@", coordinates.latitude, coordinates.longitude, [[OSMBoundingBox alloc] initWithTile:centerTile].url);
}

#pragma mark - OSMTileDownloader Delegate

- (void)tilesDownloaded
{
    [self updateNodesFromDB];
}

#pragma mark - Place details

- (void)announceClosestPlace
{
    double angle = [Calculations thetaForCurrentLocation:currentLocation previousLocation:previousLocation placeLocation:closestPlaceLocation];
    previousLocation = currentLocation;
    
    OSMNode *closestPlace;
    CLLocationDistance distanceToClosestPlace = INT_MAX;
    
    for (OSMNode *node in nodes) {
        CLLocationDistance distance = [currentLocation distanceFromLocation:node.location];
        if (distanceToClosestPlace > distance) {
            distanceToClosestPlace = distance;
            closestPlace = node;
        }
    }
    if (distanceToClosestPlace > maxDistance) {
        _distanceLabel.text = [NSString stringWithFormat:@"over %i km", (int)maxDistance / KILOMETER];
        return;
    }

    if (!closestPlace.isAnnounced) {
        [self speakPlace:closestPlace distance:distanceToClosestPlace];
    }
    
    NSString *distance;
    if (distanceToClosestPlace > KILOMETER) {
        distance = [NSString stringWithFormat:@"%.1lf km", distanceToClosestPlace / KILOMETER];
    }
    else {
        distance = [NSString stringWithFormat:@"%i m", (int)distanceToClosestPlace];
    }
    
    NSString *direction = @"";
    if (angle >=0 && angle < 45) {
        direction = @"in front";
    }
    else if (angle >=45 && angle < 135) {
        direction = @"in the right";
    }
    else if (angle >=135 && angle < 225) {
        direction = @"back";
    }
    else if (angle >=225 && angle < 315) {
        direction = @"in the left";
    }
    else if (angle >=315 && angle <= 360) {
        direction = @"in front";
    }
    
    _nameLabel.text = closestPlace.name;
    _distanceLabel.text = [NSString stringWithFormat:@"%@ %@", distance, direction];
    _typeLabel.text = closestPlace.type;
    closestPlaceLocation = closestPlace.location;
}

- (void)speakPlace:(OSMNode*)place distance:(CLLocationDistance)distance
{
    if (distance > 0) {
        NSString *placeString = [NSString stringWithFormat:@"Closest place is %@, %@ with distance %li m", place.name, place.type, (long)distance];
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:placeString];
        [self.synth speakUtterance:utterance];
        [place announce];
        
        NSLog(@"announce place \"%@\"", placeString);
    }
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    currentLocation = newLocation;
    
    if (previousLocation == nil) {
        NSLog(@"initial coordinates: (%lf; %lf)", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
        previousLocation = newLocation;
        
        [self updateNodesFromDB];
        [self downloadNeighboringTiles];
        [self announceClosestPlace];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location manager error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"location manager status: %i", status);
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusNotDetermined) {
        isLocationEnabled = NO;
    }
    else {
        isLocationEnabled = YES;
    }

    [self checkLocationsPermissions];
}

// start or stop downloading
- (void)checkLocationsPermissions
{
    if (isLocationEnabled) {
        tilesTimer = [NSTimer scheduledTimerWithTimeInterval:downloadTilesTimeInterval target:self selector:@selector(downloadNeighboringTiles) userInfo:nil repeats:YES];
        [self updatingIntervalChanged];
    }
    else {
        if ([tilesTimer isValid]) {
            [tilesTimer invalidate];
        }
        if ([announceDistanceTimer isValid]) {
            [announceDistanceTimer invalidate];
        }
    }
    
    self.allowAccessLabel.hidden = isLocationEnabled;
}

@end
