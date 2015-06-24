//
//  NewNoteViewController.m
//  flightlog
//
//  Created by Chris Frederick on 11/27/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import "NewNoteViewController.h"

@interface NewNoteViewController ()

@end

@implementation NewNoteViewController

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
    _doneBtn.enabled = NO;
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
    if([_comment length] > 0)
        _doneBtn.enabled = true;
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
      [self.delegate newNoteForDate:_date  withComment:_comment];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Value: %@", segue.identifier);
    if([segue.identifier isEqualToString:@"CommentDateSegue"]) {
        DatePickerViewController  *dateController = [segue destinationViewController];
        dateController.delegate = self;
        CGSize size;
        size.width = 320;
        size.height = 450-37;
        [dateController setContentSizeForViewInPopover:size];
    } else if([segue.identifier isEqualToString:@"NoteCommentSegue"]) {
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(_readOnly)
    {
        if (indexPath.section == 1)
            return indexPath;
        else
            return nil;
    }
    else
        return indexPath;
}

@end
