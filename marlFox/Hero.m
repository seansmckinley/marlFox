//
//  Hero.m
//  marlFox
//
//  Created by Sean McKinley on 4/23/15.
//  Copyright 2015 Sean McKinley. All rights reserved.
//



#import "Hero.h"

@implementation Hero

@synthesize desiredPosition =_desiredPosition; //the reason you keep track of the desiredPosition is because we want
                                                // to be able to tell the sprite if something is not a legal move.
@synthesize onGround = _onGround;
@synthesize velocity = _velocity;

@synthesize jumping = _jumping;
@synthesize walking = _walking;
@synthesize facing = _facing;


-(id)initWithFile:(NSString *)filename {
    if (self = [super initWithFile:filename]) {
        self.velocity= ccp(0.0,0.0);
        self.onGround = NO;
    }
    return self;
}
-(void)update:(ccTime)deltaTime
{
    //For each second of time we need to decrease sprites altitude by
    // because update will be called each second
    CGPoint gravity = ccp(0.0, -350.0);
    CGPoint gravityStep = ccpMult(gravity, deltaTime);
    CGPoint lateralMove = ccp(100.0,0.0);    CGPoint upwardForce = ccp(0.0,250.0);
    self.velocity = ccpAdd(self.velocity, gravityStep);
    if(self.walking == YES && self.facing == NO){ //backward
        self.velocity =ccpSub(self.velocity,lateralMove);
        [self setFlipX:FALSE]; //dont flip image if moving left
    }
    else if(self.walking == YES && self.facing ==YES){ //forward
        self.velocity =ccpAdd(self.velocity,lateralMove); //flip image if moving right
        [self setFlipX:TRUE];
    }
    else if(self.walking == NO && _onGround == YES)
        self.velocity = CGPointZero;
    if(self.jumping == YES && _onGround == YES)
        self.velocity = ccpAdd(self.velocity, upwardForce);
    else if (self.jumping == NO && self.velocity.y > 100.0)
        self.velocity = ccp(self.velocity.x, 100.0);
    CGPoint minVel = ccp(-120.0, -400.0);
    CGPoint maxVel = ccp(120.0, 250.0);
    self.velocity = ccpClamp(self.velocity, minVel, maxVel  );
    CGPoint stepVelocity = ccpMult(self.velocity, deltaTime);
    self.desiredPosition = ccpAdd(self.position, stepVelocity);

}
-(CGRect) cBox{
    // using CGRectInset will make our cBox not terribly sensitive so we overlap a little bit
    // with floor tiles/wall tiles
    CGRect cBox = CGRectInset(self.boundingBox, 2, 0);
    CGPoint difference= ccpSub(self.desiredPosition, self.position);
    return CGRectOffset(cBox,difference.x,difference.y);
}
@end
