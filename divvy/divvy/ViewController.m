//
//  ViewController.m
//  divvy
//
//  Created by Neel Mouleeswaran on 10/5/13.
//  Copyright (c) 2013 divvy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize list_of_peers;
@synthesize display_name_label;

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    peers = [[NSMutableArray alloc]init];
    
    peerId = [[MCPeerID alloc]initWithDisplayName:@"test display name"];
    
    [display_name_label setText:[peerId displayName]];
    
    [peers addObject:@"person1"];
    
    
    
	// Do any additional setup after loading the view, typically from a nib.
    
}

-(void)beginSearch {
   
    
  
    
    NSDate *start = [NSDate date];
    // do stuff...
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    
    
    while(timeInterval < 100000) {
        
        NSInteger time = timeInterval;
        
        if(time % 5000 == 0) {
           
        }
        
        timeInterval = [start timeIntervalSinceNow];
    }
    
    

}

-(void)beginAdvertising {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    [cell setSelected:NO animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"peer_cell"];
        
    if(!([indexPath row] > [peers count] - 1)) {
        [[cell textLabel]setText:[peers objectAtIndex:[indexPath row]]];
    }
    else {
        [[cell textLabel]setText:@"---"];
    }
    
    
        return cell;
}



- (IBAction)search_button:(id)sender {
    [self beginSearch];
}

- (IBAction)advert_button:(id)sender {
    
}
@end
