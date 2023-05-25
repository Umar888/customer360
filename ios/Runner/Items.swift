//
//  Items.swift
//  Runner
//
//  Created by Arshad on 28/02/2023.
//

import Foundation

struct Items {
    var WarrantyStyleDesc:String?
    var WarrantySkuId:String?
    var WarrantyPrice:Double?
    var WarrantyId:String?
    var warrantyDisplayName:String?
    var UnitPrice:Double?
    var Quantity:Double?
    var Warranties:[Warranties]
    var PimSkuId: String?
    var IsCartAdding:Bool?
    var IsUpdatingCoverage:Bool?
    var IsWarrantiesLoading:Bool?
    var IsExpanded:Bool?
    var IsOverridden: Bool?
}
