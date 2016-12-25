//
//  TKTabView.h
//  TelerikUI
//
//  Copyright (c) 2016 Telerik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKTabStrip.h"
#import "TKSlideView.h"


#ifndef TKTAB_VIEW
#define TKTAB_VIEW

@protocol TKTabLayout;
@protocol TKTabViewDelegate <NSObject>

@optional
- (TKTabItemView *) viewForTab: (TKTab *) tab;
- (UIView *) contentViewForTab: (TKTab *) tab;
@end

@interface TKTabView : UIView

@property (strong, nonatomic) TKSlideView *slideView;
@property (strong, nonatomic) TKTabStrip *tabStrip;

@property (strong, nonatomic) TKTab *selectedTab;
@property (strong, nonatomic, readonly) NSArray *tabs;
@property (weak, nonatomic) id<TKTabViewDelegate> delegate;

- (TKTab *) addTabWithTitle: (NSString *) title;
- (TKTab *) addTabWithTitle: (NSString *) title andContentView: (UIView *) contentView;
- (TKTab *) addTabWithTitle: (NSString *) title view: (TKTabItemView *) view andContentView: (UIView *) contentView;

- (void) removeTabWithTitle: (NSString *) title;

- (TKTab *) tabWithTitle: (NSString *) title;
- (BOOL) removeTab: (TKTab *) tab;
@end

#endif
