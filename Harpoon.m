//
//  SnowballProjectile.m
//  SnowAndProjectiles
//
//  Created by Fletcher Rhoads on 2/17/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "Harpoon.h"

@implementation Harpoon

+ (Harpoon*)projectile
{
    Harpoon* projectile = [Harpoon spriteNodeWithImageNamed:@"harpoon_arrow.png"];
    projectile.damage = 1;
    projectile = (Harpoon*)[super setProjectileProperties:projectile];
    
    
 //   snowballProjectile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:snowballProjectile.frame.size];
    
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    //[snowballProjectile.physicsBody applyAngularImpulse:45];
    
    
    return projectile;
}

@end
