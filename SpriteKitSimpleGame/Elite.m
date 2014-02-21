//
//  Elite.m
//  Avast
//
//  Created by Andrew Webb on 2/21/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "Elite.h"

@implementation Elite

+ (Elite*)monster
{
    Elite* elite = [Elite spriteNodeWithImageNamed:@"crab"];
    elite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:elite.size];
    elite.baseSpeed = 1;
    elite.damage = 5;
    elite.ScoreValue = 20;
    elite.health = 5;
    elite = (Elite*)[super setMonsterProperties:elite];
    elite.goldValue = 25;
    
    return elite;
}

@end
