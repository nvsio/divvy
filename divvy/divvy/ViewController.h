//
//  ViewController.h
//  Venmo-Bill-Split
//
//  Created by Neel Mouleeswaran on 10/5/13.
//  Copyright (c) 2013 TestiOS7. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    MCPeerID *peerId;
    NSMutableArray *peers;

}
@property (weak, nonatomic) IBOutlet UITableView *list_of_peers;
@property (weak, nonatomic) IBOutlet UILabel *display_name_label;
- (IBAction)search_button:(id)sender;

- (IBAction)advert_button:(id)sender;


@end
