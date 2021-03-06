//
//  MyScene.m
//  SpriteKitSimpleGame
//
//  Created by Main Account on 9/4/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "GameScene.h"
#import "GameOverScene.h"
#import "Monster.h"
#import "Minion.h"
#import "Brute.h"
#import "Skirmisher.h"
#import "Elite.h"
#import "Boss.h"
#import "Hero.h"
#import "Projectile.h"
#import "Harpoon.h"
#import "Soldier.h"
#import "FireProjectile.h"
#import "IceProjectile.h"
#import "SplitProjectile.h"

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;
static const uint32_t heroCategory           =  0x11;

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

@interface GameScene () <SKPhysicsContactDelegate, UIGestureRecognizerDelegate>
{
    Hero* hero;
    Boss* kraken;
    SKNode* boat;
    
    UIPanGestureRecognizer* panGestureRecognizer;
    CGPoint projectileSpawnPoint;
    CGPoint releasePoint;
    
    SKLabelNode *_playerHealthLabel;
    NSString    *_healthBar;
    SKNode      *_hudLayerNode;
    SKLabelNode* currencyLabel;
    SKLabelNode* splitLabel;
    SKLabelNode* fireLabel;
    SKLabelNode* iceLabel;
    SKSpriteNode* pauseButton;
    SKSpriteNode* upgradeArrow;
    SKLabelNode* waveComplete;
    SKSpriteNode* fireProjectileButton;
    SKSpriteNode* freezeProjectileButton;
    SKSpriteNode* splitProjectileButton;
    
    SKEmitterNode* shimmer;
    SKEmitterNode* fireDeath;
    SKEmitterNode* catSun;
    SKEmitterNode* fireball;
    SKEmitterNode* iceball;
    SKEmitterNode* snowSplosion;
    
    ProjectileType projectileType;
    
    int _score;
    SKLabelNode *scoreLabel;
    SKNode* healthBarNode;
    SKNode* bubbleLayer;
    SKLabelNode* waveLabel;
    int _gameState;
    
    NSMutableArray* monstersForWave;
    
    BOOL upgradeMode;
    
