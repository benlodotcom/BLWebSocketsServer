BLWebSocketsServer is a simple websockets server for iOS built around [libwebsockets](http://git.warmcat.com/cgi-bin/cgit/libwebsockets/). Here's how easy it is to start a Websockets server in your iOS app:

``` objective-c
BLWebSocketsServer *server = [[BLWebSocketsServer alloc] initWithPort:9000 andProtocolName:@"my-protocol-name"];
[server setHandleRequestBlock:^NSData *(NSData *data) {
  //simply echo what has been received
  return data;
}];
[server start];
```

## How To Get Started

- [Download BLWebSocketsServer](https://github.com/AFNetworking/AFNetworking/zipball/master) and try out the echo server example.
- To include the server in your app copy the BLWebSocketsServer, add it to your project and add libz.dylib.

## Usage

This is what you need to know about BLWebSocketsServer:

``` objective-c
//To handle a request, use a block that receives as arguments the data in the request and returns the response data
typedef NSData *(^BLWebSocketsHandleRequestBlock)(NSData * requestData);
//Get the status of the server with this
@property (atomic, assign, readonly) BOOL isRunning;
//Create the server with this
- (id)initWithPort:(int)port andProtocolName:(NSString *)protocolName;
//Add the block that'll handle the request and the corresponding response with this
- (void)setHandleRequestBlock:(HandleRequestBlock)block;
//Method to start the server
- (void)start;
//Well...method to stop the server
- (void)stop;
```

## Contribute
When there is a change you'd like to make:

- Fork the repository
- [Send a pull request](https://github.com/benlodotcom/BLWebSocketsServer/pulls)
- I'll happily merge it in the master ;-)

## Todo
Here are some things I'd like to improve:

- Use poll() or select() to avoid having anf infinite while loop polling the socket for data.

