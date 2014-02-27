//
//  TutorialScene.m
//  Obj. Seafood
//
//  Created by Andrew Webb on 2/26/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "TutorialScene.h"
#import "TutorialScreenTwo.h"

@implementation TutorialScene

-(id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    
    _background = [SKSpriteNode spriteNodeWithImageNamed:@"tutorialScreenOne.png"];
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
        TutorialScreenTwo *screenTwo = [[TutorialScreenTwo alloc] initWithSize:self.size];
        [self.view presentScene:screenTwo transition: reveal];
    }
}


@end
