import UIKit
import Flutter
import MSAL
import Firebase
import GoogleMaps


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, Epos2PtrReceiveDelegate {
    
    let PAGE_AREA_HEIGHT: Int = 500
    let PAGE_AREA_WIDTH: Int = 500
    let FONT_A_HEIGHT: Int = 24
    let FONT_A_WIDTH: Int = 12
    let BARCODE_HEIGHT_POS: Int = 70
    let BARCODE_WIDTH_POS: Int = 110
    
    
    var printer: Epos2Printer?
    
    var valuePrinterSeries: Epos2PrinterSeries = EPOS2_TM_M30II
    var valuePrinterModel: Epos2ModelLang = EPOS2_MODEL_ANK
    
    private var eventChannel: FlutterEventChannel?
    private let linkStreamHandler = LinkStreamHandler()
    
    let result = Epos2Log.setLogSettings(EPOS2_PERIOD_TEMPORARY.rawValue, output: EPOS2_OUTPUT_STORAGE.rawValue, ipAddress:nil, port:0, logSize:1, logLevel:EPOS2_LOGLEVEL_LOW.rawValue)
    
    
    func onPtrReceive(_ printerObj: Epos2Printer!, code: Int32, status: Epos2PrinterStatusInfo!, printJobId: String!) {
        let queue = OperationQueue()
        queue.addOperation({ [self] in
            self.disconnectPrinter()
        })
    }
    
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GMSServices.provideAPIKey("AIzaSyCR2Kkq0xSfZLvoM0LBoSgp1XRPlOg17SQ")
        FirebaseApp.configure()
        GeneratedPluginRegistrant.register(with: self)
        
        // 1
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        let deviceChannel = FlutterMethodChannel(name: "com.guitarcenter.uatcustomer360/iOS",
                                                 binaryMessenger: controller.binaryMessenger)
//
//        methodChannel = FlutterMethodChannel(name: "com.guitarcenter.uatcustomer360/iOS", binaryMessenger: controller.binaryMessenger)
        eventChannel = FlutterEventChannel(name: "guitarcenter/events", binaryMessenger: controller.binaryMessenger)
        
        
        prepareMethodHandler(deviceChannel: deviceChannel)
        eventChannel?.setStreamHandler(linkStreamHandler)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      eventChannel?.setStreamHandler(linkStreamHandler)
      linkStreamHandler.handleLink(url.absoluteString)
      return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
    }
    
    class LinkStreamHandler:NSObject, FlutterStreamHandler {

      var eventSink: FlutterEventSink?

      // links will be added to this queue until the sink is ready to process them
      var queuedLinks = [String]()

      func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        queuedLinks.forEach({ events($0) })
        queuedLinks.removeAll()
        return nil
      }

      func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
      }

      func handleLink(_ link: String) -> Bool {
        guard let eventSink = eventSink else {
          queuedLinks.append(link)
          return false
        }
        eventSink(link)
        return true
      }
    }


    
    private func prepareMethodHandler(deviceChannel: FlutterMethodChannel) {
        deviceChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            
            if call.method == "printOrder" {
                
                guard let args = call.arguments as? [String : Any] else {return}
                let ipAddress = args["ipAddresss"] as? String
                guard let orderDetails = args["orderDetails"] as? [String:AnyObject] else {
                    self.receiveDeviceModel(result: result, status: "Order Details are not correct")
                    return
                }
                guard let paymentDetails = args["paymentInfo"] as? [[String:AnyObject]] else {
                    self.receiveDeviceModel(result: result, status: "Payment Info are not correct")
                    return
                }
                
                guard let storeAddress = args["storeAddress"] as? [String:AnyObject] else {
                    self.receiveDeviceModel(result: result, status: "Store Address are not found.")
                    return
                }
                
                if(self.initializePrinterObject()){
                    if(self.runPrinterReceiptSequence(result: result, ipAddress: ipAddress ?? "", orderDetails: orderDetails, paymentDetails: paymentDetails,storeAddress: storeAddress )){
                        self.receiveDeviceModel(result: result, status: "Printed Successfully")
                    } else{
                        self.receiveDeviceModel(result: result, status: "Failed")
                    }
                } else{
                    //                        self.initializePrinterObject()
                    self.receiveDeviceModel(result: result, status: "Failed")
                }
                
            } else if call.method == "getDevices" {
                
//               let deviceTest = PrinterDeviceInfo(key: "Testt", value: "192.168.1.219", hashCode: 2751563630)
                
                var wifiDevices: [PrinterDeviceInfo] = []
//                wifiDevices.append(deviceTest)

                let delegate = PrinterDiscoveryDelegate()
                delegate.onDiscoveryCallback = { deviceInfo in
                    // Handle discovered printer
                    wifiDevices.append(PrinterDeviceInfo(key: deviceInfo.deviceName, value: deviceInfo.ipAddress, hashCode: 2751563630))
                    
                }
                delegate.onDiscoveryCompleteCallback = { devices in
                    // Handle discovery complete
                    wifiDevices = devices.map { PrinterDeviceInfo(key: $0.deviceName, value: $0.ipAddress, hashCode: 2751563630) }

                }
                
                // Set the filter option to search for only WiFi printers
                let filterOption = Epos2FilterOption()
                filterOption.deviceType = EPOS2_TYPE_ALL.rawValue
                
                let timeout = DispatchTime.now() + .seconds(2)
                let semaphore = DispatchSemaphore(value: 0)

                // Start the printer search with the filter option and delegate
                Epos2Discovery.start(filterOption, delegate: delegate)
                
                DispatchQueue.global().asyncAfter(deadline: timeout) {
                    semaphore.signal()
                }

                semaphore.wait()
                
                Epos2Discovery.stop()
                
                let jsonDevices = try? JSONEncoder().encode(wifiDevices)
                    let jsonString = String(data: jsonDevices!, encoding: .utf8)
                    // Return the JSON string via the platform channel
                    result(jsonString)
                
            } else if call.method == "getPrintData" {
                guard let args = call.arguments as? [String : Any] else {return}
                
                let ipAddress = args["ipAddresss"] as? String
                guard let orderDetails = args["orderDetails"] as? [String:AnyObject] else {
                    self.receiveDeviceModel(result: result, status: "Order Details are not correct")
                    return
                }
                guard let paymentDetails = args["paymentInfo"] as? [[String:AnyObject]] else {
                    self.receiveDeviceModel(result: result, status: "Payment Info are not correct")
                    return
                }
                
                guard let storeAddress = args["storeAddress"] as? [String:AnyObject] else {
                    self.receiveDeviceModel(result: result, status: "Store Address are not found.")
                    return
                }
                
                let samplePrintData = self.createSampleReceiptData(orderDetails: orderDetails, paymentDetails: paymentDetails, storeAddress: storeAddress)
                
                result(samplePrintData)
                
            } else if call.method == "initialLink" {
                
            } else {
                result(FlutterMethodNotImplemented)
                return
            }
        })
    }
    
    private func receiveDeviceModel(result: FlutterResult, status: String) {
//        let deviceModel = UIDevice.current.model
        result(status)
    }
    
    func runPrinterReceiptSequence(result: FlutterResult, ipAddress: String, orderDetails: [String:AnyObject], paymentDetails: [[String:AnyObject]], storeAddress: [String:AnyObject] ) -> Bool {
        if !createReceiptData(orderDetails: orderDetails, paymentDetails: paymentDetails, storeAddress: storeAddress) {
            self.receiveDeviceModel(result: result, status: "Failed")
            return false
        }
        
        if !printData(ipAddress: ipAddress) {
            self.receiveDeviceModel(result: result, status: "Failed")
            return false
        }
        
       
        
        return true
    }
    
    @discardableResult
    func initializePrinterObject() -> Bool {
        printer = Epos2Printer(printerSeries: valuePrinterSeries.rawValue, lang: valuePrinterModel.rawValue)
        
        if printer == nil {
            return false
        }
        printer!.setReceiveEventDelegate(self)
        
        return true
    }
    func connectPrinter(target: String) -> Bool {
        var result: Int32 = EPOS2_SUCCESS.rawValue
        
        if printer == nil {
            return false
        }
        
        //Note: This API must be used from background thread only
        result = printer!.connect(target, timeout:Int(EPOS2_PARAM_DEFAULT))
        if result != EPOS2_SUCCESS.rawValue {
            //            MessageView.showErrorEpos(result, method:"connect")
            return false
        }
        
        return true
    }
    
    func disconnectPrinter() {
        var result: Int32 = EPOS2_SUCCESS.rawValue
        
        if printer == nil {
            return
        }
        
        //Note: This API must be used from background thread only
        result = printer!.disconnect()
                if result != EPOS2_SUCCESS.rawValue {
//                    DispatchQueue.main.async(execute: {
//                        MessageView.showErrorEpos(result, method:"disconnect")
//                    })
                }
        
        printer!.clearCommandBuffer()
    }
    
    func printData(ipAddress: String) -> Bool {
        if printer == nil {
            return false
        }
        
        if !connectPrinter(target: ipAddress) {
            printer!.clearCommandBuffer()
            return false
        }
        
        let result = printer!.sendData(Int(EPOS2_PARAM_DEFAULT))
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            //            MessageView.showErrorEpos(result, method:"sendData")
            printer!.disconnect()
            return false
        }
        
        return true
    }
    
    func formatDouble(value: Double) -> String {
        return String(format: "%.2f", value);
    }
    
    func getObjectFromJsonString(arrayString:String)-> [String : AnyObject] {
        var emptyDictionary = [String: AnyObject]()
        do {
            return try  JSONSerialization.jsonObject(with:
            arrayString.data(using:
            String.Encoding.utf8, allowLossyConversion: false)!,
            options:
            JSONSerialization.ReadingOptions.allowFragments) as? [String :
                                                                    AnyObject] ?? emptyDictionary
        } catch _ {
            return emptyDictionary;
        }
    }
    
    func createReceiptData(orderDetails: [String:AnyObject], paymentDetails: [[String:AnyObject]], storeAddress:[String:AnyObject]) -> Bool {
        
        // Set the font size to normal
        
        var result = EPOS2_SUCCESS.rawValue
                
        result = printer!.addTextFont(EPOS2_FONT_A.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            //            MessageView.showErrorEpos(result, method:"addTextAlign")
            return false;
        }
        
        result = printer!.addTextStyle(EPOS2_FALSE, ul: EPOS2_FALSE, em: EPOS2_TRUE, color: EPOS2_COLOR_1.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            //            MessageView.showErrorEpos(result, method:"addTextAlign")
            return false;
        }
        

        
        let textData: NSMutableString = NSMutableString()
        let logoData = UIImage(named: "store2.png")

        if logoData == nil {
            return false
        }
        
        result = printer!.addTextAlign(EPOS2_ALIGN_CENTER.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            //            MessageView.showErrorEpos(result, method:"addTextAlign")
            return false;
        }
        
        // Specify logo position and size// in dots
        
        result = printer!.add(logoData, x: 0, y:0,
                              width:Int(logoData!.size.width),
                              height:Int(logoData!.size.height),
                              color:EPOS2_COLOR_1.rawValue,
                              mode:EPOS2_MODE_MONO.rawValue,
                              halftone:EPOS2_HALFTONE_DITHER.rawValue,
                              brightness:Double(EPOS2_PARAM_DEFAULT),
                              compress:EPOS2_COMPRESS_AUTO.rawValue)
        
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            //            MessageView.showErrorEpos(result, method:"addImage")
            return false
        }
        
        let items = orderDetails["Items"] as? [[String:AnyObject]]
        
        let salesDate = orderDetails["OrderDate"] as? String
        let salesNumber = orderDetails["OrderNumber"] as? String
