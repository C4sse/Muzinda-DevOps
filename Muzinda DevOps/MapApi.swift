//
//  MapApi.swift
//  Muzinda DevOps
//
//  Created by Casse on 4/5/2019.
//  Copyright © 2019 Casse. All rights reserved.
//

import Foundation
import Firebase

class MapApi {
    
    var REF_MAPREQ = Database.database().reference().child("requests")
    
    func observeMap(completion: @escaping (MapModel) -> Void) {
        REF_MAPREQ.observe(.childAdded, with: { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let pin = MapModel.stransformMap(dict: dict, key: snapshot.key)
                completion(pin)
            }
        })
    }

}
