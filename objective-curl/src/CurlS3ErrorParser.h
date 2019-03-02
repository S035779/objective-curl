//
//  S3ErrorParser.h
//  objective-curl
//
//  Copyright 2010 Nick Jensen <http://goto11.net>
//

#import <Cocoa/Cocoa.h>


static const NSString * S3ErrorCodeKey;

static const NSString * S3ErrorMessageKey;


@interface CurlS3ErrorParser : NSObject

+ (NSDictionary *)parseErrorDetails:(NSString *)resp;

+ (int)transferStatusForErrorCode:(NSString *)code;

@end
