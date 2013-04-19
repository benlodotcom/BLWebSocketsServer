//
//  ViewController.m
//  BLWebSocketsServer
//
//  Created by Benjamin Loulier on 1/22/13.
//  Copyright (c) 2013 Benjamin Loulier. All rights reserved.
//

#import "ViewController.h"
#import "BLWebSocketsServer.h"

static int port = 9000;
static NSString *echoProtocol = @"echo-protocol";

@interface ViewController ()

@property (nonatomic, strong) BLWebSocketsServer *server;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	/*Create a simple echo server*/
    [[BLWebSocketsServer sharedInstance] setHandleRequestBlock:^NSData *(NSData *data) {
        return data;
    }];
    
    /*Load the test html file in the webview*/
    NSURL *indexURL = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html" subdirectory:@"www"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:indexURL]];
}


- (IBAction)toggleServer:(UIBarButtonItem *)sender {
    sender.enabled = NO;
    if ([BLWebSocketsServer sharedInstance].isRunning) {
        [[BLWebSocketsServer sharedInstance] stopWithCompletionBlock:^ {
            NSLog(@"Server stopped");
            sender.title = @"Start server";
            sender.enabled = YES;
        }];
    }
    else {
        [[BLWebSocketsServer sharedInstance] startListeningOnPort:port withProtocolName:echoProtocol andCompletionBlock:^(NSError *error) {
            NSLog(@"Server started");
            sender.title = @"Stop server";
            sender.enabled = YES;
        }];
    }
    [self.webView reload];
}
@end
