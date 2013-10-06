//
//  MultipeerConnectivityViewController.h
//  iOS7Sampler
//
//  Created by Andrew Frederick and adapted by Neel Mouleeswaran on 8/05/13.
//  Copyright (c) 2013 Nikhil Srinivasan and Neel Mouleeswaran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultipeerConnectivityViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>  {
    BOOL isPaying;
    NSMutableArray *cells;
    BOOL stillWaiting;
    int submissions_recieved;
    BOOL isTip;
    NSString *name;
    NSString *access_token;
    NSMutableDictionary *payments;
    int num_peers;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *waiting_label;
@property (weak, nonatomic) IBOutlet UIButton *pay_bill_button;
@property (weak, nonatomic) IBOutlet UIButton *pay_later_button;

@end