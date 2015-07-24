//
//  GameViewController.h
//  FiftyCans
//

//  Copyright (c) 2015 DoSomething.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@interface DSOGameViewController : UIViewController

- (void)updateScore:(NSUInteger)score;
- (void)displayGameOver;

@end
