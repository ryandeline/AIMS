//
//  MaintenanceEntryViewController.m
//  flightlog
//
//  Created by Chris Frederick on 12/9/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import "MaintenanceEntryViewController.h"

@interface MaintenanceEntryViewController ()

@end

@implementation MaintenanceEntryViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    self.dateLabel.text = [formatter stringFromDate:_date];
    _comment = nil;
    self.commentLabel.text = nil;
    _oldIndexPath = nil;
    _doneBtn.enabled = NO;
    
    _picker.delegate = self;
    _picker.dataSource = self;
    
    self.decimalnumbers = [[NSArray alloc]
                           initWithObjects: [NSNumber numberWithInt:0],
                           [NSNumber numberWithInt:1],
                           [NSNumber numberWithInt:2],
                           [NSNumber numberWithInt:3],
                           [NSNumber numberWithInt:4],
                           [NSNumber numberWithInt:5],
                           [NSNumber numberWithInt:6],
                           [NSNumber numberWithInt:7],
                           [NSNumber numberWithInt:8],
                           [NSNumber numberWithInt:9], nil];
    
    self.wholenumbers = [[NSMutableArray alloc] initWithCapacity:100000];
    
    //setup our numberFormatter
    self.numberFormatter = [[NSNumberFormatter alloc] init];
    [self.numberFormatter setMaximumFractionDigits:1];
}

-(void) viewDidAppear:(BOOL)animated {
    
    CGSize size;
    size.width = 320;
    size.height = 500-37;
    [self setContentSizeForViewInPopover:size];
    
    NSInteger maxValue = [_tachHours integerValue];
    if(maxValue == 0)
        maxValue = 99999;
    else
        maxValue += 100;
    
    for(int i=[_tachHours integerValue]; i<maxValue; i++) {
        [self.wholenumbers addObject:[NSNumber numberWithInt:i]];
    }
    
    [_picker reloadAllComponents];
}

- (void)setPickerRows:(NSNumber*)value {
    @try {
        //Find the whole number index
        NSInteger index = [self.wholenumbers indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop)
                           {
                               if ([obj intValue] == [value intValue])
                                   return YES;
                               else
                                   return NO;
                           }];
        [self.picker selectRow:index inComponent:0 animated:YES];
        
        index = [self tensPlaceValue:value];
        [self.picker selectRow:index inComponent:1 animated:YES];
    }
    @catch(NSException *exception) {
        NSLog(@"Caught exception in setPickerRows: %@", value);
    }
}

- (NSInteger) tensPlaceValue:(NSNumber*)value {
    //Find the 10's place whole number
    NSNumber *diff =[[NSNumber alloc] initWithFloat:([value floatValue] - floorf([value floatValue]))];
    NSString *decimalString = [self.numberFormatter stringFromNumber:diff];
    NSLog(@"DecimalString value: %@", decimalString);
    if([[decimalString substringWithRange:NSMakeRange (0, 1)] isEqualToString:@"."])
    {
        NSInteger index = [[decimalString substringWithRange:NSMakeRange (1, 1)] intValue];
        return index;
    }
    else
        return 0;
};
-(void) commentEdited:(NSString *)comment {
    _comment = comment;
    _commentLabel.text = _comment;
    [self.navigationController popViewControllerAnimated:YES];
    [self toggleDoneBtn];
}

-(void) dateSelected:(NSDate *)date {
    _date = date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    self.dateLabel.text = [formatter stringFromDate:_date];
    [self.navigationController popViewControllerAnimated:YES];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if(component ==0)
        return [self.wholenumbers count];
    else
        return [self.decimalnumbers count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(component == 0) {
        NSNumber *i = (NSNumber*)[self.wholenumbers objectAtIndex:row];
        return [i stringValue];
    } else {
        NSNumber *i = (NSNumber*)[self.decimalnumbers objectAtIndex:row];
        return [i stringValue];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    //I have taken two components thats why I have set frame of my "label" accordingly. you can set the frame of the label depends on number of components you have...
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 145, 45)];
    
    //For right alignment of text,You can set the NSTextAlignmentRight of the label.
    //No need to set alignment to UITextAlignmentLeft because it is defaulted to picker data display behavior.
    label.opaque=NO;
    label.backgroundColor=[UIColor clearColor];
    label.textColor = [UIColor blackColor];
    UIFont *font = [UIFont boldSystemFontOfSize:20];
    label.font = font;
    if(component == 0)
    {
        [label setTextAlignment:NSTextAlignmentRight];
        [label setText:[NSString stringWithFormat:@"%@",[self.wholenumbers objectAtIndex:row]]];
    }
    else if(component == 1)
    {
        [label setText:[NSString stringWithFormat:@".%@", [self.decimalnumbers objectAtIndex:row]]];
    }
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSUInteger component0row = [pickerView selectedRowInComponent:0];
    NSUInteger component1row = [pickerView selectedRowInComponent:1];
    
    UILabel *firstPart = (UILabel*)[pickerView viewForRow:component0row forComponent:0];
    UILabel *secondPart = (UILabel*)[pickerView viewForRow:component1row forComponent:1];
    
    float fWhole = [firstPart.text floatValue];
    float fDecimal = [secondPart.text floatValue];
    float fValue = fWhole + fDecimal;
    
    _tachHours = [[NSNumber alloc] initWithFloat:fValue];
    
}

- (IBAction)onDone:(id)sender {
     [self.delegate newMaintenanceEntry:_date withType:_maintenanceType tachHours:_tachHours andComment:_comment];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Value: %@", segue.identifier);
    if([segue.identifier isEqualToString:@"MaintenanceDateSegue"]) {
        DatePickerViewController  *dateController = [segue destinationViewController];
        dateController.delegate = self;
        CGSize size;
        size.width = 320;
        size.height = 500-37;
        [dateController setContentSizeForViewInPopover:size];
    } else if([segue.identifier isEqualToString:@"MaintenanceCommentSegue"]) {
        CommentsViewController *controller = (CommentsViewController*)[segue destinationViewController];
        controller.delegate = self;
        CGSize size;
        size.width = 320;
        size.height = 500-37;
        controller.initialComment = _comment;
        [controller setContentSizeForViewInPopover:size];
    }
}

-(void)toggleDoneBtn {
    if(_oldIndexPath != nil && _comment && _comment.length > 0)
        _doneBtn.enabled = YES;
    else
        _doneBtn.enabled = NO;
}

-(void)toggleCheckmarkedCell:(UITableViewCell *)cell
{
    if (cell.accessoryType == UITableViewCellAccessoryNone)
    	cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
    	cell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section ==1) {
        if(_oldIndexPath.row != indexPath.row || _oldIndexPath == nil) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            _maintenanceType = cell.textLabel.text;
            UITableViewCell *cell2 = [tableView cellForRowAtIndexPath:_oldIndexPath];
            // Toggle cells
            [self toggleCheckmarkedCell:cell];
            [self toggleCheckmarkedCell:cell2];
            _oldIndexPath = indexPath;
            [self toggleDoneBtn];
        }
    }
}

@end
