//
//  GameElements.swift
//  Time Fighter
//
//  Created by Wilson Martins on 10/07/17.
//  Copyright © 2017 Fera. All rights reserved.
//

import UIKit

class GameElements {
    public static let mainCharacter: UInt32 = 0b000001
    public static let ground: UInt32 = 0b000010
    public static let enemy: UInt32 = 0b000100
    public static let bullet: UInt32 = 0b001000
    public static let boundaries: UInt32 = 0b010000
    public static let camera: UInt32 = 0b100000
    public static let bossDoor: UInt32 = 0b1000000
}
