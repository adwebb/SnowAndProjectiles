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
    BOOL muted;
}

@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@property (nonatomic) AVAudioPlayer* gameMusicPlayer;
@property (nonatomic) MyScene* myScene;
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
    if(!muted)
    [self.backgroundMusicPlayer play];
    
    NSURL * gameMusicURL = [[NSBundle mainBundle] URLForResource:@"bg" withExtension:@"mp3"];
    self.gameMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:gameMusicURL error:&error];
    self.gameMusicPlayer.numberOfLoops = -1;
    [self.gameMusicPlayer prepareToPlay];
    
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
- (IBAction)onSoundTogglePressed:(UIButton *)sender
{
    muted = !muted;
    
    if(self.myScene != nil)
    {
    self.myScene.muted = muted;
    }
    if(muted)
    {
        [sender setImage:[UIImage imageNamed:@"soundOff"] forState:UIControlStateNormal];
        self.backgroundMusicPlayer.volume = 0;
        self.gameMusicPlayer.volume = 0;
    }else{
        [sender setImage:[UIImage imageNamed:@"soundOn"] forState:UIControlStateNormal];
        self.backgroundMusicPlayer.volume = 1;
        self.gameMusicPlayer.volume = 1;
    }
}

- (IBAction)onNewGameButtonPressed:(id)sender {
   
    [self.backgroundMusicPlayer stop];
    self.backgroundMusicPlayer.currentTime = 0;
    
    if(!muted)
    [self.gameMusicPlayer play];
    
    [self showIntroScreen:NO];
    
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        NSLog(@"%@",NSStringFromCGSize(self.view.frame.size));
        
        // Create and configure the scene.
        MyScene * scene = [MyScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        scene.muted = muted;
        
        self.myScene = scene;
        
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
