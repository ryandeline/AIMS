//
//  NewNoteViewController.h
//  flightlog
//
//  Created by Chris Frederick on 11/27/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatePickerViewController.h"
#import "CommentsViewController.h"

@protocol NewNoteDelegate <NSObject>
- (void)newNoteForDate:(NSDate *)date withComment:(NSString*)comment;
@end

@interface NewNoteViewController : UITableViewController  <DatePickerDelegate, CommentEditedDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBtn;
@property NSString *comment;
@property NSDate *date;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) id<NewNoteDelegate> delegate;
@property BOOL readOnly;

@end
