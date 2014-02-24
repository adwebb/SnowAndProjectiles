//
//  MyScene.m
//  SpriteKitSimpleGame
//
//  Created by Main Account on 9/4/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "MyScene.h"
#import "GameOverScene.h"
#import "Monster.h"
#import "SnowmanMonster.h"
#import "YetiMonster.h"
#import "Skirmisher.h"
#import "Elite.h"
#import "Boss.h"
#import "Hero.h"
#import "Projectile.h"
#import "SnowballProjectile.h"
#import "DragonMonster.h"
#import "FireProjectile.h"
#import "IceProjectile.h"
#import "SplitProjectile.h"


static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;
static const uint32_t heroCategory           =  0x11;

typedef NS_ENUM(int32_t, PCGameState)
{
    PCGameStateStartingLevel,
    PCGameStatePlaying,
    PCGameStateInLevelMenu,
    PCGameStateInReloadMenu,
};

typedef enum {
    untyped,
    split,
    fire,
    ice
} ProjectileType;

typedef enum {
    minion = 1,
    brute = 2,
    soldier = 3,
    skirmisher = 4,
    elite = 5,
    boss = 6
}monsterType;

@interface MyScene () <SKPhysicsContactDelegate, UIGestureRecognizerDelegate>
{
    Hero* hero;
    
    UIPanGestureRecognizer* panGestureRecognizer;
    CGPoint projectileSpawnPoint;
    
    SKLabelNode *_playerHealthLabel;
    NSString    *_healthBar;
    SKAction    *_scoreFlashAction;
    SKAction    *_gameOverPulse;
    SKLabelNode *_gameOverLabel;
    SKNode      *_hudLayerNode;
    SKLabelNode *_tapScreenLabel;
    SKLabelNode* currencyLabel;
    SKSpriteNode* pauseButton;
    SKSpriteNode* upgradeArrow;
    SKLabelNode* waveComplete;
    ProjectileType projectileType;
    
    int _score;
    SKLabelNode *scoreLabel;
    int _gameState;
    
    NSMutableArray* monstersForWave;
    
    BOOL upgradeMode;
}

@property (nonatomic) int monstersDestroyed;
@property (nonatomic) Projectile* projectile;
@property (nonatomic) int currency;
@property (nonatomic) int wave;
@property (nonatomic) NSMutableDictionary* upgrades;
@property (nonatomic) SKNode* monsterLayer;

@end

static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

static inline CGPoint rwInvert(CGPoint point)
{
    return CGPointMake(-point.x, -point.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

@implementation MyScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        
        [self setupUI];
        [self upgrades];
    }
    return self;
}

- (void)spawnProjectileOfType:(ProjectileType)type
{
    [self.projectile removeFromParent];
    switch (type) {
        case untyped:
            self.projectile = [SnowballProjectile snowballProjectile];
            break;
        case fire:
        {
            self.projectile = [FireProjectile fireProjectileOfRank:[[_upgrades objectForKey:@"fire"]integerValue] inScene:self];
            break;
        }
        case ice:
            self.projectile = [IceProjectile iceProjectileOfRank:[[_upgrades objectForKey:@"ice"]integerValue] inScene:self];
            break;
        case split:
            self.projectile = [SplitProjectile splitProjectileOfRank:[[_upgrades objectForKey:@"split"]integerValue] + 1];
            break;
        default:
            break;
    }
    self.projectile.position = projectileSpawnPoint;

    
    [self addChild:self.projectile];
}

