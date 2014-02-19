//
//  IceProjectile.m
//  SnowAndProjectiles
//
//  Created by Andrew Webb on 2/18/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "IceProjectile.h"

@implementation IceProjectile

+(IceProjectile*)iceProjectileOfRank:(int)rank inScene:(SKScene*)scene
{
    IceProjectile* iceProjectile = [IceProjectile spriteNodeWithImageNamed:@"snowball"];
    iceProjectile.color = [SKColor colorWithRed:0 green:144/255.0 blue:1 alpha:1];
    iceProjectile.colorBlendFactor = .5;
    iceProjectile.potency = rank;
    iceProjectile.damage = rank;
    iceProjectile = (IceProjectile*)[super setProjectileProperties:iceProjectile];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"iceball" ofType:@"sks"];
    SKEmitterNode* iceEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    iceEmitter.targetNode = scene;
    [iceProjectile addChild:iceEmitter];

    
    return iceProjectile;
}

@end
