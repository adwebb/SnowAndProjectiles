//
//  CreditsScene.m
//  Obj. Seafood
//
//  Created by Andrew Webb on 2/26/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "CreditsScene.h"
#import "MainMenuScene.h"

@implementation CreditsScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
         NSLog(@"Size: %@", NSStringFromCGSize(size));
    
    _background = [SKSpriteNode spriteNodeWithImageNamed:@"backgroundScene.png"];
    [_background setName:@"background"];
    [_background setPosition:(CGPointMake(self.size.width/2, self.size.height/2))];
    SKAction* greyOutBackground = [SKAction colorizeWithColor:[UIColor lightGrayColor] colorBlendFactor:1 duration:0];
    [_background runAction:greyOutBackground];
    [self addChild:_background];

    
    [self showCreditText];
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode* node = [self nodeAtPoint:location];

    
    if([node.name hasSuffix:@"labelFive"])
    {
       [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.spritekitchen.com"]];
    }
    else if(touch)
    {
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:1.0];
        MainMenuScene *mainMenuScene = [[MainMenuScene alloc] initWithSize:self.size];
        [self.view presentScene:mainMenuScene transition: reveal];
    }
}

- (void)showCreditText
{
    SKLabelNode* creditTextLabelOne = [[SKLabelNode alloc]init];
    creditTextLabelOne = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
    creditTextLabelOne.fontColor = [SKColor whiteColor];
    creditTextLabelOne.fontSize = 18.0f;
    creditTextLabelOne.text = @"Objective: Seafood";
    creditTextLabelOne.position = CGPointMake(self.size.width/2, self.size.height/1.7);

    
    SKLabelNode* creditTextLabelTwo = [[SKLabelNode alloc]init];
    creditTextLabelTwo = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
    creditTextLabelTwo.fontColor = [SKColor whiteColor];
    creditTextLabelTwo.fontSize = 18.0f;
    creditTextLabelTwo.text = @"Designed by SpriteKitchen";
    creditTextLabelTwo.position = CGPointMake(self.size.width/2, creditTextLabelOne.position.y - 30);
    //creditTextLabelTwo.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    
    SKLabelNode* creditTextLabelThree = [[SKLabelNode alloc]init];
    creditTextLabelThree = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
    creditTextLabelThree.fontColor = [SKColor whiteColor];
    creditTextLabelThree.fontSize = 18.0f;
    creditTextLabelThree.text = @"Art by Joe Call";
    creditTextLabelThree.position = CGPointMake(self.size.width/2, creditTextLabelTwo.position.y - 30);
    
    SKLabelNode* creditTextLabelFour = [[SKLabelNode alloc]init];
    creditTextLabelFour = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
    creditTextLabelFour.fontColor = [SKColor whiteColor];
    creditTextLabelFour.fontSize = 18.0f;
    creditTextLabelFour.text = @"Music from Audionautix.com";
    creditTextLabelFour.position = CGPointMake(self.size.width/2, creditTextLabelThree.position.y - 30);
    
    SKLabelNode* creditTextLabelFive = [[SKLabelNode alloc]init];
    creditTextLabelFive = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
    creditTextLabelFive.fontColor = [SKColor blueColor];
    creditTextLabelFive.fontSize = 18.0f;
    creditTextLabelFive.text = @"Visit us at SpriteKitchen.com";
    creditTextLabelFive.name = @"labelFive";
    creditTextLabelFive.position = CGPointMake(self.size.width/2, creditTextLabelFour.position.y - 90);

    [self addChild:creditTextLabelOne];
    [self addChild:creditTextLabelTwo];
    [self addChild:creditTextLabelThree];
    [self addChild:creditTextLabelFour];
    [self addChild:creditTextLabelFive];
}

@end