- (void)didMoveToView:(SKView *)view
{
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [[self view] addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.delegate = self;
    
    if(_continued)
    {
        [self load];
    }else
    {
        _score = 0;
        _currency = 0;
        [self advanceToWave:1];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode* node = [self nodeAtPoint:location];
    
    if (_gameState == GameOver)
    {
        
        [self restartGame];
    }
    
    if([node.name hasSuffix:@"Button"])
    {
        if ([node.name isEqualToString:@"IceButton"])
        {
            if (upgradeMode == YES)
            {
                [self upgradeProjectile:ice];
            }
            if ([[_upgrades objectForKey:@"ice"] integerValue] > 0)
            {
                projectileType = ice;
            }
        }
        else if (([node.name isEqualToString:@"FireButton"] && [[_upgrades objectForKey:@"fire"] integerValue] > 0) || upgradeMode == YES)
        {
            if (upgradeMode == YES)
            {
                [self upgradeProjectile:fire];
            }
            if ([[_upgrades objectForKey:@"fire"] integerValue] > 0)
            {
                projectileType = fire;
            }
        }
        else if (([node.name isEqualToString:@"SplitButton"] && [[_upgrades objectForKey:@"split"] integerValue] > 0) || upgradeMode == YES)
        {
            if (upgradeMode == YES)
            {
                [self upgradeProjectile:split];
            }
            if ([[_upgrades objectForKey:@"split"] integerValue] > 0)
            {
                projectileType = split;
            }
        }
    }
    [self spawnProjectileOfType: projectileType];
    
    if ([node.name isEqualToString:@"PauseButton"])
    {
        if (self.view.scene.paused == NO)
        {
            self.view.scene.paused = YES;
            [pauseButton setTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"play"]]];
        }
        else
        {
            self.view.scene.paused = NO;
            [pauseButton setTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"pause"]]];
        }
    }
    if ([node.name isEqualToString:@"upgradeArrow"])
    {
        upgradeMode = YES;
        
//        if ([node.name isEqualToString:@"IceButton"] && upgradeMode == YES)
//        {
//            if ([node.name isEqualToString:@"FireButton"])
//            {
//                NSInteger currentLevel = [[_upgrades objectForKey:@"fire"] integerValue];
//                currentLevel += 1;
//                
//                if (currentLevel == 1)
//                {
//                    self.currency -= 50;
//                }
//                else if (currentLevel == 2)
//                {
//                    self.currency -= 100;
//                }
//                else if (currentLevel == 3)
//                {
//                    self.currency -= 250;
//                }
//                
//                [_upgrades setObject:[NSNumber numberWithInt:currentLevel] forKey:@"fire"];
//                
//                upgradeArrow.hidden = YES;
//            }
//            else if ([node.name isEqualToString:@"SplitButton"])
//            {
//                NSInteger currentLevel = [[_upgrades objectForKey:@"split"] integerValue];
//                currentLevel += 1;
//                
//                if (currentLevel == 1)
//                {
//                    self.currency -= 50;
//                }
//                else if (currentLevel == 2)
//                {
//                    self.currency -= 100;
//                }
//                else if (currentLevel == 3)
//                {
//                    self.currency -= 250;
//                }
//                
//                [_upgrades setObject:[NSNumber numberWithInt:currentLevel] forKey:@"split"];
//                
//                upgradeArrow.hidden = YES;
//                
//            }
//            [self spawnProjectileOfType: projectileType];
//        }
    }
}

-(void)upgradeProjectile:(ProjectileType)type
{
    NSString* typeString;
    
    switch (type)
    {
        case fire:
            typeString = @"fire";
            break;
        case ice:
            typeString = @"ice";
            break;
        case split:
            typeString = @"split";
        default:
            break;
    }
    
    NSInteger currentLevel = [[_upgrades objectForKey:typeString] integerValue];
    currentLevel += 1;
    
    if (currentLevel == 1)
    {
        self.currency -= 50;
    }
    else if (currentLevel == 2)
    {
        self.currency -= 100;
    }
    else if (currentLevel == 3)
    {
        self.currency -= 250;
    }
    
    [_upgrades setObject:[NSNumber numberWithInt:currentLevel] forKey:typeString];
    
    upgradeMode = NO;
    upgradeArrow.hidden = YES;
    NSLog(@"%@ level %@",typeString, [_upgrades objectForKey:typeString]);
}

- (NSMutableDictionary*)upgrades
{
    if (!_upgrades)
    {
        _upgrades = [NSMutableDictionary new];
    }
    _upgrades = [@{@"fire": @0, @"ice": @0, @"split": @0} mutableCopy];
    
    return _upgrades;
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer
{
	if(self.projectile.physicsBody.affectedByGravity == NO)
    {
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [self convertPointFromView:touchLocation];
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            [self selectNodeForTouch:touchLocation];
        } else if (recognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint translation = [recognizer translationInView:recognizer.view];
            translation = CGPointMake(translation.x, -translation.y);
            [self panForTranslation:translation fromStartPoint:touchLocation];
            [recognizer setTranslation:CGPointZero inView:recognizer.view];
            
        } else if (recognizer.state == UIGestureRecognizerStateEnded) {
            
            if ([[_selectedNode name] isEqualToString:movableNodeName]) {
                
                CGPoint location = self.projectile.position;
                CGPoint offset = rwSub(location, projectileSpawnPoint);
                
                // Bail out if you are shooting down or backwards
                if (offset.x >= 0) return;
                
                // Get the direction of where to shoot
                CGPoint direction = rwNormalize(offset);
                CGPoint launchDirection = rwInvert(direction);
                float force = rwLength(offset);
                CGPoint multiplied = rwMult(launchDirection, force/3);
                CGVector launcher = CGVectorMake(multiplied.x, multiplied.y);
                
                [self launchProjectileWithImpulse:launcher];
            }
        }
    }
}

