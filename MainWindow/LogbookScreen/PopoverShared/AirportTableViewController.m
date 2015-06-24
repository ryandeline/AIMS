//
//  AirportTableViewController.m
//  flightlog
//
//  Created by Chris Frederick on 10/29/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import "AirportTableViewController.h"

@interface AirportTableViewController ()

@end

@implementation AirportTableViewController

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

    _searchBar.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark search bar
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterContentForSearchText:searchText];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self filterContentForSearchText:searchBar.text];
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _fetchedResultsController.fetchRequest.predicate = nil;
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    [self.tableView reloadData];
}

// The method to change the predicate of the FRC
- (void)filterContentForSearchText:(NSString*)searchText
{
    NSError *error;
    if (searchText.length > 0) {
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"icao beginswith [cd] %@ or iata contains [cd] %@ or airportLocation contains [cd] %@ or airportName contains [cd] %@",searchText, searchText,searchText,searchText];
        _fetchedResultsController.fetchRequest.predicate = newPredicate;
        [self.fetchedResultsController performFetch:&error];
    } else {
        _fetchedResultsController.fetchRequest.predicate = nil;
        [self.fetchedResultsController performFetch:&error];
    }
    
    NSLog(@"Airport count %d", [self.fetchedResultsController.fetchedObjects count]);
    
    [self.tableView reloadData];
}

#pragma mark table view controller
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Airport *airport = [_fetchedResultsController objectAtIndexPath:indexPath];
    [self.delegate airportSelected:airport];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Airport" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"icao" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // set cacheName to nil and don't set a delegate to disable change tracking and allow us to use the NSDictionaryResultType
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Airport *airport = (Airport*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    if([airport.iata length] ==3)
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", airport.icao, airport.iata];
    else
        cell.textLabel.text = [NSString stringWithFormat:@"%@", airport.icao];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", airport.airportName];
}

@end
