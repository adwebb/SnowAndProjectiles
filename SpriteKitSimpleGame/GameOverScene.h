//
//  GameOverScene.h
//  SpriteKitSimpleGame
//
//  Created by Main Account on 9/4/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@import GameKit;

@interface GameOverScene : SKScene <GKGameCenterControllerDelegate>
 
-(id)initWithSize:(CGSize)size won:(BOOL)won score:(int)score;
 
@end
