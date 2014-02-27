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
    [self addChild:_background];

    
    [self showCreditText];
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];

    if(touch)
    {
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:1.0];
        MainMenuScene *mainMenuScene = [[MainMenuScene alloc] initWithSize:self.size];
        [self.view presentScene:mainMenuScene transition: reveal];
    }
}

- (void)showCreditText
{
    SKLabelNode* creditTextLabel = [[SKLabelNode alloc]init];
    creditTextLabel = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
    creditTextLabel.fontColor = [SKColor blackColor];
    creditTextLabel.fontSize = 18.0f;
    creditTextLabel.text = @"Objective: Seafood designed by SpriteKitchen";
    creditTextLabel.position = CGPointMake(self.size.width/2, self.size.height/2);

    [self addChild:creditTextLabel];
}

@end
