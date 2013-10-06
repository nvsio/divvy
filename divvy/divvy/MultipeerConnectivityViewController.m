//
//  MultipeerConnectivityViewController.m
//  divvy
//
//  Created by Andrew Frederick and adapted by Neel Mouleeswaran on 8/05/13.
//  Copyright (c) 2013 Nikhil Srinivasan. All rights reserved.
//

#import "MultipeerConnectivityViewController.h"

#import <MultipeerConnectivity/MultipeerConnectivity.h>

// Service name must be < 16 characters
static NSString * const kServiceName = @"multipeer";
static NSString * const kMessageKey = @"message";

@interface MultipeerConnectivityViewController () <MCBrowserViewControllerDelegate,
                                                   MCSessionDelegate>

// Required for both Browser and Advertiser roles
@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;

// Browser using provided Apple UI
@property (nonatomic, strong) MCBrowserViewController *browserView;

// Advertiser assistant for declaring intent to receive invitations
@property (nonatomic, strong) MCAdvertiserAssistant *advertiserAssistant;

@property (weak, nonatomic) IBOutlet UIButton *launchBrowserButton;
@property (weak, nonatomic) IBOutlet UIButton *launchAdvertiserButton;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendMessageButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

- (IBAction)launchBrowserPressed:(id)sender;
- (IBAction)launchAdvertiser:(id)sender;
- (IBAction)sendMessageButtonPressed:(id)sender;

@end

@implementation MultipeerConnectivityViewController
@synthesize tableView;
@synthesize waiting_label;
@synthesize pay_bill_button;
@synthesize pay_later_button;

- (void)viewDidLoad {
    [super viewDidLoad];
    submissions_recieved = 0;
    cells = [[NSMutableArray alloc]init];
    isPaying = false;
    stillWaiting = false;
    _messageTextField.hidden = YES;
    _sendMessageButton.hidden = YES;
    _activityView.hidden = YES;
    [tableView setHidden:YES];
    [waiting_label setHidden:YES];
    
    
    
    
}

- (IBAction)launchBrowserPressed:(id)sender {
    [pay_bill_button setHidden:YES];
    [pay_later_button setHidden:YES];
    isPaying = TRUE;
    _peerID = [[MCPeerID alloc] initWithDisplayName:@"Browser Name"];
    _session = [[MCSession alloc] initWithPeer:_peerID];
    _session.delegate = self;
    _browserView = [[MCBrowserViewController alloc] initWithServiceType:kServiceName
                                                                session:_session];
    _browserView.delegate = self;
    [self presentViewController:_browserView animated:YES completion:nil];
    
    _launchAdvertiserButton.hidden = YES;
    _launchBrowserButton.hidden = YES;
    _messageTextField.hidden = YES;
    _sendMessageButton.hidden = YES;
}

- (IBAction)launchAdvertiser:(id)sender {
    [pay_bill_button setHidden:YES];
    [pay_later_button setHidden:YES];
    _peerID = [[MCPeerID alloc] initWithDisplayName:@"Advertiser Name"];
    _session = [[MCSession alloc] initWithPeer:_peerID];
    _session.delegate = self;
    _advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:kServiceName
                                                                discoveryInfo:nil
                                                                      session:_session];
    [_advertiserAssistant start];
    
    _launchAdvertiserButton.hidden = YES;
    _launchBrowserButton.hidden = YES;
    _activityView.hidden = NO;
    [tableView setHidden:YES];
}

- (IBAction)sendMessageButtonPressed:(id)sender {
    
    
    
    NSString *message = _messageTextField.text;
    NSDictionary *dataDict = @{ kMessageKey : message };
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:dataDict
                                                              format:NSPropertyListBinaryFormat_v1_0
                                                             options:0
                                                               error:NULL];
    NSError *error;
    [self.session sendData:data
                   toPeers:[_session connectedPeers]
                  withMode:MCSessionSendDataReliable
                     error:&error];
    
    UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Sent payment" message:@"Wait while tip is calculated..." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [messageAlert show];
    
    [[self view]endEditing:YES];
    _messageTextField.hidden = YES;
    _sendMessageButton.hidden = YES;
    
    _activityView.hidden=NO;
    _activityView.startAnimating;
    
    
}

