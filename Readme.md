BLWebSocketsServer is a simple websockets server for iOS built around [libwebsockets](http://git.warmcat.com/cgi-bin/cgit/libwebsockets/). Here's how easy it is to start a Websockets server in your iOS app:

``` objective-c
[[BLWebSocketsServer sharedInstance] setHandleRequestBlock:^NSData *(NSData *data) {
  //simply echo what has been received
  return data;
}];
[[BLWebSocketsServer sharedInstance] startListeningOnPort:9000 withProtocolName:@"my-protocol-name" andCompletionBlock:^(NSError *error) {
    if (!error) {
        NSLog(@"Server started");
    }
    else {
        NSLog(@"%@", error);
    }
}];
```

## How To Get Started

- [Download BLWebSocketsServer](https://github.com/AFNetworking/AFNetworking/zipball/master) and try out the echo server example.
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
//Well...method to stop the server
- (void)stopWithCompletionBlock:(void(^)())completionBlock;
```

## Contribute
When there is a change you'd like to make (if you don't feel inspired you can check the Todo below):

- Fork the repository
- [Send a pull request](https://github.com/benlodotcom/BLWebSocketsServer/pulls)
- I'll happily merge it in the master !

## Todo

- Add async (push) support.
- Add the ability to listen simultaneously on multiple ports for different protocols.
- Use dispatch sources instead of an infinite loop.

Keep working on the documentation, it is a never ending task anyway ;-)


