//
//  CommentsViewController.h
//  flightlog
//
//  Created by Chris Frederick on 10/29/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommentEditedDelegate <NSObject>
- (void)commentEdited:(NSString *)comment;
@end

@interface CommentsViewController : UIViewController

@property UITextView *textView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *onDone;
@property id<CommentEditedDelegate> delegate;
@property NSString *initialComment;
@property BOOL readOnly;
@end
