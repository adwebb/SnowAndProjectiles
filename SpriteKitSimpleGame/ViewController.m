//
//  ViewController.m
//  SpriteKitSimpleGame
//
//  Created by Main Account on 9/4/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "ViewController.h"
#import "MainMenuScene.h"

@import AVFoundation;

@interface ViewController ()

@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@property (nonatomic) AVAudioPlayer* gameMusicPlayer;
@end

@implementation ViewController

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Create and configure the scene.
    MainMenuScene * scene = [MainMenuScene sceneWithSize:self.view.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [(id)self.view presentScene:scene];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    NSError *error;
    NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"intro" withExtension:@"mp3"];
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    self.backgroundMusicPlayer.numberOfLoops = 1;
    [self.backgroundMusicPlayer prepareToPlay];
    [self introMusic:YES];
    
    NSURL * gameMusicURL = [[NSBundle mainBundle] URLForResource:@"bg" withExtension:@"mp3"];
    self.gameMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:gameMusicURL error:&error];
    self.gameMusicPlayer.numberOfLoops = -1;
    [self.gameMusicPlayer prepareToPlay];
    
}

-(void)introMusic:(BOOL)play
{
    if(play)
    {
        if(self.gameMusicPlayer.isPlaying)
        {
            [self gameMusic:NO];
        }
        self.backgroundMusicPlayer.currentTime = 0;
        [self.backgroundMusicPlayer play];
    }else{
        [self.backgroundMusicPlayer stop];
    }
}

-(void)gameMusic:(BOOL)play
{
    if(play)
    {
        if(self.backgroundMusicPlayer.isPlaying)
        {
            [self introMusic:NO];
        }
        self.gameMusicPlayer.currentTime = 0;
        [self.gameMusicPlayer play];
    }else{
        [self.gameMusicPlayer stop];
    }
}



//-(void)showIntroScreen:(BOOL)toggle
//{
//    for (UIView* view in outlets) {
//        view.hidden = !toggle;
//    }
//}

//- (IBAction)onSoundTogglePressed:(UIButton *)sender
//{
//    muted = !muted;
//    
//    if(self.myScene != nil)
//    {
//    self.myScene.muted = muted;
//    }
//    if(muted)
//    {
//        [sender setImage:[UIImage imageNamed:@"soundOff"] forState:UIControlStateNormal];
//        if(self.backgroundMusicPlayer.isPlaying)
//            [self.backgroundMusicPlayer stop];
//        if(self.gameMusicPlayer.isPlaying)
//            [self.gameMusicPlayer stop];
//    }else{
//        [sender setImage:[UIImage imageNamed:@"soundOn"] forState:UIControlStateNormal];
//        if(self.myScene)
//        {
//            [self.gameMusicPlayer play];
//        }else{
//            [self.backgroundMusicPlayer play];
//        }
//    }
//}

//-(void)beginGame:(BOOL)continued
//{
//    [self.backgroundMusicPlayer stop];
//    self.backgroundMusicPlayer.currentTime = 0;
//    
//    if(!muted)
//        [self.gameMusicPlayer play];
//    
//    [self showIntroScreen:NO];
//    
//    SKView * skView = (SKView *)self.view;
//    if (!skView.scene) {
//        skView.showsFPS = YES;
//        skView.showsNodeCount = YES;
//        NSLog(@"%@",NSStringFromCGSize(self.view.frame.size));
//        
//        // Create and configure the scene.
//        GameScene * scene = [GameScene sceneWithSize:skView.bounds.size];
//        scene.scaleMode = SKSceneScaleModeAspectFill;
//        
//        scene.muted = muted;
//        scene.continued = continued;
//        self.myScene = scene;
//        
//        
//        // Present the scene.
//        [skView presentScene:scene];
//    }
//
//}

//- (IBAction)onNewGameButtonPressed:(id)sender
//{
//    [self beginGame:NO];
//}
//
//
//- (IBAction)onContinueButtonPressed:(id)sender
//{
//    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
//    if([userDefaults objectForKey:@"wave"])
//    {
//        [self beginGame:YES];
//    }
//}

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
