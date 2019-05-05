//
//  CustomPin.swift
//  Muzinda DevOps
//
//  Created by Casse on 5/5/2019.
//  Copyright © 2019 Casse. All rights reserved.
//

import Foundation
import MapKit

class customPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(pinTitle: String, pinSubtitle: String, location: CLLocationCoordinate2D) {
        
        self.title = pinTitle
        self.subtitle = pinSubtitle
        self.coordinate = location
    }
}
