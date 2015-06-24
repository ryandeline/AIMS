//
//  NonFlightViewController.h
//  flightlog
//
//  Created by Chris Frederick on 11/26/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatePickerViewController.h"
#import "CommentsViewController.h"

@protocol NewNonFlightDelegate <NSObject>
- (void)newNonFlightEntryForDate:(NSDate *)date withReason:(NSString *)reason andComment:(NSString*)comment;
@end

@interface NonFlightViewController : UITableViewController <DatePickerDelegate, CommentEditedDelegate>

@property NSDate *date;
@property NSString *reason;
@property NSString *comment;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBtn;
@property NSIndexPath *oldIndexPath;
@property (weak, nonatomic) id<NewNonFlightDelegate> delegate;
@property BOOL readOnly;
@end