-(void)launchProjectileWithImpulse:(CGVector)vector
{
    self.projectile.physicsBody.dynamic = YES;
    self.projectile.physicsBody.affectedByGravity = YES;
    
    if(projectileType == split)
    {
        [self.projectile removeAllActions];
        NSLog(@"split");
        for (SplitProjectile* projectile in self.projectile.children) {
            int xVariance = arc4random()%5+1;
            int sign = arc4random()%2;
            
            projectile.physicsBody.dynamic = YES;
            projectile.physicsBody.affectedByGravity = YES;
           
            if(sign == 0)
            {
                [projectile.physicsBody applyImpulse:CGVectorMake((vector.dx-xVariance)/12, vector.dy/12)];
            }
            else
            {
                [projectile.physicsBody applyImpulse:CGVectorMake((vector.dx+xVariance)/12, vector.dy/12)];
            }
        }
    }
    else
    {
       [self.projectile.physicsBody applyImpulse:vector];
    }
}

- (void)panForTranslation:(CGPoint)translation fromStartPoint:(CGPoint)point
{
    if([self isWithinSlingshotDragArea:point])
    {
        CGPoint position = self.projectile.position;
        CGPoint newPosition = CGPointMake(position.x + translation.x, position.y + translation.y);
        if([self isWithinSlingshotDragArea:newPosition]) {
            [self.projectile setPosition:newPosition];
        }
    }
}

- (void)selectNodeForTouch:(CGPoint)touchLocation
{
    if([self isWithinSlingshotDragArea:touchLocation])
    {
        SKAction *sequence = [SKAction sequence:@[[SKAction rotateByAngle:degToRad(-4.0f) duration:0.1],
                                                  [SKAction rotateByAngle:0.0 duration:0.1],
                                                  [SKAction rotateByAngle:degToRad(4.0f) duration:0.1]]];

    [self.projectile runAction:[SKAction repeatActionForever:sequence]];
        _selectedNode = self.projectile;
    }
}

-(BOOL)isWithinSlingshotDragArea:(CGPoint)point
{
    if(point.x < projectileSpawnPoint.x)
    {
        return YES;
    }
    return NO;
}

float degToRad(float degree)
{
	return degree / 180.0f * M_PI;
}

- (void)addMonsterOfType:(monsterType)type
{
    Monster* monster;
    
    switch (type) {
        case minion:
            monster = [SnowmanMonster monster];
            break;
        case brute:
            monster = [YetiMonster monster];
            break;
        case soldier:
            monster = [DragonMonster monster];
            break;
        case skirmisher:
            monster = [Skirmisher monster];
            break;
        case elite:
            monster = [Elite monster];
            break;
        case boss:
            monster = [Boss monster];
        default:
            break;
    }
    // Determine where to spawn the monster along the Y axis
    // monster.position = CGPointMake(self.frame.size.width - monster.size.width/2, self.frame.size.height/2);
    monster.position = CGPointMake(self.frame.size.width - monster.size.width/2, self.frame.size.height/2);
    
    NSValue *value = [NSValue valueWithCGPoint:monster.position];
    
    [self.monsterLayer addChild:monster];
    
    // Create the actions
    SKAction * actionMove = [SKAction followPath:[self generateCurvePath:@[value]] asOffset:YES orientToPath:NO duration:5.0];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    
    [monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]withKey:@"path"];
}

-(CGMutablePathRef)generateCurvePath:(NSArray*)coordinates
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, Nil, 0, 0);
    CGPathAddCurveToPoint(path, nil, -100, 100, -200, -100, -560, -50);
    
    return path;
}

