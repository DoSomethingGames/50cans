//
//  GameViewController.m
//  FiftyCans
//
//  Created by Jonathan Uy on 3/13/15.
//  Copyright (c) 2015 DoSomething.org. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@interface GameViewController()
@property (strong, nonatomic) GameScene *scene;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pauseButton;
- (IBAction)pauseTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton;
- (IBAction)playTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    // Create and configure the scene.
    self.scene = [GameScene unarchiveFromFile:@"GameScene"];
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    self.scene.gameVC = self;

    [self updateScore:0];
    
    // Present the scene.
    [skView presentScene:self.scene];

    self.playButton.enabled = FALSE;
}

- (void)updateScore:(NSUInteger)score {
    self.scoreLabel.text = [NSString stringWithFormat:@"%li", score];
}

- (void)displayGameOver{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"You win"
                                          message:@"Great job!"
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Play again", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [self viewDidLoad];
                               }];

    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)pauseTapped:(id)sender {
    self.scene.view.paused = YES;
    self.pauseButton.enabled = NO;
    self.playButton.enabled = YES;
}
- (IBAction)playTapped:(id)sender {
    self.scene.view.paused = NO;
    self.pauseButton.enabled = YES;
    self.playButton.enabled = NO;
}
@end
