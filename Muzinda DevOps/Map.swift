//
//  Map.swift
//  Muzinda DevOps
//
//  Created by Casse on 4/5/2019.
//  Copyright © 2019 Casse. All rights reserved.
//

import Foundation
class MapModel {
    
    var latitude: Double?
    var longitude: Double?
    var name: String?
}

extension MapModel {
    
    static func stransformMap(dict: [String: Any], key: String) -> MapModel {
    
    let map = MapModel()
        map.latitude = dict["latitude"] as? Double
        map.longitude = dict["longitude"] as? Double
        map.name = dict["name"] as? String
    return map
    }
}