//        let salesType = orderDetails["SourceCode"] as? String
        

        let subtotal = self.formatDouble(value: (orderDetails["Subtotal"] as? Double ?? 0.0))
        let discount = self.formatDouble(value: (orderDetails["TotalDiscount"] as? Double ?? 0.0))
        let shippingAndHandling = self.formatDouble(value: (orderDetails["ShippingAndHandling"] as? Double ?? 0.0))
        
        let tax = self.formatDouble(value: (orderDetails["Tax"] as? Double ?? 0.0))
        let total = self.formatDouble(value: (orderDetails["Total"] as? Double ?? 0.0))
        
        let ShippingZipcode = orderDetails["ShippingZipcode"] as? String ?? ""
//        let ShippingTax = orderDetails["ShippingTax"] as? Double ?? 0.0
        let ShippingState = orderDetails["ShippingState"] as? String ?? ""
//        let ShippingMethodNumber = orderDetails["ShippingMethodNumber"] as? String ?? ""
//        let ShippingMethod = orderDetails["ShippingMethod"] as? String
//        let ShippingFee = orderDetails["ShippingFee"] as? Double
//        let ShippingEmail = orderDetails["ShippingEmail"] as? String
        let ShippingCountry = orderDetails["ShippingCountry"] as? String ?? ""
        let ShippingCity = orderDetails["ShippingCity"] as? String ?? ""