#pragma mark - MCBrowserViewControllerDelegate

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    
    _messageTextField.hidden = YES;
    _sendMessageButton.hidden = YES;
    
    [waiting_label setHidden:FALSE];
    [tableView setHidden:FALSE];
    
    _activityView.hidden=NO;
    _activityView.startAnimating;
    
    [self dismissViewControllerAnimated:YES completion:^{
        [_browserView.browser stopBrowsingForPeers];
    }];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [self dismissViewControllerAnimated:YES completion:^{
        [_browserView.browser stopBrowsingForPeers];
        _launchAdvertiserButton.hidden = NO;
        _launchBrowserButton.hidden = NO;
    }];
}

#pragma mark - MCSessionDelegate

// MCSessionDelegate methods are called on a background queue, if you are going to update UI
// elements you must perform the actions on the main queue.

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    switch (state) {
        case MCSessionStateConnected: {
            dispatch_async(dispatch_get_main_queue(), ^{
                _messageTextField.hidden = NO;
                _sendMessageButton.hidden = NO;
                _activityView.hidden = YES;
            });
            
            // This line only necessary for the advertiser. We want to stop advertising our services
            // to other browsers when we successfully connect to one.
            [_advertiserAssistant stop];
            break;
        }
        case MCSessionStateNotConnected: {
            dispatch_async(dispatch_get_main_queue(), ^{
                _launchAdvertiserButton.hidden = NO;
                _launchBrowserButton.hidden = NO;
                _messageTextField.hidden = YES;
                _sendMessageButton.hidden = YES;
            });
            break;
        }
        default:
            break;
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    
    NSLog(@"submissions received = %d\nconnected peers = %lu", submissions_recieved, (unsigned long)[[_session connectedPeers]count]);
    
    if(isPaying) {
        submissions_recieved++;
        
        if(submissions_recieved >= [[_session connectedPeers]count]) {
            // all submissions received
            UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"All payments received" message:@"Enter individual tip..." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [messageAlert show];
            
            
            
            [tableView setHidden:YES];
            [waiting_label setHidden:YES];
            _messageTextField.hidden=FALSE;
            _sendMessageButton.hidden=FALSE;
            
            
            
        }
        
    }
    
    NSPropertyListFormat format;
    NSDictionary *receivedData = [NSPropertyListSerialization propertyListWithData:data
                                                                           options:0
                                                                            format:&format
                                                                             error:NULL];
    NSString *message = receivedData[kMessageKey];
    if ([message length]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(isPaying) {
                
                UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
                [[cell detailTextLabel]setText:@"Paid"];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [[cell textLabel]setText:[peerID displayName]];
                
                [cells addObject:cell];
                
                [[self tableView]reloadData];
                
                /*
            UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:[@"Received payment from " stringByAppendingString:[peerID displayName]]     message:message
                                delegate:self
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil];
            [messageAlert show];
                 */
                
            }
        });
    }
}

// Required MCSessionDelegate protocol methods but are unused in this application.

- (void)                      session:(MCSession *)session
    didStartReceivingResourceWithName:(NSString *)resourceName
                             fromPeer:(MCPeerID *)peerID
                         withProgress:(NSProgress *)progress {
    
}

- (void)     session:(MCSession *)session
    didReceiveStream:(NSInputStream *)stream
            withName:(NSString *)streamName
            fromPeer:(MCPeerID *)peerID {
    
}

- (void)                       session:(MCSession *)session
    didFinishReceivingResourceWithName:(NSString *)resourceName
                              fromPeer:(MCPeerID *)peerID
                                 atURL:(NSURL *)localURL
                             withError:(NSError *)error {
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    return [[_session connectedPeers] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    if([cells count] == 0) {
        return [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    else {
        return [cells objectAtIndex:[indexPath row]];
    }
}

@end
