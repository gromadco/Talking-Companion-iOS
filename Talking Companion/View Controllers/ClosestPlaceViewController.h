//
//  SpeedViewController.h
//  Talking Companion
//
//  Created by Sergey Butenko on 25.06.14.
//  Copyright (c) 2014 serejahh inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Talking_Companion-Swift.h"

@interface ClosestPlaceViewController : UIViewController <CLLocationManagerDelegate, OSMTilesDownloaderDelegate>

@property (weak, nonatomic) IBOutlet UILabel *currentSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *directionLabel;

@property (weak, nonatomic) IBOutlet UILabel *allowAccessLabel;

@end
