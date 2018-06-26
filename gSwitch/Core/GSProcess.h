//
//  GSProcess.m
//  gSwitch
//
//  https://github.com/codykrieger/gfxCardStatus/blob/master/LICENSE @ Jun 17, 2012
//  Copyright (c) 2010-2012, Cody Krieger
//  All rights reserved.
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
