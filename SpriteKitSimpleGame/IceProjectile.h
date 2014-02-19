//
//  IceProjectile.h
//  SnowAndProjectiles
//
//  Created by Andrew Webb on 2/18/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "Projectile.h"

@interface IceProjectile : Projectile
@property int potency;
+(IceProjectile*)iceProjectileOfRank:(int)rank inScene:(SKScene*)scene;
@end
