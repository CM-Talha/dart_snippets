// ignore_for_file: camel_case_extensions

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../widgets/alerts/custom_snack_bar.dart';

export '/src/utils/extensions.dart';

extension CustomExtensions on String? {
  String isNull() {
    if (this == null) {
      return "Not Found";
    } else {
      return this!;
    }
  }

  int parseInt() {
    if (this == null) {
      return 0;
    } else {
      return int.tryParse(this!) ?? 0;
    }
  }

  double parseDouble() {
    if (this == null) {
      return 0.0;
    } else {
      return double.tryParse(this!) ?? 0.0;
    }
  }

  num parseNum() {
    if (this == null) {
      return 0;
    } else {
      return num.tryParse(this!) ?? 0;
    }
  }

  String getDateDDMMYYYYMMSSFromString() {
    DateFormat format = DateFormat("dd-MM-yyyy hh:mm");
    if (this != null) {
      return format.format(DateTime.parse(this!));
    }
    return "Not Found";
  }

  String getDateDDMMYYYYFromString() {
    if (this != null) {
      return DateFormat("dd-MM-yyyy").format(DateTime.parse(this!));
    }
    return "Not Found";
  }

  bool isEmail() {
    String emailExp =
        r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$';
    RegExp emailRegex = RegExp(emailExp, caseSensitive: false);
    if (this == null) {
      return false;
    }
    if (this!.isEmpty) {
      return false;
    } else if (!emailRegex.hasMatch(this!)) {
      return false;
    } else {
      return true;
    }
  }

  bool isEqual(String? x) {
    if (this == null || x == null) {
      return false;
    } else if (this!.toLowerCase() != x.toLowerCase()) {
      return false;
    } else {
      return true;
    }
  }
}

typedef Method1 = Function(int a, int b);

method2(int a, int b) {
  print(a + b);
  return a + b;
}

checkMethod() {
  String? str1 = "";
  String? str2;

  Method1 m = method2(1, 1);
  m(1, 2);
  if (kDebugMode) {
    print(str1.isEqual(str2));
    print(str1.parseInt());
  }
}

extension on Widget {
  SizedBox normalHeight() {
    return const SizedBox(height: 10,);
  }
  Padding paddingAll(double value, {Key? key}) => Padding(
    key: key,
    padding: EdgeInsets.all(value),
    child: this,
  );
}

extension ToString on SnackBarType {
  String toStr () {
    return toString().split('.').last;
  }
}