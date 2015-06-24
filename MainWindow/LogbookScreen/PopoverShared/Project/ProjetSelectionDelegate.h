//
//  ProjetSelectionDelegate.h
//  flightlog
//
//  Created by Chris Frederick on 10/23/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Project.h"

@protocol ProjetSelectionDelegate <NSObject>

- (void)projectDataSelectedFor:(Project *)project;

@end
