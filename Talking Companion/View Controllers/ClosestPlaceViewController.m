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
static const NSTimeInterval hideSettingsButtonInterval = 10;
static const NSInteger kDefaultZoom = 16;
static const int KILOMETER = 1000;
static const CLLocationDistance maxDistance = 10 * KILOMETER;

@interface ClosestPlaceViewController () <CLLocationManagerDelegate, OSMTilesDownloaderDelegate>
{
    CLLocation *currentLocation;
    NSArray *nodes;
    NSTimer *tilesTimer;
    
    NSTimeInterval announceDistanceTimeInterval;
    NSTimer *announceDistanceTimer;
    CLLocation *previousLocation;
    CLLocation *closestPlaceLocation;
    
    NSTimer *hideSettingsButtonTimer;
}

@property (nonatomic, strong) OSMTilesDownloader *tilesDownloader;
@property (nonatomic, strong) AVSpeechSynthesizer *synth;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
- (IBAction)showSettingsViewController:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation ClosestPlaceViewController

#pragma mark - View Methods

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    previousLocation = nil;
    [self.locationManager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"path to documents: %@", NSHomeDirectory());
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatingIntervalChanged) name:@"UpdatingIntervalNotification" object:nil];
    [self.settingsButton setTitle:@"\u2699" forState:UIControlStateNormal];
    
    [self updateNodesFromDB];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSettingsButton:)];
    [self.view addGestureRecognizer:tap];
    [self startHideButtonTimer];
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

#pragma mark - Settings Button

- (void)showSettingsButton:(UIGestureRecognizer*)recognizer
{
    self.settingsButton.hidden = !self.settingsButton.isHidden;
    
    if (self.settingsButton.hidden == NO) {
        [self startHideButtonTimer];
    }
    else {
        if ([hideSettingsButtonTimer isValid]) {
             [hideSettingsButtonTimer invalidate];
        }
    }
}

- (void)startHideButtonTimer
{
    hideSettingsButtonTimer = [NSTimer scheduledTimerWithTimeInterval:hideSettingsButtonInterval target:self selector:@selector(hideSettingsButton) userInfo:nil repeats:NO];
}

- (void)hideSettingsButton
{
    self.settingsButton.hidden = YES;
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

- (OSMTilesDownloader *)tilesDownloader
{
    if (!_tilesDownloader) {
        _tilesDownloader = [[OSMTilesDownloader alloc] init];
        _tilesDownloader.delegate = self;
        
    }
    return _tilesDownloader;
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
    
    if (currentLocation.speed > 0) {
        self.statusLabel.text = @"";
    }
    else {
        self.statusLabel.text = [NSString stringWithFormat:@"Start moving\n%i poins around", (int)nodes.count];
    }
    //NSLog(@"received nodes from db: %li", nodes.count);
}

- (void)downloadNeighboringTiles
{
    self.statusLabel.text = @"Loading...";
    OSMTile *centerTile = [[OSMTile alloc] initWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude zoom:kDefaultZoom];
    [self.tilesDownloader downloadNeighboringTilesForTile:centerTile];
    //NSLog(@"downloading neighboring tiles for tile(%lf; %lf) @ %@", coordinates.latitude, coordinates.longitude, [[OSMBoundingBox alloc] initWithTile:centerTile].url);
}

#pragma mark - OSMTileDownloader Delegate

- (void)tilesDownloaded
{
    [self updateNodesFromDB];
}

#pragma mark - Place details

// part
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
    
    if (!closestPlace) {
        return;
    }
    
    NSString *distance;
    if (distanceToClosestPlace > maxDistance) {
        distance = [NSString stringWithFormat:@"over %i km", (int)maxDistance / KILOMETER];
    }
    else {
        if (distanceToClosestPlace > KILOMETER) {
            distance = [NSString stringWithFormat:@"%.1lf km", distanceToClosestPlace / KILOMETER];
        }
        else {
            distance = [NSString stringWithFormat:@"%i m", (int)distanceToClosestPlace];
        }
    }

    if (!closestPlace.isAnnounced) {
        [self speakPlace:closestPlace distance:distanceToClosestPlace];
    }
    
    NSString *direction = @"";
    if (angle >=0 && angle < 45) {
        direction = @"in front";
    }
    else if (angle >=45 && angle < 135) {
        direction = @"to the right";
    }
    else if (angle >=135 && angle < 225) {
        direction = @"back";
    }
    else if (angle >=225 && angle < 315) {
        direction = @"to the left";
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
        NSString *placeString = [NSString stringWithFormat:@"Closest place is %@, %@with distance %li m", place.name, place.type, (long)distance];
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
    
    BOOL locationEnabled;
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusNotDetermined) {
        locationEnabled = NO;
    }
    else {
        locationEnabled = YES;
    }

    [self checkLocationsPermissions:locationEnabled];
}

// start or stop downloading
- (void)checkLocationsPermissions:(BOOL)isLocationEnabled
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

    self.statusLabel.text = isLocationEnabled ? @"" : @"Allow location access";
}

@end
