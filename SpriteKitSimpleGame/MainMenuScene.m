//
//  MainMenuScene.m
//  Obj. Seafood
//
//  Created by Andrew Webb on 2/25/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "MainMenuScene.h"
#import "GameScene.h"
#import "TutorialScene.h"
#import "CreditsScene.h"
#import "ViewController.h"

@implementation MainMenuScene

-(id)initWithSize:(CGSize)size
{
    if(self = [super initWithSize:size])
    {
        SKSpriteNode* bgImageNode = [SKSpriteNode spriteNodeWithImageNamed:@"introbg"];
        [bgImageNode setPosition:(CGPointMake(self.size.width/2, self.size.height/2))];
        [bgImageNode setName:@"background"];
        [self addChild:bgImageNode];
        
        SKLabelNode* title = [SKLabelNode labelNodeWithFontNamed:@"CarnivaleeFreakshow"];
        title.text = @"Objective: Seafood";
        title.fontSize = 50;
        [title setPosition:CGPointMake(self.size.width/2, self.size.height*3/4+10)];
        [self addChild:title];
        
        SKLabelNode* byLabel = [SKLabelNode labelNodeWithFontNamed:@"CoolveticaRg-Regular"];
        byLabel.text = @"by SpriteKitchen.com";
        byLabel.fontSize = 20;
        [byLabel setPosition:CGPointMake(self.size.width-10, self.size.height*3/4-title.frame.size.height/2+byLabel.frame.size.height/2)];
        byLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
        [self addChild:byLabel];
        
        SKShapeNode* buttonLayer = [SKShapeNode node];
        CGPathRef path = CGPathCreateWithRoundedRect(CGRectMake(0, 0, 250, 200), 20, 20, nil);
        [buttonLayer setPath:path];
        [buttonLayer setPosition:(CGPointMake(self.size.width/2-buttonLayer.frame.size.width/2, self.size.height/2-buttonLayer.frame.size.height/2-50))];
        buttonLayer.glowWidth = 5;
        buttonLayer.strokeColor = buttonLayer.fillColor = [SKColor colorWithRed:12/255.0 green:32/255.0 blue:40/255.0 alpha:.7];
        [self addChild: buttonLayer];
        
        CGPathRelease(path);
        
        SKLabelNode* newGameButton = [SKLabelNode labelNodeWithFontNamed:@"Opificio-Bold"];
        newGameButton.text = @"New Game";
        newGameButton.fontSize = 40;
        newGameButton.name = @"1";
        [newGameButton setPosition:(CGPointMake(buttonLayer.frame.size.width/2, self.size.height/2))];
        [buttonLayer addChild:newGameButton];
        
        SKLabelNode* continueButton = [SKLabelNode labelNodeWithFontNamed:@"Opificio-Bold"];
        continueButton.text = @"Continue";
        continueButton.name = @"2";
         continueButton.fontSize = 40;
        [continueButton setPosition:(CGPointMake(buttonLayer.frame.size.width/2, self.size.height/2-continueButton.frame.size.height*1.5))];
        [buttonLayer addChild:continueButton];
        
        SKLabelNode* tutorial = [SKLabelNode labelNodeWithFontNamed:@"Opificio-Bold"];
        tutorial.text = @"Tutorial";
        tutorial.name = @"3";
          tutorial.fontSize = 40;
        [tutorial setPosition:(CGPointMake(buttonLayer.frame.size.width/2, self.size.height/2-continueButton.frame.size.height*1.5-tutorial.frame.size.height*1.5))];
        [buttonLayer addChild:tutorial];
        
        SKLabelNode* credits = [SKLabelNode labelNodeWithFontNamed:@"Opificio-Bold"];
        credits.text = @"Credits";
        credits.name = @"4";
          credits.fontSize = 40;
        [credits setPosition:(CGPointMake(buttonLayer.frame.size.width/2, self.size.height/2-continueButton.frame.size.height*1.5-tutorial.frame.size.height*1.5-credits.frame.size.height*1.5))];
        [buttonLayer addChild:credits];
    }
                                 
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode* node = [self nodeAtPoint:location];
    
    int buttonPosition = node.name.intValue;
    
    ViewController* vc = (ViewController*)self.view.window.rootViewController;
    
    switch (buttonPosition) {
        case 1: //New Game
        {
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:1.0];
            GameScene * gameScene = [[GameScene alloc] initWithSize:self.size continued:NO];
            [self.view presentScene:gameScene transition: reveal];
            
            [vc gameMusic:YES];
            break;
        }
        case 2: //Continue
        {
            NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
            if([userDefaults objectForKey:@"wave"])
            {
                SKTransition *reveal = [SKTransition flipHorizontalWithDuration:1.0];
                GameScene * gameScene = [[GameScene alloc] initWithSize:self.size continued:YES];
                
                [self.view presentScene:gameScene transition: reveal];
                
                [vc gameMusic:YES];
            }
            
            break;
        }
        case 3: //Tutorial
        {
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:1.0];
            TutorialScene * tutorialScene = [[TutorialScene alloc] initWithSize:self.size];
            [self.view presentScene:tutorialScene transition: reveal];
            break;
        }
        case 4: //Credits
        {
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:1.0];
            CreditsScene *creditsScene = [[CreditsScene alloc] initWithSize:self.size];
            [self.view presentScene:creditsScene transition: reveal];
            break;
        }
        default:
            break;
    }
   
}


@end
