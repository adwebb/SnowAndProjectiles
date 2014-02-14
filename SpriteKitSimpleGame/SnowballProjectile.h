//
//  SnowBall.h
//  SnowAndProjectiles
//
//  Created by Fletcher Rhoads on 2/13/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "Projectile.h"

@interface SnowballProjectile : Projectile

@property float damage;

+ (SnowballProjectile*)makeSnowballProjectile;

@end
