import 'package:intl/intl.dart';

mixin DateHelper {
  static String? getDateDDMMYYYYMMSSFromString(String? date) {
    if(date!=null){
      return DateFormat("dd-MM-yyyy hh:mm").format(DateTime.parse(date));
    }
    return null;
  }
  static String? getDateDDMMYYYYFromString(String? date) {
    if(date!=null){
      return DateFormat("dd-MM-yyyy").format(DateTime.parse(date));
    }
    return null;
  }
  static String? getDateDDMMYYYYFromDateTime(DateTime? date) {
    if(date!=null){
      return DateFormat("dd-MM-yyyy").format(date);
    }
    return null;
  }
}