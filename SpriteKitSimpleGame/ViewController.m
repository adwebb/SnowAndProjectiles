//
//  ViewController.m
//  SpriteKitSimpleGame
//
//  Created by Main Account on 9/4/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"
#import <QuartzCore/QuartzCore.h>

@import AVFoundation;

@interface ViewController ()
{
    IBOutletCollection(id) NSArray *outlets;
    
    __weak IBOutlet UIView *myView;
}

@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@property (nonatomic) AVAudioPlayer* gameMusicPlayer;
@end

@implementation ViewController

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    NSError *error;
    NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"intro" withExtension:@"mp3"];
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    self.backgroundMusicPlayer.numberOfLoops = 1;
    [self.backgroundMusicPlayer prepareToPlay];
    [self.backgroundMusicPlayer play];
    
    NSURL * gameMusicURL = [[NSBundle mainBundle] URLForResource:@"bg" withExtension:@"mp3"];
    self.gameMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:gameMusicURL error:&error];
    self.gameMusicPlayer.numberOfLoops = -1;
    [self.gameMusicPlayer prepareToPlay];
    [self.gameMusicPlayer play];
    
    myView.layer.cornerRadius = 10;
    myView.layer.masksToBounds = YES;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self showIntroScreen:YES];
}

-(void)showIntroScreen:(BOOL)toggle
{
    for (UIView* view in outlets) {
        view.hidden = !toggle;
    }
}

- (IBAction)onNewGameButtonPressed:(id)sender {
   
    [self.backgroundMusicPlayer stop];
    self.backgroundMusicPlayer.currentTime = 0;
    [self.gameMusicPlayer play];
    [self showIntroScreen:NO];
    
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        NSLog(@"%@",NSStringFromCGSize(self.view.frame.size));
        
        // Create and configure the scene.
        SKScene * scene = [MyScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene];
    }
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

@end
