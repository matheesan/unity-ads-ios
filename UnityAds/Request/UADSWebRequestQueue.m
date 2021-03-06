#import "UADSWebRequestQueue.h"
#import "UADSWebRequest.h"

@implementation UADSWebRequestQueue

static NSOperationQueue *requestQueue;
static NSOperationQueue *resolveQueue;
static dispatch_once_t onceToken;

+ (void)start {
    dispatch_once(&onceToken, ^{
        if (!requestQueue) {
            requestQueue = [[NSOperationQueue alloc] init];
            requestQueue.maxConcurrentOperationCount = 1;
        }

        if (!resolveQueue) {
            resolveQueue = [[NSOperationQueue alloc] init];
            resolveQueue.maxConcurrentOperationCount = 1;
        }
    });
}

+ (void)requestUrl:(NSString *)url type:(NSString *)type headers:(NSDictionary<NSString*, NSArray*> *)headers completeBlock:(UnityAdsWebRequestCompletion)completeBlock connectTimeout:(int)connectTimeout {
    [UADSWebRequestQueue requestUrl:url type:type headers:headers body:NULL completeBlock:completeBlock connectTimeout:connectTimeout];
}

+ (void)requestUrl:(NSString *)url type:(NSString *)type headers:(NSDictionary<NSString*, NSArray*> *)headers body:(NSString *)body completeBlock:(UnityAdsWebRequestCompletion) completeBlock connectTimeout:(int)connectTimeout {
    
    if (requestQueue && url && type && completeBlock) {
        UADSWebRequestOperation *operation = [[UADSWebRequestOperation alloc] initWithUrl:url requestType:type headers:headers body:body completeBlock:completeBlock connectTimeout:connectTimeout];
        [requestQueue addOperation:operation];
    }
}

+ (BOOL)resolve:(NSString *)host completeBlock:(UnityAdsResolveRequestCompletion)completeBlock {
    if (resolveQueue && host && completeBlock) {
        UADSResolveOperation *operation = [[UADSResolveOperation alloc] initWithHostName:host completeBlock:completeBlock];
        [resolveQueue addOperation:operation];

        return true;
    }

    return false;
}

+ (void)cancelAllOperations {
    if (requestQueue) {
        [requestQueue cancelAllOperations];
    }
    if (resolveQueue) {
        [resolveQueue cancelAllOperations];
    }
}

@end