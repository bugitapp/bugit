//
//  AppearanceManager.swift
//  bugit
//
//  Created by Bill on 11/30/16.
//  Copyright © 2016 BillLuoma. All rights reserved.
//  Based on https://www.raywenderlich.com/108766/uiappearance-tutorial

import UIKit



class AppearanceManager
{
    
    static func applyBlueTranslucentTheme(window: UIWindow?) {
        
        UINavigationBar.appearance().barStyle = .default
        UINavigationBar.appearance().isTranslucent = true
        //UINavigationBar.appearance().backIndicatorImage = UIImage(named: "backArrow")
        //UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "backArrowMask")
        
        UINavigationBar.appearance().barTintColor = brightBlueThemeColor
        UINavigationBar.appearance().tintColor = lightBlueThemeColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: lightGrayThemeColor, NSFontAttributeName: UIFont(name: "SFUIText-Light", size: 21)!]
        
        
        UIButton.appearance().backgroundColor = brightBlueThemeColor
        UIButton.appearance().tintColor = lightBlueThemeColor
        UILabel.appearance().font = UIFont(name: "SFUIText-Light", size: 17)!
        
        UICollectionView.appearance().backgroundColor = lightLightLightGrayThemeColor
        
        ScreenshotSectionHeaderView.appearance().backgroundColor = lightBlueThemeColor
        
        window?.tintColor = brightBlueThemeColor
        
     
    }

    
}
