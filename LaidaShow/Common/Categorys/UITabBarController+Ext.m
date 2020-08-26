//
//  UITabBarController+Ext.m
//  HiTravelService
//
//  Created by hitomedia on 2017/4/14.
//  Copyright © 2017年 hitumedia. All rights reserved.
//

#import "UITabBarController+Ext.h"
#import "UIFont+Ext.h"

@implementation UITabBarController (Ext)

- (void)configTabbarWithCtrls:(NSArray*)ctrls
                       titles:(NSArray*)titles
             selectedImgNames:(NSArray*)sImgNames
               normalImgNames:(NSArray*)nImgNames
                    textColor:(UIColor*)textColor
             selctedTextColor:(UIColor*)sTextColor{
    
    NSArray *nonSelectImgNames = nImgNames;
    NSArray *selectImgNames    = sImgNames;

    UIColor *selectedTextColor = sTextColor;
    for( NSUInteger i=0; i<ctrls.count; i++ ){
        UIViewController *ctrl = ctrls[i];
        NSString *title = titles[i];
        
        NSString *selectImgName = nil;
        if( i<selectImgNames.count ){
            selectImgName = selectImgNames[i];
        }
        
        NSString *nonSelectImgName = nil;
        if( i<nonSelectImgNames.count ){
            nonSelectImgName = nonSelectImgNames[i];
        }
        [self setTabbarItem:ctrl.tabBarItem title:title selectedImgName:selectImgName nonSeleImgName:nonSelectImgName textColorForNormal:textColor textColorForSelected:selectedTextColor];
    }
    
    [self setViewControllers:ctrls];
    self.tabBar.barTintColor = [UIColor whiteColor];
}

-(void)setTabbarItem:(UITabBarItem*)tabBarItem title:(NSString*)title selectedImgName:(NSString*)sImg nonSeleImgName:(NSString*)nsImg textColorForNormal:(UIColor*)textColor textColorForSelected:(UIColor*)selectedTextColor{
    if( title.length )
        tabBarItem.title = title;
    tabBarItem.image = [[UIImage imageNamed:nsImg] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem.selectedImage = [[UIImage imageNamed:sImg] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontSmall],
                                         NSForegroundColorAttributeName:textColor}
                              forState:UIControlStateNormal];
    [tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontSmall],
                                         NSForegroundColorAttributeName:selectedTextColor}
                              forState:UIControlStateSelected];
}
@end
