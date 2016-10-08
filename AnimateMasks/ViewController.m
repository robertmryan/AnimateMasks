//
//  ViewController.m
//  AnimateMasks
//
//  Created by Robert Ryan on 8/18/14.
//  Copyright (c) 2014 Robert Ryan. All rights reserved.
//
//  This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
//  http://creativecommons.org/licenses/by-sa/4.0/

#import "ViewController.h"
#import "UIImage+SimpleResize.h"

@interface ViewController ()

// keep track of the image names, their imageviews and the masks for those image views

@property (nonatomic, strong) NSArray *imageNames;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) NSMutableArray *imageViewMasks;

// keep track of gesture

@property (nonatomic) CGPoint startPoint;

// some variables for the display link which will animate when you end the gesture

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic) CFTimeInterval startTime;
@property (nonatomic) CGPoint startOffset;
@property (nonatomic) CGPoint stopOffset;
@property (nonatomic) CGFloat animationDuration;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // these are a few random images I found by searching for "landscape" at images.google.com

    self.imageNames = @[@"image1.png", @"image2.jpg", @"image3.jpg", @"image4.jpg"];

    self.imageViews = [NSMutableArray array];
    self.imageViewMasks = [NSMutableArray array];

    // add the three image views

    for (NSInteger i = 0; i < 3; i++) {

        // add the image view

        UIImageView *imageView = [[UIImageView alloc] initWithImage:[self imageWithName:self.imageNames[i]]];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.view addSubview:imageView];

        // set its size accordingly using auto layout

        NSDictionary *views = NSDictionaryOfVariableBindings(imageView);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:views]];
        [self.imageViews addObject:imageView];

        // create mask the for imageview (we'll set it's path below)

        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        imageView.layer.mask = maskLayer;
        [self.imageViewMasks addObject:maskLayer];
    }

    [self updateMasksWithOffset:CGPointZero];
}

#pragma mark - Handle touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.startPoint = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    NSArray<UITouch *> *predictedTouches;
    
    if ([event respondsToSelector:@selector(predictedTouchesForTouch:)]) {
        predictedTouches = [event predictedTouchesForTouch:touch];
    }
    
    UITouch *lastTouch = [predictedTouches lastObject] ?: touch;
    CGPoint location = [lastTouch locationInView:self.view];

    CGPoint translation = CGPointMake(location.x - self.startPoint.x, 0);
    
    [self updateMasksWithOffset:translation];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    self.startOffset = CGPointMake(location.x - self.startPoint.x, 0);
    self.stopOffset = CGPointZero;
    
    self.animationDuration = 0.5 * fabs(self.startOffset.x / self.view.bounds.size.width); // set animation duration commensurate with how far it has to be animated (so the speed is same regardless of distance

    [self startDisplayLink];
}

#pragma mark - Image routines

- (UIImage *)imageWithName:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:[name stringByDeletingPathExtension] ofType:[name pathExtension]];

    UIImage *image = [UIImage imageWithContentsOfFile:path];

    // you don't have to resize if you don't want, but it can be faster to animate if images are
    // resized according to the size of the image view you're going to use them on

    return [image imageByScalingAspectFillSize:self.view.bounds.size];
}

#pragma mark - Masks and mask paths

- (void)updateMasksWithOffset:(CGPoint)offset {
    CGPoint start = CGPointMake(offset.x - self.view.bounds.size.width, 0.0);
    UIBezierPath *path;
    CAShapeLayer *mask;

    for (NSInteger i = 0; i < 3; i++) {
        path = [self pathStartingAtPoint:start];
        mask = self.imageViewMasks[i];
        mask.path = path.CGPath;

        start.x += self.view.bounds.size.width;
    }
}

static CGFloat kSlantOffset = 50.0;

- (UIBezierPath *)pathStartingAtPoint:(CGPoint)start {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint point = start;

    point.x += kSlantOffset;
    [path moveToPoint:point];

    point.x += self.view.bounds.size.width;
    [path addLineToPoint:point];

    point.x -= kSlantOffset * 2.0;
    point.y += self.view.bounds.size.height;
    [path addLineToPoint:point];

    point.x -= self.view.bounds.size.width;
    [path addLineToPoint:point];
    
    [path closePath];

    return path;
}

#pragma mark - Display Link

- (void)startDisplayLink {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
    self.startTime = CACurrentMediaTime();
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopDisplayLink {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

// this display link handler is used for animating the changing of the paths for the masks

- (void)handleDisplayLink:(CADisplayLink *)displayLink {
    CFTimeInterval elapsed = CACurrentMediaTime() - self.startTime;
    CGFloat percent = elapsed / self.animationDuration;

    if (percent < 1.0) {
        CGPoint offset = CGPointMake(self.startOffset.x + (self.stopOffset.x - self.startOffset.x) * percent,
                                     self.startOffset.y + (self.stopOffset.y - self.startOffset.y) * percent);
        [self updateMasksWithOffset:offset];
    } else {
        [self updateMasksWithOffset:self.stopOffset];
        [self stopDisplayLink];
    }
}


@end
