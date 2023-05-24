class CaseHistoryListModelClass {
  CaseHistoryListModelClass({
    required this.totalSize,
    required this.done,
    required this.records,
  });
  late final int totalSize;
  late final bool done;
  late final List<Records> records;

  CaseHistoryListModelClass.fromJson(Map<String, dynamic> json) {
    totalSize = json['totalSize'];
    done = json['done'];
    if (json['records'] == null) {
      json['records'] = [];
    } else {
      records =
          List.from(json['records']).map((e) => Records.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['totalSize'] = totalSize;
    data['done'] = done;
    return data;
  }
}

class Records {
  Records({
    required this.attributes,
    required this.id,
    required this.caseNumber,
    this.caseTypeC,
    this.caseSubtypeC,
    this.type,
    this.orderNumberC,
    this.dAXOrderNumberC,
    this.orderTotalC,
    required this.priority,
    this.reason,
    this.subject,
    required this.status,
    required this.account,
    required this.owner,
    required this.createdDate,
    required this.lastModifiedDate,
  });
  late final Attributes attributes;
  late final String id;
  late final String caseNumber;
  late final String? caseTypeC;
  late final String? caseSubtypeC;
  late final dynamic type;
  late final dynamic orderNumberC;
  late final dynamic dAXOrderNumberC;
  late final dynamic orderTotalC;
  late final String priority;
  late final dynamic reason;
  late final dynamic subject;
  late final String status;
  late final Account account;
  late final Owner owner;
  late final String createdDate;
  late final String lastModifiedDate;

  Records.fromJson(Map<String, dynamic> json) {
    attributes = Attributes.fromJson(json['attributes']);
    id = json['Id'] ?? '';
    caseNumber = json['CaseNumber'] ?? '';
    caseTypeC = json['Case_Type__c'] ?? '';
    caseSubtypeC = json['Case_Subtype__c'] ?? '';
    type = json['Type'] ?? '';
    orderNumberC = json['Order_Number__c'] ?? '';
    dAXOrderNumberC = json['DAX_Order_Number__c'] ?? '';
    orderTotalC = json['Order_Total__c'] ?? '';
    priority = json['Priority'] ?? '';
    reason = json['Reason'] ?? '';
    subject = json['Subject'] ?? '';
    status = json['Status'] ?? '';
    account = Account.fromJson(json['Account']);
    owner = Owner.fromJson(json['Owner']);
    createdDate = json['CreatedDate'] ?? '';
    lastModifiedDate = json['LastModifiedDate'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['attributes'] = attributes.toJson();
    data['Id'] = id;
    data['CaseNumber'] = caseNumber;
    data['Case_Type__c'] = caseTypeC;
    data['Case_Subtype__c'] = caseSubtypeC;
    data['Type'] = Type;
    data['Order_Number__c'] = orderNumberC;
    data['DAX_Order_Number__c'] = dAXOrderNumberC;
    data['Order_Total__c'] = orderTotalC;
    data['Priority'] = priority;
    data['Reason'] = reason;
    data['Subject'] = subject;
    data['Status'] = status;
    data['Account'] = account.toJson();
    data['Owner'] = owner.toJson();
    data['CreatedDate'] = createdDate;
    data['LastModifiedDate'] = lastModifiedDate;
    return data;
  }
}

class Attributes {
  Attributes({
    required this.type,
    required this.url,
  });
  late final String type;
  late final String url;

  Attributes.fromJson(Map<String, dynamic> json) {
    type = json['type'] ?? '';
    url = json['url'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    data['url'] = url;
    return data;
  }
}

class Account {
  Account({
    required this.attributes,
    required this.name,
  });
  late final Attributes attributes;
  late final String name;

  Account.fromJson(Map<String, dynamic> json) {
    attributes = Attributes.fromJson(json['attributes']);
    name = json['Name'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['attributes'] = attributes.toJson();
    data['Name'] = name;
    return data;
  }
}

class Owner {
  Owner({
    required this.attributes,
    required this.name,
  });
  late final Attributes attributes;
  late final String name;

  Owner.fromJson(Map<String, dynamic> json) {
    attributes = Attributes.fromJson(json['attributes']);
    name = json['Name'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['attributes'] = attributes.toJson();
    data['Name'] = name;
    return data;
  }
}