-(void)initializeMonsterWave:(int)wave
{
    monstersForWave = [NSMutableArray new];
    
    switch (wave) {
        case 1:
        {
            monstersForWave = @[@1, @1, @1, @1, @1, @1, @1, @2, @2, @2].mutableCopy;
            break;
        }
        case 2:
        {
            monstersForWave = @[@1, @1, @1, @1, @1, @1, @1, @2, @2, @2,
                                @4, @4, @4, @4, @4, @4, @3, @3, @3, @3].mutableCopy;
            break;
        }
        case 3:
        {
            monstersForWave = @[@1, @1, @1, @1, @1, @1, @1, @1, @1, @2,
                                @2, @2, @2, @2, @3, @3, @3, @3, @3, @4,
                                @4, @4, @4, @4, @4, @4, @4, @4, @5, @5].mutableCopy;
            break;
        }
        case 4:
        {
            monstersForWave = @[@1, @1, @1, @1, @1, @1, @1, @1, @1, @1,
                                @2, @2, @2, @2, @2, @2, @2, @2, @2, @2,
                                @4, @4, @4, @4, @4, @4, @4, @4, @4, @4,
                                @3, @3, @3, @3, @3, @5, @5, @5, @5, @5].mutableCopy;
            break;
        }
        case 5:
        {
            monstersForWave = @[@2, @2, @2, @2, @2, @2, @2, @2, @2, @2,
                                @2, @2, @2, @2, @2, @2, @2, @2, @2, @2,
                                @4, @4, @4, @4, @4, @4, @4, @4, @4, @4,
                                @3, @3, @3, @3, @3, @3, @3, @3, @3, @3,
                                @5, @5, @5, @5, @5, @5, @5, @5, @5, @5].mutableCopy;
            break;
        }
        case 6:
        {
            monstersForWave = @[@6].mutableCopy;
            break;
        }
            
        default:
            break;
    }
}

-(void)spawnMonsters
{
    SKAction* addMonster = [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        int randomMonsterFromArray = arc4random()%monstersForWave.count;
        monsterType type = ((NSNumber*)monstersForWave[randomMonsterFromArray]).intValue;
        [self addMonsterOfType:type];
        [monstersForWave removeObjectAtIndex:randomMonsterFromArray];
    }];
    
    //If we want to add in difficulty levels, the below waitForDuration is a great place to do so. It controls
    //monster-spawn spacing. Current timing may be too hard to be considered "normal".
    
    SKAction* pauseAndAdd = [SKAction sequence:@[[SKAction waitForDuration:2 withRange:1], addMonster]];
    
        SKAction *sq = [SKAction sequence:@[[SKAction repeatAction:pauseAndAdd count:monstersForWave.count],[SKAction waitForDuration:5], [SKAction performSelector:@selector(waveComplete) onTarget:self]]];
    
    [self.monsterLayer runAction:sq];
    
  
}

-(void)waveComplete
{
    if(self.wave <= 5)
    {
        waveComplete = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        waveComplete.position = CGPointMake(self.size.width/2, self.size.height/2);
        waveComplete.fontSize = 20;
        waveComplete.fontColor = [SKColor whiteColor];
        waveComplete.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        waveComplete.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        waveComplete.text = [NSString stringWithFormat:@"Wave %d Complete!",self.wave];
        [self addChild:waveComplete];
        self.wave++;
        [self save];
        [self advanceToWave:self.wave];
    }
    
}

-(void)advanceToWave:(int)waveNumber
{
    self.wave = waveNumber;
    [self initializeMonsterWave:self.wave];
    
    
    [self runAction:[SKAction waitForDuration:3] completion:^{
      if (GameRunning){

        waveComplete.text = [NSString stringWithFormat:@"Prepare yourself! Wave %d Incoming!",self.wave];
        }
        [self runAction:[SKAction waitForDuration:3] completion:^{
            [waveComplete removeFromParent];
            [self spawnMonsters];
        }];
    }];
    
}


