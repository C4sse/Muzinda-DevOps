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
    var title: String?
    var address: String?
    var description: String?
    var duration: String?
    var endDate: String?
    var locationSize: String?
    var price: String?
    var startDate: String?
}

extension MapModel {
    
    static func stransformMap(dict: [String: Any], key: String) -> MapModel {
    
    let map = MapModel()
        map.latitude = dict["latitude"] as? Double
        map.longitude = dict["longitude"] as? Double
        map.title = dict["title"] as? String
        map.address = dict["address"] as? String
        map.description = dict["description"] as? String
        map.duration = dict["duration"] as? String
        map.endDate = dict["endDate"] as? String
        map.locationSize = dict["locationSize"] as? String
        map.price = dict["price"] as? String
        map.startDate = dict["startDate"] as? String
    return map
    }
}
