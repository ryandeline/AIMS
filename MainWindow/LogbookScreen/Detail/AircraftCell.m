//
//  AircraftCell.m
//  flightlog
//
//  Created by Chris Frederick on 1/10/13.
//  Copyright (c) 2013 Chris Frederick. All rights reserved.
//

#import "AircraftCell.h"

@implementation AircraftCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