- (void)update:(NSTimeInterval)currentTime
{
    switch (_gameState)
    {
        case GameRunning:
            
            // Update the healthbar color and length based on the...urm...players health :)
            _playerHealthLabel.text = [_healthBar substringToIndex:(hero.health / 10 * _healthBar.length)];
            currencyLabel.text = [NSString stringWithFormat:@"%d",self.currency];
            
            for (NSArray* value in [_upgrades allValues])
            {
                NSArray* value = [_upgrades allValues];

                if ([value containsObject:[NSNumber numberWithInt:0]] && self.currency >= 50)
                {
                    upgradeArrow.hidden = NO;
                }
                else if ([value containsObject:[NSNumber numberWithInt:1]] && self.currency >= 100)
                {
                    upgradeArrow.hidden = NO;
                }
                else if ([value containsObject:[NSNumber numberWithInt:2]] && self.currency >= 250)
                {
                    upgradeArrow.hidden = NO;
                }
                else
                {
                    upgradeArrow.hidden = YES;
                }
            }
    
//            if (([_upgrades allValues]) && self.currency >= 50)
//            {
//                upgradeArrow.hidden = NO;
//            }
            // If the players health has dropped to <= 0 then set the game state to game over
            if (hero.health <= 0) {
                _gameState = GameOver;
                break;
            }
            
            if(self.projectile.position.x > self.size.width || -self.projectile.position.y > self.size.height)
            {
                [self.projectile removeFromParent];
            }
            
            if(projectileType == split)
            {
                for (Projectile* projectile in self.projectile.children)
                {
                    if(projectile.position.x > self.size.width || -projectile.position.y > self.size.height)
                    {
                        [projectile removeFromParent];
                    }
                }
                if(self.projectile.children.count <= 0)
                {
                    [self.projectile removeFromParent];
                }
            }
            
            if(![self.children containsObject:self.projectile])
            {
                [self spawnProjectileOfType: projectileType];
            }
            
            break;
        case GameOver:
        {
            // If the game over message has not been added to the scene yet then add it
            if (!_gameOverLabel.parent)
            {
                [hero removeFromParent];
                [_monsterLayer removeFromParent];

                
                [_hudLayerNode addChild:_gameOverLabel];
                [_hudLayerNode addChild:_tapScreenLabel];
                [_tapScreenLabel runAction:_gameOverPulse];
                
                SKColor *newColor = [SKColor colorWithRed:drand48() green:drand48() blue:drand48() alpha:1.0];
                _gameOverLabel.fontColor = newColor;
            }
            break;
        }
        default:
            NSLog(@"default case");
            break;
    }
}

- (void)monster:(Monster*)monster didCollideWithHero:(Hero*)ourHero
{
    ourHero.health--;
    NSLog(@"ouch! I have %f life!", ourHero.health);
    [hero runAction:[self onHitColoration]];
    [monster removeFromParent];
}
    
- (SKAction *)onHitColoration
{
    SKAction* stutter = [SKAction waitForDuration:.15];
    SKAction* reColor = [SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:1.0 duration:0];
    SKAction* deColor = [SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:0.0 duration:0];
    
    return [SKAction sequence:@[reColor,stutter,deColor]];
}

- (void)projectile:(Projectile *)projectile didCollideWithMonster:(Monster *)monster
{
    monster.health = monster.health - projectile.damage;
    NSLog(@"Hit");
    [self increaseScoreBy:10];
    
    if(!self.muted)
    {
        if (projectileType == fire)
        {
            [self runAction:[SKAction playSoundFileNamed:@"fireExplosion.wav" waitForCompletion:NO]];
            [monster runAction:[self onHitColoration]];
        }
        else if (projectileType == ice)
        {
            [self runAction:[SKAction playSoundFileNamed:@"iceHit.wav" waitForCompletion:NO]];
            SKAction* stutter = [SKAction waitForDuration:.4];
            SKAction* reColor = [SKAction colorizeWithColor:[UIColor blueColor] colorBlendFactor:1.0 duration:0];
            SKAction* deColor = [SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:0.0 duration:0];
            [monster runAction:[SKAction sequence:@[reColor, stutter, deColor]]];
        }
    }
    //[monster runAction:[self onHitColoration]];
    
    if (monster.health <= 0)
    {
        [self killedMonster:monster];
    }
    else if (projectileType == ice)
    {
        [monster runAction:[SKAction sequence:@[[SKAction speedTo:monster.baseSpeed/([[_upgrades objectForKey:@"ice"]integerValue] +2) duration:0],[SKAction waitForDuration:.5], [SKAction speedTo:monster.baseSpeed duration:2]]]];
    }
    [projectile removeFromParent];
    
    self.monstersDestroyed++;

}