//        let ShippingAdjustment = orderDetails["ShippingAdjustment"] as? String ?? ""
        let ShippingAddress2 = orderDetails["ShippingAddress2"] as? String ?? ""
        let ShippingAddress = orderDetails["ShippingAddress"] as? String ?? ""
        let Phone = orderDetails["Phone"] as? String ?? ""
        let Lastname = orderDetails["Lastname"] as? String ?? ""
        let FirstName = orderDetails["FirstName"] as? String ?? ""
        
        var BillingCountry = ""
        var BillingAddress =  ""
        var BillingAddress2 =  ""
        var BillingState = ""
        var BillingZipCode = ""
        var BillingCity =  ""
        var BillingFirstName = ""
        var BillingLastName = ""
        var BillingPhone = ""
        
//        var StoreCountry = ""
        var StoreAddress =  "7425 Sunset Blvd"
        var StoreState = "CA"
        var StoreZipCode = "90046-3403"
        var StoreCity =  "Hollywood"
        var StoreName = "hollywood"
        var StorePhone = "323-874-1069"

        
        
        // Section 1 : Store information
        result = printer!.addFeedLine(1)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            //            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false
        }
        
        StoreAddress = storeAddress["StoreAddress__c"] as? String ?? ""
        StoreState = storeAddress["State__c"] as? String ?? ""
        StoreZipCode = storeAddress["PostalCode__c"] as? String ?? ""
        StoreCity = storeAddress["StoreCity__c"] as? String ?? ""
        StoreName = storeAddress["StoreName__c"] as? String ?? ""
        StorePhone = storeAddress["Phone__c"] as? String ?? ""
        
        textData.append("\(StoreName)\n")
        textData.append("\(StoreAddress),\n")
        textData.append("\(StoreCity), \(StoreState), \(StoreZipCode),\n")
        textData.append("\(StorePhone)")
        textData.append("\n")
        textData.append("\n")
        result = printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            return false;
        }
        result = printer!.addTextAlign(EPOS2_ALIGN_LEFT.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            return false;
        }
        textData.setString("")
        result = printer!.addText("Sales Date   :".padding(toLength: 16, withPad: " ", startingAt: 0) + "\(salesDate ?? "")\n")
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            return false;
        }
        result = printer!.addText("Sales No     :".padding(toLength: 16, withPad: " ", startingAt: 0) + "\(salesNumber ?? "")\n")
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            return false;
        }
        result = printer!.addText("Sales Type   :".padding(toLength: 16, withPad: " ", startingAt: 0) + "SF SPO\n")
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            return false;
        }
        textData.append("\n")
        textData.append("\n")
        result = printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            return false;
        }
        textData.setString("")

        // Section 2 : Purchaced items
        
        
        
        result = printer!.addText("QTY".padding(toLength: 6, withPad: " ", startingAt: 0)+"DESCRIPTION".padding(toLength: 30, withPad: " ", startingAt: 0) + "EXT AMT\n")

        result = printer!.addFeedLine(1)
        if result != EPOS2_SUCCESS.rawValue {
            return false;
        }
        
        let quantityWidth = 6 // Adjust to fit your printer
        let nameWidth = 28 // Adjust to fit your printer
        let priceWidth = 10 // Adjust to fit your printer
        
