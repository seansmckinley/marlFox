
//
//  Coin.m
//  marlFox
//
//  Created by Sean McKinley on 5/3/15.
//  Copyright 2015 Sean McKinley. All rights reserved.
//

#import "Coin.h"



@implementation Coin

@synthesize desiredPosition =_desiredPosition;
@synthesize onGround = _onGround;
@synthesize velocity = _velocity;



-(id)initWithFile:(NSString *)filename {
    if (self = [super initWithFile:filename]) {
        self.velocity = ccp(0.0,0.0);
        self.onGround = NO;
    }
    return self;
}

-(void)update:(ccTime)deltaTime
{
    //For each second of time we need to decrease sprites altitude by
    // because update will be called each second
    CGPoint gravity = ccp(0.0, -200.0);
    CGPoint gravityStep = ccpMult(gravity, deltaTime);
    self.velocity = ccpAdd(self.velocity, gravityStep);
    CGPoint minVel = ccp(-120.0, -400.0); CGPoint maxVel = ccp(120.0, 250.0);
    self.velocity = ccpClamp(self.velocity, minVel, maxVel  );
    CGPoint stepVelocity = ccpMult(self.velocity, deltaTime);
    self.desiredPosition = ccpAdd(self.position, stepVelocity);
    
}
-(CGRect) cBox{
    // using CGRectInset will make our cBox not terribly sensitive
        // in the case of the coins however, this is not our desired behavior
    CGRect cBox = CGRectInset(self.boundingBox, 0, 0);
    CGPoint difference = ccpSub(self.desiredPosition, self.position);
    return CGRectOffset(cBox,difference.x,difference.y);
    
}
@end
