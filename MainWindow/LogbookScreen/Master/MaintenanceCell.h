//
//  MaintenanceCell.h
//  flightlog
//
//  Created by Chris Frederick on 12/9/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaintenanceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *maintenanceTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *tachHours;
@property (weak, nonatomic) IBOutlet UIImageView *syncImage;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@end
