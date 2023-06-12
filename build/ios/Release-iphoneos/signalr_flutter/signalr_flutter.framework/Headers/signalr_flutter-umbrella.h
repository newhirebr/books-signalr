#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SignalrApi.h"
#import "SignalrFlutterPlugin.h"
#import "signalr_flutter.h"

FOUNDATION_EXPORT double signalr_flutterVersionNumber;
FOUNDATION_EXPORT const unsigned char signalr_flutterVersionString[];

