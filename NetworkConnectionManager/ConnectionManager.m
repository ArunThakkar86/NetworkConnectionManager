

#import "ConnectionManager.h"

#define kCONTENT_TYPE @"Content-Type"
#define kAPPLICATION_JSON @"application/json"

#define kSUCCESS 200
#define kUNAUTHOURIZATION_ERROR 401
#define kNO_ERROR 0

#define kROOT_JSON_KEY @"data"
#define kAUTHOURIZATION_KEY @"Authorization"

#define kLOCATION_KEY @"locations"

#define kERROR_KEY @"errors"
#define kERROR_CODE_KEY @"error_code"
#define kERROR_MESSAGE_KEY @"error_msg"

@implementation ConnectionManager

+ (ConnectionManager *)sharedInstance {
    
    static dispatch_once_t onceToken;
    static id sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] init];
    });
    
    return sharedInstance;
}



+ (void)sendRequestWithURLString:(NSString *)strURL indicatorMessage:(NSString*)indMessage methodType:(NSString *)methodType requestDictionary:(NSDictionary *)_requestDictionary completionHandler:(void (^) (NSDictionary *responseDictionary, NSError *error))completionHandler {

    NSError *error = nil;
    NSData *requestJSON = nil;
    if(_requestDictionary != nil) {
        NSDictionary *requestDictionary = @{kROOT_JSON_KEY: _requestDictionary};
        requestJSON = [NSJSONSerialization dataWithJSONObject:requestDictionary options:NSJSONWritingPrettyPrinted error:&error];
    }

    NSURL *URL = [NSURL URLWithString:strURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
   
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    [[urlSession  dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
        BOOL isSuccess = NO;
        
        if (responseCode == kSUCCESS) {
            if (!error && data) {
                NSError *JSONError = nil;
                id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&JSONError];
                if (!JSONError) {
                    NSLog(@"###### RESPONSE JSON: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                    
                    NSArray *errors = responseJSON[kERROR_KEY];
                    if (errors.count == kNO_ERROR) {
                        isSuccess = YES;
                        
                        NSDictionary *responseDataDic = responseJSON;
                        completionHandler(responseDataDic, error);
                    } else {
                        NSLog(@"DEV ERROR");
                        //completionHandler(responseJSON, error);
                    }
                } else {
                    NSLog(@"JSONError: %@", error);
                }
            } else {
                NSLog(@"connectionError: %@", error);
            }
        } else if (responseCode == kUNAUTHOURIZATION_ERROR) { // authorization error
            NSLog(@"kUNAUTHOURIZED_ERROR");
        } else {
            NSLog(@"Server Error: %@", error);
        }
        
        if (!isSuccess) {
            //error = [NSError errorWithDomain:@"ATMLocator" code:100 userInfo:@{@"status":@"0"}];
            completionHandler(@{}, error);
        }
    }] resume];
}


#pragma mark - NSURLSession delegate

-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    // Get remote certificate
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, 0);
    
    // Set SSL policies for domain name check
    NSMutableArray *policies = [NSMutableArray array];
    [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)challenge.protectionSpace.host)];
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
    
    // Evaluate server certificate
    SecTrustResultType result;
    SecTrustEvaluate(serverTrust, &result);
    BOOL certificateIsValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
    
    // Get local and remote cert data
    NSData *remoteCertificateData = CFBridgingRelease(SecCertificateCopyData(certificate));
    NSString *pathToCert = [[NSBundle mainBundle]pathForResource:@"GIAG2" ofType:@"cer"];
    NSData *localCertificate = [NSData dataWithContentsOfFile:pathToCert];
    
    // The pinnning check
    if ([remoteCertificateData isEqualToData:localCertificate] && certificateIsValid) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, NULL);
    }
}

@end
