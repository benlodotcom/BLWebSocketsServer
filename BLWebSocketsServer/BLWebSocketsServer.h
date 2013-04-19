//
//  BLWebSocketServer.h
//  LibWebSocket
//
//  Created by Benjamin Loulier on 1/22/13.
//  Copyright (c) 2013 Benjamin Loulier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "libwebsockets.h"

typedef NSData *(^BLWebSocketsHandleRequestBlock)(NSData * requestData);

@interface BLWebSocketsServer : NSObject

@property (atomic, assign, readonly) BOOL isRunning;

+ (BLWebSocketsServer *)sharedInstance;

- (void)startListeningOnPort:(int)port withProtocolName:(NSString *)protocolName;
- (void)stop;
- (void)setHandleRequestBlock:(BLWebSocketsHandleRequestBlock)block;

@end
