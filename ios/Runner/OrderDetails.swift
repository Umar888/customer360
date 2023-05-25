//
//  OrderDetails.swift
//  Runner
//
//  Created by Arshad on 28/02/2023.
//

import Foundation


struct OrderDetails {
    var Total: Double?
    var TaxExempt: Bool?
    var Tax: Double?
    var Subtotal: Double?
    var StoreId: String?
    var OrderStore: OrderStore?
    var OrderStoreInfo: OrderStoreInfo?
    var SourceCode: String?
    var ShippingZipcode: String?
    var ShippingTax: Double?
    var ShippingState: String?
    var ShippingMethodNumber: String?
    var ShippingMethod:String?
    var ShippingFee: Double?
    var ShippingEmail:String?
    var ShippingCountry:String?
    var ShippingCity:String?
    var ShippingAndHandling:Double?
    var PaymentMethods:[PaymentMethods]?
    var ShippingAdjustment:Double?
    var ShippingAddress2:String?
    var ShippingAddress:String?
    var ShipmentOverrideReason:String?
    var SelectedStoreCity:String?
    var Phone:String?
    var PaymentMethodTotal:Double?
    var OrderOverrideReason:String?
    var OrderNumber:String?
    var OrderDate:String?
    var OrderCreatedDate:String?
    var OrderApprovalRequest:String?
    var OrderAdjustment:String?
    var MiddleName:String?
    var Lastname:String?
    var Items:[Items]?
    var FirstName:String?
    var DiscountType: String?
    var Discounts:String?
    var DiscountCodes: String?
    var DiscountCode: String?
    var Discount: Double?
    var TotalDiscount: Double?
    var TotalLineDiscount: Double?
    var DeliveryOption:  String?
    var DeliveryFeeEligible: Bool?
    var CustomerId: String?
    var BrandCode:  String?
    var BillingZipcode: String?
    var BillingState: String?
    var BillingPhone: String?
    var BillingEmail: String?
    var BillingCountry: String?
    var BillingCity: String?
    var BillingAddress2: String?
    var BillingAddress: String?
    var ApprovalRequest: String?
    var OrderStatus: String?
    
    
     
}



