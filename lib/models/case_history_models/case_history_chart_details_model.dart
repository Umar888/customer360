class CaseHistoryChartDetails {
  CaseHistoryChartDetails({
    required this.totalSize,
    required this.done,
    required this.records,
  });
  late final int totalSize;
  late final bool done;
  late final List<Records> records;

  CaseHistoryChartDetails.fromJson(Map<String, dynamic> json) {
    totalSize = json['totalSize'];
    done = json['done'];
    records =
        List.from(json['records']).map((e) => Records.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['totalSize'] = totalSize;
    data['done'] = done;
    data['records'] = records.map((e) => e.toJson()).toList();
    return data;
  }
}

class Records {
  Records({
    required this.attributes,
    required this.id,
    required this.caseNumber,
    required this.createdDate,
    required this.lastModifiedDate,
    required this.priority,
    this.reason,
    this.subject,
    required this.status,
    required this.account,
    required this.owner,
  });
  late final Attributes attributes;
  late final String id;
  late final String caseNumber;
  late final String createdDate;
  late final String lastModifiedDate;
  late final String priority;
  late final dynamic reason;
  late final dynamic subject;
  late final String status;
  late final Account account;
  late final Owner owner;

  Records.fromJson(Map<String, dynamic> json) {
    attributes = Attributes.fromJson(json['attributes']);
    id = json['Id'];
    caseNumber = json['CaseNumber'];
    createdDate = json['CreatedDate'];
    lastModifiedDate = json['LastModifiedDate'];
    priority = json['Priority'];
    reason = json['Reason'] ?? '';
    subject = json['Subject'] ?? '';
    status = json['Status'];
    account = Account.fromJson(json['Account']);
    owner = Owner.fromJson(json['Owner']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['attributes'] = attributes.toJson();
    data['Id'] = id;
    data['CaseNumber'] = caseNumber;
    data['CreatedDate'] = createdDate;
    data['LastModifiedDate'] = lastModifiedDate;
    data['Priority'] = priority;
    data['Reason'] = reason;
    data['Subject'] = subject;
    data['Status'] = status;
    data['Account'] = account.toJson();
    data['Owner'] = owner.toJson();
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
    type = json['type'];
    url = json['url'];
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
    name = json['Name'];
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
    name = json['Name'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['attributes'] = attributes.toJson();
    data['Name'] = name;
    return data;
  }
}