    SKSpriteNode *_seagull;
    NSArray *seagullFrames;
    
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

@implementation GameScene

-(id)initWithSize:(CGSize)size continued:(BOOL)continued
{
    if (self = [super initWithSize:size])
    {
        [self setupEmitters];
        [self setupUI];
        [self flyingSeaguls];
        
        if(continued)
        {
            [self load];
        }else
        {
            _score = 0;
            _currency = 0;
            _upgrades = [self upgrades];
            [self advanceToWave:1];
            [self takeDamage:0];
        }
        
    }
    return self;
}


- (void)spawnProjectileOfType:(ProjectileType)type
{
    [self.projectile removeFromParent];
    switch (type)
    {
        case untyped:
        {
            self.projectile = [Harpoon projectile];
            [self.projectile.physicsBody applyForce:CGVectorMake(25.0, 0)];
            break;
        }
        case fire:
        {
            self.projectile = [FireProjectile fireProjectileOfRank:[[_upgrades objectForKey:@"fire"]integerValue]];
            SKEmitterNode* fireEmitter = fireball.copy;
            fireEmitter.targetNode = self;
            fireEmitter.position = CGPointMake(self.projectile.position.x+self.projectile.size.width/3,self.projectile.position.y+self.projectile.size.height/3);
            [self.projectile addChild:fireEmitter];
            break;
        }
        case ice:
        {
            self.projectile = [IceProjectile iceProjectileOfRank:[[_upgrades objectForKey:@"ice"]integerValue]];
            SKEmitterNode* iceEmitter = iceball.copy;
            iceEmitter.targetNode = self;
            iceEmitter.position = CGPointMake(self.projectile.position.x+self.projectile.size.width/3,self.projectile.position.y+self.projectile.size.height/3);
            [self.projectile addChild:iceEmitter];
            break;
        }
        case split:
        {
            self.projectile = [SplitProjectile splitProjectileOfRank:[[_upgrades objectForKey:@"split"]integerValue]];
            break;
        }
        default:
            break;
    }
    self.projectile.position = projectileSpawnPoint;
    [self addChild:self.projectile];
}

-(void)flyingSeaguls
{
    
    _seagull = [SKSpriteNode spriteNodeWithImageNamed:@"gulls"];
    _seagull.position = CGPointMake(self.size.width/2, self.size.height/2);
   
    [self addChild:_seagull];
    
    CGPathRef path = CGPathCreateWithEllipseInRect(CGRectMake(0, self.size.height*2/3, self.size.width, self.size.height), NULL);
    
    _seagull.zRotation = 0;
    
    [_seagull runAction:[SKAction followPath:path asOffset:NO orientToPath:NO duration:7].reversedAction];
    
}

- (void)didMoveToView:(SKView *)view
{
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [[self view] addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.delegate = self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode* node = [self nodeAtPoint:location];
    
    if([node.name hasSuffix:@"Button"])
    {
        if ([node.name isEqualToString:@"IceButton"])
        {
            if (upgradeMode == YES)
            {
                [self upgradeProjectile:ice];
                //freezeProjectileButton.colorBlendFactor = 0;
                freezeProjectileButton.alpha = 1.0f;
            }
            if ([[_upgrades objectForKey:@"ice"] integerValue] > 0)
            {
                projectileType = ice;
            }
        }
        else if ([node.name isEqualToString:@"FireButton"])
        {
            if (upgradeMode == YES)
            {
                [self upgradeProjectile:fire];
                //fireProjectileButton.colorBlendFactor = 0;
                fireProjectileButton.alpha = 1.0f;
            }
            if ([[_upgrades objectForKey:@"fire"] integerValue] > 0)
            {
                projectileType = fire;
            }
        }
        else if ([node.name isEqualToString:@"SplitButton"])
        {
            if (upgradeMode == YES)
            {
                [self upgradeProjectile:split];
                //splitProjectileButton.colorBlendFactor = 0;
                splitProjectileButton.alpha = 1.0f;
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
    
            [pauseButton setTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"btn_play"]]];
            fireProjectileButton.hidden = YES;
            freezeProjectileButton.hidden = YES;
            splitProjectileButton.hidden = YES;
        }
        else
        {
            self.view.scene.paused = NO;
            [pauseButton setTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"btn_pause"]]];
            fireProjectileButton.hidden = NO;
            freezeProjectileButton.hidden = NO;
            splitProjectileButton.hidden = NO;
        }
    }
    if ([node.name isEqualToString:@"upgradeArrow"])
    {
        upgradeMode = YES;
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
            break;
        case untyped:
            typeString = @"";
            break;
    }
    
    int currentLevel = [self.upgrades[typeString] intValue];

    if (currentLevel == 0 && self.currency >= 50)
    {
        [self increaseCurrencyBy:-50];
        currentLevel++;
    }
    else if (currentLevel == 1 && self.currency >= 100)
    {
        [self increaseCurrencyBy:-100];
        currentLevel++;
    }
    else if (currentLevel == 2 && self.currency >= 250)
    {
        [self increaseCurrencyBy:-250];
        currentLevel++;
    }
    if(![typeString isEqualToString:@""])
    [_upgrades setObject:@(currentLevel) forKey:typeString];
    
    splitLabel.text = [NSString stringWithFormat:@"%d/3", [[_upgrades objectForKey:@"split"] integerValue]];
    fireLabel.text = [NSString stringWithFormat:@"%d/3", [[_upgrades objectForKey:@"fire"] integerValue]];
    iceLabel.text = [NSString stringWithFormat:@"%d/3", [[_upgrades objectForKey:@"ice"] integerValue]];
    
    [[bubbleLayer childNodeWithName:[NSString stringWithFormat:@"%@Bubble",typeString]] removeFromParent];
    
    upgradeMode = NO;
    upgradeArrow.hidden = YES;
}

