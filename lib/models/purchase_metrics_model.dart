class PurchaseMetricsModel {
  PurchaseMetricsModel({
    this.epsilonCustomerKey,
    this.purchaseChannel,
    this.purchaseCategory,
    this.historyPurchase,
  });

  String? epsilonCustomerKey;
  Map<String, String?>? purchaseChannel;
  Map<String, String?>? purchaseCategory;
  List<HistoryPurchase>? historyPurchase;

  factory PurchaseMetricsModel.fromJson(Map<String, dynamic> json) {
    Map<String, String?> channel = {};
    (json["PurchaseChannel"] as Map<String, dynamic>).forEach((key, value) {
      channel.addAll({key: value?.toString()});
    });

    Map<String, String?> categories = {};
    (json["PurchaseCategory"] as Map<String, dynamic>).forEach((key, value) {
      categories.addAll({key: value?.toString()});
    });

    return PurchaseMetricsModel(
      epsilonCustomerKey: json["Epsilon_Customer_Key"],
      purchaseChannel: channel,
      purchaseCategory: categories,
      historyPurchase: List<HistoryPurchase>.from(
          json["history"].map((x) => HistoryPurchase.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "Epsilon_Customer_Key": epsilonCustomerKey,
        "PurchaseChannel": purchaseChannel,
        "PurchaseCategory": purchaseCategory,
        "history":
            List<dynamic>.from(historyPurchase?.map((x) => x.toJson()) ?? []),
      };
}

// class PurchaseCategory {
//   PurchaseCategory({
//     this.amplifiersEffects = '1.0',
//     this.keyboardsMidi = '0.0',
//     this.gcLessons = '0.0',
//     this.accessories = '0.0',
//   });

//   String amplifiersEffects;
//   String keyboardsMidi;
//   String gcLessons;
//   String accessories;

//   factory PurchaseCategory.fromJson(Map<String, dynamic> json) =>
//       PurchaseCategory(
//         amplifiersEffects: json["Amplifiers & Effects"] ?? '1.0',
//         keyboardsMidi: json["Keyboards & MIDI"] ?? '0.0',
//         gcLessons: json["GC Lessons"] ?? '0.0',
//         accessories: json["Accessories"] ?? '0.0',
//       );

//   Map<String, dynamic> toJson() => {
//         "Amplifiers & Effects": amplifiersEffects,
//         "Keyboards & MIDI": keyboardsMidi,
//         "GC Lessons": gcLessons,
//         "Accessories": accessories,
//       };
// }

// class PurchaseChannel {
//   PurchaseChannel({
//     this.web = '0.0',
//     this.retail = '0.0',
//   });

//   String web;
//   String retail;

//   factory PurchaseChannel.fromJson(Map<String, dynamic> json) =>
//       PurchaseChannel(
//         web: json["Web"] ?? '0.0',
//         retail: json["Retail"] ?? '0.0',
//       );

//   Map<String, dynamic> toJson() => {
//         "Web": web,
//         "Retail": retail,
//       };
// }

class HistoryPurchase {
  HistoryPurchase({
    this.salesBrand,
    this.orderNumber,
    this.orderDate,
    this.orderPurchaseChannel,
    this.lineItems,
  });

  String? salesBrand;
  String? orderNumber;
  DateTime? orderDate;
  String? orderPurchaseChannel;
  List<LineItem>? lineItems;

  factory HistoryPurchase.fromJson(Map<String, dynamic> json) =>
      HistoryPurchase(
        salesBrand: json["SalesBrand"],
        orderNumber: json["OrderNumber"],
        orderDate: DateTime.parse(json["OrderDate"]),
        orderPurchaseChannel: json["OrderPurchaseChannel"],
        lineItems: List<LineItem>.from(
            json["LineItems"].map((x) => LineItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "SalesBrand": salesBrand,
        "OrderNumber": orderNumber,
        "OrderDate":
            "${orderDate?.year.toString().padLeft(4, '0')}-${orderDate?.month.toString().padLeft(2, '0')}-${orderDate?.day.toString().padLeft(2, '0')}",
        "OrderPurchaseChannel": orderPurchaseChannel,
        "LineItems":
            List<dynamic>.from(lineItems?.map((x) => x.toJson()) ?? []),
      };
}

class LineItem {
  LineItem({
    this.enterpriseSku,
    this.sku,
    this.title,
    this.quantity,
    this.lineItemPurchaseChannel,
    this.lineItemPurchaseCategory,
    this.sellingPrice,
    this.purchasedPrice,
  });

  String? enterpriseSku;
  String? sku;
  String? title;
  String? quantity;
  String? lineItemPurchaseChannel;
  String? lineItemPurchaseCategory;
  String? sellingPrice;
  String? purchasedPrice;

  factory LineItem.fromJson(Map<String, dynamic> json) => LineItem(
        enterpriseSku: json["EnterpriseSKU"],
        sku: json["SKU"],
        title: json["Title"],
        quantity: json["Quantity"],
        lineItemPurchaseChannel: json["LineItemPurchaseChannel"],
        lineItemPurchaseCategory: json["LineItemPurchaseCategory"],
        sellingPrice: json["SellingPrice"],
        purchasedPrice: json["PurchasedPrice"],
      );

  Map<String, dynamic> toJson() => {
        "EnterpriseSKU": enterpriseSku,
        "SKU": sku,
        "Title": title,
        "Quantity": quantity,
        "LineItemPurchaseChannel": lineItemPurchaseChannel,
        "LineItemPurchaseCategory": lineItemPurchaseCategory,
        "SellingPrice": sellingPrice,
        "PurchasedPrice": purchasedPrice,
      };
}
