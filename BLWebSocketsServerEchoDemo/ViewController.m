//
//  ViewController.m
//  BLWebSocketsServer
//
//  Created by Benjamin Loulier on 1/22/13.
//  Copyright (c) 2013 Benjamin Loulier. All rights reserved.
//

#import "ViewController.h"
#import "BLWebSocketsServer.h"

static NSString *echoProtocol = @"echo-protocol";

@interface ViewController ()

@property (nonatomic, strong) BLWebSocketsServer *server;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	/*Create a simple echo server*/
    self.server = [[BLWebSocketsServer alloc] initWithPort:9000 andProtocolName:echoProtocol];
    [self.server setHandleRequestBlock:^NSData *(NSData *data) {
        return data;
    }];
    
    /*Load the test html file in the webview*/
    //NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"www"];
    NSURL *indexURL = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html" subdirectory:@"www"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:indexURL]];
}


- (IBAction)toggleServer:(UIBarButtonItem *)sender {
    if (self.server.isRunning) {
        [self.server stop];
        sender.title = @"Start server";
    }
    else {
        [self.server start];
        sender.title = @"Stop server";
    }
    [self.webView reload];
}
@end
