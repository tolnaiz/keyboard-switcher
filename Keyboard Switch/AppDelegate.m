//
//  AppDelegate.m
//  Keyboard Switch
//
//  Created by Tolnai Zoltán on 2021. 10. 27..
//

#import "AppDelegate.h"

@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                          selector:@selector(appDidActivate:)
                         name:NSWorkspaceDidActivateApplicationNotification
                           object:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

- (NSString *)runCommand:(NSString *)commandToRun
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];

    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    NSLog(@"run command:%@", commandToRun);
    [task setArguments:arguments];

    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];

    NSFileHandle *file = [pipe fileHandleForReading];

    [task launch];

    NSData *data = [file readDataToEndOfFile];

    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}

- (void)appDidActivate:(NSNotification *)notification {
//    NSDictionary *userInfo = [notification userInfo];
//    NSRunningApplication *app = [userInfo objectForKey:NSWorkspaceApplicationKey];

    NSRunningApplication* app = [[NSWorkspace sharedWorkspace] frontmostApplication];

    
    NSDictionary *dict = @{
        @"com.sublimetext.4": @"org.unknown.keylayout.USqwertz",
        @"net.kovidgoyal.kitty": @"org.unknown.keylayout.USqwertz",
        @"com.apple.Terminal": @"org.unknown.keylayout.USqwertz",
        @"com.apple.dt.Xcode": @"org.unknown.keylayout.USqwertz",
        @"com.googlecode.iterm2": @"org.unknown.keylayout.USqwertz",
        @"com.github.atom": @"org.unknown.keylayout.USqwertz"
    };
    NSString *inputSourceKey = @"";
    if (dict[app.bundleIdentifier]){
        inputSourceKey = @"org.unknown.keylayout.USqwertz";
        //NSLog(@"exists");
    }else{
        inputSourceKey = @"com.apple.keyboardlayout.roman.keylayout.HungarianPro";
        //NSLog(@"NOT exists");
    }
    NSLog(@"String:%@",app.bundleIdentifier);
    NSString *baseCommand = @"/Users/tolnaiz/bin/InputSourceSelector select ";
    NSString *cmd = [baseCommand stringByAppendingString:inputSourceKey];

    NSString *output = [self runCommand:cmd];
/*
    NSString *inputSourceID = [NSString stringWithUTF8String:inputSourceKey];
    NSDictionary *properties = [NSDictionary dictionaryWithObject:inputSourceID
                                                                forKey:(NSString *)kTISPropertyInputSourceID];
    NSArray *inputSources = (__bridge NSArray *)TISCreateInputSourceList((__bridge CFDictionaryRef) properties, true);
    
    TISInputSourceRef a = (__bridge TISInputSourceRef)[inputSources objectAtIndex:0];
    NSString *localizedName = TISGetInputSourceProperty(a, kTISPropertyLocalizedName);
    NSLog(localizedName);
    
     OSStatus err = TISSelectInputSource((__bridge TISInputSourceRef) [inputSources objectAtIndex:0]);
     if(err != noErr){
         NSLog(@"%d", err);
         TISSelectInputSource((__bridge TISInputSourceRef) [inputSources objectAtIndex:0]);
     }else{
         NSLog(@"selected %s", inputSourceKey);
     }
     
 */
    
//    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.3);
//    dispatch_after(delay, dispatch_get_main_queue(), ^(void){
//        TISSelectInputSource((__bridge TISInputSourceRef) [inputSources objectAtIndex:0]);
//    });


}



@end
