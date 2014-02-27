//
//  TutorialScreenTwo.m
//  Obj. Seafood
//
//  Created by Fletcher Rhoads on 2/27/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "TutorialScreenTwo.h"
#import "MainMenuScene.h"

@implementation TutorialScreenTwo

-(id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    
    _background = [SKSpriteNode spriteNodeWithImageNamed:@"tutorialScreenTwo.png"];
    [_background setName:@"screenOne"];
    [_background setPosition:(CGPointMake(self.size.width/2, self.size.height/2))];
    
    [self addChild:_background];
    
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


@end
