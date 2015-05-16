//
//  GameScene.m
//  FiftyCans
//
//  Created by Jonathan Uy on 3/13/15.
//  Copyright (c) 2015 DoSomething.org. All rights reserved.
//

#import "GameScene.h"
static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t canCategory        =  0x1 << 1;

@interface GameScene() <SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode *player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic, strong) NSMutableArray *canImages;
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

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

@implementation GameScene

-(void)didMoveToView:(SKView *)view {

    self.backgroundColor = [SKColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
    self.player = [SKSpriteNode spriteNodeWithImageNamed:@"console-color"];
    self.player.position = CGPointMake(200, 150);
    [self addChild:self.player];
    self.physicsWorld.gravity = CGVectorMake(0,0);
    self.physicsWorld.contactDelegate = self;
    self.canImages = [[NSMutableArray alloc] init];
    self.canImages[0] = @"can-tuna";
    self.canImages[1] = @"can-soda";
    self.canImages[2] = @"can-soup";
    [self addCan];
}

- (void)addCan {
    NSString *fileName = self.canImages[arc4random_uniform(3)];
    SKSpriteNode *can = [SKSpriteNode spriteNodeWithImageNamed:fileName];
    can.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:can.size];
    can.physicsBody.dynamic = YES;
    can.physicsBody.categoryBitMask = canCategory;
    can.physicsBody.contactTestBitMask = projectileCategory;
    can.physicsBody.collisionBitMask = 0;

    // Determine where to spawn the can along the Y axis
    int minY = can.size.height / 2;
    int maxY = self.frame.size.height - can.size.height / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;

    // Create the can slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    can.position = CGPointMake(self.frame.size.width + can.size.width/2, actualY);
    [self addChild:can];

    // Determine speed of the monster
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;

    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(-can.size.width/2, actualY) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [can runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {

    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addCan];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    // Choose one of the touches to work with
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];

    // Set up initial location of projectile
    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"laser"];
    projectile.position = self.player.position;
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = canCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;

    // Determine offset of location to projectile
    CGPoint offset = rwSub(location, projectile.position);
    [self addChild:projectile];

    // Get the direction of where to shoot.
    CGPoint direction = rwNormalize(offset);

    //Make it shoot far enough to be guaranteed off screen.
    CGPoint shootAmount = rwMult(direction, 1000);

    // Add the shoot amount to the current position.
    CGPoint realDest = rwAdd(shootAmount, projectile.position);

    float velocity = 480.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
}

- (void)projectile:(SKSpriteNode *)projectile didCollideWithCan:(SKSpriteNode *)can {
    [projectile removeFromParent];
    [can removeFromParent];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{

    SKPhysicsBody *firstBody, *secondBody;

    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }

    if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
        (secondBody.categoryBitMask & canCategory) != 0) {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithCan:(SKSpriteNode *) secondBody.node];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }

    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

@end
