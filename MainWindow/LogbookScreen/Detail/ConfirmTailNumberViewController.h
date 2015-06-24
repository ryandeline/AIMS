//
//  ConfirmTailNumberViewController.h
//  flightlog
//
//  Created by Chris Frederick on 9/29/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ConfirmTailNumberViewController;

@protocol ConfirmTailNumberDelegate <NSObject>

// recipe == nil on cancel
- (void)confirmTailNumberViewController:(ConfirmTailNumberViewController *)confirmTailNumberController
                   didConfirm:(BOOL)confirmed;
@end

@interface ConfirmTailNumberViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *aircraftImage;

@property (weak, nonatomic) IBOutlet UILabel *tailNumber;
@property (nonatomic, weak) id<ConfirmTailNumberDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property NSString *airplaneTail;
@end
