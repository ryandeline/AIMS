//
//  LogbookCell.h
//  flightlog
//
//  Created by Chris Frederick on 11/3/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogbookCell : UITableViewCell
//@property (weak, nonatomic) IBOutlet UIButton *hobbsBtnLabel;
//@property (weak, nonatomic) IBOutlet UIButton *tachBtnLabel;
//@property (weak, nonatomic) IBOutlet UILabel *pilotLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
//@property (weak, nonatomic) IBOutlet UILabel *tachStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *tachEndLabel;
//@property (weak, nonatomic) IBOutlet UILabel *hobbsStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *hobbsEndLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *projectLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *syncImage;
@property (weak, nonatomic) IBOutlet UILabel *routeLabel;
//@property (weak, nonatomic) IBOutlet UILabel *areaLabel;
//@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
//@property (weak, nonatomic) IBOutlet UILabel *tachDurationLabel;
//@property (weak, nonatomic) IBOutlet UILabel *hobbsDurationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *syncBtn;

@end
