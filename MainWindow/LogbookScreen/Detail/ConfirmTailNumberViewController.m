//
//  ConfirmTailNumberViewController.m
//  flightlog
//
//  Created by Chris Frederick on 9/29/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import "ConfirmTailNumberViewController.h"
#import "MasterViewController.h"

@interface ConfirmTailNumberViewController ()

@end

@implementation ConfirmTailNumberViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tailNumber.text = self.airplaneTail;
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *jpgFilePath = [NSString stringWithFormat:@"%@/%@.jpg",docDir,self.airplaneTail];
    UIImage *aircraftImage = [UIImage imageWithContentsOfFile:jpgFilePath];
    
    _aircraftImage.image = aircraftImage;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onCancel:(id)sender {
    [self.delegate confirmTailNumberViewController:self didConfirm:NO];
}

- (IBAction)onConfirm:(id)sender {
    [self.delegate confirmTailNumberViewController:self didConfirm:YES];
}

@end
