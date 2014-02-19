//
//  FireProjectile.h
//  SnowAndProjectiles
//
//  Created by Andrew Webb on 2/18/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "Projectile.h"

@interface FireProjectile : Projectile

+(FireProjectile*)fireProjectileOfRank:(int)rank inScene:(SKScene*)scene;

@end
