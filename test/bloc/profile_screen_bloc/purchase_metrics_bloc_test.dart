import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/profile_screen_bloc/purchase_metrics_bloc/purchase_metrics_bloc.dart';
import 'package:gc_customer_app/data/data_sources/profile_screen/purchase_metrics_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/profile/purchase_metrics_repository.dart';
import 'package:gc_customer_app/models/purchase_metrics_model.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PurchaseMetricsBloc purchaseMetricsBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
  });

  setUp(
    () {
      var purchaseMetricsDataSource = PurchaseMetricsDataSource();
      purchaseMetricsDataSource.httpService.client = MockClient(
        (request) async {
          return Response(
              json.encode({
                "Epsilon_Customer_Key": "1000000000002",
                "PurchaseChannel": {"CC": "676.82", "Retail": "26.79"},
                "PurchaseCategory": {
                  "Pro Audio": "15.40",
                  "Keyboards & MIDI": "64.45",
                  "Guitars": "576.58",
                  "Folk & Traditional Instruments": "17.46",
                  "Accessories": "29.72"
                },
                "history": [
                  {
                    "SalesBrand": "GC",
                    "OrderNumber": "GCQ5780291",
                    "OrderDate": "2020-08-06",
                    "OrderPurchaseChannel": "CC",
                    "LineItems": [
                      {
                        "EnterpriseSKU": "1274115033214",
                        "SKU": "336005000000000",
                        "Title": "PA130 Power Adapter for Portable Keys and SV",
                        "Quantity": "1",
                        "LineItemPurchaseChannel": "CC",
                        "LineItemPurchaseCategory": "Accessories",
                        "SellingPrice": "16.99",
                        "PurchasedPrice": "11.39"
                      }
                    ]
                  },
                  {
                    "SalesBrand": "GC",
                    "OrderNumber": "GCQ5630508",
                    "OrderDate": "2020-06-29",
                    "OrderPurchaseChannel": "Retail",
                    "LineItems": [
                      {
                        "EnterpriseSKU": "1500000051977",
                        "SKU": "113316046",
                        "Title": "PSR-E363 61-Key Portable Keyboard Black",
                        "Quantity": "1",
                        "LineItemPurchaseChannel": "Retail",
                        "LineItemPurchaseCategory": "Keyboards & MIDI",
                        "SellingPrice": "199.99",
                        "PurchasedPrice": "153.09"
                      }
                    ]
                  },
                  {
                    "SalesBrand": "GC",
                    "OrderNumber": "GCQ4930315",
                    "OrderDate": "2019-08-12",
                    "OrderPurchaseChannel": "Retail",
                    "LineItems": [
                      {
                        "EnterpriseSKU": "1427728874484",
                        "SKU": "111255717",
                        "Title": "MU40 Soprano Ukulele Natural",
                        "Quantity": "1",
                        "LineItemPurchaseChannel": "Retail",
                        "LineItemPurchaseCategory":
                            "Folk & Traditional Instruments",
                        "SellingPrice": "49.99",
                        "PurchasedPrice": "17.46"
                      }
                    ]
                  },
                  {
                    "SalesBrand": "GC",
                    "OrderNumber": "GCQ4720721",
                    "OrderDate": "2019-06-30",
                    "OrderPurchaseChannel": "Retail",
                    "LineItems": [
                      {
                        "EnterpriseSKU": "1308847077942",
                        "SKU": "107059750",
                        "Title":
                            "CGS Student Classical Guitar Natural 1/2-Size",
                        "Quantity": "1",
                        "LineItemPurchaseChannel": "Retail",
                        "LineItemPurchaseCategory": "Guitars",
                        "SellingPrice": "129.99",
                        "PurchasedPrice": "64.45"
                      }
                    ]
                  },
                  {
                    "SalesBrand": "GC",
                    "OrderNumber": "GCQ5650090",
                    "OrderDate": "2020-07-02",
                    "OrderPurchaseChannel": "Retail",
                    "LineItems": [
                      {
                        "EnterpriseSKU": "1405106207389",
                        "SKU": "110618675",
                        "Title": "PL4KD Doublebraced Keyboard X-Stand",
                        "Quantity": "1",
                        "LineItemPurchaseChannel": "Retail",
                        "LineItemPurchaseCategory": "Accessories",
                        "SellingPrice": "69.99",
                        "PurchasedPrice": "18.33"
                      }
                    ]
                  },
                  {
                    "SalesBrand": "GC",
                    "OrderNumber": "GCQ5630508",
                    "OrderDate": "2020-06-29",
                    "OrderPurchaseChannel": "CC",
                    "LineItems": [
                      {
                        "EnterpriseSKU": "1500000051289",
                        "SKU": "J55277000001000",
                        "Title": "KBX2 Double-Braced Keyboard Stand Black",
                        "Quantity": "1",
                        "LineItemPurchaseChannel": "CC",
                        "LineItemPurchaseCategory": "Accessories",
                        "SellingPrice": "33.99",
                        "PurchasedPrice": "9.88"
                      }
                    ]
                  },
                  {
                    "SalesBrand": "GC",
                    "OrderNumber": "GCQ5630508",
                    "OrderDate": "2020-06-29",
                    "OrderPurchaseChannel": "CC",
                    "LineItems": [
                      {
                        "EnterpriseSKU": "1385392677648",
                        "SKU": "J04052000000000",
                        "Title": "TH-200X Studio Headphones",
                        "Quantity": "1",
                        "LineItemPurchaseChannel": "CC",
                        "LineItemPurchaseCategory": "Pro Audio",
                        "SellingPrice": "99.99",
                        "PurchasedPrice": "15.40"
                      }
                    ]
                  },
                  {
                    "SalesBrand": "GC",
                    "OrderNumber": "GCQ5460554",
                    "OrderDate": "2020-03-30",
                    "OrderPurchaseChannel": "Retail",
                    "LineItems": [
                      {
                        "EnterpriseSKU": "1500000005657",
                        "SKU": "112013503",
                        "Title": "FP-30 DIGITAL PIANO Black",
                        "Quantity": "1",
                        "LineItemPurchaseChannel": "Retail",
                        "LineItemPurchaseCategory": "Keyboards & MIDI",
                        "SellingPrice": "719.99",
                        "PurchasedPrice": "423.49"
                      }
                    ]
                  }
                ]
              }),
              200);
        },
      );
      purchaseMetricsBloc = PurchaseMetricsBloc(PurchaseMetricsRepository());
      purchaseMetricsBloc.purchaseMetricsRepository.purchaseMetricsDataSource =
          purchaseMetricsDataSource;
    },
  );

  blocTest(
    'Get added cards',
    build: () => purchaseMetricsBloc,
    act: (bloc) => bloc.add(LoadMetricsData()),
    expect: () => [
      PurchaseMetricsProgress(),
      isA<PurchaseMetricsSuccess>(),
    ],
  );
}
