//
//  Skirmisher.m
//  Avast
//
//  Created by Andrew Webb on 2/21/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "Skirmisher.h"

@implementation Skirmisher

+ (Skirmisher*)monster
{
    Skirmisher* skirmisher = [Skirmisher spriteNodeWithImageNamed:@"fish"];
    skirmisher.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:skirmisher.size];
    skirmisher.baseSpeed = 2;
    skirmisher.damage = 1;
    skirmisher.ScoreValue = 10;
    skirmisher.health = 2;
    skirmisher = (Skirmisher*)[super setMonsterProperties:skirmisher];
    skirmisher.goldValue = 6;
    
    return skirmisher;
}

@end
