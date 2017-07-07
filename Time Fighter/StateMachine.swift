//
//  StateMachine.swift
//  Time Fighter
//
//  Created by Paulo Henrique Favero Pereira on 7/6/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import UIKit


class StateMachine {
    
    public static let walk:  UInt32 = 0b0001
    public static let jump:  UInt32 = 0b0010
    public static let idle:  UInt32 = 0b0100
    public static let shoot: UInt32 = 0b1000
  
    func idleShoot() -> UInt32 {
        
        return (StateMachine.idle | StateMachine.shoot)
    }
    
}
