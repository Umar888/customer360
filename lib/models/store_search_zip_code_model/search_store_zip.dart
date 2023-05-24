import 'package:equatable/equatable.dart';

class SearchStoreModel extends Equatable{
  List<SearchStoreList>? searchStoreList;
  List<SearchStoreListInformation>? searchStoreListInformation;

  SearchStoreModel({this.searchStoreList, this.searchStoreListInformation});

  SearchStoreModel.fromJson(Map<String, dynamic> json) {
    if (json['searchStoreList'] != null) {
      searchStoreList = <SearchStoreList>[];
      json['searchStoreList'].forEach((v) {
        searchStoreList!.add(SearchStoreList.fromJson(v));
      });
    }
    if (json['storeList'] != null) {
      searchStoreListInformation = <SearchStoreListInformation>[];
      json['storeList'].forEach((v) {
        searchStoreListInformation!.add(SearchStoreListInformation.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.searchStoreList != null) {
      data['storeList'] = this.searchStoreList!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  List<Object?> get props => [searchStoreList, searchStoreListInformation];
}

class SearchStoreList extends Equatable{
  bool? rowClicked;
  String? postalCode;
  String? name;
  String? id;
  String? distance;
  String? dimensionID;
  String? avaibility;

  SearchStoreList(
      {
        this.rowClicked,
      this.postalCode,
      this.name,
      this.id,
      this.distance,
      this.dimensionID,
      this.avaibility,
      });

  SearchStoreList.fromJson(Map<String, dynamic> json) {
    rowClicked = json['rowClicked'];
    postalCode = json['postalCode'];
    name = json['name'];
    id = json['id'];
    distance = json['distance'];
    dimensionID = json['dimensionID'];
    avaibility = json['Avaibility'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rowClicked'] = this.rowClicked;
    data['postalCode'] = this.postalCode;
    data['name'] = this.name;
    data['id'] = this.id;
    data['distance'] = this.distance;
    data['dimensionID'] = this.dimensionID;
    data['Avaibility'] = this.avaibility;
    return data;
  }

  @override
  List<Object?> get props => [
    rowClicked,
    postalCode,
    name,
    id,
    distance,
    dimensionID,
    avaibility,
  ];
}

class SearchStoreListInformation extends Equatable{
  SearchStoreListInformation({
    this.id,
    this.developerName,
    this.masterLabel,
    this.language,
    this.label,
    this.qualifiedApiName,
    this.corporateC,
    this.companyC,
    this.regionC,
    this.regionDescriptionC,
    this.districtC,
    this.districtDescriptionC,
    this.storeC,
    this.storeDescriptionC,
    this.storeNameC,
    this.storeAddressC,
    this.storeCityC,
    this.stateC,
    this.countryC,
    this.postalCodeC,
    this.latitudeC,
    this.longitudeC,
    this.faxC,
    this.phoneC,
    this.lessonsC,
    this.activeC,
  });

  String? id;
  String? developerName;
  String? masterLabel;
  String? language;
  String? label;
  String? qualifiedApiName;
  String? corporateC;
  String? companyC;
  double? regionC;
  String? regionDescriptionC;
  double? districtC;
  String? districtDescriptionC;
  String? storeC;
  String? storeDescriptionC;
  String? storeNameC;
  String? storeAddressC;
  String? storeCityC;
  String? stateC;
  String? countryC;
  String? postalCodeC;
  String? latitudeC;
  String? longitudeC;
  String? faxC;
  String? phoneC;
  bool? lessonsC;
  bool? activeC;

  factory SearchStoreListInformation.fromJson(Map<String, dynamic> json) =>
      SearchStoreListInformation(
        id: json["Id"],
        developerName: json["DeveloperName"],
        masterLabel: json["MasterLabel"],
        language: json["Language"],
        label: json["Label"],
        qualifiedApiName: json["QualifiedApiName"],
        corporateC: json["Corporate__c"],
        companyC: json["Company__c"],
        regionC: (json["Region__c"] is double)
            ? json["Region__c"]
            : json["Region__c"].toDouble(),
        regionDescriptionC: json["RegionDescription__c"],
        districtC: (json["District__c"] is double)
            ? json["District__c"]
            : json["District__c"].toDouble(),
        districtDescriptionC: json["DistrictDescription__c"],
        storeC: json["Store__c"],
        storeDescriptionC: json["StoreDescription__c"],
        storeNameC: json["StoreName__c"],
        storeAddressC: json["StoreAddress__c"],
        storeCityC: json["StoreCity__c"],
        stateC: json["State__c"],
        countryC: json["Country__c"],
        postalCodeC: json["PostalCode__c"],
        latitudeC: json["Latitude__c"],
        longitudeC: json["Longitude__c"],
        faxC: json["Fax__c"],
        phoneC: json["Phone__c"],
        lessonsC: json["Lessons__c"],
        activeC: json["Active__c"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "DeveloperName": developerName,
        "MasterLabel": masterLabel,
        "Language": language,
        "Label": label,
        "QualifiedApiName": qualifiedApiName,
        "Corporate__c": corporateC,
        "Company__c": companyC,
        "Region__c": regionC,
        "RegionDescription__c": regionDescriptionC,
        "District__c": districtC,
        "DistrictDescription__c": districtDescriptionC,
        "Store__c": storeC,
        "StoreDescription__c": storeDescriptionC,
        "StoreName__c": storeNameC,
        "StoreAddress__c": storeAddressC,
        "StoreCity__c": storeCityC,
        "State__c": stateC,
        "Country__c": countryC,
        "PostalCode__c": postalCodeC,
        "Latitude__c": latitudeC,
        "Longitude__c": longitudeC,
        "Fax__c": faxC,
        "Phone__c": phoneC,
        "Lessons__c": lessonsC,
        "Active__c": activeC,
      };

  @override
  List<Object?> get props => [
    id,
    developerName,
    masterLabel,
    language,
    label,
    qualifiedApiName,
    corporateC,
    companyC,
    regionC,
    regionDescriptionC,
    districtC,
    districtDescriptionC,
    storeC,
    storeDescriptionC,
    storeNameC,
    storeAddressC,
    storeCityC,
    stateC,
    countryC,
    postalCodeC,
    latitudeC,
    longitudeC,
    faxC,
    phoneC,
    lessonsC,
    activeC,
  ];
}
