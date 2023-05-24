import 'package:intl/intl.dart';

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
  String changeToBritishFormat(String date) {
    if (date.isNotEmpty) {
      String firstDate = date.contains("T") ? date.split("T")[0] : date;
      firstDate = firstDate.contains(":")
          ? firstDate.trim().split(" ")[0]
          : firstDate.trim();
      List<String> fullMonths = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "JULY",
        "AUGUST",
        "SEPTEMBER",
        "OCTOBER",
        "NOVEMBER",
        "DECEMBER"
      ];
      List<String> halfMonths = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "JUL",
        "AUG",
        "SEP",
        "OCT",
        "NOV",
        "DEC"
      ];

      String month = "";
      if (firstDate.split("-").length > 1) {
        month = firstDate.split("-")[1];
        if (isNumeric(firstDate.split("-")[1])) {
          if (firstDate.split("-")[0].length == 4) {
            String formattedDate = DateFormat('MMMM dd, yyyy').format(DateTime(
                int.parse(firstDate.split("-")[0]),
                int.parse(firstDate.split("-")[1]),
                int.parse(firstDate.split("-")[2])));
            return formattedDate;
          } else {
            String formattedDate = DateFormat('MMMM dd, yyyy').format(DateTime(
                int.parse(firstDate.split("-")[2]),
                int.parse(firstDate.split("-")[1]),
                int.parse(firstDate.split("-")[0])));
            return formattedDate;
          }
        } else {
          if (firstDate.split("-")[1].length == 3) {
            int index = halfMonths.indexOf(halfMonths.firstWhere((element) =>
                element.toLowerCase() ==
                firstDate.split("-")[1].toLowerCase()));
            if (index < 0) {
              return "Not a valid date";
            } else {
              if (firstDate.split("-")[0].length == 4) {
                String formattedDate = DateFormat('MMMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split("-")[0]), (index + 1),
                        int.parse(firstDate.split("-")[2])));
                return formattedDate;
              } else {
                String formattedDate = DateFormat('MMMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split("-")[2]), (index + 1),
                        int.parse(firstDate.split("-")[0])));
                return formattedDate;
              }
            }
          } else {
            int index = fullMonths.indexOf(fullMonths.firstWhere((element) =>
                element.toLowerCase() ==
                firstDate.split("-")[1].toLowerCase()));
            if (index < 0) {
              return "Not a valid date";
            } else {
              if (firstDate.split("-")[0].length == 4) {
                String formattedDate = DateFormat('MMMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split("-")[0]), (index + 1),
                        int.parse(firstDate.split("-")[2])));
                return formattedDate;
              } else {
                String formattedDate = DateFormat('MMMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split("-")[2]), (index + 1),
                        int.parse(firstDate.split("-")[0])));
                return formattedDate;
              }
            }
          }
        }
      } else if (firstDate.split("/").length > 1) {
        month = firstDate.split("/")[1];
        if (isNumeric(firstDate.split("/")[1])) {
          if (firstDate.split("/")[0].length == 4) {
            String formattedDate = DateFormat('MMMM dd, yyyy').format(DateTime(
                int.parse(firstDate.split("/")[0]),
                int.parse(firstDate.split("/")[1]),
                int.parse(firstDate.split("/")[2])));
            return formattedDate;
          } else {
            String formattedDate = DateFormat('MMMM dd, yyyy').format(DateTime(
                int.parse(firstDate.split("/")[2]),
                int.parse(firstDate.split("/")[1]),
                int.parse(firstDate.split("/")[0])));
            return formattedDate;
          }
        } else {
          if (firstDate.split("/")[1].length == 3) {
            int index = halfMonths.indexOf(halfMonths.firstWhere((element) =>
                element.toLowerCase() ==
                firstDate.split("/")[1].toLowerCase()));
            if (index < 0) {
              return "Not a valid date";
            } else {
              if (firstDate.split("/")[0].length == 4) {
                String formattedDate = DateFormat('MMMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split("/")[0]), (index + 1),
                        int.parse(firstDate.split("/")[2])));
                return formattedDate;
              } else {
                String formattedDate = DateFormat('MMMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split("/")[2]), (index + 1),
                        int.parse(firstDate.split("/")[0])));
                return formattedDate;
              }
            }
          } else {
            int index = fullMonths.indexOf(fullMonths.firstWhere((element) =>
                element.toLowerCase() ==
                firstDate.split("/")[1].toLowerCase()));
            if (index < 0) {
              return "Not a valid date";
            } else {
              if (firstDate.split("/")[0].length == 4) {
                String formattedDate = DateFormat('MMMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split("/")[0]), (index + 1),
                        int.parse(firstDate.split("/")[2])));
                return formattedDate;
              } else {
                String formattedDate = DateFormat('MMMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split("/")[2]), (index + 1),
                        int.parse(firstDate.split("/")[0])));
                return formattedDate;
              }
            }
          }
        }
      } else if (firstDate.split(" ").length > 1) {
        month = firstDate.split(" ")[1];
        if (isNumeric(firstDate.split(" ")[1])) {
          if (firstDate.split(" ")[0].length == 4) {
            String formattedDate = DateFormat('MMMM dd, yyyy').format(DateTime(
                int.parse(firstDate.split(" ")[0]),
                int.parse(firstDate.split(" ")[1]),
                int.parse(firstDate.split(" ")[2])));
            return formattedDate;
          } else {
            String formattedDate = DateFormat('MMMM dd, yyyy').format(DateTime(
                int.parse(firstDate.split(" ")[2]),
                int.parse(firstDate.split(" ")[1]),
                int.parse(firstDate.split(" ")[0])));
            return formattedDate;
          }
        } else {
          if (firstDate.split(" ")[1].length == 3) {
            int index = halfMonths.indexOf(halfMonths.firstWhere((element) =>
                element.toLowerCase() ==
                firstDate.split(" ")[1].toLowerCase()));
            if (index < 0) {
              return "Not a valid date";
            } else {
              if (firstDate.split(" ")[0].length == 4) {
                String formattedDate = DateFormat('MMMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split(" ")[0]), (index + 1),
                        int.parse(firstDate.split(" ")[2])));
                return formattedDate;
              } else {
                String formattedDate = DateFormat('MMMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split(" ")[2]), (index + 1),
                        int.parse(firstDate.split(" ")[0])));
                return formattedDate;
              }
            }
          } else {
            int index = fullMonths.indexOf(fullMonths.firstWhere((element) =>
                element.toLowerCase() ==
                firstDate.split(" ")[1].toLowerCase()));
            if (index < 0) {
              return "Not a valid date";
            } else {
              if (firstDate.split(" ")[0].length == 4) {
                String formattedDate = DateFormat('MMMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split(" ")[0]), (index + 1),
                        int.parse(firstDate.split(" ")[2])));
                return formattedDate;
              } else {
                String formattedDate = DateFormat('MMMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split(" ")[2]), (index + 1),
                        int.parse(firstDate.split(" ")[0])));
                return formattedDate;
              }
            }
          }
        }
      }
    }

    return "";
  }

  String changeToBritishFormatHalf(String date) {
    if (date.isNotEmpty) {
      String firstDate = date.contains("T") ? date.split("T")[0] : date;
      firstDate = firstDate.contains(":")
          ? firstDate.trim().split(" ")[0]
          : firstDate.trim();
      List<String> fullMonths = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "JULY",
        "AUGUST",
        "SEPTEMBER",
        "OCTOBER",
        "NOVEMBER",
        "DECEMBER"
      ];
      List<String> halfMonths = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "JUL",
        "AUG",
        "SEP",
        "OCT",
        "NOV",
        "DEC"
      ];

      String month = "";
      if (firstDate.split("-").length > 1) {
        month = firstDate.split("-")[1];
        if (isNumeric(firstDate.split("-")[1])) {
          if (firstDate.split("-")[0].length == 4) {
            String formattedDate = DateFormat('MMM dd, yyyy').format(DateTime(
                int.parse(firstDate.split("-")[0]),
                int.parse(firstDate.split("-")[1]),
                int.parse(firstDate.split("-")[2])));
            return formattedDate;
          } else {
            String formattedDate = DateFormat('MMM dd, yyyy').format(DateTime(
                int.parse(firstDate.split("-")[2]),
                int.parse(firstDate.split("-")[1]),
                int.parse(firstDate.split("-")[0])));
            return formattedDate;
          }
        } else {
          if (firstDate.split("-")[1].length == 3) {
            int index = halfMonths.indexOf(halfMonths.firstWhere((element) =>
                element.toLowerCase() ==
                firstDate.split("-")[1].toLowerCase()));
            if (index < 0) {
              return "Not a valid date";
            } else {
              if (firstDate.split("-")[0].length == 4) {
                String formattedDate = DateFormat('MMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split("-")[0]), (index + 1),
                        int.parse(firstDate.split("-")[2])));
                return formattedDate;
              } else {
                String formattedDate = DateFormat('MMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split("-")[2]), (index + 1),
                        int.parse(firstDate.split("-")[0])));
                return formattedDate;
              }
            }
          } else {
            int index = fullMonths.indexOf(fullMonths.firstWhere((element) =>
                element.toLowerCase() ==
                firstDate.split("-")[1].toLowerCase()));
            if (index < 0) {
              return "Not a valid date";
            } else {
              if (firstDate.split("-")[0].length == 4) {
                String formattedDate = DateFormat('MMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split("-")[0]), (index + 1),
                        int.parse(firstDate.split("-")[2])));
                return formattedDate;
              } else {
                String formattedDate = DateFormat('MMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split("-")[2]), (index + 1),
                        int.parse(firstDate.split("-")[0])));
                return formattedDate;
              }
            }
          }
        }
      } else if (firstDate.split("/").length > 1) {
        month = firstDate.split("/")[1];
        if (isNumeric(firstDate.split("/")[1])) {
          if (firstDate.split("/")[0].length == 4) {
            String formattedDate = DateFormat('MMM dd, yyyy').format(DateTime(
                int.parse(firstDate.split("/")[0]),
                int.parse(firstDate.split("/")[1]),
                int.parse(firstDate.split("/")[2])));
            return formattedDate;
          } else {
            String formattedDate = DateFormat('MMM dd, yyyy').format(DateTime(
                int.parse(firstDate.split("/")[2]),
                int.parse(firstDate.split("/")[1]),
                int.parse(firstDate.split("/")[0])));
            return formattedDate;
          }
        } else {
          if (firstDate.split("/")[1].length == 3) {
            int index = halfMonths.indexOf(halfMonths.firstWhere((element) =>
                element.toLowerCase() ==
                firstDate.split("/")[1].toLowerCase()));
            if (index < 0) {
              return "Not a valid date";
            } else {
              if (firstDate.split("/")[0].length == 4) {
                String formattedDate = DateFormat('MMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split("/")[0]), (index + 1),
                        int.parse(firstDate.split("/")[2])));
                return formattedDate;
              } else {
                String formattedDate = DateFormat('MMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split("/")[2]), (index + 1),
                        int.parse(firstDate.split("/")[0])));
                return formattedDate;
              }
            }
          } else {
            int index = fullMonths.indexOf(fullMonths.firstWhere((element) =>
                element.toLowerCase() ==
                firstDate.split("/")[1].toLowerCase()));
            if (index < 0) {
              return "Not a valid date";
            } else {
              if (firstDate.split("/")[0].length == 4) {
                String formattedDate = DateFormat('MMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split("/")[0]), (index + 1),
                        int.parse(firstDate.split("/")[2])));
                return formattedDate;
              } else {
                String formattedDate = DateFormat('MMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split("/")[2]), (index + 1),
                        int.parse(firstDate.split("/")[0])));
                return formattedDate;
              }
            }
          }
        }
      } else if (firstDate.split(" ").isNotEmpty) {
        month = firstDate.split(" ")[1];
        if (isNumeric(firstDate.split(" ")[1])) {
          if (firstDate.split(" ")[0].length == 4) {
            String formattedDate = DateFormat('MMM dd, yyyy').format(DateTime(
                int.parse(firstDate.split(" ")[0]),
                int.parse(firstDate.split(" ")[1]),
                int.parse(firstDate.split(" ")[2])));
            return formattedDate;
          } else {
            String formattedDate = DateFormat('MMM dd, yyyy').format(DateTime(
                int.parse(firstDate.split(" ")[2]),
                int.parse(firstDate.split(" ")[1]),
                int.parse(firstDate.split(" ")[0])));
            return formattedDate;
          }
        } else {
          if (firstDate.split(" ")[1].length == 3) {
            int index = halfMonths.indexOf(halfMonths.firstWhere((element) =>
                element.toLowerCase() ==
                firstDate.split(" ")[1].toLowerCase()));
            if (index < 0) {
              return "Not a valid date";
            } else {
              if (firstDate.split(" ")[0].length == 4) {
                String formattedDate = DateFormat('MMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split(" ")[0]), (index + 1),
                        int.parse(firstDate.split(" ")[2])));
                return formattedDate;
              } else {
                String formattedDate = DateFormat('MMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split(" ")[2]), (index + 1),
                        int.parse(firstDate.split(" ")[0])));
                return formattedDate;
              }
            }
          } else {
            int index = fullMonths.indexOf(fullMonths.firstWhere((element) =>
                element.toLowerCase() ==
                firstDate.split(" ")[1].toLowerCase()));
            if (index < 0) {
              return "Not a valid date";
            } else {
              if (firstDate.split(" ")[0].length == 4) {
                String formattedDate = DateFormat('MMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split(" ")[0]), (index + 1),
                        int.parse(firstDate.split(" ")[2])));
                return formattedDate;
              } else {
                String formattedDate = DateFormat('MMM dd, yyyy').format(
                    DateTime(int.parse(firstDate.split(" ")[2]), (index + 1),
                        int.parse(firstDate.split(" ")[0])));
                return formattedDate;
              }
            }
          }
        }
      }
    }

    return "";
  }

  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }

  String toMobileFormat() {
    return this.replaceAllMapped(RegExp(r'(\d{3})(\d{3})(\d+)'),
        (Match m) => "(${m[1]}) ${m[2]}-${m[3]}");
  }

  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
