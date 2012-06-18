#line 1 "/Users/tj/Documents/iOS Development/VolumePlayer/VolumePlayer/VolumePlayer.xm"











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

#include <substrate.h>
@class SBMediaController; @class SpringBoard; 
static void (*_logos_orig$_ungrouped$SpringBoard$volumeChanged$)(SpringBoard*, SEL, GSEventRef); static void _logos_method$_ungrouped$SpringBoard$volumeChanged$(SpringBoard*, SEL, GSEventRef); 
static Class _logos_static_class$SBMediaController; 
#line 36 "/Users/tj/Documents/iOS Development/VolumePlayer/VolumePlayer/VolumePlayer.xm"
static void doCallBack(CFRunLoopTimerRef timer, void *info)
{
    
    finishedHolding = true;
	if(upVolumePressed)
    {
        [[_logos_static_class$SBMediaController sharedInstance] changeTrack:1];
    }
    
    else if(downVolumePressed)
    {
        [[_logos_static_class$SBMediaController sharedInstance] changeTrack:-1];
    }
}





static void _logos_method$_ungrouped$SpringBoard$volumeChanged$(SpringBoard* self, SEL _cmd, GSEventRef changed) {
NSDictionary *prefs=[[NSDictionary alloc]initWithContentsOfFile:prefpath];
if([prefs objectForKey:@"holdTime"]) holdTime=[[prefs objectForKey:@"holdTime"]intValue];

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
            _logos_orig$_ungrouped$SpringBoard$volumeChanged$(self, _cmd, changed);
        }
        DestroyTimer();
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
            _logos_orig$_ungrouped$SpringBoard$volumeChanged$(self, _cmd, changed);
        }
        DestroyTimer();
        NSLog( @"DOWN VOLUME IS UP");
        break;
        
    }
}
}


static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(volumeChanged:), (IMP)&_logos_method$_ungrouped$SpringBoard$volumeChanged$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$volumeChanged$);} {_logos_static_class$SBMediaController = objc_getClass("SBMediaController"); } }
#line 103 "/Users/tj/Documents/iOS Development/VolumePlayer/VolumePlayer/VolumePlayer.xm"
