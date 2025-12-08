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
    [NSApp setActivationPolicy: NSApplicationActivationPolicyProhibited];
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
        @"com.jetbrains.PhpStorm": @"org.unknown.keylayout.USqwertz",
        @"com.apple.Terminal": @"org.unknown.keylayout.USqwertz",
        @"com.apple.dt.Xcode": @"org.unknown.keylayout.USqwertz",
        @"com.googlecode.iterm2": @"org.unknown.keylayout.USqwertz",
        @"com.torusknot.SourceTreeNotMAS": @"org.unknown.keylayout.USqwertz",
        @"com.microsoft.VSCode": @"org.unknown.keylayout.USqwertz",
        @"net.kovidgoyal.kitty": @"org.unknown.keylayout.USqwertz",
        @"com.vscodium": @"org.unknown.keylayout.USqwertz",
        @"com.todesktop.230313mzl4w4u92": @"org.unknown.keylayout.USqwertz"
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
    NSString *baseCommand = @"~/bin/InputSourceSelector select ";
    NSString *cmd = [baseCommand stringByAppendingString:inputSourceKey];

    NSString *output = [self runCommand:cmd];

}



@end