-(void)killedMonster:(Monster*)monster
{
    monster.physicsBody.contactTestBitMask = 0x0;
    monster.physicsBody.categoryBitMask = 0x0;
    monster.speed = 1;
    [monster removeActionForKey:@"path"];
    
    [self increaseScoreBy:monster.ScoreValue];
    
    if (projectileType == fire)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"FireDeath" ofType:@"sks"];
        SKEmitterNode* explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        [monster addChild:explosion];
    }
    else
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SnowSplosion" ofType:@"sks"];
        SKEmitterNode* explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        [monster addChild:explosion];
    }
   
    SKAction* wait = [SKAction waitForDuration:.5];
    SKAction* remove = [SKAction removeFromParent];
    SKAction* fadeOut = [SKAction fadeOutWithDuration:.5];
    SKAction* burnOut = [SKAction colorizeWithColor:[UIColor blackColor] colorBlendFactor:0.8f duration:0.8f];
    [monster runAction:burnOut];
    [monster runAction:[SKAction sequence:@[fadeOut, wait, remove]]];
    
    SKNode* coinNode = [SKNode new];
    [self addChild:coinNode];
    
    SKSpriteNode* coin = [SKSpriteNode spriteNodeWithImageNamed:@"coin"];
    coin.position = CGPointMake(monster.position.x, monster.position.y+monster.size.height/2);
    [coinNode addChild:coin];
    
    SKLabelNode* gold = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
    gold.text = [NSString stringWithFormat:@"%d",monster.goldValue];
    gold.fontSize = 15.0;
    gold.fontColor = [UIColor colorWithRed:1 green:192/255.0 blue:0 alpha:1];
    gold.position = CGPointMake(coin.position.x+coin.size.width*1.2, coin.position.y-5);
    [coinNode addChild:gold];
    
    [coinNode runAction:[SKAction waitForDuration:.4] completion:^{
        [coinNode removeFromParent];
    }];
    
    self.currency += monster.goldValue;
    self.monstersDestroyed++;
    
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
        SKPhysicsBody *firstBody, *secondBody;
        
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }else if (contact.bodyA.categoryBitMask == contact.bodyB.categoryBitMask)
    {
        if(contact.bodyA.node.position.x < contact.bodyB.node.position.x)
        {
            firstBody = contact.bodyA;
            secondBody = contact.bodyB;
        }
    }else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if (firstBody.categoryBitMask == monsterCategory && secondBody.categoryBitMask == heroCategory)
    {
        [self monster:(Monster*)firstBody.node didCollideWithHero:(Hero*)secondBody.node];
    }
    else if (firstBody.categoryBitMask == projectileCategory && secondBody.categoryBitMask == monsterCategory)
    {
        [self projectile:(Projectile *) firstBody.node didCollideWithMonster:(Monster *) secondBody.node];
    }else if (firstBody.categoryBitMask == monsterCategory && secondBody.categoryBitMask == monsterCategory)
    {
        float baseSpeed = ((Monster*)secondBody.node).baseSpeed;
        
        [secondBody.node runAction:[SKAction sequence:@[[SKAction speedTo:.01 duration:0],[SKAction waitForDuration:.01], [SKAction speedTo:baseSpeed duration:2]]]];
    }
}

- (void)setupUI
{
    
    [self removeAllChildren];
    
    _background = [SKSpriteNode spriteNodeWithImageNamed:@"bg.jpg"];
    [_background setName:@"background"];
    [_background setAnchorPoint:CGPointZero];
    [self addChild:_background];
    
    _hudLayerNode = [SKNode node];
    [self addChild:_hudLayerNode];
    
    
    self.monsterLayer = [SKNode node];
    [self addChild:self.monsterLayer];
    
  //  NSLog(@"Size: %@", NSStringFromCGSize(self.size));
    hero = [Hero spawnHero];
    hero.position = CGPointMake(hero.size.width*2, self.frame.size.height*2/5);
    [self addChild:hero];
    
    projectileSpawnPoint = CGPointMake(hero.size.width*2, self.frame.size.height*2/5+hero.size.height/2);
    
    NSString *snowPath = [[NSBundle mainBundle] pathForResource:@"backgroundSnow" ofType:@"sks"];
    SKEmitterNode* snowEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:snowPath];
    snowEmitter.position = CGPointMake(self.frame.size.width/2, self.frame.size.height+10);
    [_background addChild:snowEmitter];
    
    self.physicsWorld.gravity = CGVectorMake(0,-5);
    self.physicsWorld.contactDelegate = self;
    
    self.currency = 0;

        [[_hudLayerNode childNodeWithName:@"scoreLabel"] removeFromParent];
        [[_hudLayerNode childNodeWithName:@"coinStack"] removeFromParent];
        [[_hudLayerNode childNodeWithName:@"currencyLabel"] removeFromParent];
    
        int barHeight = 35;
        CGSize backgroundSize = CGSizeMake(self.size.width, barHeight);
        
        SKColor *backgroundColor = [SKColor colorWithRed:0 green:0 blue:0.05 alpha:.5];
        SKSpriteNode *hudBarBackground = [SKSpriteNode spriteNodeWithColor:backgroundColor size:backgroundSize];
        hudBarBackground.position = CGPointMake(0, self.size.height - barHeight);
        hudBarBackground.anchorPoint = CGPointZero;
        [_hudLayerNode addChild:hudBarBackground];
        
        // 1
        scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
        
        // 2
        scoreLabel.fontSize = 20.0;
        scoreLabel.text = @"Score: 0";
        scoreLabel.name = @"scoreLabel";
        // 3
        scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        // 4
        scoreLabel.position = CGPointMake(self.size.width / 2, self.size.height - scoreLabel.frame.size.height + 3);
        // 5
        [_hudLayerNode addChild:scoreLabel];
        
        // 1
        _healthBar = @"❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️";
