class PeriodicTimeModel {
  int? validateTokenInSec;
  int? timeInSeconds;
  int? refreshTokenInSec;

  PeriodicTimeModel(
      {this.validateTokenInSec, this.timeInSeconds, this.refreshTokenInSec});

  PeriodicTimeModel.fromJson(Map<String, dynamic> json) {
    validateTokenInSec = json['validateTokenInSec'];
    timeInSeconds = json['timeInSeconds'];
    refreshTokenInSec = json['refreshTokenInSec'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['validateTokenInSec'] = this.validateTokenInSec;
    data['timeInSeconds'] = this.timeInSeconds;
    data['refreshTokenInSec'] = this.refreshTokenInSec;
    return data;
  }
}