//        var warrantyTotalPrice: Double = 0.0
        
        for item in items ?? [] {
            let unitPrice = item["UnitPrice"] as? Double ?? 0.0
            let warrantyPrice = item["WarrantyPrice"] as? Double ?? 0.0
            let quantity = item["Quantity"] as? Int ?? 1
            let ItemDesc = item["ItemDesc"] as? String ?? ""
            let OverridePriceApproval = item["OverridePriceApproval"] as? String ?? ""
            let OverridePrice = item["OverridePrice"] as? Double ?? 0.0
            let itemTotalPrice = self.formatDouble(value: (unitPrice));
            let warrantyDisplayName = item["WarrantyDisplayName"] as? String ?? ""
//            warrantyTotalPrice = warrantyTotalPrice + (warrantyPrice * Double(quantity))
            
            let quantityLines = self.splitTextIntoLines(text: "\(quantity)", maxLineLength: quantityWidth)
            let nameLines = self.splitTextIntoLines(text: ItemDesc, maxLineLength: nameWidth)
            let priceLines = self.splitTextIntoLines(text: "$\(itemTotalPrice)", maxLineLength: priceWidth)
            
            if(OverridePrice > 0 && OverridePriceApproval == "Approved"){
               let overridePrice = self.formatDouble(value: (OverridePrice));
              
//                priceLines = self.splitTextIntoLines(text: "$\(itemTotalPrice) $\(overridePrice)", maxLineLength: priceWidth)
                for i in 0..<max(nameLines.count, quantityLines.count) {
                    let quantityValue = quantityLines.count > i ? quantityLines[i] : "      "
                    let descValue = nameLines.count > i ? nameLines[i] : ""
//                    let amountValue = priceLines.count > i ? priceLines[i] : ""
                    if(i == 0){
                        let line = "\(quantityValue)".padding(toLength: 6, withPad: " ", startingAt: 0)+"\(descValue)".padding(toLength: 30, withPad: " ", startingAt: 0)+"$\(itemTotalPrice)"
                        result = printer!.addText(line)
                        if result != EPOS2_SUCCESS.rawValue {
                            printer!.clearCommandBuffer()
                            return false;
                        }
                        
                        result = printer!.addHPosition(0)

                        if result != EPOS2_SUCCESS.rawValue {
                            printer!.clearCommandBuffer()
                            return false;
                        }
                        
                        
                        result = printer!.addTextStyle(EPOS2_FALSE, ul: EPOS2_FALSE, em: EPOS2_TRUE, color: EPOS2_COLOR_1.rawValue)
                        if result != EPOS2_SUCCESS.rawValue {
                            //            MessageView.showErrorEpos(result, method:"addTextAlign")
                            return false;
                        }
                        
                        
                        let strikeThrough = "".padding(toLength: 36, withPad: " ", startingAt: 0) + String(repeating: "=", count: (itemTotalPrice.count + 1))
                            
                        result = printer!.addText(strikeThrough)
                            
                        if result != EPOS2_SUCCESS.rawValue {
                                printer!.clearCommandBuffer()
                                    return false;
                        }
                        
                        result = printer!.addFeedLine(1)
                        if result != EPOS2_SUCCESS.rawValue {
                            printer!.clearCommandBuffer()
                            return false;
                        }
                        
                        
                        if(nameLines.count == 1){
                            let line = "".padding(toLength: 6, withPad: " ", startingAt: 0)+"".padding(toLength: 30, withPad: " ", startingAt: 0) +  "$\(overridePrice)\n"
                            result = printer!.addText(line)
                            if result != EPOS2_SUCCESS.rawValue {
                                printer!.clearCommandBuffer()
                                return false;
                            }
                        }
                    } else if(i == 1) {
                        let line = "\(quantityValue)".padding(toLength: 6, withPad: " ", startingAt: 0)+"\(descValue)".padding(toLength: 30, withPad: " ", startingAt: 0) +  "$\(overridePrice)\n"
                        result = printer!.addText(line)
                        if result != EPOS2_SUCCESS.rawValue {
                            printer!.clearCommandBuffer()
                            return false;
                        }
                    } else {
                        let line = "\(quantityValue)".padding(toLength: 6, withPad: " ", startingAt: 0)+"\(descValue)".padding(toLength: 30, withPad: " ", startingAt: 0) +  "\n"
                        result = printer!.addText(line)
                        if result != EPOS2_SUCCESS.rawValue {
                            printer!.clearCommandBuffer()
                            return false;
                        }
                    }
                }
            } else {
                for i in 0..<max(nameLines.count, priceLines.count) {
                    let quantityValue = quantityLines.count > i ? quantityLines[i] : ""
                    let descValue = nameLines.count > i ? nameLines[i] : ""
                    let amountValue = priceLines.count > i ? priceLines[i] : ""
                    let line = "\(quantityValue)".padding(toLength: 6, withPad: " ", startingAt: 0)+"\(descValue)".padding(toLength: 30, withPad: " ", startingAt: 0) +  "\(amountValue)\n"
                    result = printer!.addText(line)
                    if result != EPOS2_SUCCESS.rawValue {
                        printer!.clearCommandBuffer()
                        return false;
                    }
                }
            }
            
            if(warrantyPrice > 0){
                let proCoverage = self.formatDouble(value: warrantyPrice)
                let proCoverageDisplayNameLines = self.splitTextIntoLines(text: "\(warrantyDisplayName)", maxLineLength: nameWidth)
                let proCoveragePriceLines = self.splitTextIntoLines(text: "$\(proCoverage)", maxLineLength: priceWidth)
                
                for i in 0..<max(proCoverageDisplayNameLines.count, proCoveragePriceLines.count) {
                    let quantityValue = quantityLines.count > i ? quantityLines[i] : ""
                    let proCoverageDescValue = proCoverageDisplayNameLines.count > i ? proCoverageDisplayNameLines[i] : ""
                    let proCoverageAmountValue = proCoveragePriceLines.count > i ? proCoveragePriceLines[i] : ""
                    let line = "\(quantityValue)".padding(toLength: 6, withPad: " ", startingAt: 0)+"\(proCoverageDescValue)".padding(toLength: 30, withPad: " ", startingAt: 0) +  "\(proCoverageAmountValue)\n"
                    result = printer!.addText(line)
                    if result != EPOS2_SUCCESS.rawValue {
                        printer!.clearCommandBuffer()
                        return false;
                    }
                }
                                
                // Section 3 : Payment infomation
//                result = printer!.addText("Pro Coverage  :".padding(toLength: 38, withPad: " ", startingAt: 0) + "$\(proCoverage)\n")
//                if result != EPOS2_SUCCESS.rawValue {
//                    printer!.clearCommandBuffer()
//                    return false;
//                }
            }
        }
        
        result = printer!.addFeedLine(2)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            return false;
        }
        
        // Section 3 : Payment infomation
        result = printer!.addText("Subtotal  :".padding(toLength: 30, withPad: " ", startingAt: 0) + "$\(subtotal)\n")
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            return false;
        }
        result = printer!.addText("Discount  :".padding(toLength: 30, withPad: " ", startingAt: 0) + "($\(discount))\n")
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            return false;
        }
        result = printer!.addText("Shipping & Handling  :".padding(toLength: 30, withPad: " ", startingAt: 0) + "$\(shippingAndHandling)\n")
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            return false;
        }
        result = printer!.addText("Sales Tax  :".padding(toLength: 30, withPad: " ", startingAt: 0) + "$\(tax)\n")
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            return false;
        }
        result = printer!.addText("Total     :".padding(toLength: 30, withPad: " ", startingAt: 0) + "$\(total)\n\n")
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            return false;
        }
