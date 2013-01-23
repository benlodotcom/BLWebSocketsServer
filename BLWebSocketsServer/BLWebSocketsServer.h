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

- (id)initWithPort:(int)port andProtocolName:(NSString *)protocolName;
- (void)start;
- (void)stop;
- (void)setHandleRequestBlock:(BLWebSocketsHandleRequestBlock)block;

@end
