//
//  GameOverScene.m
//  SpriteKitSimpleGame
//
//  Created by Main Account on 9/4/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "GameOverScene.h"
#import "MainMenuScene.h"
#import "ViewController.h"

 
@implementation GameOverScene 
 
-(id)initWithSize:(CGSize)size won:(BOOL)won score:(int)score{
    if (self = [super initWithSize:size]) {
 
        // 1
        SKSpriteNode* bgImageNode = [SKSpriteNode spriteNodeWithImageNamed:@"introbg"];
        [bgImageNode setPosition:(CGPointMake(self.size.width/2, self.size.height/2))];
        [bgImageNode setName:@"background"];
        [self addChild:bgImageNode];
 
        SKLabelNode* title = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
        title.text = @"Objective: Seafood";
        title.fontSize = 50;
        [title setPosition:CGPointMake(self.size.width/2, self.size.height*3/4+10)];
        [self addChild:title];
        
        SKLabelNode* byLabel = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
        byLabel.text = @"by SpriteKitchen";
        byLabel.fontSize = 20;
        [byLabel setPosition:CGPointMake(self.size.width, self.size.height*3/4-title.frame.size.height/2+byLabel.frame.size.height/2)];
        byLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
        [self addChild:byLabel];
        
        // 2
        NSString * message;
        if (won) {
            message = @"Congratulations!";
        } else {
            message = @"Game Over :[";
        }
 
        // 3
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = message;
        label.fontSize = 40;
        label.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:label];
 
        // 4
        
        if([GKLocalPlayer localPlayer].isAuthenticated)
        {
            GKScore *myScore = [[GKScore alloc] initWithLeaderboardIdentifier:@"OBJSEAHIGHSCORE" forPlayer:[GKLocalPlayer localPlayer].playerID];
            
            myScore.value = score;
            
            [GKScore reportScores:@[myScore] withCompletionHandler:^(NSError *error) {
                if(error != nil)
                {
                    NSLog(@"Score Submission Failed");
                } else {
                    NSLog(@"Score Submitted");
                }
            }];
            
            [self runAction:[SKAction waitForDuration:3] completion:^{
                [self showLeaderboard:@"OBJSEAHIGHSCORE"];
            }];
            
        }else{
            [self runAction:[SKAction waitForDuration:3] completion:^{
                [self returnToMenu];
            }];
        }
    }
    return self;
}

- (void) showLeaderboard: (NSString*) leaderboardID
{
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    if (gameCenterController != nil)
    {
        gameCenterController.gameCenterDelegate = self;
        gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
        [self.view.window.rootViewController presentViewController: gameCenterController animated: YES completion:nil];
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:^{
        [self returnToMenu];
    }];
}

-(void)returnToMenu
{
    ViewController* vc = (ViewController*)self.view.window.rootViewController;
    [vc introMusic:YES];
    
    SKTransition *reveal = [SKTransition flipHorizontalWithDuration:1.0];
    MainMenuScene *menuScene = [[MainMenuScene alloc] initWithSize:self.size];
    [self.view presentScene:menuScene transition: reveal];
}

@end
