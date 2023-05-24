abstract class Endpoints {
  static String kBaseURL = 'https://gcinc--tracuat.sandbox.my.salesforce.com';
  // static String kBaseURL = 'https://gcinc.my.salesforce.com';
  static String kBaseURLProd = 'https://gcinc.my.salesforce.com';
  static String kApigeeUrlProd = 'https://guitarcenter-prod.apigee.net';
  static String kCustomerSearch =
      '/services/apexrest/GC_C360_CustomerSearchAPI';
  static String kCustomerSearchByPhone =
      '/services/data/v53.0/query/?q=SELECT id,name,firstname,lastname,accountEmail__c,email__c,PersonMailingStreet, Address_2__c, PersonMailingCity, PersonMailingState, PersonMailingPostalCode, PersonMailingCountry,Zip_Last_4__c,accountPhone__c,phone__c,Last_Transaction_Date__c,Lifetime_Net_Sales_Amount__c,Lifetime_Net_Sales_Transactions__c,Primary_Instrument_Category__c,epsilon_customer_brand_key__c from account where (accountPhone__c=';
  static String kCustomerSearchByEmail =
      '/services/data/v53.0/query/?q=SELECT id,name,firstname,lastname,accountEmail__c,email__c,PersonMailingStreet, Address_2__c, PersonMailingCity, PersonMailingState, PersonMailingPostalCode, PersonMailingCountry,Zip_Last_4__c,accountPhone__c,phone__c,Last_Transaction_Date__c,Lifetime_Net_Sales_Amount__c,Lifetime_Net_Sales_Transactions__c,Primary_Instrument_Category__c,epsilon_customer_brand_key__c from account where accountEmail__c=';
  static String kClientPromotionsService = '/cc/v1/customer/email/message/';
  static String lRecommendation =
      '/services/apexrest/GC_C360_ProductRecommendationAPI?recordId=';
  // static String kOrderAccessories =
  //     '/services/apexrest/GC_C360_PurchaseMetricsAPI?recordId=';
  static String kReminders =
      '/services/apexrest/GC_C360_CustomerReminderAPI?recordId=';
  static String kOpenOrders =
      '/services/apexrest/GC_C360_CustomerOrderAPI?recordId=';
  static String kOrderHistory =
      '/services/apexrest/services/apexrest/GC_C360_CustomerOrderHistoryAPI';
  static String kOpenCases =
      '/services/data/v53.0/query/?q=SELECT Id,CaseNumber,Case_Type__c,Case_Subtype__c,type,Order_Number__c,DAX_Order_Number__c,Order_Total__c,Priority,Reason,Subject,Status,Account.Name,Owner.Name,CreatedDate,LastModifiedDate FROM Case WHERE AccountId = ';
  static String kItemAvailability =
      '/services/apexrest/GC_C360_ProductInventoryAPI?itemSkuId=';
  static String kOrderQuote = '/services/apexrest/GC_C360_OrderQuoteAPI?';
  static String kFavoriteBrands =
      '/services/apexrest/GC_C360_ProductBrandAPI?recordId=';
  static String kTags = '/services/apexrest/GC_C360_TaggingAPI?recordId=';
  static String kOffers = '/services/apexrest/GC_C360_OffersAPI';
  static String kAssignedAgent =
      '/services/apexrest/GC_C360_UsersAPI?recordId=';
  static String kAssignAgent = '/services/apexrest/GC_C360_UsersAPI';
  static String kCustomerSearchByName =
      '/services/data/v53.0/query/?q=SELECT id,name,firstname,lastname,accountEmail__c,email__c,accountPhone__c,phone__c,Last_Transaction_Date__c,Lifetime_Net_Sales_Amount__c,Lifetime_Net_Sales_Transactions__c,Primary_Instrument_Category__c,epsilon_customer_brand_key__c from account where (name like ';
  static String kCustomerAllOrders =
      '/services/data/v53.0/query/?q=SELECT Id,OwnerId,First_Name__c,Last_Name__c,Order_Number__c,Total_Amount__c,Commission_JSON__c, Rollup_Count_Order_Line_Items__c,Order_Status__c,CreatedDate,LastModifiedDate FROM GC_Order__c where OwnerId IN (SELECT Id FROM User WHERE Email = ';
  static String kCustomerOpenOrders =
      '/services/data/v53.0/query/?q=SELECT Id, OwnerId, First_Name__c, Last_Name__c, Order_Number__c, LastModifiedDate, CreatedDate, Total_Amount__c, Commission_JSON__c, Rollup_Count_Order_Line_Items__c, Order_Status__c FROM GC_Order__c where OwnerId IN (SELECT Id FROM User WHERE Email = ';
  static String kClientPromos =
      '/services/data/v53.0/query/?q=SELECT CreatedBy.Name,CreatedDate,Subject FROM EmailMessage where RelatedToId = ';
  static String kClientNoteByID =
      '/services/data/v53.0/query/?q=SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = ';
  static String kClientNotes =
      '/services/data/v53.0/query/?q=SELECT Id, Title, FileType, TextPreview, Content, LastModifiedBy.Name,CreatedDate,LastModifiedDate FROM ContentNote WHERE Id IN  ';
  static String kClientActivity =
      '/services/data/v53.0/query/?q=SELECT Id, ActivityDate, Priority, WhatId,What.Name,Owner.Name, Status, Subject, TaskSubtype, Type,CompletedDateTime FROM Task WHERE WhatId = ';
  static String kClientOpenOrders =
      '/services/data/v53.0/query/?q=select Id,Name, CreatedDate,Total__c,Order_Number__c,(select Image_URL1__c  from GC_Order_Line_Items__r) from GC_Order__c where Customer__c = ';
  static String kClientOrderHistory = '/services/apexrest/GC_NewApp/';
  static String kClientBasicDetails =
      '/services/data/v53.0/query/?q=SELECT id,name,firstname,lastname,accountEmail__c,Brand_Code__c,accountPhone__c,Last_Transaction_Date__c,Lifetime_Net_Sales_Amount__c,Lifetime_Net_Sales_Transactions__c,Primary_Instrument_Category__c,Net_Sales_Amount_12MO__c, (select Total_Amount__c from GC_Orders__r  where Order_Status__c = \'Completed\' Order by lastmodifieddate desc limit 1)epsilon_customer_brand_key__c,Lessons_Customer__c,Open_Box_Purchaser__c,Loyalty_Customer__c,Used_Purchaser__c,Synchrony_Customer__c,Vintage_Purchaser__c  from account where id = ';
  static String kClientBasicDetailsById =
      '/services/data/v53.0/query/?q=SELECT id,name,firstname,lastname,Phone__c,phone,Email__c,accountEmail__c,Brand_Code__c,accountPhone__c,Last_Transaction_Date__c,Lifetime_Net_Sales_Amount__c,Lifetime_Net_Sales_Transactions__c,Primary_Instrument_Category__c,Net_Sales_Amount_12MO__c, (select Total_Amount__c from GC_Orders__r  where Order_Status__c = \'Completed\' Order by lastmodifieddate desc limit 1)epsilon_customer_brand_key__c,Lessons_Customer__c,Open_Box_Purchaser__c,Loyalty_Customer__c,Used_Purchaser__c,Synchrony_Customer__c,Vintage_Purchaser__c  from account WHERE Id IN (SELECT AccountId from Contact WHERE Id ='; //accounid to bind
  static String kStoreZipAddress = '/services/apexrest/GC_C360_StoreAPI';
  static String kCustomerReminder =
      '/services/apexrest/GC_C360_CustomerReminderAPI';
  static String kSubmitQuote = '/services/apexrest/GC_C360_OrderQuoteAPI';
  static String kPeriodicTime = '/services/apexrest/GC_C360_PeriodicAPI';
  static String kClientBuyAgain =
      '/services/data/v53.0/query/?q=SELECT id,lastmodifieddate,Order_Status__c,Customer__c,(select id, GC_Order__r.Site_Id__c,GC_Order__r.Name, GC_Order__c, GC_Order__r.Customer__r.PersonEmail,Description__c, Item_Id_formula__c, PIM_Sku__c , Item_Id__c, Condtion__c, Image_URL__c, Item_Price__c, Quantity__c, Warranty_Id__c, Warranty_Name__c,Warranty_price__c, Item_SKU__c,Warranty_style__c, Warranty_Enterprise_SkuId__c from GC_Order_Line_Items__r where Status__c != \'Deleted\') FROM GC_Order__c where Customer__c = ';
  static String kClientCartByID =
      '/services/data/v53.0/query/?q=SELECT Id, Customer__c,Cart_Sku_1__c, Cart_Sku_2__c, Cart_Sku_3__c, Cart_Sku_4__c, Cart_Sku_5__c, Cart_Sku_6__c, Cart_Sku_7__c, Cart_Sku_8__c, Cart_Sku_9__c FROM Lead where epsilon_customer_brand_key__c = ';
  static String kClientCartProduct =
      '/services/data/v53.0/query/?q=SELECT id,Brand__c,Name,Vender_Name__c,Standard_Unit_Cost__c,ProductImage__c FROM Product2 WHERE Item_ID__c in ';
  static String kClientPurchaseChannelAndCategory =
      'https://guitarcenter-prod.apigee.net/cc/v1/customer/';
  static String kSearchDetail = '/services/apexrest/GC_C360_ProductSearchAPI/';
  static String kClientBrowsingHistoryRecentlyViewedIds =
      '/services/data/v53.0/query/?q=SELECT Id,Name,Type,LastReferencedDate,LastViewedDate FROM RecentlyViewed WHERE Type = \'Product2\'';
  static String kClientBrowsingHistoryProducts =
      '/services/data/v53.0/query/?q=select id,Brand__c,Name,Vender_Name__c,Standard_Unit_Cost__c,ProductImage__c FROM Product2 WHERE Id in ';
  static String kClientOpenCases =
      '/services/data/v53.0/query/?q=SELECT CaseNumber,Case_Subtype__c,Case_Type__c,DAX_Order_Number__c,Id,Priority,Reason,Subject,Status,Account.Name,Owner.Name,CreatedDate,LastModifiedDate FROM Case where AccountId = ';
  static String kClientClosedCases =
      '/services/data/v53.0/query/?q=SELECT CaseNumber,Case_Subtype__c,Case_Type__c,DAX_Order_Number__c,Id,Priority,Reason,Subject,Status,Account.Name,Owner.Name,CreatedDate,LastModifiedDate FROM Case where AccountId = ';
  static String kCustomerMightAlsoLike =
      '/services/apexrest/GC_NewApp/@accountId-CustomerMightAlsoLike';
  static String kSmartTriggers = '/services/apexrest/GC_SmartTriggerAPI';
  static String kUserInformation =
      '/services/data/v53.0/query/?q=SELECT id,name,email,MobilePhone,SmallPhotoUrl,FullPhotoUrl,storeid__c from user where email=';
  static String kSmartTriggerOrder =
      '/services/apexrest/GC_SmartTriggerOrderAPI';
  static String kAddToCartAndProductOrder =
      '/services/apexrest/GC_C360_ProductOrderAPI/';
  static String kUpdateCartAndProductOrder =
      '/services/apexrest/GC_C360_ProductOrderAPI/';
  static String kOverrideReasons =
      '/services/apexrest/GC_C360_ProductPriceAPI/';
  static String kShippingOverrideReasons =
      '/services/apexrest/GC_C360_OrderPriceAPI/';
  static String kWarranties =
      '/services/apexrest/GC_C360_ProductWarrantyAPI?skuEntId';
  static String kWarrantiesUpdate =
      '/services/apexrest/GC_C360_ProductWarrantyAPI';
  static String kOrderDetail = '/services/apexrest/GC_C360_OrderDetailAPI/';
  static String kStoreAgents = '/services/apexrest/GC_SmartTriggerProfileAPI/';
  static String kUpdateOrder = '/services/apexrest/GC_SmartTriggerOrderAPI/';
  static String kAgentMetrics = '/services/apexrest/GC_SmartTriggerAccountAPI/';
  static String kOverrideRequests =
      '/services/apexrest/GC_C360_ProductPriceAPI/';
  static String kShippingOverrideRequests =
      '/services/apexrest/GC_C360_OrderPriceAPI/';
  static String kCommissionEmployeesDetail =
      '/services/apexrest/GC_C360_OrderCommissionAPI/';
  static String kAgentTeamTaskList =
      '/services/apexrest/GC_SmartTriggerTeamAPI/';
  static String kReasonList = '/services/apexrest/GC_C360_OrderAPI';
  static String kCustomerTasks =
      '/services/apexrest/GC_C360_SmartTriggerAPI?recordId=';
  static String kStoreList = '/services/apexrest/GC_SmartTriggerAccountAPI/';
  static String kAgentProfile = '/services/apexrest/GC_SmartTriggerProfileAPI/';
  static String kNotificationAPI = '/services/apexrest/GC_C360_NotificationAPI/';
  static String kMegaNotificationAPI = '/services/apexrest/GC_Mega_NotificationAPI/';
  static String kLoginAPI = '/services/apexrest/GC_C360_LoginAPI';
  static String kPrintLoggingAPI = '/services/apexrest/GC_C360_PrinterAPI/';
  static String kLoggingAPI = '/services/apexrest/GC_C360_LoggingAPI/';
  static String kAgentNotification =
      '/services/apexrest/GC_SmartTriggerNotificationAPI/';
  static String kCreateTask = '/services/apexrest/GC_SmartTriggerTaskAPI/';
  static String kCustomerInfo =
      "/services/data/v53.0/query/?q=SELECT id,name,firstname,lastname,accountEmail__c,Brand_Code__c,PersonEmail,Email__c,Phone__c,Phone,accountPhone__c, Premium_Purchaser__c,Last_Transaction_Date__c,Lifetime_Net_Sales_Amount__c,Lifetime_Net_Sales_Transactions__c,Lifetime_Net_Units__c,Primary_Instrument_Category__c,Net_Sales_Amount_12MO__c,Order_Count_12MO__c,(select Total_Amount__c from GC_Orders__r where Order_Status__c = 'Completed' Order by lastmodifieddate desc limit 1),epsilon_customer_brand_key__c,Lessons_Customer__c,Open_Box_Purchaser__c,Loyalty_Customer__c,Used_Purchaser__c,Synchrony_Customer__c,Vintage_Purchaser__c from account where ";
  static String kCustomerOrderInfo =
      "/services/data/v53.0/query/?q=SELECT id, name, firstname, lastname, Last_Transaction_Date__c, Lifetime_Net_Sales_Amount__c, Lifetime_Net_Sales_Transactions__c, Lifetime_Net_Units__c, Primary_Instrument_Category__c, Net_Sales_Amount_12MO__c, Order_Count_12MO__c FROM Account WHERE Id=";
  static String ksmartTriggerOrders = '/services/apexrest/GC_SmartTriggerAPI/';
  static String customerFavouriteList =
      '/services/apexrest/GC_C360_ProductBrandAPI';
  static String recommendationsList =
      '/services/apexrest/GC_C360_ProductRecommendationAPI';
  static String buyItemList =
      '/services/apexrest/GC_C360_ProductRecommendationAPI';
  static String ksmartTriggerTaskSearch =
      '/services/apexrest/GC_SmartTriggerSearchAPI?search=';
  static String kOrderProceed = '/services/apexrest/GC_C360_OrderAPI/';
  static String kSubmitCommission =
      '/services/apexrest/GC_C360_OrderCommissionAPI/';
  static String openCasesList = '/services/data/v53.0/query/';
  static String kClientPaymentCards =
      '/services/apexrest/GC_C360_PaymentCardsAPI';
  static String kClientProfileDetails =
      '/services/data/v53.0/query/?q=SELECT id,name,firstname,lastname,accountEmail__c,Brand_Code__c,accountPhone__c, PersonEmail,Email__c,Phone__c,Phone,Premium_Purchaser__c,PersonMailingStreet, Address_2__c, PersonMailingCity, PersonMailingState, PersonMailingPostalCode, PersonMailingCountry,Zip_Last_4__c,Last_Transaction_Date__c,Lifetime_Net_Sales_Amount__c,Lifetime_Net_Sales_Transactions__c,Lifetime_Net_Units__c,Primary_Instrument_Category__c,Net_Sales_Amount_12MO__c,Order_Count_12MO__c,(select Total_Amount__c from GC_Orders__r where Order_Status__c = \'Completed\' Order by lastmodifieddate desc limit 1),epsilon_customer_brand_key__c,Lessons_Customer__c,Open_Box_Purchaser__c,Loyalty_Customer__c,Used_Purchaser__c,Synchrony_Customer__c,Vintage_Purchaser__c from account where Id=';
  static String kClientProfilePurchaseMetrics =
      '/services/apexrest/GC_C360_PurchaseMetricsAPI?recordId=';
  static String kClientPromotions = '/services/apexrest/GC_C360_PromotionsAPI';
  static String kClientAddress =
      '/services/apexrest/GC_C360_CustomerAddressAPI';
  static String kShippingMethods =
      '/services/apexrest/GC_C360_OrderCalculationAPI';
  static String kClientCustomer = '/services/apexrest/GC_C360_CustomerAPI';
  static String kShowProCoverageModel =
      '/services/apexrest/GC_C360_ProductOrderAPI/';
  static String kClientCredit = '/services/apexrest/GC_C360_CustomerCreditAPI';
  static String kClientOrderPayment =
      '/services/apexrest/GC_C360_OrderPaymentAPI';
  static String kClientOrderCalculation =
      '/services/apexrest/GC_C360_OrderCalculationAPI';
  static String kClientLocation = '/services/apexrest/Location';
  static String kClientApprovalProcess =
      '/services/apexrest/GC_C360_ApprovalProcessAPI';
  static String kClientOrderLookUp =
      '/services/apexrest/GC_C360_OrderLookupAPI';
  static String kProductInventory =
      '/services/apexrest/GC_C360_ProductInventoryAPI';
  static String kClientPrinterType = '/services/apexrest/GC_C360_PrinterAPI';
  static String kSmartTriggerUser =
      '/services/apexrest/GC_SmartTriggerUserAPI/';

  static String showProCoverageModel() {
    return '$kBaseURL$kShowProCoverageModel';
  }

  static String getCommissionsDetail() {
    return '$kBaseURL$kCommissionEmployeesDetail';
  }

  static String getStoreZipAddress() {
    return '$kBaseURL$kStoreZipAddress';
  }

  static String orderProceed() {
    return '$kBaseURL$kOrderProceed';
  }

  static String getSearchedTask(String searchString, String storeid) {
    return "$kBaseURL$ksmartTriggerTaskSearch$searchString&storeId=$storeid";
  }

  static String submitCommission() {
    return '$kBaseURL$kSubmitCommission';
  }

  static String loginAPI() {
    return '$kBaseURL$kLoginAPI';
  }

  static String printLoggingAPI() {
    return '$kBaseURL$kPrintLoggingAPI';
  }

  static String loggingAPI() {
    return '$kBaseURL$kLoggingAPI';
  }

  static String getCustomerInfo(String customerEmail) {
    return "$kBaseURL${kCustomerInfo}accountEmail__c='$customerEmail' LIMIT 1";
  }

  static String getCustomerInfoById(String customerID) {
    return "$kBaseURL${kCustomerInfo}Id='$customerID' LIMIT 1";
  }

  static String getCustomerOrderInfo(String customerID) {
    return "$kBaseURL$kCustomerOrderInfo'$customerID' LIMIT 1";
  }

  static String getSearchDetail() {
    return '$kBaseURL$kSearchDetail';
  }

  static String customTokenApi() {
    return 'https://mp4gqy2upf.execute-api.us-west-2.amazonaws.com/dev/api/authorization/token';
  }

  static String periodicTimeApi(String userId) {
    return '$kBaseURL$kPeriodicTime?loggedinUserId=$userId';
  }

  static String addToCartAndCreateOrder() {
    return '$kBaseURL$kAddToCartAndProductOrder';
  }

  static String updateCartAndCreateOrder() {
    return '$kBaseURL$kUpdateCartAndProductOrder';
  }

  static String getCustomerSearchByPhone(String phone) {
    return '$kBaseURL$kCustomerSearchByPhone\'$phone\' OR Best_Phone__c = \'$phone\' OR Best_Phone__c = \'1$phone\' OR PersonMobilePhone = \'$phone\' OR PersonMobilePhone = \'1$phone\') and brand_code__c=\'GC\'';
    // return '$kBaseURL$kCustomerSearch?brand=GC&phone=$phone';
  }

  static String getRecommendation(String type, String id) {
    return '$kBaseURL$lRecommendation$id&recommendType=$type';
  }

  static String getProductBundles(String itemSKUid, String id) {
    return '$kBaseURL$lRecommendation$id&itemSkuId=$itemSKUid&recommendType=ItemRecommends';
  }

  // static String getOrderAccessories(String id) {
  //   return '$kBaseURL$kOrderAccessories$id';
  // }

  static String getInventoryDetail(String id) {
    return '$kBaseURL$kItemAvailability$id&recordType=detail';
  }

  static String sendOverrideRequest() {
    return '$kBaseURL$kOverrideRequests';
  }

  static String sendShippingOverrideRequest() {
    return '$kBaseURL$kShippingOverrideRequests';
  }

  static String getReminders(String recordID, String userID) {
    return '$kBaseURL$kReminders$recordID&loggedinUserId=$userID';
  }

  static String getRemindersOnWeb(String recordID) {
    return '$kBaseURL$kReminders$recordID';
  }

  static String getOpenOrders(String recordID) {
    return '$kBaseURL$kOpenOrders$recordID&isOpen=true&numberOfRecords=20&pageNumber=1';
  }

  static String getOrderHistory(String recordID, int page) {
    return '$kBaseURL$kOrderHistory?recordId=$recordID&numberOfRecords=20&pageNumber=$page';
  }

  static String getPastOrderDetail(String orderID) {
    return '$kBaseURL$kOrderDetail$orderID';
  }

  static String getOpenCases(String recordID) {
    return '$kBaseURL$kOpenCases\'$recordID\' and status NOT IN (\'Closed\',\'Auto-Closed\',\'Resolved\') ORDER BY CreatedDate DESC LIMIT 3';
  }

  static String getOverrideReasons() {
    return '$kBaseURL$kOverrideReasons';
  }

  static String getShippingOverrideReasons() {
    return '$kBaseURL$kShippingOverrideReasons';
  }

  static String sendTaxInfo(String orderId) {
    return '$kBaseURL$kReasonList/$orderId';
  }

  static String getRecordOptions(String userId, String recordType) {
    return '$kBaseURL$kClientCustomer?loggedinUserId=$userId&recordType=$recordType';
  }

  static String getWarranties(String skuEntId) {
    return '$kBaseURL$kWarranties=$skuEntId&brand=GC';
  }

  static String getReasons() {
    return '$kBaseURL$kReasonList/';
  }

  static String deleteOrder(String orderId) {
    return '$kBaseURL$kReasonList/$orderId';
  }

  static String updateWarranties() {
    return '$kBaseURL$kWarrantiesUpdate';
  }

  static String getItemAvailability(String skuID, String loggedInUserId) {
    return '$kBaseURL$kItemAvailability$skuID&loggedinUserId=$loggedInUserId';
  }

  static String getItemEligibility(String skuID, String loggedInUserId) {
    return '$kBaseURL$kItemAvailability$skuID&loggedinUserId=$loggedInUserId&recordType=moreInfo';
  }

  static String getFavoriteBrands(String recordId) {
    return '$kBaseURL$kFavoriteBrands$recordId';
  }

  static String getTags(String recordId) {
    return '$kBaseURL$kTags$recordId';
  }

  static String getOffers() {
    return '$kBaseURL$kOffers';
  }

  static String getAssignedAgent(String recordId, String loggedInUserId) {
    return '$kBaseURL$kAssignedAgent$recordId&loggedinUserId=$loggedInUserId&recordType=Agent';
  }

  static String assignAgent(String recordId, String loggedInUserId) {
    return '$kBaseURL$kAssignAgent';
  }

  static String getAssignedAgentList(String recordId, String loggedInUserId) {
    return '$kBaseURL$kAssignedAgent$recordId&loggedinUserId=$loggedInUserId&recordType=AgentList';
  }

  static String getCustomerSearchByEmail(String email) {
    return '$kBaseURL$kCustomerSearchByEmail\'$email\' and brand_code__c=\'GC\'';
    // return '$kBaseURL$kCustomerSearch?brand=GC&email=$email';
  }

  static String getCustomerSearchByName(String name, int offset) {
    return '$kBaseURL$kCustomerSearchByName%27${name.trim()}%25%27 or lastname like %27${name.trim()}%25%27) and brand_code__c=\'GC\' LIMIT 10';
    // return '$kBaseURL$kCustomerSearch?brand=GC&name=$name';
  }

  static String getCustomerSearchPost() {
    return '$kBaseURL$kCustomerSearch';
  }

  static String getCustomerAllOrders(String email, int offset) {
    return '$kBaseURL$kCustomerAllOrders${'\'$email\') ORDER BY CreatedDate DESC, LastModifiedDate DESC NULLS LAST LIMIT 20 OFFSET $offset'}';
  }

  static String getCustomerOpenOrders(String email, int offset) {
    return '$kBaseURL$kCustomerOpenOrders${'\'$email\') and Order_Status__c = \'Draft\' ORDER BY CreatedDate DESC, LastModifiedDate DESC NULLS LAST LIMIT 20 OFFSET $offset'}';
  }

  static String getClientOpenCases(String accountId) {
    return '$kBaseURL$kClientOpenCases\'$accountId\'  and status not in (\'Closed\',\'Auto-Closed\',\'Resolved\') ORDER BY CreatedDate DESC limit 2 offset 0';
  }

  static String getClientPromos(String relatedToId) {
    return '$kBaseURL$kClientPromos${'\'$relatedToId\''}';
  }

  static String getClientNotesById(String linkedEntityId) {
    return '$kBaseURL$kClientNoteByID${'\'$linkedEntityId\''}';
  }

  static String getStartCommission(String orderId, String loggedUserId) {
    return '$kBaseURL$kCommissionEmployeesDetail?orderId=$orderId&loggedinUserId=$loggedUserId&recordType=Commission';
  }

  static String getCommissionLog(String orderId, String loggedUserId) {
    return '$kBaseURL$kCommissionEmployeesDetail?orderId=$orderId&loggedinUserId=$loggedUserId&recordType=Notes';
  }

  static String searchEmployeesById(String text) {
    return '$kBaseURL$kCommissionEmployeesDetail?searchText=$text&searchType=EmployeeNumber';
  }

  static String searchEmployeesByName(String text) {
    return '$kBaseURL$kCommissionEmployeesDetail?searchText=$text&searchType=EmployeeName';
  }

  static String saveCommission() {
    return '$kBaseURL$kSubmitCommission';
  }

  static String getClientNotes(List<String> noteIds) {
    var noteIdsString = '';

    for (var id in noteIds) {
      var insertIds = '\'$id\'';
      noteIdsString = noteIdsString + insertIds + ',';
    }

    if (noteIdsString.isNotEmpty) {
      noteIdsString = noteIdsString.substring(0, noteIdsString.length - 1);
    }

    return '$kBaseURL$kClientNotes${'($noteIdsString)'}';
  }

  static String getClientBuyAgain(String customerId) {
    return '$kBaseURL$kClientBuyAgain\'$customerId\' and Order_Status__c = \'Completed\' Order by lastmodifieddate desc limit 1';
  }

  static String getClientCartById(String customerId) {
    return '$kBaseURL$kClientCartByID${'\'$customerId\''}';
  }

  static String getClientCart(String cartsId) {
    return '$kBaseURL$kClientCartProduct${'($cartsId)'}';
  }

  static String getClientActivity(String clientId) {
    return '$kBaseURL$kClientActivity${'\'$clientId\''}';
  }

  static String getClientOpenOrders(String clientId) {
    return '$kBaseURL$kClientOpenOrders${'\'$clientId\' and Order_Status__c = \'Draft\' ORDER BY createddate desc limit 2 OFFSET 0'}';
  }

  static String getClientOrderHistory(String clientId) {
    return '$kBaseURL$kClientOrderHistory$clientId-OrderHistory';
  }

  static String getClientBasicDetails(String clientId) {
    return '$kBaseURL$kClientBasicDetailsById\'$clientId\')';
  }

  static String getClientPurchaseChannelAndCategory(String epsilonCustomerKey) {
    var editedKey = epsilonCustomerKey.replaceAll('GC_', '');
    return '$kClientPurchaseChannelAndCategory' '$editedKey/txn/hist';
  }

  static String getClientBrowsingHistoryProductIDs() {
    return '$kBaseURL$kClientBrowsingHistoryRecentlyViewedIds';
  }

  static String getClientRecentlyViewedProducts(List<String> productIDs) {
    var productIdsString = '';

    for (var id in productIDs) {
      var insertIds = '\'$id\'';
      productIdsString = productIdsString + insertIds + ',';
    }

    if (productIdsString.isNotEmpty) {
      productIdsString =
          productIdsString.substring(0, productIdsString.length - 1);
    }

    return '$kBaseURL$kClientBrowsingHistoryProducts($productIdsString)';
  }

  static String getClientClosedCases(String accountId) {
    return '$kBaseURL$kClientClosedCases\'$accountId\'  and status in (\'Closed\',\'Resolved\') and Case_Type__c!=null ORDER BY CreatedDate DESC limit 4 offset 0';
  }

  static String getSmartTriggers() {
    return '$kBaseURL$kSmartTriggers';
  }

  static String getTaskDetails(String taskId) {
    return '$kBaseURL$kSmartTriggers/$taskId';
  }

  static String getUserInformation(String email) {
    return '$kBaseURL$kUserInformation\'$email\'';
  }

  static String getSmartTriggerOrder(String orderId, String taskId) {
    return '$kBaseURL$kSmartTriggerOrder?orderNo=$orderId&taskId=$taskId';
  }

  static String getStoreAgents(String storeID) {
    return '$kBaseURL$kStoreAgents$storeID';
  }

  static String postTaskDetails(String taskId) {
    return '$kBaseURL$kUpdateOrder/$taskId';
  }

  static String getAgentMetrics() {
    return '$kBaseURL$kAgentMetrics';
  }

  static String getTeamTaskList() {
    return '$kBaseURL$kAgentTeamTaskList';
  }

  static String getCustomerTasks(String id) {
    return '$kBaseURL$kCustomerTasks$id';
  }

  static String getStoreList() {
    return '$kBaseURL$kStoreList';
  }

  static String getAgentProfile() {
    return '$kBaseURL$kAgentProfile';
  }

  static String getNotificationAPI() {
    return '$kBaseURL$kNotificationAPI';
  }

  static String getMegaNotificationAPI() {
    return '$kBaseURL$kMegaNotificationAPI';
  }

  static String getAgentNotification() {
    return '$kBaseURL$kAgentNotification';
  }

  static String getCreateTask() {
    return '$kBaseURL$kCreateTask';
  }

  static String completeTask() {
    return '$kBaseURL$kCreateTask';
  }

  static String getFavouriteItemsList(String recordID) {
    return '$kBaseURL$customerFavouriteList?recordId=$recordID';
  }

  static String getRecommendationScreenLists(String recordID) {
    return '$kBaseURL$recommendationsList?recordId=$recordID&recommendType=BrowsingHistory';
  }

  static String saveReminder() {
    return '$kBaseURL$kCustomerReminder';
  }

  static String submitQuote() {
    return '$kBaseURL$kSubmitQuote';
  }

  static String getBuyItemsPageList(String recordID) {
    return '$kBaseURL$buyItemList?recordId=$recordID&recommendType=BuyAgain';
  }

  static String getCartBrowsePageList(String recordID) {
    return '$kBaseURL$recommendationsList?recordId=$recordID&recommendType=Cart';
  }

  static String getOpenCasesList(String recordID) {
    return "$kBaseURL$openCasesList?q=SELECT Id,CaseNumber,Case_Type__c,Case_Subtype__c,type,Order_Number__c,DAX_Order_Number__c,Order_Total__c,Priority,Reason,Subject,Status,Account.Name,Owner.Name,CreatedDate,LastModifiedDate FROM Case WHERE AccountId ='$recordID' and status NOT IN ('Closed','Auto-Closed','Resolved') ORDER BY CreatedDate DESC LIMIT 3";
  }

  static String getHistoryCasesList(String recordID) {
    return "$kBaseURL$openCasesList?q=SELECT Id,CaseNumber,Case_Type__c,Case_Subtype__c,type,Order_Number__c,DAX_Order_Number__c,Order_Total__c,Priority,Reason,Subject,Status,Account.Name,Owner.Name,CreatedDate,LastModifiedDate FROM Case WHERE AccountId = '$recordID' and status IN ('Closed','Auto-Closed','Resolved') ORDER BY CreatedDate DESC LIMIT 4";
  }

  static String getCartFrequentlyBaughtItemsList(
      String recordID, String productListNumber) {
    return '$kBaseURL$recommendationsList?recordId=$recordID&recommendType=CartOthers&productList="$productListNumber"';
  }

  static String getHistoryChartData(String recordID) {
    return "$kBaseURL$openCasesList?q=SELECT Id, CaseNumber, CreatedDate, LastModifiedDate, Priority, Reason, Subject, Status, Account.Name, Owner.Name FROM Case WHERE AccountId = '$recordID' ORDER BY CreatedDate DESC LIMIT 1";
  }

  static String getClientProfilePaymentCards(String recordId) {
    return '$kBaseURL$kClientPaymentCards?recordId=$recordId';
  }

  static String getClientProfileDetails(String userId) {
    return '$kBaseURL$kClientProfileDetails\'$userId\' LIMIT 1 ';
  }

  static String saveAddress() {
    return '$kBaseURL$kClientAddress';
  }

  static String searchAddress(String recordId, String searchText) {
    return '$kBaseURL$kClientAddress?recordId=$recordId&recordType=search&searchText=$searchText';
  }

  static String getRecommendedAddress(
      String address1,
      String address2,
      String city,
      String state,
      String postalCode,
      String country,
      bool isShipping,
      bool isBilling) {
    return '$kBaseURL$kClientAddress?recordType=RecommendedAddress&addressline1=$address1&addressline2=$address2&city=$city&state=$state&postalcode=$postalCode&country=$country&isShipping=$isShipping&isBilling=$isBilling';
  }

  static String getClientProfilePurchaseMetrics(String recordId) {
    return '$kBaseURL$kClientProfilePurchaseMetrics$recordId';
  }

  static String getPromotions(String userRecordId) {
    return '$kBaseURL$kClientPromotions?recordId=$userRecordId&numberOfRecords=15&pageNumber=1';
  }

  static String getPromotionDetail(String promotionId) {
    return '$kBaseURL$kClientPromotions?emailId=$promotionId';
  }

  static String getPromotionDetailService(String serviceCommunicationId) {
    return '$kApigeeUrlProd$kClientPromotionsService$serviceCommunicationId/brand/GC';
  }

  static String getOffersList() {
    return "$kBaseURL/services/apexrest/GC_C360_OffersAPI";
  }

  static String getClientAddresses(String userRecordId) {
    return '$kBaseURL$kClientAddress?recordId=$userRecordId';
  }

  static String getOrderAddresses(String userRecordId) {
    return '$kBaseURL$kClientAddress?recordId=$userRecordId';
  }

  static String getShippingMethods(String userRecordId, String orderId) {
    return '$kBaseURL$kShippingMethods?loggedinUserId=$userRecordId&orderId=$orderId';
  }

  static String getSettingsChecks(String recordID) {
    return "$kBaseURL/services/apexrest/GC_C360_SettingsAPI?recordId=$recordID";
  }

  static String saveSettingsCheck(String recordID) {
    return "$kBaseURL/services/apexrest/GC_C360_SettingsAPI";
  }

  static String saveNewCustomer() {
    return '$kBaseURL$kClientCustomer';
  }

  static String getQuotesHistoryList(
      {required String recordID,
      required String orderId,
      required loggedInUserId}) {
    return '$kBaseURL${kOrderQuote}recordId=$recordID&orderId=$orderId&loggedinUserId=$loggedInUserId&recordType=quote';
  }

  static String getCreditBalance(String email) {
    return '$kBaseURL$kClientCredit?customerEmail=$email&customerBrand=GC';
  }

  static String getGiftCardsBalance(String cardNumber, String pin) {
    ///"giftCardBalance" for gift card
    ///"COAStatus" for COA
    return '$kBaseURL$kClientOrderPayment?cardNumber=$cardNumber&cardPin=$pin&brandCode=GC&recordType=GiftCard';
  }

  static String getCOABalance(String email) {
    ///"COAStatus" for COA
    return '$kBaseURL$kClientOrderPayment?email=$email&brandCode=GC&recordType=COA';
  }

  static String getFinancialCards(String orderId, String loggedUserId) {
    ///"PLC promos" for Gear card
    ///"Fortiva promos" for Essential card
    return '$kBaseURL$kClientOrderCalculation?loggedinUserId=$loggedUserId&orderId=$orderId';
  }

  static String getEssentialFinanceMessage(String orderId, String loggedUserId,
      String cardNumber, String pin, String amount) {
    return '$kBaseURL$kClientOrderPayment?orderId=$orderId&loggedinUserId=$loggedUserId&cardNumber=$cardNumber&planCode=$pin&amount=$amount&brandCode=GC&recordType=EssentialCard';
  }

  static String getGearFinanceMessage(
      String orderId, String cardNumber, String pin, String amount) {
    return '$kBaseURL$kClientOrderPayment?orderId=$orderId&cardNumber=$cardNumber&planCode=$pin&amount=$amount&brandCode=GC&recordType=GearCard';
  }

  static String getCalculatedTax(String orderId, String loggedUserId) {
    return '$kBaseURL$kClientOrderCalculation?loggedinUserId=$loggedUserId&orderId=$orderId';
  }

  static String getExistingCards(String email) {
    return '$kBaseURL$kClientPaymentCards?email=$email&brandCode=GC';
  }

  static String applyCoupon(String orderId) {
    return '$kBaseURL$kReasonList/$orderId';
  }

  static String getPrinters(String loggedInId) {
    return '$kBaseURL$kClientLocation?userid=$loggedInId';
  }

  static String printOrder() {
    return '$kBaseURL$kClientLocation';
  }

  static String fetchStoreAddress(String loggedInId) {
    return '$kBaseURL$kStoreZipAddress?loggedinUserId=$loggedInId&recordType=address';
  }

  static String getApprovalProcess(String loggedInId) {
    return '$kBaseURL$kClientApprovalProcess?loggedinUserId=$loggedInId&numberOfRecords=50&pageNumber=1';
  }

  static String getAllClientsCount() {
    return '$kBaseURL/services/apexrest/MyCustomers_GetAllAccountCountApi';
  }

  static String getNewCustomerCount() {
    return '$kBaseURL/services/apexrest/MyCustomers_GetNewAccountCountApi';
  }

  static String getLoggedUserName() {
    return '$kBaseURL/services/apexrest/MyCustomers_GetLoggedInUserNameApi';
  }

  static String getClientList() {
    return '$kBaseURL/services/apexrest/MyCustomers_PriorityCountsApi';
  }

  static String getPurchasedList() {
    return '$kBaseURL/services/apexrest/MyCustomers_PurchasedCountsApi';
  }

  static String getContactedList() {
    return '$kBaseURL/services/apexrest/MyCustomers_ContactedCountsApi';
  }

  static String getIsAccountManager() {
    return '$kBaseURL/services/apexrest/MyCustomers_IsManagerApi';
  }

  static String getUsersInManagerRole() {
    return '$kBaseURL/services/apexrest/MyCustomers_GetUsersForStoreApi';
  }

  static String getOrderLookUp(String searchText) {
    return '$kBaseURL$kClientOrderLookUp?searchString=$searchText';
  }

  static String getOrderLookUpOpenOrderByOrderNumber(String searchText) {
    return '$kBaseURL$kClientOrderLookUp?recordType=OrderNumber&numberValue=$searchText';
  }

  static String getOrderLookUpOpenOrderByQouteNumber(String searchText) {
    return '$kBaseURL$kClientOrderLookUp?recordType=QuoteNumber&numberValue=$searchText';
  }

  static String verificationAddress(
      String loggedInId,
      String addressline1,
      String addressline2,
      String city,
      String state,
      String postalcode,
      bool isShipping,
      bool isBilling) {
    return '$kBaseURL$kClientAddress?loggedinUserId=$loggedInId&recordType=RecommendedAddress&addressline1=$addressline1&addressline2=$addressline2&city=$city&state=$state&postalcode=$postalcode&country=US&isShipping=$isShipping&isBilling=$isBilling';
  }

  static String selectInventoryUpdateReason() {
    return '$kBaseURL$kProductInventory';
  }

  static String getPrinterTypes() {
    return '$kBaseURL$kClientPrinterType?recordType=status';
  }

  static String getUserSmartTrigger() {
    return '$kBaseURL$kSmartTriggerUser';
  }
}
