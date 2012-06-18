
// Logos by Dustin Howett
// See http://iphonedevwiki.net/index.php/Logos

/*
 #error iOSOpenDev post-project creation from template requirements (remove these lines after completed) -- \
 Link to libsubstrate.dylib: \
 (1) go to TARGETS > Build Phases > Link Binary With Libraries and add /opt/iOSOpenDev/lib/libsubstrate.dylib \
 (2) remove these lines from *.xm files (not *.mm files as they're automatically generated from *.xm files)
 */

#import "GraphicsServices/GSEvent.h"
#import "CoreFoundation/CFRunLoop.h"
#import <Foundation/Foundation.h>
#import <SpringBoard/SBMediaController.h>

bool downVolumePressed;
bool upVolumePressed;
bool finishedHolding;
static CFRunLoopTimerRef ButtonDownTimer;
double holdTime;

#define prefpath @"/var/mobile/Library/Preferences/com.fire30.VolumePlayer.plist"


static void DestroyTimer()
{       if (ButtonDownTimer) {
    
    CFRunLoopRemoveTimer(CFRunLoopGetCurrent(), ButtonDownTimer, kCFRunLoopCommonModes);
    CFRelease(ButtonDownTimer);
    ButtonDownTimer = NULL;
    finishedHolding = false;
}
}

static void doCallBack(CFRunLoopTimerRef timer, void *info)
{
    
    finishedHolding = true;
	if(upVolumePressed)
    {
        [[%c(SBMediaController) sharedInstance] changeTrack:1];
    }
    
    else if(downVolumePressed)
    {
        [[%c(SBMediaController) sharedInstance] changeTrack:-1];
    }
}

%hook SpringBoard


- (void) volumeChanged:(GSEventRef)changed
{
NSDictionary *prefs=[[NSDictionary alloc]initWithContentsOfFile:prefpath];
if([prefs objectForKey:@"holdTime"]) holdTime=[[prefs objectForKey:@"holdTime"]doubleValue];

switch(GSEventGetType(changed))
{
    case kGSEventVolumeUpButtonDown:{
        
        DestroyTimer();
        upVolumePressed = true;
        ButtonDownTimer = CFRunLoopTimerCreate(kCFAllocatorDefault,CFAbsoluteTimeGetCurrent() + holdTime ,0,0,0,doCallBack,NULL);
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), ButtonDownTimer, kCFRunLoopCommonModes);
        NSLog( @"UP VOLUME IS DOWN");
        break;
    }
        
        
    case kGSEventVolumeUpButtonUp: {
        NSLog( @"UP VOLUME IS UP");
        if(!finishedHolding)
        {
            %orig;
        }
        DestroyTimer();
        upVolumePressed = false;
        break;
    }
    case kGSEventVolumeDownButtonDown:{
        DestroyTimer();
        downVolumePressed = true;
        ButtonDownTimer = CFRunLoopTimerCreate(kCFAllocatorDefault,CFAbsoluteTimeGetCurrent() + holdTime ,0,0,0,doCallBack,NULL);
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), ButtonDownTimer, kCFRunLoopCommonModes);
        NSLog( @"DOWN VOLUME IS DOWN");
        break;
    }
    case kGSEventVolumeDownButtonUp:{
        if(!finishedHolding)
        {
            %orig;
        }
        DestroyTimer();
        downVolumePressed = false;
        NSLog( @"DOWN VOLUME IS UP");
        break;
        
    }
}
}

%end