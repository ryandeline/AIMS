//
//  LogbookCell.m
//  flightlog
//
//  Created by Chris Frederick on 11/3/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import "LogbookCell.h"

@implementation LogbookCell

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
