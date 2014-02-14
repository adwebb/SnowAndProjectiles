//
//  Projectile.m
//  SnowAndProjectiles
//
//  Created by Fletcher Rhoads on 2/13/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "Projectile.h"

@implementation Projectile


- (Projectile*)makeProjectile
{
    Projectile* projectile = [Projectile new];
    projectile.physicsBody.affectedByGravity = NO;
    projectile.alpha = 1;
    
    return projectile;
}

@end
