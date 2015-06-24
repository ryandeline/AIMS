//
//  AircraftCell.h
//  flightlog
//
//  Created by Chris Frederick on 1/10/13.
//  Copyright (c) 2013 Chris Frederick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AircraftCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *tailNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *aircraftImageView;

@end