- (NSMutableDictionary*)upgrades
{
    return _upgrades ?: (_upgrades = @{@"fire": @0, @"ice": @0, @"split": @0}.mutableCopy);
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
                
                CGPoint location = releasePoint;
                CGPoint offset = rwSub(location, projectileSpawnPoint);
                
                // Bail out if you are shooting down or backwards
                if (offset.x >= 0) return;
                
                // Get the direction of where to shoot
                CGPoint direction = rwNormalize(offset);
                CGPoint launchDirection = rwInvert(direction);
                float force = rwLength(offset);
                CGPoint multiplied = rwMult(launchDirection, force/5);
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
    self.projectile.physicsBody.categoryBitMask = projectileCategory;
    [hero.arm setPosition:CGPointMake(-hero.arm.size.width/30, hero.arm.position.y)];
    hero.zRotation = 0;
    
    if(projectileType == split)
    {
        [self.projectile removeAllActions];

        for (SplitProjectile* projectile in self.projectile.children) {
            int xVariance = arc4random()%10+1;
            int sign = arc4random()%2;
            
            projectile.physicsBody.dynamic = YES;
            projectile.physicsBody.affectedByGravity = YES;
            projectile.physicsBody.categoryBitMask = projectileCategory;
           
            if(sign == 0)
            {
                [projectile.physicsBody applyImpulse:CGVectorMake((vector.dx-xVariance), vector.dy)];
            }
            else
            {
                [projectile.physicsBody applyImpulse:CGVectorMake((vector.dx+xVariance), vector.dy)];
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
        CGPoint projectilePosition = self.projectile.position;
        CGPoint newProjectilePosition = CGPointMake(projectilePosition.x + translation.x, projectilePosition.y);
        CGPoint newArmPosition = CGPointMake(hero.arm.position.x + translation.x, hero.arm.position.y);
       
        if([self isWithinSlingshotDragArea:newProjectilePosition])
        {
            if(newProjectilePosition.x < projectileSpawnPoint.x-15)
            {
                newProjectilePosition.x = projectileSpawnPoint.x-15;
                newArmPosition.x = -hero.arm.size.width/5;
            }
            
            releasePoint = CGPointMake(point.x + translation.x, point.y + translation.y);
            [self.projectile setPosition:newProjectilePosition];
            [hero.arm setPosition:newArmPosition];
            
            float zRotate = atan2(releasePoint.y, releasePoint.x)/10;
            hero.zRotation = zRotate;
            self.projectile.zRotation = zRotate;
        }
        
    }
}

- (void)selectNodeForTouch:(CGPoint)touchLocation
{
    if([self isWithinSlingshotDragArea:touchLocation])
    {
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
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, Nil, 0, 0);
   // CGPathAddCurveToPoint(path, nil, -self.size.height/3, self.size.height/3, -self.size.height*2/3, -self.size.height/3, -self.size.width, -50);

    Monster* monster;
    
   // monster.position = CGPointMake(self.frame.size.width - monster.size.width/2, self.frame.size.height/2);
    
    switch (type) {
        case minion:
            monster = [Minion monster];
            CGPathAddCurveToPoint(path, nil, -self.size.height, -self.size.height/2, -self.size.height*2/3, -self.size.height/3, -self.size.width, -50);

            monster.position = CGPointMake(self.frame.size.width - monster.size.width/2, self.frame.size.height/2);

            break;
        case brute:
            monster = [Brute monster];
            CGPathAddCurveToPoint(path, nil, -self.size.height/2, self.size.height/2, -self.size.height/2, -self.size.height/3, -self.size.width, -80);

            monster.position = CGPointMake(self.frame.size.width - monster.size.width/*/2*/, self.frame.size.height/2);

            break;
        case soldier:
            monster = [Soldier monster];

            CGPathAddCurveToPoint(path, nil, -self.size.width, -self.size.height/2, -self.size.height*2/3, -self.size.height/4, -self.size.width, -50);
            
            monster.position = CGPointMake(self.frame.size.width - monster.size.width/2, self.frame.size.height/2);

            break;
        case skirmisher:
            monster = [Skirmisher monster];
            
            CGPathAddCurveToPoint(path, nil, -self.size.height/2/3, -self.size.height/2, -self.size.height*2/3, -self.size.height/3, -self.size.width, -50);
            
            monster.position = CGPointMake(self.frame.size.width - monster.size.width/2, self.frame.size.height/2);
            break;
        case elite:
            monster = [Elite monster];
            
            CGPathAddCurveToPoint(path, nil, -self.size.height/3, self.size.height/3, -self.size.height*2/3, -self.size.height/3, -self.size.width, -50);

            monster.position = CGPointMake(self.frame.size.width - monster.size.width/2, self.frame.size.height/2);
            
            break;
        case boss:
            monster = [Boss monster];
            CGPathAddCurveToPoint(path, nil, -self.size.height/3, self.size.height/3, -self.size.height*2/3, -self.size.height/3, -self.size.width, -50);
            
            monster.position = CGPointMake(self.frame.size.width - monster.size.width/2, self.frame.size.height/2);
            [self flyingSeaguls];

        default:
            break;
    }
    
    [self.monsterLayer addChild:monster];
    
    // Create the actions
    SKAction * actionMove = [SKAction followPath:path asOffset:YES orientToPath:NO duration:5.0];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    
    CGPathRelease(path);
    
    [monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]withKey:@"path"];
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
    if(self.wave <= 5 && hero.health > 0)
    {
        waveComplete = [SKLabelNode labelNodeWithFontNamed:@"Opificio-Bold"];
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
    if(waveNumber < 6)
    {
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
    }else{
        kraken.physicsBody.categoryBitMask = monsterCategory;
        [kraken runAction:[SKAction moveByX:-self.size.width y:0 duration:5]];
    }
    
    if(!waveLabel)
    {
        waveLabel = [SKLabelNode labelNodeWithFontNamed:@"Typodermic-Regular"];
        waveLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
        waveLabel.position = CGPointMake(self.size.width-10, 10);
        waveLabel.zPosition = 4;
        waveLabel.fontSize = 18;
        [self addChild:waveLabel];
    }
    
     waveLabel.text = [NSString stringWithFormat:@"Wave: %d/6",self.wave];
    
}


- (void)update:(NSTimeInterval)currentTime
{
    if(self.projectile.position.x > projectileSpawnPoint.x)
        self.projectile.zRotation = atan2(self.projectile.physicsBody.velocity.dy,self.projectile.physicsBody.velocity.dx);
    
    
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
            
            if(projectile.position.x > projectileSpawnPoint.x)
                projectile.zRotation = atan2(projectile.physicsBody.velocity.dy,projectile.physicsBody.velocity.dx);
            
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
}

- (void)monster:(Monster*)monster didCollideWithHero:(Hero*)ourHero
{
    [self takeDamage:monster.damage];
    [ourHero runAction:[self onHitColoration]];
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
   // monster.health = monster.health - projectile.damage;
    [self dealDamage:projectile.damage toMonster:monster];
    [self increaseScoreBy:10];
    
    if(!self.muted)
    {
        if (projectileType == fire)
        {
            [self runAction:[SKAction playSoundFileNamed:@"fireExplosion.wav" waitForCompletion:NO]];
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
    if(projectileType != ice)
    [monster runAction:[self onHitColoration]];
    
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

-(void)dealDamage:(int)amount toMonster:(Monster*)monster
{
    monster.health -= amount;
}

-(void)killedMonster:(Monster*)monster
{
    monster.physicsBody.contactTestBitMask = 0x0;
    monster.physicsBody.categoryBitMask = 0x0;
    monster.speed = 1;
    [monster removeActionForKey:@"path"];
    
    [self increaseScoreBy:monster.ScoreValue];
    
    if(![monster isKindOfClass:[Boss class]])
    {
        if (projectileType == fire)
        {
            [monster addChild:fireDeath.copy];
        }
        else
        {
            [monster addChild:snowSplosion.copy];
        }
        
        SKAction* wait = [SKAction waitForDuration:.5];
        SKAction* remove = [SKAction removeFromParent];
        SKAction* fadeOut = [SKAction fadeOutWithDuration:.5];
        SKAction* burnOut = [SKAction colorizeWithColor:[UIColor blackColor] colorBlendFactor:0.8f duration:0.8f];
        [monster runAction:burnOut];
        [monster runAction:[SKAction sequence:@[fadeOut, wait, remove]]];
        
        SKNode* coinNode = [SKNode new];
        [self addChild:coinNode];
        
        SKSpriteNode* coin = [SKSpriteNode spriteNodeWithImageNamed:@"ic_kill_gem"];
        coin.position = CGPointMake(monster.position.x, monster.position.y+monster.size.height/2);
        [coinNode addChild:coin];
        
        SKLabelNode* gold = [SKLabelNode labelNodeWithFontNamed:@"Typodermic-Regular"];
        gold.text = [NSString stringWithFormat:@"%d",monster.goldValue];
        gold.fontSize = 15.0;
        gold.fontColor = [UIColor colorWithRed:1 green:192/255.0 blue:0 alpha:1];
        gold.position = CGPointMake(coin.position.x+coin.size.width*1.2, coin.position.y-5);
        [coinNode addChild:gold];
        
        [coinNode runAction:[SKAction waitForDuration:.4] completion:^{
            [coinNode removeFromParent];
        }];
        
        [self increaseCurrencyBy:monster.goldValue];
        self.monstersDestroyed++;
    }else{
        [self sink:kraken];
    }
}

- (void)sink:(SKNode*)node
{
    BOOL won;
    if([node.name isEqualToString:@"Kraken"])
    {
        won = YES;
    }else {
        won = NO;
    }
    
    
    SKAction *rumble = [SKAction sequence:
                        @[[SKAction rotateByAngle:degToRad(-4.0f) duration:0.1],
                          [SKAction rotateByAngle:0.0 duration:0.1],
                          [SKAction rotateByAngle:degToRad(4.0f) duration:0.1]]];
    
    SKAction* rumbleUntilGone = [SKAction repeatActionForever:rumble];
    
    SKAction* sinkAction = [SKAction moveByX:0 y:-50 duration:1];
    
    SKAction* fire = [SKAction customActionWithDuration:1 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        
        float fireX = (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * node.frame.size.width);
        float fireY = (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * node.frame.size.height);
        
        SKEmitterNode* explosion = fireDeath.copy;
        explosion.position = CGPointMake(fireX, fireY);
        
        [node addChild:explosion];
    }];
    
    SKAction* sinkSequence = [SKAction sequence:@[fire, sinkAction, [SKAction waitForDuration:.5]]];
    
    SKAction* sinkUntilGone = [SKAction repeatAction:sinkSequence count:node.position.y/50];
    
    if(!won)
    {
        [boat runAction:sinkUntilGone];
        self.projectile.paused = YES;
        self.projectile.hidden = YES;
    }
    
    [node removeAllActions];
    [node runAction:rumbleUntilGone];
    [node runAction:sinkUntilGone completion:^{
        
        if(won)
        {
            [kraken removeFromParent];
        }else{
            [boat removeFromParent];
        }
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:1];
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:won score:_score];
        [self.view presentScene:gameOverScene transition: reveal];
    }];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
        SKPhysicsBody *firstBody, *secondBody;
        
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else if (contact.bodyA.categoryBitMask == contact.bodyB.categoryBitMask)
    {
        if(contact.bodyA.node.position.x < contact.bodyB.node.position.x)
        {
            firstBody = contact.bodyA;
            secondBody = contact.bodyB;
        }
    }
    else
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
    }
    else if (firstBody.categoryBitMask == monsterCategory && secondBody.categoryBitMask == monsterCategory)
    {
        [self monster:(Monster*)firstBody.node didCollideWithMonster:(Monster*)secondBody.node];
    }
}

-(void)monster:(Monster*)monster1 didCollideWithMonster:(Monster*)monster2
{
    float baseSpeed = monster2.baseSpeed;
    
    [monster2 runAction:[SKAction sequence:@[[SKAction speedTo:.01 duration:0],[SKAction waitForDuration:.01], [SKAction speedTo:baseSpeed duration:2]]]];
}

- (void)setupUI
{
    [hero removeFromParent];
    [self removeAllChildren];
    [self removeAllActions];
    
    _background = [SKSpriteNode spriteNodeWithImageNamed:@"fullscreen_background"];
    [_background setName:@"background"];
    [_background setPosition:(CGPointMake(self.size.width/2, self.size.height/2+35))];
    //[_background setAnchorPoint:CGPointZero];
    [self addChild:_background];
    
    SKSpriteNode* bgWave = [SKSpriteNode spriteNodeWithImageNamed:@"back_wave"];
    [self addChild:bgWave];
    [bgWave setPosition: CGPointMake(self.size.width/2,bgWave.size.height/2)];
    
    SKAction* toWaveMove = [SKAction moveByX:-100 y:0 duration:4];
    toWaveMove.timingMode = SKActionTimingEaseInEaseOut;
    SKAction* froWaveMove = [SKAction moveByX:100 y:0 duration:4];
    froWaveMove.timingMode = SKActionTimingEaseInEaseOut;
    [bgWave runAction:[SKAction repeatActionForever:[SKAction sequence:@[toWaveMove, froWaveMove]]]];
    
    boat = [SKNode node];
    [self addChild:boat];
    
    SKSpriteNode* backOfBoat = [SKSpriteNode spriteNodeWithImageNamed:@"boat_back"];
    [backOfBoat setPosition:CGPointMake(backOfBoat.size.width/2, backOfBoat.size.height*1.2)];
    backOfBoat.name = @"boatBack";
    [boat addChild:backOfBoat];
    
    hero = [Hero spawnHero];
    hero.position = CGPointMake(hero.size.width, self.frame.size.height*2/5);
    hero.name = @"Hero";
    hero.zPosition = 1;
    [boat addChild:hero];
    
    projectileSpawnPoint = CGPointMake(hero.size.width*1.5, self.frame.size.height*2/5-5);
    
    SKSpriteNode* frontOfBoat = [SKSpriteNode spriteNodeWithImageNamed:@"boat_front"];
    [frontOfBoat setPosition:CGPointMake(frontOfBoat.size.width/2, frontOfBoat.size.height*1.2)];
    frontOfBoat.name = @"boatFront";
    frontOfBoat.zPosition = 2;
    [boat addChild:frontOfBoat];
    
    self.monsterLayer = [SKNode node];
    [self addChild:self.monsterLayer];
    
    toWaveMove = [SKAction moveByX:-100 y:0 duration:6];
    froWaveMove = [SKAction moveByX:100 y:0 duration:6];
    
    SKSpriteNode* fWave = [SKSpriteNode spriteNodeWithImageNamed:@"front_wave"];
    [self addChild:fWave];
    fWave.zPosition = 3;
    [fWave setPosition: CGPointMake(self.size.width/2,fWave.size.height/2-10)];
    [fWave runAction:[SKAction repeatActionForever:[SKAction sequence:@[froWaveMove, toWaveMove]]]];
    
    kraken = [Boss monster];
    [self.monsterLayer addChild:kraken];
    kraken.name = @"Kraken";
    kraken.physicsBody.categoryBitMask = 0x0;
    [kraken setPosition:CGPointMake(self.size.width-kraken.size.width/4, kraken.size.height/2)];
    
    SKEmitterNode* sun = catSun.copy;
    sun.position = CGPointMake(self.frame.size.width*2/3+8, self.frame.size.height-48);
    [self addChild:sun];
    
    _hudLayerNode = [SKNode node];
    [self addChild:_hudLayerNode];
    
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
    
    scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Typodermic-Regular"];
    
    scoreLabel.fontSize = 20.0;
    scoreLabel.text = @"Score: 0";
    scoreLabel.name = @"scoreLabel";
    
    scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    
    scoreLabel.position = CGPointMake(self.size.width/2+55, self.size.height - scoreLabel.frame.size.height + 3);
    
    [_hudLayerNode addChild:scoreLabel];
    
    SKLabelNode *playerHealthBackground = [SKLabelNode labelNodeWithFontNamed:@"Typodermic-Regular"];
    playerHealthBackground.name = @"playerHealthBackground";
    playerHealthBackground.color = [SKColor darkGrayColor];
    playerHealthBackground.colorBlendFactor = .5;
    playerHealthBackground.fontSize = 15.0f;
    
    playerHealthBackground.text = _healthBar;
    
    pauseButton = [SKSpriteNode spriteNodeWithImageNamed:@"btn_pause"];
    pauseButton.position = CGPointMake(self.size.width-pauseButton.size.width, self.size.height-barHeight/2);
    pauseButton.name = @"PauseButton";
    [_hudLayerNode addChild:pauseButton];
    
    currencyLabel = [SKLabelNode labelNodeWithFontNamed:@"Typodermic-Regular"];
    SKSpriteNode* coinStack = [SKSpriteNode spriteNodeWithImageNamed:@"ic_gem_status"];
    coinStack.position = CGPointMake(pauseButton.position.x-coinStack.size.width-10, self.size.height-barHeight/2);
    currencyLabel.position = CGPointMake(coinStack.position.x-coinStack.size.width*2/3, coinStack.position.y);
    currencyLabel.fontSize = 20;
    currencyLabel.text = @"0";
    currencyLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    currencyLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    [_hudLayerNode addChild:currencyLabel];
    [_hudLayerNode addChild:coinStack];
    
    SKNode* projectileButtonLayer = [SKNode node];
    projectileButtonLayer.zPosition = 5;
    [self addChild:projectileButtonLayer];
    
    splitProjectileButton = [SKSpriteNode spriteNodeWithImageNamed:@"btn_harpoon_split"];
    splitProjectileButton.position = CGPointMake(splitProjectileButton.size.width, splitProjectileButton.size.height/2);
    splitProjectileButton.name = @"SplitButton";
    splitProjectileButton.hidden = NO;
    splitProjectileButton.alpha = 0.4f;
    
    [projectileButtonLayer addChild:splitProjectileButton];
    
    splitLabel = [SKLabelNode new];
    splitLabel = [SKLabelNode labelNodeWithFontNamed:@"Typodermic-Regular"];
    splitLabel.fontSize = 10.0f;
    splitLabel.fontColor = [SKColor whiteColor];
    splitLabel.text = [NSString stringWithFormat:@"%d/3", [[_upgrades objectForKey:@"split"] integerValue]];
    splitLabel.position = CGPointMake(splitProjectileButton.position.x, 5);
    
    [projectileButtonLayer addChild:splitLabel];
    
    freezeProjectileButton = [SKSpriteNode spriteNodeWithImageNamed:@"btn_harpoon_ice"];
    freezeProjectileButton.position = CGPointMake(freezeProjectileButton.size.width*2.5, freezeProjectileButton.size.height/2);
    freezeProjectileButton.name = @"IceButton";
    freezeProjectileButton.hidden = NO;
    freezeProjectileButton.alpha = 0.4f;
    
    [projectileButtonLayer addChild:freezeProjectileButton];
    
    iceLabel = [SKLabelNode labelNodeWithFontNamed:@"Typodermic-Regular"];
    iceLabel.fontSize = 10.0f;
    iceLabel.fontColor = [SKColor whiteColor];
    iceLabel.text = [NSString stringWithFormat:@"%d/3", [[_upgrades objectForKey:@"ice"] integerValue]];
    iceLabel.position = CGPointMake(freezeProjectileButton.position.x, 5);
    
    [projectileButtonLayer addChild:iceLabel];
    
    fireProjectileButton = [SKSpriteNode spriteNodeWithImageNamed:@"btn_harpoon_fire"];
    fireProjectileButton.position = CGPointMake(fireProjectileButton.size.width*4, fireProjectileButton.size.height/2);
    fireProjectileButton.name = @"FireButton";
    fireProjectileButton.hidden = NO;
    fireProjectileButton.alpha = 0.4f;

    [projectileButtonLayer addChild:fireProjectileButton];
    
    fireLabel = [SKLabelNode labelNodeWithFontNamed:@"Typodermic-Regular"];
    fireLabel.fontSize = 10.0f;
    fireLabel.fontColor = [SKColor whiteColor];
    fireLabel.text = [NSString stringWithFormat:@"%d/3", [[_upgrades objectForKey:@"fire"] integerValue]];
    fireLabel.position = CGPointMake(fireProjectileButton.position.x, 5);
    
    [projectileButtonLayer addChild:fireLabel];
    
    upgradeArrow = [SKSpriteNode spriteNodeWithImageNamed:@"btn_levelUp"];
    upgradeArrow.position = CGPointMake(fireProjectileButton.size.width*5.5, fireProjectileButton.size.height/2);
    upgradeArrow.hidden = YES;
    upgradeArrow.name = @"upgradeArrow";
    [projectileButtonLayer addChild:upgradeArrow];
}

-(void)setupEmitters
{
    NSString* shimmerPath = [[NSBundle mainBundle] pathForResource:@"shimmer" ofType:@"sks"];
    NSString* catPath = [[NSBundle mainBundle] pathForResource:@"catSun" ofType:@"sks"];
    NSString* firePath = [[NSBundle mainBundle] pathForResource:@"FireDeath" ofType:@"sks"];
    NSString* fireballPath = [[NSBundle mainBundle] pathForResource:@"fireball" ofType:@"sks"];
    NSString* iceballPath = [[NSBundle mainBundle] pathForResource:@"iceball" ofType:@"sks"];
    NSString* snowSplosionPath = [[NSBundle mainBundle] pathForResource:@"SnowSplosion" ofType:@"sks"];
    
    shimmer = [NSKeyedUnarchiver unarchiveObjectWithFile:shimmerPath];
    catSun = [NSKeyedUnarchiver unarchiveObjectWithFile:catPath];
    fireDeath = [NSKeyedUnarchiver unarchiveObjectWithFile:firePath];
    fireball = [NSKeyedUnarchiver unarchiveObjectWithFile:fireballPath];
    iceball = [NSKeyedUnarchiver unarchiveObjectWithFile:iceballPath];
    snowSplosion = [NSKeyedUnarchiver unarchiveObjectWithFile:snowSplosionPath];
}

-(void)takeDamage:(int)amount
{
    hero.health -= amount;
    
    if(!healthBarNode)
    {
        healthBarNode = [SKNode node];
        [self addChild:healthBarNode];
    }else{
        [healthBarNode removeAllChildren];
    }
    
    for(int i = 0;i < hero.health; i++)
    {
        SKSpriteNode* healthbarPiece = [SKSpriteNode spriteNodeWithImageNamed:@"ic_ship_health"];
        healthbarPiece.size = CGSizeMake(22, 22);
        healthbarPiece.position = CGPointMake(healthbarPiece.size.width*i+18, self.size.height - healthbarPiece.size.height*3/4);
        
        [healthBarNode addChild:healthbarPiece];
    }
    
    if (hero.health <= 0)
    {
        [self sink:hero];
    }

}

- (void)increaseScoreBy:(int)increment
{
    _score += increment;
    scoreLabel.text = [NSString stringWithFormat:@"Score: %d", _score];
    
    if(_score%100 == 0)
        [self flyingSeaguls];
}

-(void)increaseCurrencyBy:(int)increment
{
    self.currency += increment;
    currencyLabel.text = [NSString stringWithFormat:@"%d", self.currency];
    
    NSArray* values = [_upgrades allValues];
    
    BOOL shouldHideArrow = YES;
    
    if(self.currency > 50 && [values containsObject:@0])
       shouldHideArrow = [self checkForUpgradeEligibility:0];
    
    if(self.currency > 100 && [values containsObject:@1])
       shouldHideArrow = [self checkForUpgradeEligibility:1];
        
    if(self.currency > 250 && [values containsObject:@2])
       shouldHideArrow = [self checkForUpgradeEligibility:2];
    
    upgradeArrow.hidden = shouldHideArrow;
    if(shouldHideArrow)
        [bubbleLayer removeAllChildren];
    
}

-(BOOL)checkForUpgradeEligibility:(int)rank
{
    if(!bubbleLayer)
    {
        bubbleLayer = [SKNode node];
        bubbleLayer.zPosition = 4;
        [self addChild:bubbleLayer];
    }
    
    [self flyingSeaguls];
    
    if([_upgrades[@"fire"] intValue] == rank && ![bubbleLayer childNodeWithName:@"fireBubble"])
    {
        SKSpriteNode* bubble = [SKSpriteNode spriteNodeWithImageNamed:@"btn_bubble"];
        bubble.name = @"fireBubble";
        bubble.position = fireProjectileButton.position;
        [bubbleLayer addChild:bubble];
    }
    
    if([_upgrades[@"ice"] intValue] == rank && ![bubbleLayer childNodeWithName:@"iceBubble"])
    {
        SKSpriteNode* bubble = [SKSpriteNode spriteNodeWithImageNamed:@"btn_bubble"];
        bubble.name = @"iceBubble";
        bubble.position = freezeProjectileButton.position;
        [bubbleLayer addChild:bubble];
    }
    
    if([_upgrades[@"split"] intValue] == rank && ![bubbleLayer childNodeWithName:@"splitBubble"])
    {
        SKSpriteNode* bubble = [SKSpriteNode spriteNodeWithImageNamed:@"btn_bubble"];
        bubble.name = @"splitBubble";
        bubble.position = splitProjectileButton.position;
        [bubbleLayer addChild:bubble];
    }
    
    return NO;
}

-(void)save
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(self.wave) forKey:@"wave"];
    [userDefaults setObject:@(hero.health) forKey:@"health"];
    [userDefaults setObject:self.upgrades forKey:@"upgrades"];
    [userDefaults setObject:@(self.currency) forKey:@"currency"];
    [userDefaults setObject:@(_score) forKey:@"score"];
    [userDefaults setObject:@(projectileType) forKey:@"projectile"];
    [userDefaults synchronize];
}

-(void)load
{
   NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    self.wave = ((NSNumber*)[userDefaults objectForKey:@"wave"]).intValue;
    hero.health = ((NSNumber*)[userDefaults objectForKey:@"health"]).intValue;
    self.upgrades = [[userDefaults objectForKey:@"upgrades"] mutableCopy];
    self.currency = ((NSNumber*)[userDefaults objectForKey:@"currency"]).intValue;
    _score = ((NSNumber*)[userDefaults objectForKey:@"score"]).intValue;
    projectileType = ((NSNumber*)[userDefaults objectForKey:@"projectile"]).intValue;
    
    [self increaseCurrencyBy:0];
    [self increaseScoreBy:0];
    [self takeDamage:0];
    
    [self advanceToWave:self.wave];
}

@end
