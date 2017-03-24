

#import <Foundation/Foundation.h>

@interface ConnectionManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;

+ (ConnectionManager *)sharedInstance;

+ (void)sendRequestWithURLString:(NSString *)strSubURL indicatorMessage:(NSString*)indMessage methodType:(NSString *)methodType requestDictionary:(NSDictionary *)requestDictionary completionHandler:(void (^) (NSDictionary *responseDictionary, NSError *error))completionHandler;

@end
