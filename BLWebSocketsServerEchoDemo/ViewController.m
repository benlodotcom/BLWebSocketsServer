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
static NSTimeInterval pushInterval = 0.5;
static NSString *echoProtocol = @"echo-protocol";
static NSString *starwarsFilename = @"starwars";
static NSString *starwarsFiletype = @"txt";

@interface ViewController ()

@property (nonatomic, strong) BLWebSocketsServer *server;

/* Push */
@property (nonatomic, strong) NSTimer *pushTimer;
@property (nonatomic, strong) NSArray *starwars;
@property (nonatomic, assign) int currentLineIndex;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*Load the test html file in the webview*/
    NSURL *indexURL = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html" subdirectory:@"www"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:indexURL]];
    
    /* Setup the server */
    [self setupEchoServer];
    
    /* Zwooo, Zhwooo (lightsaber noise), prepare the data to be pushed later */
    NSString *starwarsString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:starwarsFilename ofType:starwarsFiletype] encoding:NSUTF8StringEncoding error:nil];
    self.starwars = [starwarsString componentsSeparatedByString:@"\n"];
}

#pragma mark - WebSockets server management

/* Pass a block to the server that will handle requests from the client, in our case we just send
 back the data sent by the client */
- (void)setupEchoServer {
    [[BLWebSocketsServer sharedInstance] setHandleRequestBlock:^NSData *(NSData *requestData) {
        return requestData;
    }];
}

/* Start/Stop the server */
- (IBAction)toggleServer:(UIBarButtonItem *)sender {
    sender.enabled = NO;
    /* If the server is running */
    if ([BLWebSocketsServer sharedInstance].isRunning) {
        /* The server is stopped */
        [self stopPushing];
        [[BLWebSocketsServer sharedInstance] stopWithCompletionBlock:^ {
            NSLog(@"Server stopped");
            sender.title = @"Start server";
            sender.enabled = YES;
        }];
    }
    /* If it is not running */
    else {
        /* The server is started */
        [[BLWebSocketsServer sharedInstance] startListeningOnPort:port withProtocolName:echoProtocol andCompletionBlock:^(NSError *error) {
            NSLog(@"Server started");
            sender.title = @"Stop server";
            sender.enabled = YES;
            [self startPushing];
        }];
    }
    [self.webView reload];
}

#pragma mark - Push methods
/* Regularly push to all the clients a JSON object containing a line of text */
- (void)startPushing {
    self.currentLineIndex = 0;
    self.pushTimer = [NSTimer scheduledTimerWithTimeInterval:pushInterval target:self selector:@selector(push) userInfo:nil repeats:YES];
}

- (void)stopPushing {
    [self.pushTimer invalidate];
    self.pushTimer = nil;
}

- (void)push {
    
    /* JSON keys */
    static NSString *kType = @"messageType";
    static NSString *kText = @"text";
    static NSString *kAppendLineType = @"appendLine";
    static NSString *kClearType = @"clear";
    
    NSData *message;
    __autoreleasing NSError *error = nil;
    
    if (self.currentLineIndex < self.starwars.count) {
        NSString *textLine = self.starwars[self.currentLineIndex];
        NSDictionary *jsonDict = @{kType: kAppendLineType, kText: textLine};
        
        message = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
    }
    else {
        message = [NSJSONSerialization dataWithJSONObject:@{kType: kClearType} options:NSJSONWritingPrettyPrinted error:&error];
        self.currentLineIndex = 0;
    }
    
    if (!error) {
        /* Enqueue the message in the push queue */
        [[BLWebSocketsServer sharedInstance] pushToAll:message];
    }
    else {
        NSLog(@"%@", error);
    }
    
    self.currentLineIndex++;
}

@end
