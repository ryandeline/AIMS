//
//  MaintenanceEntryViewController.h
//  flightlog
//
//  Created by Chris Frederick on 12/9/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatePickerViewController.h"
#import "CommentsViewController.h"

@protocol MaintenanceEntryDelegate <NSObject>
- (void)newMaintenanceEntry:(NSDate *)date withType:(NSString *)maintenanceType tachHours:(NSNumber *)tach andComment:(NSString*)comment;
@end

@interface MaintenanceEntryViewController : UITableViewController <DatePickerDelegate, CommentEditedDelegate,
UIPickerViewDelegate, UIPickerViewDataSource>

@property NSDate *date;
@property NSString *maintenanceType;
@property NSString *comment;
@property NSNumber *tachHours;
@property (strong, nonatomic) NSArray *decimalnumbers;
@property (strong, nonatomic) NSMutableArray *wholenumbers;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property NSIndexPath *oldIndexPath;
@property (weak, nonatomic) id<MaintenanceEntryDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBtn;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property NSNumberFormatter *numberFormatter;

@end