//        float testHealth = 7;
//        NSString * actualHealth = [_healthBar substringToIndex:(testHealth / 10 * _healthBar.length)];
    
        // 2
        SKLabelNode *playerHealthBackground = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
        playerHealthBackground.name = @"playerHealthBackground";
        playerHealthBackground.color = [SKColor darkGrayColor];
        playerHealthBackground.colorBlendFactor = .5;
        playerHealthBackground.fontSize = 15.0f;

        playerHealthBackground.text = _healthBar;
        
        currencyLabel = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
        SKSpriteNode* coinStack = [SKSpriteNode spriteNodeWithImageNamed:@"stack"];
        coinStack.position = CGPointMake(self.size.width-coinStack.size.width-55, self.size.height-barHeight/2);
        currencyLabel.position = CGPointMake(coinStack.position.x-coinStack.size.width*2/3, coinStack.position.y);
        currencyLabel.fontSize = 20;
        currencyLabel.text = @"0";
        currencyLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
        currencyLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        [_hudLayerNode addChild:currencyLabel];
        [_hudLayerNode addChild:coinStack];
    
        pauseButton = [SKSpriteNode spriteNodeWithImageNamed:@"pause"];
        pauseButton.position = CGPointMake(self.size.width-pauseButton.size.width*2.5, self.size.height-barHeight/2);
        pauseButton.name = @"PauseButton";
        [_hudLayerNode addChild:pauseButton];
        
        // 3
        playerHealthBackground.horizontalAlignmentMode =  SKLabelHorizontalAlignmentModeLeft;
        playerHealthBackground.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        playerHealthBackground.position =  CGPointMake(0, self.size.height - barHeight/4);
        [_hudLayerNode addChild:playerHealthBackground];
        
        // 4
        _playerHealthLabel = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
        _playerHealthLabel.name = @"playerHealth";
        _playerHealthLabel.fontColor = [SKColor whiteColor];
        _playerHealthLabel.fontSize = 15.0f;
        //_playerHealthLabel.text = actualHealth;
        _playerHealthLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _playerHealthLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        _playerHealthLabel.position = CGPointMake(0, self.size.height - barHeight/4);
        [_hudLayerNode addChild:_playerHealthLabel];
        
        _gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        _gameOverLabel.name = @"gameOver";
        _gameOverLabel.fontSize = 40.0f;
        _gameOverLabel.fontColor = [SKColor whiteColor];
        _gameOverLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _gameOverLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _gameOverLabel.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        _gameOverLabel.text = @"GAME OVER";
        
        _tapScreenLabel = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
        _tapScreenLabel.name = @"tapScreen";
        _tapScreenLabel.fontSize = 20.0f;
        _tapScreenLabel.fontColor = [SKColor whiteColor];
        _tapScreenLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _tapScreenLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _tapScreenLabel.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 - 100);
        _tapScreenLabel.text = @"Tap Screen To Restart";
        
        _gameOverPulse = [SKAction repeatActionForever:[SKAction sequence:@[[SKAction fadeOutWithDuration:1.0], [SKAction fadeInWithDuration:1.0]]]];
    
        SKSpriteNode* splitProjectileButton = [SKSpriteNode spriteNodeWithImageNamed:@"green"];
        splitProjectileButton.position = CGPointMake(self.frame.size.height/8, self.frame.size.width/15);
        splitProjectileButton.name = @"SplitButton";
        splitProjectileButton.hidden = NO;
        [_hudLayerNode addChild:splitProjectileButton];
        
        SKSpriteNode* freezeProjectileButton = [SKSpriteNode spriteNodeWithImageNamed:@"blue"];
        freezeProjectileButton.position = CGPointMake(self.frame.size.height/3.2, self.frame.size.width/15);
        freezeProjectileButton.name = @"IceButton";
        freezeProjectileButton.hidden = NO;

        [_hudLayerNode addChild:freezeProjectileButton];
        
        SKSpriteNode* fireProjectileButton = [SKSpriteNode spriteNodeWithImageNamed:@"red"];
        fireProjectileButton.position = CGPointMake(self.frame.size.height/2, self.frame.size.width/15);
        fireProjectileButton.name = @"FireButton";
        fireProjectileButton.hidden = NO;

        [_hudLayerNode addChild:fireProjectileButton];
    
    upgradeArrow = [SKSpriteNode spriteNodeWithImageNamed:@"upgradeArrow"];
    upgradeArrow.position = CGPointMake(self.frame.size.height/8, self.frame.size.width/7);
    upgradeArrow.hidden = YES;
    upgradeArrow.name = @"upgradeArrow";
    [_hudLayerNode addChild:upgradeArrow];
}

