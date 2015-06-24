//
//  NewFlightControllerViewController.m
//  flightlog
//
//  Created by Chris Frederick on 10/4/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import "NewFlightControllerViewController.h"
#import "SyncEngine.h"

@interface NewFlightControllerViewController ()

@end

@implementation NewFlightControllerViewController

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

    self.hobbsStaticLabel.text = @"Hobbs End\nHobbs Duration\nTach Duration\n";
    self.projectStaticLabel.text = @"Project\nLocation\nArea";
}

-(void)setupForLogEntry:(LogEntry*) logEntry
{
    self.logEntry = logEntry;
    [self refreshFieldLabels];
}

// Date was selected
- (void)dateSelected:(NSDate *)date {
    
    self.logEntry.logDate = date;
    [self refreshFieldLabels];
    [self.navigationController popViewControllerAnimated:YES];
}

//we know the hobbs selected (and other meter stuff)
-(void)MeterDataEnteredForHobbsStart:(NSNumber*)hobbsStart
                          HobbsEnd:(NSNumber*)hobbsEnd
                          HobbsDuration:(NSNumber*)hobbsDuration
                          TachStart:(NSNumber*)tachStart
                          TachEnd:(NSNumber*)tachEnd
                          TachDuration:(NSNumber*)tachDuration
                          BrokenTach:(BOOL)brokenTach
                          BrokenHobbs:(BOOL)brokenHobbs
{
    
    if([self.title isEqualToString:@"View Flight"])
        return;

    _logEntry.hobbsStart = hobbsStart;
    _logEntry.hobbsEnd = hobbsEnd;
    _logEntry.hobbsDuration = hobbsDuration;
    _logEntry.tachDuration = tachDuration;
    _logEntry.tachEnd = tachEnd;
    _logEntry.tachStart = tachStart;
    
    Aircraft *a = [SyncEngine findAircraftForTailNumber:_logEntry.tailNumber inManagedObjectContext:_managedObjectContext];
    a.brokenHobbs = brokenHobbs;
    a.brokenTach = brokenTach;
    
    
    [self refreshFieldLabels];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)projectDataSelectedFor:(Project*)project {
    [_logEntry setProject:project];
    [self refreshFieldLabels];
    
    //Get the view controller that is 3 step behind
    UIViewController *controller = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 4];
    
    //Go to that controller
    [self.navigationController popToViewController:controller animated:YES];
}

-(void)SensorSelected:(Sensor *)sensor {
    _logEntry.sensor = sensor;
    [self refreshFieldLabels];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)CrewSelected:(Crew *)crew   {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    switch(path.row) {
        case 0:
            _logEntry.pilot = crew;
            break;
        case 1:
            _logEntry.pilot2 = crew;
            break;
        case 2:
            _logEntry.pilot3 = crew;
            break;
        case 3:
            _logEntry.pilot4 = crew;
            break;
    }
    [self refreshFieldLabels];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)airportSelected:(Airport *)airport {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    switch(path.row) {
        case 0:
            _logEntry.fromICAO = airport.icao;
            break;
        case 1:
            _logEntry.toICAO = airport.icao;
            break;
    }
    [self refreshFieldLabels];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)commentEdited:(NSString *)comment {
    _logEntry.comment = comment;
    [self.navigationController popViewControllerAnimated:YES];
    [self refreshFieldLabels];
}

