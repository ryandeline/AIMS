//
//  DatePickerViewController.h
//  flightlog
//
//  Created by Chris Frederick on 10/5/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DatePickerViewController;

@protocol DatePickerDelegate <NSObject>
- (void)dateSelected:(NSDate *)date;
@end

@interface DatePickerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) id<DatePickerDelegate> delegate;

- (IBAction)onDone:(id)sender;

@end
