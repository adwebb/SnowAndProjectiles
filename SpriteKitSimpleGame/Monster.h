//
//  Monster.h
//  SnowAndProjectiles
//
//  Created by Fletcher Rhoads on 2/13/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Monster : SKSpriteNode

@property float health;
@property float baseSpeed;
@property int goldValue;
@property int damage;
@property int ScoreValue;

+ (Monster*)setMonsterProperties:(Monster*)monster;

@end