- (void)increaseScoreBy:(float)increment
{
    _score += increment;
    scoreLabel = (SKLabelNode*)[_hudLayerNode childNodeWithName:@"scoreLabel"];
    scoreLabel.text = [NSString stringWithFormat:@"Score: %1.0d", _score];
    [scoreLabel removeAllActions];
    [scoreLabel runAction:_scoreFlashAction];
}

- (void)restartGame
{
    // Reset the state of the game
    _gameState = GameRunning;

    // Set up the entities again and the score
    [self setupUI];
    [self increaseScoreBy:-_score];
    self.wave = 1;
    [self initializeMonsterWave:self.wave];
    
    // Reset the score and the players health
  //  scoreLabel = (SKLabelNode *)[_hudLayerNode childNodeWithName:@"scoreLabel"];
    hero.health = 10;

    hero = [Hero spawnHero];
    hero.position = CGPointMake(hero.size.width*2, self.frame.size.height*2/5);
    [self addChild:hero];
    
    [self advanceToWave:self.wave];
    

    // Remove the game over HUD labels
    [[_hudLayerNode childNodeWithName:@"gameOver"] removeFromParent];
    [[_hudLayerNode childNodeWithName:@"tapScreen"] removeAllActions];
    [[_hudLayerNode childNodeWithName:@"tapScreen"] removeFromParent];
}

//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    //1
//    [super encodeWithCoder:aCoder];
//    //2
//    [aCoder encodeObject:_hudLayerNode forKey:@"hud"];
//    [aCoder encodeObject:hero forKey:@"hero"];
//    [aCoder encodeObject:monstersForWave forKey:@"monsters"];
//    [aCoder encodeObject:_background forKey:@"background"];
//    [aCoder encodeObject:_playerHealthLabel forKey:@"playerHealth"];
//    [aCoder encodeObject:_selectedNode forKey:@"selectedNode"];
//    
//    
//}
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    //1
//    if (self = [super initWithCoder:aDecoder]) {
//        //2
//        _hudLayerNode = [aDecoder decodeObjectForKey:@"hud"];
//        hero = [aDecoder decodeObjectForKey:@"hero"];
//        monstersForWave = [aDecoder decodeObjectForKey:@"monsters"];
//        _background = [aDecoder decodeObjectForKey:@"background"];
//        _playerHealthLabel = [aDecoder decodeObjectForKey:@"playerHealth"];
//        _selectedNode = [aDecoder decodeObjectForKey:@"selectedNode"];
//       
//    }
//   
//    return self;
//    
//}

-(void)save
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(self.wave) forKey:@"wave"];
    [userDefaults setObject:@(hero.health) forKey:@"health"];
    [userDefaults setObject:self.upgrades forKey:@"upgrades"];
    [userDefaults setObject:@(self.currency) forKey:@"currency"];
    [userDefaults setObject:@(_score) forKey:@"score"];
    [userDefaults synchronize];
}

-(void)load
{
   NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    self.wave = ((NSNumber*)[userDefaults objectForKey:@"wave"]).intValue;
    hero.health = ((NSNumber*)[userDefaults objectForKey:@"health"]).floatValue;
    self.upgrades = [userDefaults objectForKey:@"upgrades"];
    self.currency = ((NSNumber*)[userDefaults objectForKey:@"currency"]).intValue;
    _score = ((NSNumber*)[userDefaults objectForKey:@"score"]).floatValue;
    //restore value of score
    scoreLabel.text = [NSString stringWithFormat:@"Score: %1.0d", _score];

    [self advanceToWave:self.wave];
}



@end
