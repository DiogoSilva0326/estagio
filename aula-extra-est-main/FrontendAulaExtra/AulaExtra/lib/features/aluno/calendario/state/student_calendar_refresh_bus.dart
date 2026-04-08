import 'package:flutter/foundation.dart';

class StudentCalendarRefreshBus {
  StudentCalendarRefreshBus._();

  static final ValueNotifier<int> notifier = ValueNotifier<int>(0);

  static void notifyChanged() {
    notifier.value = notifier.value + 1;
  }
}
