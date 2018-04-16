//
//  GSProcess.h
//  gfxCardStatus
//
//  Created by Cody Krieger on 6/21/11.
//  Copyright 2011 Cody Krieger. All rights reserved.
//

#include <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <sys/sysctl.h>
#include <unistd.h>

#define kTaskItemName  @"name"
#define kTaskItemPID   @"pid"

@interface GSProcess : NSObject

// Get the current list of processes that are requiring the discrete GPU to be
// powered on and eating away at the user's precious battery life.
+ (NSArray *)getTaskList;

@end
