//
//  BLAsyncMessageQueue.m
//  BLWebSocketsServer
//
//  Created by Benjamin Loulier on 4/21/13.
//  Copyright (c) 2013 Benjamin Loulier. All rights reserved.
//

#import "BLAsyncMessageQueue.h"

@interface NSMutableArray (QueueAdditions)

- (void)enqueue:(id)object;
- (id)dequeue;

@end

@implementation NSMutableArray (QueueAdditions)

- (void)enqueue:(id)object{
    
    //[self addObject:object];
    [self insertObject:object atIndex:0];
}

- (id)dequeue {
    if (self.count == 0) {
        return nil;
    }
    id obj = self.lastObject;
    [self removeObjectAtIndex:[self indexOfObject:obj]];
    return obj;
}

@end

@interface BLAsyncMessageQueue()

@property (nonatomic, strong) NSMutableDictionary *usersMessageQueues;

@end

@implementation BLAsyncMessageQueue

- (id)init {
    self = [super init];
    if (self) {
        self.usersMessageQueues = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return self;
}

- (void)addMessageQueueForUserWithId:(int)userId {
    @synchronized (self) {
        self.usersMessageQueues[[NSNumber numberWithInt:userId]] = [NSMutableArray arrayWithCapacity:0];
    }
}

- (void)removeMessageQueueForUserWithId:(int)userId {
    NSNumber *userIdNumber = [NSNumber numberWithInt:userId];
    @synchronized (self) {
        self.messagesCount -= [self.usersMessageQueues[userIdNumber] count];
        [self.usersMessageQueues removeObjectForKey:userIdNumber];
    }
}

- (void)enqueueMessageForAllUsers:(NSData *)message {
    @synchronized(self) {
        for (NSMutableArray *messageQueue in self.usersMessageQueues.objectEnumerator) {
            [messageQueue enqueue:message];
            self.messagesCount++;
        }
    }
}

- (NSData *)messageForUserWithId:(int)userId {
    NSData *message;
    @synchronized(self) {
       message = [self.usersMessageQueues[[NSNumber numberWithInt:userId]] dequeue];
        self.messagesCount--;
    }
    return message;
}

- (void)reset {
    [self.usersMessageQueues removeAllObjects];
}

@end
