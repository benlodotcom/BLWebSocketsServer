//
//  BLAsyncMessageQueue.h
//  BLWebSocketsServer
//
//  Created by Benjamin Loulier on 4/21/13.
//  Copyright (c) 2013 Benjamin Loulier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLAsyncMessageQueue : NSObject

@property (atomic, assign) int messagesCount;

- (void)addMessageQueueForUserWithId:(int)userId;
- (void)removeMessageQueueForUserWithId:(int)userId;
- (void)enqueueMessageForAllUsers:(NSData *)message;
- (NSData *)messageForUserWithId:(int)userId;
- (void)reset;
@end
