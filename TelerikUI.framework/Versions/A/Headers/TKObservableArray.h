//
//  TKObservableArray.h
//  TelerikUI
//
//  Created by Viktor Skarlatov on 11/30/16.
//  Copyright © 2016 Telerik. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TKObservableArrayDelegate <NSObject>

@optional
- (void) didAddObject: (id) object atIndex: (NSInteger) index;
- (void) didRemoveObject: (id) object atIndex: (NSInteger) index;
- (void) didSetObject: (id) object atIndex: (NSInteger) index ofOldObject: (id) oldObject;
@end

@interface TKObservableArray : NSMutableArray

@property (weak, nonatomic) id<TKObservableArrayDelegate> delegate;

@end
