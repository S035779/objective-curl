//
//  NSFileManager+MimeType.m
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import "NSFileManager+MimeType.h"


@implementation NSFileManager (MimeType)

+ (NSString *)mimeTypeForFileAtPath:(NSString *)path
{
	BOOL isDir = NO;
	NSFileManager *mgr = [[NSFileManager alloc] init];
	__block NSString *mimeType = @"";
	
	if ([mgr fileExistsAtPath:path isDirectory:&isDir] && isDir) {
		mimeType = @"application/x-directory";
	} else {
		NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
		//NSURLResponse *resp = nil;
        __block NSString *resp = nil;
		NSError *err = nil;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
		//[NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&err];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"did finish download.\n%@", response.URL);
            if(err) {
                NSLog(@"Error trying to get MimeType of file: %@ - %@", path, [err description]);
                dispatch_semaphore_signal(semaphore);
                return;
            }
            resp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            mimeType = [(NSURLResponse *)resp MIMEType];
            dispatch_semaphore_signal(semaphore);
        }];
        [task resume];
	}
	[mgr release];
	return mimeType;
}

@end