//        textData.append("Discount  :             \(discount)\n");
//        textData.append("Shipping & Handling  :  \(shippingAndHandling)\n");
//        textData.append("Total     :             \(total)\n");
        for paymentDetail in paymentDetails {
            let lastDigit = paymentDetail["Last_digit"] as? String ?? ""
            let paymentMethod = paymentDetail["PaymentMethod"] as? [String:AnyObject]
            let BillingPaymentMethod = paymentMethod?["Payment_Method__c"] as? String ?? ""
            let Amount = paymentMethod?["Amount__c"] as? String ?? ""
            if(BillingPaymentMethod == "Credit Card" || BillingCountry == ""){
                BillingCountry = paymentMethod?["Country__c"] as? String ?? BillingCountry
            }
            if(BillingPaymentMethod == "Credit Card" || BillingAddress == ""){
                BillingAddress = paymentMethod?["Address__c"] as? String ?? BillingAddress
            }
            if(BillingPaymentMethod == "Credit Card" || BillingAddress2 == ""){
                BillingAddress2 = paymentMethod?["Address_2__c"] as? String ?? BillingAddress2
            }
            if(BillingPaymentMethod == "Credit Card" || BillingState == ""){
                BillingState = paymentMethod?["State__c"] as? String ?? BillingState
            }
            if(BillingPaymentMethod == "Credit Card" || BillingZipCode == ""){
                BillingZipCode = paymentMethod?["Zip_Code__c"] as? String ?? BillingZipCode
            }
            if(BillingPaymentMethod == "Credit Card" || BillingCity == ""){
                BillingCity = paymentMethod?["City__c"] as? String ?? BillingCity
            }
            if(BillingPaymentMethod == "Credit Card" || BillingFirstName == ""){
                BillingFirstName = paymentMethod?["First_Name__c"] as? String ?? BillingFirstName
            }
            if(BillingPaymentMethod == "Credit Card" || BillingLastName == ""){
                BillingLastName = paymentMethod?["Last_Name__c"] as? String ?? BillingLastName
            }
            if(BillingPaymentMethod == "Credit Card" || BillingPhone == ""){
                BillingPhone = paymentMethod?["Phone__c"] as? String ?? BillingPhone
            }
            textData.append("Paid By \(BillingPaymentMethod) \(lastDigit)  :".padding(toLength: 30, withPad: " ", startingAt: 0) + "$\(Amount)\n");
        }
        textData.append("\n");
        textData.append("\n");
        result = printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            //            MessageView.showErrorEpos(result, method:"addText")
            return false
        }
        textData.setString("")
        
        result = printer!.addFeedLine(1)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            //            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false;
        }
        result = printer!.addTextAlign(EPOS2_ALIGN_CENTER.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            //            MessageView.showErrorEpos(result, method:"addTextAlign")
            return false;
        }
        textData.append("Shipping & Billing Information\n\n")
        result = printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            //            MessageView.showErrorEpos(result, method:"addText")
            return false
        }
        textData.setString("")
        result = printer!.addTextAlign(EPOS2_ALIGN_LEFT.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            return false;
        }
        textData.append("Ship To: \(FirstName ) \(Lastname ),\n")
        textData.append("\(ShippingAddress ),\n")
        textData.append("\(ShippingAddress2),\(ShippingCity),\(ShippingState) \(ShippingZipcode),\n")
