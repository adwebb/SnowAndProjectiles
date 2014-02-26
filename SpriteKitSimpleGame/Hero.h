//
//  Hero2.h
//  SnowAndProjectiles
//
//  Created by Fletcher Rhoads on 2/17/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Hero : SKSpriteNode
+(Hero*)spawnHero;
@property int health;

@end
