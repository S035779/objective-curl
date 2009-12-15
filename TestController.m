//
//  TestController.m
//  objective-curl
//
//  Created by nrj on 12/7/09.
//  Copyright 2009. All rights reserved.
//

#import "TestController.h"
#import "CurlFTP.h"


@implementation TestController


- (IBAction)runTest:(id)sender
{
	CurlFTP *ftp = [[CurlFTP alloc] init];
	
	[ftp setVerbose:YES];
	[ftp setShowProgress:YES];
	
	[ftp uploadFile:@"/Users/nrj/Desktop/bigfile.zip" 
		 toLocation:@"ftp://bender.local/bigfile.zip"
	withCredentials:@"guest:guest"];
}


@end