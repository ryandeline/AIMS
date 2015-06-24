//
//  HobbsTableViewController.h
//  flightlog
//
//  Created by Chris Frederick on 10/10/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MeterDataEnteredDelegate <NSObject>
- (void)MeterDataEnteredForHobbsStart:(NSNumber*)hobbsStart HobbsEnd:(NSNumber*)hobbsEnd HobbsDuration:(NSNumber*)hobbsDuration TachStart:(NSNumber*)tachStart TachEnd:(NSNumber*)tachEnd TachDuration:(NSNumber*)tachDuration BrokenTach:(BOOL)brokenTach BrokenHobbs:(BOOL)brokenHobbs;
@end

typedef enum meterStateTypes
{
    EDIT_HOBBS_START,
    EDIT_HOBBS_END,
    EDIT_HOBBS_DURATION,
    EDIT_TACH_START,
    EDIT_TACH_END,
    EDIT_TACH_DURATION
    
} MeterState;

@interface HobbsTableViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBtn;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UILabel *hobbsStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *hobbsEndLabel;
@property (weak, nonatomic) IBOutlet UILabel *hobbsDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *tachStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *tachEndLabel;
@property (weak, nonatomic) IBOutlet UILabel *tachDurationLabel;
@property (strong, nonatomic) NSArray *decimalnumbers;
@property (strong, nonatomic) NSMutableArray *wholenumbers;
@property (weak, nonatomic) id<MeterDataEnteredDelegate> delegate;
@property NSNumber *hobbsStart;
@property NSNumber *hobbsEnd;
@property NSNumber *hobbsDuration;
@property NSNumber *tachStart;
@property NSNumber *tachEnd;
@property NSNumber *tachDuration;
@property NSNumberFormatter *numberFormatter;
@property MeterState meterState;
@property BOOL readOnly;
@property BOOL brokenHobbs;
@property BOOL brokenTach;
@property (strong, nonatomic) UISwitch *hobbsSwitch;
@property (strong, nonatomic) UISwitch *tachSwitch;

@end
