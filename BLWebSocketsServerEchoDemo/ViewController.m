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
    if ([BLWebSocketsServer sharedInstance].isRunning) {
        [[BLWebSocketsServer sharedInstance] stop];
        sender.title = @"Start server";
    }
    else {
        [[BLWebSocketsServer sharedInstance] startListeningOnPort:port withProtocolName:echoProtocol];
        sender.title = @"Stop server";
    }
    [self.webView reload];
}
@end
