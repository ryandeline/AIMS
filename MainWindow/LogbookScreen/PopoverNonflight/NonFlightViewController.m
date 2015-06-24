//
//  NonFlightViewController.m
//  flightlog
//
//  Created by Chris Frederick on 11/26/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import "NonFlightViewController.h"

@interface NonFlightViewController ()

@end

@implementation NonFlightViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
    
    CGSize size;
    size.width = 320;
    size.height = 450-37;
    [self setContentSizeForViewInPopover:size];
}

-(void) commentEdited:(NSString *)comment {
    _comment = comment;
    _commentLabel.text = _comment;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) dateSelected:(NSDate *)date {
    _date = date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    self.dateLabel.text = [formatter stringFromDate:_date];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDone:(id)sender {
    [self.delegate newNonFlightEntryForDate:_date withReason:_reason andComment:_comment];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Value: %@", segue.identifier);
    if([segue.identifier isEqualToString:@"NonFlightDateSegue"]) {
        DatePickerViewController  *dateController = [segue destinationViewController];
        dateController.delegate = self;
        CGSize size;
        size.width = 320;
        size.height = 450-37;
        [dateController setContentSizeForViewInPopover:size];
    } else if([segue.identifier isEqualToString:@"NonFlightCommentSegue"]) {
        CommentsViewController *controller = (CommentsViewController*)[segue destinationViewController];
        controller.delegate = self;
        controller.readOnly = _readOnly;
        CGSize size;
        size.width = 320;
        size.height = 450-37;
        controller.initialComment = _comment;
        [controller setContentSizeForViewInPopover:size];
    }
}

-(void)toggleCheckmarkedCell:(UITableViewCell *)cell
{
    if (cell.accessoryType == UITableViewCellAccessoryNone)
    	cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
    	cell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section ==1) {
        if(_oldIndexPath.row != indexPath.row || _oldIndexPath == nil) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            _reason = cell.textLabel.text;
            UITableViewCell *cell2 = [tableView cellForRowAtIndexPath:_oldIndexPath];
            // Toggle cells
            [self toggleCheckmarkedCell:cell];
            [self toggleCheckmarkedCell:cell2];
            _oldIndexPath = indexPath;
            _doneBtn.enabled = YES;
        }
    }
}

@end
