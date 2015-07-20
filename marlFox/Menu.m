//
//  Menu.m
//  marlFox
//
//  Created by Sean McKinley on 5/6/15.
//  Copyright 2015 Sean McKinley. All rights reserved.
//

#import "Menu.h"

enum{
    MESS_PAD = 45,
    TITLE_PAD = 75,
    INFO_PAD = -40,
    OBJ_PAD = -60,
};

@implementation Menu

-(id) init
{
    if( (self=[super init]) ) {
        
        
        [self setTouchEnabled:YES];
        _title = [CCLabelTTF labelWithString: [NSString stringWithFormat:@"MarlFox"] fontName:@"Arial" fontSize:46];
        _message = [CCLabelTTF labelWithString: [NSString stringWithFormat:@"Please press the portrait to play"] fontName:@"Arial" fontSize:14 ];
        _info = [CCLabelTTF labelWithString: [NSString stringWithFormat:@"Use arrow keys on the right and the cast and jump buttons on the left"] fontName:@"Arial" fontSize:14 ];
        _obj = [CCLabelTTF labelWithString: [NSString stringWithFormat:@"Seek the Frog to find victory!"] fontName:@"Arial" fontSize:14 ];
        
        _message.position =ccp([ [CCDirector sharedDirector] winSize].width/2,[[CCDirector sharedDirector]winSize].height/2+MESS_PAD);
        _title.position =ccp([ [CCDirector sharedDirector] winSize].width/2,[[CCDirector sharedDirector]winSize].height/2+TITLE_PAD);
        _info.position =ccp([ [CCDirector sharedDirector] winSize].width/2,[[CCDirector sharedDirector]winSize].height/2+INFO_PAD);
        _obj.position =ccp([ [CCDirector sharedDirector] winSize].width/2,[[CCDirector sharedDirector]winSize].height/2+OBJ_PAD);
        CCMenuItemImage *frank = [CCMenuItemImage itemWithNormalImage:@"portrait.png" selectedImage:@"portrait.png" target:self selector:@selector(portraitTouched)];
        _portraitMenu= [CCMenu menuWithArray:[NSArray arrayWithObject:frank]];
        
        [self addChild:_message z:18];
        [self addChild:_title z:18];
        [self addChild:_info z:18];
        [self addChild:_obj z:18];
        [self addChild:_portraitMenu z:17];
        
        
        CCLayerColor *blackSky = [[CCLayerColor alloc] initWithColor:ccc4(0,0,0,255)];
        [self addChild:blackSky z:16];
        
        
    }
    return self;
}
-(void)portraitTouched{
    [self removeFromParentAndCleanup:YES];
}
@end
