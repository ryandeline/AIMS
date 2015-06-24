//
//  CommentsViewController.m
//  flightlog
//
//  Created by Chris Frederick on 10/29/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import "CommentsViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CommentsViewController ()

@end

@implementation CommentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, 280, 300)];
    _textView.layer.cornerRadius = 5.0;
    _textView.clipsToBounds = YES;
    
    self.textView.textColor = [UIColor blackColor];
    self.textView.font = [UIFont fontWithName:@"Arial" size:18.0];
    self.view.backgroundColor = [UIColor underPageBackgroundColor];
    [_textView.layer setBorderColor:[[[UIColor darkGrayColor] colorWithAlphaComponent:0.5] CGColor]];
    [_textView.layer setBorderWidth:2.0];
    [self.view addSubview: _textView];
    _textView.text = _initialComment;
    if(_readOnly)
    {
        _onDone.enabled = false;
        _textView.editable = false;
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDone:(id)sender {
    [self.delegate commentEdited:_textView.text];
}

@end
