//
//  AppDelegate.m
//  SpriteKitSimpleGame
//
//  Created by Main Account on 9/4/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "AppDelegate.h"
#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"
@import GameKit;
@import SpriteKit;


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [self authenticateLocalPlayer];
    return YES;
}

- (void) authenticateLocalPlayer
{
    __weak GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil)
        {
            //showAuthenticationDialogWhenReasonable: is an example method name. Create your own method that displays an authentication view when appropriate for your app.
            [self showAuthenticationDialog: viewController];
        }
        else if (localPlayer.isAuthenticated)
        {
            //authenticatedPlayer: is an example method name. Create your own method that is called after the loacal player is authenticated.
            [self enableGameCenter: localPlayer];
        }
        else
        {
            [self disableGameCenter];
        }
    };
}

-(void)showAuthenticationDialog:(UIViewController*)viewController
{
    SKView *view = (SKView *)self.window.rootViewController.view;
    view.paused = YES;
    
    [self.window.rootViewController presentViewController:viewController animated:YES completion:^{
         view.paused = NO;
    }];
    
}

-(void)enableGameCenter:(GKLocalPlayer*)localPlayer
{
    
}

-(void)disableGameCenter
{
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    SKView *view = (SKView *)self.window.rootViewController.view;
    view.paused = YES;
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    SKView *view = (SKView *)self.window.rootViewController.view;
    view.paused = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//    MyScene* myScene = ((MyScene*)((SKView*)self.window.rootViewController.view).scene);
//    [myScene save];
}





@end
