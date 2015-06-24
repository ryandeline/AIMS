//
//  HobbsTableViewController.m
//  flightlog
//
//  Created by Chris Frederick on 10/10/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import "HobbsTableViewController.h"

@interface HobbsTableViewController ()

@end

@implementation HobbsTableViewController

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
    
    self.picker.delegate = self;
    self.picker.dataSource = self;
    
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
    
    //set the starting values.
    self.hobbsStartLabel.text = [self.hobbsStart stringValue];
    self.hobbsEndLabel.text = [self.hobbsEnd stringValue];
    self.hobbsDurationLabel.text = [self.hobbsDuration stringValue];
    self.tachStartLabel.text = [self.tachStart stringValue];
    self.tachEndLabel.text = [self.tachEnd stringValue];
    self.tachDurationLabel.text = [self.tachDuration stringValue];

    //setup our numberFormatter
    self.numberFormatter = [[NSNumberFormatter alloc] init];
    [self.numberFormatter setMaximumFractionDigits:1];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    if(_readOnly) {
        _picker.hidden = YES;
        _doneBtn.enabled = NO;
    }    
}

- (void) viewWillAppear:(BOOL)animated {
    if(_readOnly) {
        return;
    }
    //Select the Hobbs End Cell
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    //Update the meter state to reflect we are editing hobbs end.
    [self updateMeterState:EDIT_HOBBS_END];
    
    //Disable the Hobbs Duration Cell and create Hobbs Switch
    indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self disableCell:cell];
    _hobbsSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    
    if(_brokenHobbs)
        [_hobbsSwitch setOn:NO animated:NO];
    else
        [_hobbsSwitch setOn:YES animated:NO];
    
    [_hobbsSwitch addTarget:self action:@selector(hobbsSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView = _hobbsSwitch;
    
    
    
    //Disable the Tach Duration Cell and create Tach Switch
    indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
    cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self disableCell:cell];
    _tachSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    
    if(_brokenTach)
        [_tachSwitch setOn:NO animated:NO];
    else
        [_tachSwitch setOn:YES animated:NO];
    
    [_tachSwitch addTarget:self action:@selector(tachSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    indexPath = [NSIndexPath indexPathForRow:3 inSection:1];
    cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView = _tachSwitch;
    
    [self tachSwitchChanged:_tachSwitch];
    [self hobbsSwitchChanged:_hobbsSwitch];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateMeterState:(MeterState)newState {
    NSLog(@"start updateMeterState for State %d", newState);
    self.meterState = newState;
    switch(newState) {
        case EDIT_HOBBS_START:
            [self setupWholeNumbers:[self.hobbsStart intValue]];
            [self setPickerRows:self.hobbsStart];
            break;
        case EDIT_HOBBS_END:
            [self setupWholeNumbers:[self.hobbsEnd intValue]];
            [self setPickerRows:self.hobbsEnd];
            break;
        case EDIT_HOBBS_DURATION:
            [self setupWholeNumbers:[self.hobbsDuration intValue]];
            [self setPickerRows:self.hobbsDuration];
            break;
        case EDIT_TACH_START: 
            [self setupWholeNumbers:[self.tachStart intValue]];
            [self setPickerRows:self.tachStart];
            break;
        case EDIT_TACH_END:
            [self setupWholeNumbers:[self.tachEnd intValue]];
            [self setPickerRows:self.tachEnd];
            break;
        case EDIT_TACH_DURATION:
            [self setupWholeNumbers:[self.tachDuration intValue]];
            [self setPickerRows:self.tachDuration];
            break;
    }
}

- (void)setupWholeNumbers:(NSInteger)value {
    [self.wholenumbers removeAllObjects];
    NSInteger maxValue = value;
    //if(maxValue == 0)
        maxValue = 99999;
    /*else
        maxValue += 100;
    */
    for(int i=0/*value*/; i<maxValue; i++) {
        [self.wholenumbers addObject:[NSNumber numberWithInt:i]];
    }
    [self.picker reloadComponent:0];
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
        [self.picker selectRow:index inComponent:0 animated:NO];
        
        index = [self tensPlaceValue:value];
        [self.picker selectRow:index inComponent:1 animated:NO];
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
    
    
    switch (self.meterState) {
        case EDIT_HOBBS_START:
            //set hobbs start
            self.hobbsStartLabel.text = [self.numberFormatter stringFromNumber:[[NSNumber alloc] initWithFloat:fValue]];
            self.hobbsStart = [[NSNumber alloc] initWithFloat:[self.hobbsStartLabel.text floatValue]];
            
            //recalc hobbs duration
            self.hobbsDuration = [[NSNumber alloc] initWithFloat:[self.hobbsEnd floatValue] - [self.hobbsStart floatValue]];
            self.hobbsDurationLabel.text = [self.numberFormatter stringFromNumber:self.hobbsDuration];
            
            break;
        case EDIT_HOBBS_END:
            self.hobbsEndLabel.text = [self.numberFormatter stringFromNumber:[[NSNumber alloc] initWithFloat:fValue]];
            self.hobbsEnd = [[NSNumber alloc] initWithFloat:[self.hobbsEndLabel.text floatValue]];
            
            //recalc hobbs duration
            self.hobbsDuration = [[NSNumber alloc] initWithFloat:[self.hobbsEnd floatValue] - [self.hobbsStart floatValue]];
            self.hobbsDurationLabel.text = [self.numberFormatter stringFromNumber:self.hobbsDuration];
            
            
            break;
        case EDIT_HOBBS_DURATION:
            self.hobbsDurationLabel.text = [self.numberFormatter stringFromNumber:[[NSNumber alloc] initWithFloat:fValue]];
            self.hobbsDuration = [[NSNumber alloc] initWithFloat:[self.hobbsDurationLabel.text floatValue]];
            
            //recalc hobbs end
            self.hobbsEnd = [[NSNumber alloc] initWithFloat:[self.hobbsDuration floatValue] + [self.hobbsStart floatValue]];
            self.hobbsEndLabel.text = [self.numberFormatter stringFromNumber:self.hobbsEnd];
            
            break;
        case EDIT_TACH_START:
            self.tachStartLabel.text = [self.numberFormatter stringFromNumber:[[NSNumber alloc] initWithFloat:fValue]];
            self.tachStart= [[NSNumber alloc] initWithFloat:[self.tachStartLabel.text floatValue]];
            
            //recalc hobbs duration
            self.tachDuration = [[NSNumber alloc] initWithFloat:[self.tachEnd floatValue] - [self.tachStart floatValue]];
            self.tachDurationLabel.text = [self.numberFormatter stringFromNumber:self.tachDuration];
            
            break;
        case EDIT_TACH_END:
            self.tachEndLabel.text = [self.numberFormatter stringFromNumber:[[NSNumber alloc] initWithFloat:fValue]];
            self.tachEnd= [[NSNumber alloc] initWithFloat:[self.tachEndLabel.text floatValue]];
            
            //recalc tach duration
            self.tachDuration = [[NSNumber alloc] initWithFloat:[self.tachEnd floatValue] - [self.tachStart floatValue]];
            self.tachDurationLabel.text = [self.numberFormatter stringFromNumber:self.tachDuration];
            
            
            break;
        case EDIT_TACH_DURATION:
            self.tachDurationLabel.text = [self.numberFormatter stringFromNumber:[[NSNumber alloc] initWithFloat:fValue]];
            self.tachDuration= [[NSNumber alloc] initWithFloat:[self.tachDurationLabel.text floatValue]];
            
            //recalc tach end
            self.tachEnd = [[NSNumber alloc] initWithFloat:[self.tachDuration floatValue] + [self.tachStart floatValue]];
            self.tachEndLabel.text = [self.numberFormatter stringFromNumber:self.tachEnd];
            
            break;
    }
}

- (IBAction)onDone:(id)sender {    
    [self.delegate MeterDataEnteredForHobbsStart:self.hobbsStart
                                        HobbsEnd:self.hobbsEnd
                                        HobbsDuration:self.hobbsDuration
                                        TachStart:self.tachStart
                                        TachEnd:self.tachEnd
                                        TachDuration:self.tachDuration
                                        BrokenTach:_brokenTach
                                        BrokenHobbs:_brokenHobbs];
}

#pragma mark - Table view delegate

- (void) disableCell:(UITableViewCell*)cell {
    cell.textLabel.alpha = 0.439216f; // (1 - alpha) * 255 = 143
    cell.userInteractionEnabled = NO;
}
- (void) enableCell:(UITableViewCell*)cell {
    cell.textLabel.alpha = 1; // (1 - alpha) * 255 = 143
    cell.userInteractionEnabled = YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(_readOnly)
    {
        if (indexPath.section == 2 || indexPath.section == 6)
            return indexPath;
        else
            return nil;
    }
    else
        return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSUInteger selectedIndex = [indexPath indexAtPosition:[indexPath length] - 1];
    NSInteger section = [indexPath section];
    
    if(section ==0) {
        switch(selectedIndex) {
            case 0: [self updateMeterState:EDIT_HOBBS_START];
                break;
            case 1: [self updateMeterState:EDIT_HOBBS_END];
                break;
            case 2: [self updateMeterState:EDIT_HOBBS_DURATION]; break;
        }
    } else {
        switch(selectedIndex) {
            case 0: [self updateMeterState:EDIT_TACH_START];
                break;
            case 1: [self updateMeterState:EDIT_TACH_END];
                break;
            case 2: [self updateMeterState:EDIT_TACH_DURATION]; break;
        }
    }
    
    if(selectedIndex == 1) {
        NSIndexPath *t_indexPath = [NSIndexPath indexPathForRow:2 inSection:indexPath.section];
        UITableViewCell *t_cell = [tableView cellForRowAtIndexPath:t_indexPath];
        [self disableCell:t_cell];
    }
    else if(selectedIndex == 2) {
        NSIndexPath *t_indexPath = [NSIndexPath indexPathForRow:1 inSection:indexPath.section];
        UITableViewCell *t_cell = [tableView cellForRowAtIndexPath:t_indexPath];
        [self disableCell:t_cell];
    }
    
    [self enableCell:cell];
}

-(void) manageSwitchChangeForSwitch:(UISwitch*)switchControl forSection:(int)section {
    if(switchControl.on) {
        //meter control was turned back on.  Disable the duration table cell.
        NSIndexPath *t_indexPath = [NSIndexPath indexPathForRow:2 inSection:section];
        UITableViewCell *t_cell = [self.tableView cellForRowAtIndexPath:t_indexPath];
        [self disableCell:t_cell];
        [self.tableView deselectRowAtIndexPath:t_indexPath animated:NO];
        
        //enable the hobbs or duration end cell
        t_indexPath = [NSIndexPath indexPathForRow:1 inSection:section];
        t_cell = [self.tableView cellForRowAtIndexPath:t_indexPath];
        [self enableCell:t_cell];
        
        //load the hobbs or tach end numbers
        if(section ==0)
        {
            _brokenHobbs = NO;
            [self setupWholeNumbers:[self.hobbsEnd intValue]];
        }
        else
        {
            _brokenTach = NO;
            [self setupWholeNumbers:[self.tachEnd intValue]];
        }
        
        //select the hobbs or tach end cell
        [self.tableView selectRowAtIndexPath:t_indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        //tell the tableview we selected the hobbs or tach end column.
        [self tableView:self.tableView didSelectRowAtIndexPath:t_indexPath];
        
    } else {
        //switch is off
        NSIndexPath *t_indexPath = [NSIndexPath indexPathForRow:2 inSection:section];
        UITableViewCell *t_cell = [self.tableView cellForRowAtIndexPath:t_indexPath];
        [self enableCell:t_cell]; //enable the duration paramater
        [self.tableView selectRowAtIndexPath:t_indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
        //setup the array of numbers (depends on if this is hobbs or tach)
        if(section == 0)
        {
            _brokenHobbs = YES;
            [self setupWholeNumbers:[self.hobbsDuration intValue]];
        }
        else
        {
            _brokenTach = YES;
            [self setupWholeNumbers:[self.tachDuration intValue]];
        }
        //tell the tableview we selected the column
        [self tableView:self.tableView didSelectRowAtIndexPath:t_indexPath];
        
        //deselect and disable the hobbs start paramater.
        t_indexPath = [NSIndexPath indexPathForRow:1 inSection:section];
        t_cell = [self.tableView cellForRowAtIndexPath:t_indexPath];
        [self.tableView deselectRowAtIndexPath:t_indexPath animated:NO];
        [self disableCell:t_cell];
    }
}

- (void) hobbsSwitchChanged:(id)sender {
    [self manageSwitchChangeForSwitch:(UISwitch*)sender forSection:0];
}

- (void) tachSwitchChanged:(id)sender {
    [self manageSwitchChangeForSwitch:(UISwitch*)sender forSection:1];
}

@end
