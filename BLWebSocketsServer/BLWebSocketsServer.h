//
//  BLWebSocketServer.h
//  LibWebSocket
//
//  Created by Benjamin Loulier on 1/22/13.
//  Copyright (c) 2013 Benjamin Loulier. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSData *(^BLWebSocketsHandleRequestBlock)(NSData * requestData);

@interface BLWebSocketsServer : NSObject

@property (atomic, assign, readonly) BOOL isRunning;

+ (BLWebSocketsServer *)sharedInstance;

- (void)startListeningOnPort:(int)port withProtocolName:(NSString *)protocolName andCompletionBlock:(void(^)(NSError *error))completionBlock;
- (void)stopWithCompletionBlock:(void(^)())completionBlock;
- (void)setHandleRequestBlock:(BLWebSocketsHandleRequestBlock)handleRequestBlock;
- (void)pushToAll:(NSData *)data;

@end