-(void)refreshFieldLabels {
    //enable done button?
    BOOL bDoneBtnEnabled = YES;
    
    //Refresh Date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    self.dateLabel.text = [formatter stringFromDate:_logEntry.logDate];
    
    //refresh Project
    if(_logEntry.project)
    {
        self.projectLabel.text = [[NSString alloc] initWithFormat:@"%@\n%@\n%@", _logEntry.project.projectName, _logEntry.project.locationName, _logEntry.project.areaName];
    }
    else
    {
        bDoneBtnEnabled = NO;
        self.projectLabel.text = @"None\nNone\nNone";
    }
    
    //Refresh Hobbs
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setMaximumFractionDigits:1];
    self.hobbsLabel.text = [[NSString alloc] initWithFormat:@"%@\n%@\n%@",[numberFormatter stringFromNumber:_logEntry.hobbsEnd], [numberFormatter stringFromNumber:_logEntry.hobbsDuration],[numberFormatter stringFromNumber:_logEntry.tachDuration]];
    
    //Refresh Crew
    if(_logEntry.pilot) {
        _crewLabel.text = _logEntry.pilot.crewName;
        if([_crewLabel.text isEqualToString:@"None"])
            bDoneBtnEnabled = NO;
    }
    else
    {
        bDoneBtnEnabled = NO;
    }
    
    if(_logEntry.pilot2)
        _crew2Label.text = _logEntry.pilot2.crewName;
    if(_logEntry.pilot3)
        _Crew3Label.text = _logEntry.pilot3.crewName;
    if(_logEntry.pilot4)
        _crew4Label.text = _logEntry.pilot4.crewName;

    //Refresh Airports
    if(_logEntry.fromICAO)
        _routeStartLabel.text = _logEntry.fromICAO;
    else
        bDoneBtnEnabled = NO;
    
    if(_logEntry.toICAO)
        _routeEndLabel.text = _logEntry.toICAO;
    else
        bDoneBtnEnabled = NO;
    
    //Refresh Sensor
    if(_logEntry.sensor)
        self.sensorLabel.text = [[NSString alloc] initWithString:_logEntry.sensor.sensorName];
    else
        bDoneBtnEnabled = NO;
    
    //Refresh Comment
    self.commentLabel.text = _logEntry.comment;
    
    _doneBtn.enabled = bDoneBtnEnabled;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
    
    CGSize size;
    size.width = 320;
    size.height = 740-37;
    [self setContentSizeForViewInPopover:size];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Value: %@", segue.identifier);
    if([segue.identifier isEqualToString:@"DateSegue"]) {
        DatePickerViewController  *dateController = [segue destinationViewController];
        dateController.delegate = self;
        CGSize size;
        size.width = 320;
        size.height = 740-37;
        [dateController setContentSizeForViewInPopover:size];
    }
    if([segue.identifier isEqualToString:@"MeterSegue"]) {
        //find the most recent logbook entry and default the hobbs end and tach end
        HobbsTableViewController *hobbsController = [segue destinationViewController];
        CGSize size;
        size.width = 320;
        size.height = 740-37;
        [hobbsController setContentSizeForViewInPopover:size];
        
        //lookup the aircraft object so we can determine if the hobbs or tach indicators are broken
        Aircraft *aircraft = [SyncEngine findAircraftForTailNumber:_logEntry.tailNumber inManagedObjectContext:_managedObjectContext];
        
        if(aircraft.brokenTach == YES) {
            hobbsController.brokenTach = YES;
        } else {
            hobbsController.brokenTach = NO;
        }
        
        if(aircraft.brokenHobbs == YES) {
            hobbsController.brokenHobbs = YES;
        } else {
            hobbsController.brokenHobbs = NO;
        }
        
        hobbsController.delegate = self;
        hobbsController.hobbsStart = _logEntry.hobbsStart;
        hobbsController.hobbsEnd = _logEntry.hobbsEnd;
        hobbsController.hobbsDuration = _logEntry.hobbsDuration;
        hobbsController.tachStart = _logEntry.tachStart;
        hobbsController.tachEnd = _logEntry.tachEnd;
        hobbsController.tachDuration = _logEntry.tachDuration;
        hobbsController.readOnly = _readOnly;
    }
    
    if([segue.identifier isEqualToString:@"projectName"]) {
        ProjectTableViewController *controller = [segue destinationViewController];
        CGSize size;
        size.width = 320;
        size.height = 740-37;
        [controller setContentSizeForViewInPopover:size];
        
        controller.managedObjectContext = self.managedObjectContext;
        controller.className = @"Project";
        controller.fieldName = segue.identifier;
        controller.delegate = self;
    }
    
    if([segue.identifier isEqualToString:@"SensorSegue"]) {
        SensorTableViewController *controller = (SensorTableViewController*)[segue destinationViewController];
        [controller setManagedObjectContext:_managedObjectContext];
        controller.delegate = self;
        CGSize size;
        size.width = 320;
        size.height = 740-37;
        [controller setContentSizeForViewInPopover:size];
    }
    
    NSRange range = [segue.identifier rangeOfString:@"CrewSegue"];
    if(range.location != NSNotFound) {
        CrewTableViewController *controller = (CrewTableViewController*)[segue destinationViewController];
        [controller setManagedObjectContext:_managedObjectContext];
        controller.delegate = self;
        CGSize size;
        size.width = 320;
        size.height = 740-37;
        [controller setContentSizeForViewInPopover:size];
    }
    
    if([segue.identifier isEqualToString:@"RouteStartSegue"]) {
        AirportTableViewController *controller = (AirportTableViewController*)[segue destinationViewController];
        [controller setManagedObjectContext:_managedObjectContext];
        controller.delegate = self;
        UINavigationItem *item = [controller navigationItem];
        [item setTitle:@"Route Start"];
        CGSize size;
        size.width = 320;
        size.height = 740-37;
        [controller setContentSizeForViewInPopover:size];
    }
    
    if([segue.identifier isEqualToString:@"RouteEndSegue"]) {
        AirportTableViewController *controller = (AirportTableViewController*)[segue destinationViewController];
        [controller setManagedObjectContext:_managedObjectContext];
        controller.delegate = self;
        UINavigationItem *item = [controller navigationItem];
        [item setTitle:@"Route End"];
        CGSize size;
        size.width = 320;
        size.height = 740-37;
        [controller setContentSizeForViewInPopover:size];
    }
    
    
    if([segue.identifier isEqualToString:@"CommentSegue"]) {
        CommentsViewController *controller = (CommentsViewController*)[segue destinationViewController];
        controller.delegate = self;
        CGSize size;
        size.width = 320;
        size.height = 740-37;
        controller.initialComment = _logEntry.comment;
        controller.readOnly = _readOnly;
        [controller setContentSizeForViewInPopover:size];
    }
    
}

- (IBAction)onDone:(id)sender {
    [self.delegate newLogbookEntry:_logEntry];
}

#pragma mark - Table view delegate

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

@end
