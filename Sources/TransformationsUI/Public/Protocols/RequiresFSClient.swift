//
//  RequiresFSClient.swift
//  
//
//  Created by Ruben Nine on 29/4/21.
//

import Foundation
import Filestack

protocol RequiresFSClient: AnyObject {
    var fsClient: Filestack.Client? { set get }
}
