//
//  BLWebSocketServer.m
//  LibWebSocket
//
//  Created by Benjamin Loulier on 1/22/13.
//  Copyright (c) 2013 Benjamin Loulier. All rights reserved.
//

#import "BLWebSocketsServer.h"
#import "libwebsockets.h"
#import "private-libwebsockets.h"
#import "BLAsyncMessageQueue.h"

static int pollingInterval = 20000;
static char * http_only_protocol = "http-only";

/* Error constants */
static NSString *errorDomain = @"com.blwebsocketsserver";

/* Declaration of the callbacks (http and websockets), libwebsockets requires an http callback even if we don't use it*/
static int callback_websockets(struct libwebsocket_context * this,
             struct libwebsocket *wsi,
             enum libwebsocket_callback_reasons reason,
             void *user, void *in, size_t len);


static int callback_http(struct libwebsocket_context *context,
                         struct libwebsocket *wsi,
                         enum libwebsocket_callback_reasons reason, void *user,
                         void *in, size_t len);

static BLWebSocketsServer *sharedInstance = nil;

@interface BLWebSocketsServer()

/* Using atomic in our case is sufficient to ensure thread safety */
@property (atomic, assign, readwrite) BOOL isRunning;
@property (atomic, assign) BOOL stopServer;
/* Context representing the server */
@property (nonatomic, assign) struct libwebsocket_context *context;
@property (nonatomic, strong) BLAsyncMessageQueue *asyncMessageQueue;
@property (nonatomic, strong, readwrite) BLWebSocketsHandleRequestBlock handleRequestBlock;
/* Temporary storage for the server stopped completion block */
@property (nonatomic, strong) void(^serverStoppedCompletionBlock)();
/* Incremental value that defines the sessionId */
@property (nonatomic, assign) int sessionIdIncrementalCount;

- (void)cleanup;

@end

@implementation BLWebSocketsServer

#pragma mark - Shared instance
+ (BLWebSocketsServer *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.handleRequestBlock = NULL;
        sharedInstance.asyncMessageQueue = [[BLAsyncMessageQueue alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Server management
- (void)startListeningOnPort:(int)port withProtocolName:(NSString *)protocolName andCompletionBlock:(void(^)(NSError *error))completionBlock {
    
    if (self.isRunning) {
        return;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        
    dispatch_async(queue, ^{
        
        /* Context creation */
        struct libwebsocket_protocols protocols[] = {
            /* first protocol must always be HTTP handler */
            {
                http_only_protocol,
                callback_http,
                0
            },
            {
                [protocolName cStringUsingEncoding:NSASCIIStringEncoding],
                callback_websockets,   // callback
                sizeof(int)            // the session is identified by an id
                
            },
            {
                NULL, NULL, 0   /* End of list */
            }
        };
        self.context = libwebsocket_create_context(port, NULL, protocols,
                                              libwebsocket_internal_extensions,
                                              NULL, NULL, NULL, -1, -1, 0, NULL);
        NSError *error = nil;
        if (self.context == NULL) {
            error = [NSError errorWithDomain:errorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Couldn't create the libwebsockets context.", @"")}];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(error);
        });
        
        if (!error) {
            self.isRunning = YES;
            
            /* For now infinite loop which proceses events and wait for n ms. */
            while (!self.stopServer) {
                @autoreleasepool {
                    libwebsocket_service(self.context, 0);
                    if (self.asyncMessageQueue.messagesCount > 0) {
                        libwebsocket_callback_on_writable_all_protocol(&(self.context->protocols[1]));
                    }
                }
                usleep(pollingInterval);
            }
            
            self.isRunning = NO;
            
            [self cleanup];
        
            dispatch_async(dispatch_get_main_queue(), ^{
                self.serverStoppedCompletionBlock();
                self.serverStoppedCompletionBlock = nil;
            });
        }
        
    });
    
}

- (void)stopWithCompletionBlock:(void (^)())completionBlock {
    
    self.serverStoppedCompletionBlock = completionBlock;
    
    if (!self.isRunning) {
        return;
    }
    else {
        self.stopServer = YES;
    }
}

- (void)cleanup {
    libwebsocket_context_destroy(self.context);
    self.context = NULL;
    self.stopServer = NO;
    [self.asyncMessageQueue reset];
}

#pragma mark - Async messaging
- (void)pushToAll:(NSData *)data {
    [self.asyncMessageQueue enqueueMessageForAllUsers:data];
}


@end

static void write_data_websockets(NSData *data, struct libwebsocket *wsi) {
    
    unsigned char *response_buf;
    
    if (data.length > 0) {
        response_buf = (unsigned char*) malloc(LWS_SEND_BUFFER_PRE_PADDING + data.length +LWS_SEND_BUFFER_POST_PADDING);
        bcopy([data bytes], &response_buf[LWS_SEND_BUFFER_PRE_PADDING], data.length);
        libwebsocket_write(wsi, &response_buf[LWS_SEND_BUFFER_PRE_PADDING], data.length, LWS_WRITE_TEXT);
        free(response_buf);
    }
    else {
        NSLog(@"Attempt to write empty data on the websocket");
    }
}

/* Implementation of the callbacks (http and websockets) */
static int callback_websockets(struct libwebsocket_context * this,
             struct libwebsocket *wsi,
             enum libwebsocket_callback_reasons reason,
             void *user, void *in, size_t len) {
    int *session_id = (int *) user;
    switch (reason) {
        case LWS_CALLBACK_ESTABLISHED:
            NSLog(@"%@", @"Connection established");
            *session_id = sharedInstance.sessionIdIncrementalCount++;
            [sharedInstance.asyncMessageQueue addMessageQueueForUserWithId:*session_id];
            break;
        case LWS_CALLBACK_RECEIVE: {
            NSData *data = [NSData dataWithBytes:(const void *)in length:len];
            NSData *response = nil;
            if (sharedInstance.handleRequestBlock) {
                response = sharedInstance.handleRequestBlock(data);
            }
            write_data_websockets(response, wsi);
            break;
        }
        case LWS_CALLBACK_SERVER_WRITEABLE: {
            NSData *message = [sharedInstance.asyncMessageQueue messageForUserWithId:*session_id];
            write_data_websockets(message, wsi);
            break;
        }
        case LWS_CALLBACK_CLOSED: {
            [sharedInstance.asyncMessageQueue removeMessageQueueForUserWithId:*session_id];
            break;
        }
        default:
            break;
    }
    
    return 0;
}



static int callback_http(struct libwebsocket_context *context,
                         struct libwebsocket *wsi,
                         enum libwebsocket_callback_reasons reason, void *user,
                         void *in, size_t len)
{
    return 0;
}


