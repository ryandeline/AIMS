//
//  AircraftSelectionDelegate.h
//  flightlog
//
//  Created by Chris Frederick on 10/2/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Aircraft.h"

@protocol AircraftSelectionDelegate <NSObject>

- (void)aircraftSelectionChanged:(Aircraft *)currSelection;

@end