//        textData.append("\(ShippingCountry),\n")
        textData.append("\(Phone)\n")
        textData.append("\n")
        textData.append("\n")
        textData.append("Bill To: \(BillingFirstName) \(BillingLastName),\n")
        textData.append("\(BillingAddress),\n")
        textData.append("\(BillingAddress2),\(BillingCity),\(BillingState) \(BillingZipCode),\n")
//        textData.append("\(BillingCountry),\n")
        textData.append("\(BillingPhone)\n\n")
        result = printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            //            MessageView.showErrorEpos(result, method:"addText")
            return false
        }
        textData.setString("")
        
        // Section 4 : Advertisement
        textData.append("Thank You for Shopping at Guitar Center\n\n")
        textData.append("Buy Online Now at www.guitarcenter.com !\n")
        textData.append("Or call 1-666-498-7882\n")
        textData.append("WE LOVE FEEDBACK. Tell us yours at\n")
        textData.append("www.guitarcenter.com/pages/Store -Feedback.\n\n")
        textData.append("To view our Low Price Gurantee, Return Policy,\n")
        textData.append("Repair Terms and others comsumer policies,\n")
        textData.append("please go to\n")
        textData.append("www.guitarcenter.com/pages/terms-of-use.\n\n")
        textData.append("Like Us: facebook.com/guitarcenter,\n")
        textData.append("Follow Us on Twitter/Instagram : @guitarcenter\n")
        textData.append("Subscribe to us youtube.com/guitarcenter\n\n")
        result = printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            //            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        textData.setString("")
        
        result = printer!.addFeedLine(2)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            //            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false
        }
        
        result = printer!.addCut(EPOS2_CUT_FEED.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            printer!.clearCommandBuffer()
            //            MessageView.showErrorEpos(result, method:"addCut")
            return false
        }
        
        return true
    }
    
    func createSampleReceiptData(orderDetails: [String:AnyObject], paymentDetails: [[String:AnyObject]], storeAddress:[String:AnyObject]) -> String {
        
        
        let textData: NSMutableString = NSMutableString()
       
        
        let items = orderDetails["Items"] as? [[String:AnyObject]]
        
        let salesDate = orderDetails["OrderDate"] as? String
        let salesNumber = orderDetails["OrderNumber"] as? String
//        let salesType = orderDetails["SourceCode"] as? String
        

        let subtotal = self.formatDouble(value: (orderDetails["Subtotal"] as? Double ?? 0.0))
        let discount = self.formatDouble(value: (orderDetails["TotalDiscount"] as? Double ?? 0.0))
        let shippingAndHandling = self.formatDouble(value: (orderDetails["ShippingAndHandling"] as? Double ?? 0.0))
        
        let tax = self.formatDouble(value: (orderDetails["Tax"] as? Double ?? 0.0))
        let total = self.formatDouble(value: (orderDetails["Total"] as? Double ?? 0.0))
        
        let ShippingZipcode = orderDetails["ShippingZipcode"] as? String ?? ""
//        let ShippingTax = orderDetails["ShippingTax"] as? Double ?? 0.0
        let ShippingState = orderDetails["ShippingState"] as? String ?? ""
//        let ShippingMethodNumber = orderDetails["ShippingMethodNumber"] as? String ?? ""
//        let ShippingMethod = orderDetails["ShippingMethod"] as? String
//        let ShippingFee = orderDetails["ShippingFee"] as? Double
//        let ShippingEmail = orderDetails["ShippingEmail"] as? String
        let ShippingCountry = orderDetails["ShippingCountry"] as? String ?? ""
        let ShippingCity = orderDetails["ShippingCity"] as? String ?? ""
//        let ShippingAdjustment = orderDetails["ShippingAdjustment"] as? String ?? ""
        let ShippingAddress2 = orderDetails["ShippingAddress2"] as? String ?? ""
        let ShippingAddress = orderDetails["ShippingAddress"] as? String ?? ""
        let Phone = orderDetails["Phone"] as? String ?? ""
        let Lastname = orderDetails["Lastname"] as? String ?? ""
        let FirstName = orderDetails["FirstName"] as? String ?? ""
        
        var BillingCountry = ""
        var BillingAddress =  ""
        var BillingAddress2 =  ""
        var BillingState = ""
        var BillingZipCode = ""
        var BillingCity =  ""
        var BillingFirstName = ""
        var BillingLastName = ""
        var BillingPhone = ""
        
//        var StoreCountry = ""
        var StoreAddress =  "7425 Sunset Blvd"
        var StoreState = "CA"
        var StoreZipCode = "90046-3403"
        var StoreCity =  "Hollywood"
        var StoreName = "hollywood"
        var StorePhone = "323-874-1069"

        
        
        StoreAddress = storeAddress["StoreAddress__c"] as? String ?? ""
        StoreState = storeAddress["State__c"] as? String ?? ""
        StoreZipCode = storeAddress["PostalCode__c"] as? String ?? ""
        StoreCity = storeAddress["StoreCity__c"] as? String ?? ""
        StoreName = storeAddress["StoreName__c"] as? String ?? ""
        StorePhone = storeAddress["Phone__c"] as? String ?? ""
        
        textData.append("\(StoreName)\n")
        textData.append("\(StoreAddress),\n")
        textData.append("\(StoreCity), \(StoreState), \(StoreZipCode),\n")
        textData.append("\(StorePhone)")
        textData.append("\n")
        textData.append("\n")
        textData.append("Sales Date   :".padding(toLength: 16, withPad: " ", startingAt: 0) + "\(salesDate ?? "")\n")
        textData.append("Sales No     :".padding(toLength: 16, withPad: " ", startingAt: 0) + "\(salesNumber ?? "")\n")
        textData.append("Sales Type   :".padding(toLength: 16, withPad: " ", startingAt: 0) + "SF SPO\n")
        textData.append("\n")
        textData.append("\n")
        
        textData.append("QTY".padding(toLength: 6, withPad: " ", startingAt: 0)+"DESCRIPTION".padding(toLength: 46, withPad: " ", startingAt: 0) + "EXT AMT\n")

     
        let quantityWidth = 6 // Adjust to fit your printer
        let nameWidth = 25 // Adjust to fit your printer
        let priceWidth = 10 // Adjust to fit your printer
        
        
        for item in items ?? [] {
            let unitPrice = item["UnitPrice"] as? Double ?? 0.0
            let warrantyPrice = item["WarrantyPrice"] as? Double ?? 0.0
            let quantity = item["Quantity"] as? Int ?? 1
            let ItemDesc = item["ItemDesc"] as? String ?? ""
            let OverridePriceApproval = item["OverridePriceApproval"] as? String ?? ""
            let OverridePrice = item["OverridePrice"] as? Double ?? 0.0
            var itemTotalPrice = self.formatDouble(value: (unitPrice));
//            warrantyTotalPrice = warrantyTotalPrice + (warrantyPrice * Double(quantity))
            let warrantyDisplayName = item["WarrantyDisplayName"] as? String ?? ""
            
            let quantityLines = self.splitTextIntoLines(text: "\(quantity)", maxLineLength: nameWidth)
            let nameLines = self.splitTextIntoLines(text: ItemDesc, maxLineLength: nameWidth)
            var priceLines = self.splitTextIntoLines(text: "$\(itemTotalPrice)", maxLineLength: nameWidth)
            
            if(OverridePrice > 0 && OverridePriceApproval == "Approved"){
               let overridePrice = self.formatDouble(value: (OverridePrice));
              
                priceLines = self.splitTextIntoLines(text: "$\(overridePrice) (\u{001B}|sC$\(itemTotalPrice)\u{001B}|N", maxLineLength: nameWidth)
                for i in 0..<max(nameLines.count, priceLines.count) {
                    let quantityValue = quantityLines.count > i ? quantityLines[i] : "      "
                    let descValue = nameLines.count > i ? nameLines[i] : ""
                    let amountValue = priceLines.count > i ? priceLines[i] : ""
                    let line = "\(quantityValue)".padding(toLength: 6, withPad: " ", startingAt: 0)+"\(descValue)".padding(toLength: 46, withPad: " ", startingAt: 0) + "\(amountValue)\n"
                    textData.append(line)
                }
            } else {
                for i in 0..<max(nameLines.count, priceLines.count) {
                    let quantityValue = quantityLines.count > i ? quantityLines[i] : ""
                    let descValue = nameLines.count > i ? nameLines[i] : ""
                    let amountValue = priceLines.count > i ? priceLines[i] : ""
                    let line = "\(quantityValue)".padding(toLength: 6, withPad: " ", startingAt: 0)+"\(descValue)".padding(toLength: 46, withPad: " ", startingAt: 0) +  "\(amountValue)\n"
                    textData.append(line)
                }
            }
            
            if(warrantyPrice > 0){
                let proCoverage = self.formatDouble(value: warrantyPrice)
                let proCoverageDisplayNameLines = self.splitTextIntoLines(text: "\(warrantyDisplayName)", maxLineLength: nameWidth)
                var proCoveragePriceLines = self.splitTextIntoLines(text: "$\(proCoverage)", maxLineLength: priceWidth)
                
                for i in 0..<max(proCoverageDisplayNameLines.count, proCoveragePriceLines.count) {
                    let quantityValue = quantityLines.count > i ? quantityLines[i] : ""
                    let proCoverageDescValue = proCoverageDisplayNameLines.count > i ? proCoverageDisplayNameLines[i] : ""
                    let proCoverageAmountValue = proCoveragePriceLines.count > i ? proCoveragePriceLines[i] : ""
                    let line = "\(quantityValue)".padding(toLength: 6, withPad: " ", startingAt: 0)+"\(proCoverageDescValue)".padding(toLength: 46, withPad: " ", startingAt: 0) +  "\(proCoverageAmountValue)\n"
                    textData.append(line)
                    
                }
            }
        }
        
        textData.append("Subtotal  :".padding(toLength: 46, withPad: " ", startingAt: 0) + "$\(subtotal)\n")
        textData.append("Discount  :".padding(toLength: 46, withPad: " ", startingAt: 0) + "($\(discount))\n")
        textData.append("Shipping & Handling  :".padding(toLength: 46, withPad: " ", startingAt: 0) + "$\(shippingAndHandling)\n")
        textData.append("Sales Tax  :".padding(toLength: 46, withPad: " ", startingAt: 0) + "$\(tax)\n")
        textData.append("Total     :".padding(toLength: 46, withPad: " ", startingAt: 0) + "$\(total)\n\n")
        
        for paymentDetail in paymentDetails {
            let lastDigit = paymentDetail["Last_digit"] as? String ?? ""
            let paymentMethod = paymentDetail["PaymentMethod"] as? [String:AnyObject]
            let BillingPaymentMethod = paymentMethod?["Payment_Method__c"] as? String ?? ""
            let Amount = paymentMethod?["Amount__c"] as? String ?? ""
            if(BillingPaymentMethod == "Credit Card" || BillingCountry == ""){
                BillingCountry = paymentMethod?["Country__c"] as? String ?? BillingCountry
            }
            if(BillingPaymentMethod == "Credit Card" || BillingAddress == ""){
                BillingAddress = paymentMethod?["Address__c"] as? String ?? BillingAddress
            }
            if(BillingPaymentMethod == "Credit Card" || BillingAddress2 == ""){
                BillingAddress2 = paymentMethod?["Address_2__c"] as? String ?? BillingAddress2
            }
            if(BillingPaymentMethod == "Credit Card" || BillingState == ""){
                BillingState = paymentMethod?["State__c"] as? String ?? BillingState
            }
            if(BillingPaymentMethod == "Credit Card" || BillingZipCode == ""){
                BillingZipCode = paymentMethod?["Zip_Code__c"] as? String ?? BillingZipCode
            }
            if(BillingPaymentMethod == "Credit Card" || BillingCity == ""){
                BillingCity = paymentMethod?["City__c"] as? String ?? BillingCity
            }
            if(BillingPaymentMethod == "Credit Card" || BillingFirstName == ""){
                BillingFirstName = paymentMethod?["First_Name__c"] as? String ?? BillingFirstName
            }
            if(BillingPaymentMethod == "Credit Card" || BillingLastName == ""){
                BillingLastName = paymentMethod?["Last_Name__c"] as? String ?? BillingLastName
            }
            if(BillingPaymentMethod == "Credit Card" || BillingPhone == ""){
                BillingPhone = paymentMethod?["Phone__c"] as? String ?? BillingPhone
            }
            textData.append("Paid By \(BillingPaymentMethod) \(lastDigit)  :".padding(toLength: 46, withPad: " ", startingAt: 0) + "$\(Amount)\n");
        }
        textData.append("\n");
        textData.append("\n");
        textData.append("Shipping & Billing Information\n\n")
      
        textData.append("Ship To: \(FirstName ) \(Lastname ),\n")
        textData.append("\(ShippingAddress ),\n")
        textData.append("\(ShippingAddress2),\(ShippingCity),\(ShippingState) \(ShippingZipcode),\n")
//        textData.append("\(ShippingCountry),\n")
        textData.append("\(Phone)\n")
        textData.append("\n")
        textData.append("\n")
        textData.append("Bill To: \(BillingFirstName) \(BillingLastName),\n")
        textData.append("\(BillingAddress),\n")
        textData.append("\(BillingAddress2),\(BillingCity),\(BillingState) \(BillingZipCode),\n")
//        textData.append("\(BillingCountry),\n")
        textData.append("\(BillingPhone)\n\n")
       
        
        // Section 4 : Advertisement
        textData.append("Thank You for Shopping at Guitar Center\n\n")
        textData.append("Buy Online Now at www.guitarcenter.com !\n")
        textData.append("Or call 1-666-498-7882\n")
        textData.append("WE LOVE FEEDBACK. Tell us yours at\n")
        textData.append("www.guitarcenter.com/pages/Store -Feedback.\n\n")
        textData.append("To view our Low Price Gurantee, Return Policy,\n")
        textData.append("Repair Terms and others comsumer policies,\n")
        textData.append("please go to\n")
        textData.append("www.guitarcenter.com/pages/terms-of-use.\n\n")
        textData.append("Like Us: facebook.com/guitarcenter,\n")
        textData.append("Follow Us on Twitter/Instagram : @guitarcenter\n")
        textData.append("Subscribe to us youtube.com/guitarcenter\n\n")
       
        
        return String(textData)
    }
    
    func splitTextIntoLines(text: String, maxLineLength: Int) -> [String] {
        var lines: [String] = []
        var currentLine = ""
        
        for word in text.split(separator: " ") {
            let wordLength = word.count
            let lineLength = currentLine.count
            
            if lineLength + wordLength <= maxLineLength {
                if !currentLine.isEmpty {
                    currentLine += " "
                }
                currentLine += word
            } else {
                lines.append(currentLine)
                currentLine = String(word)
            }
        }
        
        if !currentLine.isEmpty {
            lines.append(currentLine)
        }
        
        return lines
    }

}
