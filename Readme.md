[![Build Status](https://travis-ci.org/benlodotcom/BLWebSocketsServer.png)](https://travis-ci.org/benlodotcom/BLWebSocketsServer)

BLWebSocketsServer is a lightweight websockets server for iOS built around [libwebsockets](http://git.warmcat.com/cgi-bin/cgit/libwebsockets/). The server suports both **synchronous requests and push**.

Here's how easy it is to start a Websockets server in your iOS app:

``` objective-c
//every request made by a client will trigger the execution of this block.
[[BLWebSocketsServer sharedInstance] setHandleRequestBlock:^NSData *(NSData *data) {
  //simply echo what has been received
  return data;
}];
//Start the server
[[BLWebSocketsServer sharedInstance] startListeningOnPort:9000 withProtocolName:@"my-protocol-name" andCompletionBlock:^(NSError *error) {
    if (!error) {
        NSLog(@"Server started");
    }
    else {
        NSLog(@"%@", error);
    }
}];
//Push a message to every connected clients
[[BLWebSocketsServer sharedInstance] pushToAll:[@"pushed message" dataUsingEncoding:NSUTF8StringEncoding]];
```

## How To Get Started

- [Download BLWebSocketsServer](https://github.com/benlodotcom/BLWebSocketsServer/archive/master.zip) or clone the repo, and try out the demo project.
- To include the server in your app copy the BLWebSocketsServer, add it to your project and add libz.dylib.

## Usage

This is what you need to know about BLWebSocketsServer:

``` objective-c
//Access the BLWebSocketsServer singleton
[BLWebSocketsServer sharedInstance]
//To handle a request, use a block that receives as arguments the data in the request and returns the response data
typedef NSData *(^BLWebSocketsHandleRequestBlock)(NSData * requestData);
//Add the block that'll handle the request and the corresponding response with this
- (void)setHandleRequestBlock:(BLWebSocketsHandleRequestBlock)block;
//Method to start the server
- (void)startListeningOnPort:(int)port withProtocolName:(NSString *)protocolName andCompletionBlock:(void(^)(NSError *error))completionBlock;
//Get the status of the server with this
@property (atomic, assign, readonly) BOOL isRunning;
//Push data to all the connected clients
- (void)pushToAll:(NSData *)data;
//Well...method to stop the server
- (void)stopWithCompletionBlock:(void(^)())completionBlock;
```

## Contribute
When there is a change you'd like to make (if you don't feel inspired you can check the Todo below):

- Fork the repository
- [Send a pull request](https://github.com/benlodotcom/BLWebSocketsServer/pulls)
- I'll happily merge it in the master !

## Todo

- Add the ability to listen simultaneously on multiple ports for different protocols.
- Use dispatch sources instead of an infinite loop.
- Add a session store.
- Implement per user push.

Keep working on the documentation, it is a never ending task anyway ;-)

## Contact

Benjamin Loulier

- http://twitter.com/benlodotcom
- http://github.com/benlodotcom

## License

BLWebSocketsServer is available under the MIT license. See the LICENSE file for more info.


