//
//  AchiviementsHelper.swift
//  Time Fighter
//
//  Created by Paulo Henrique Favero Pereira on 7/24/17.
//  Copyright © 2017 Fera. All rights reserved.
//


import Foundation
import GameKit

class AchievementsHelper {
    
    static let FaceTheDeathAchievementId =
    "grp.com.patachu.TimeNator.facethedeath"
    
    class func godsAchievement(godName: String)
        -> GKAchievement {
            
            //2
            let godsAchievement = GKAchievement(
                identifier: AchievementsHelper.FaceTheDeathAchievementId)
            
            //3
            godsAchievement.showsCompletionBanner = true
            return godsAchievement
            
    }
    
}
