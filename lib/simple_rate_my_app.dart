import 'dart:io';

import 'package:get_version/get_version.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:hive/hive.dart';

class SimpleRateMyApp {
  static void Function() _onShow;
  static bool Function() _ruleToShow;
  static bool _showIsActivated = true;
  static int daysElapsed;
  static int launchesElapsed;
  static final InAppReview inAppReview = InAppReview.instance;

  static Future init({
    void Function() onShow = openPlatformRateDialog,
    bool Function() ruleToShow = _defaultRule,
  }) async {
    _onShow = onShow;
    _ruleToShow = ruleToShow;
    await _HiveData.init();
    _showIsActivated = _HiveData.showIsActivated();
    daysElapsed = _HiveData.daysElapsed();
    launchesElapsed = _HiveData.launchesElapsed();
  }

  static Future openStore() async {
    if (Platform.isIOS || Platform.isMacOS) {
      String appStoreId;
      try {
        appStoreId = await GetVersion.appID;
      } catch (e) {
        appStoreId = 'Failed to get app ID.';
      }
      await inAppReview.openStoreListing(appStoreId: appStoreId);
    } else {
      await inAppReview.openStoreListing();
    }
  }

  static Future openPlatformRateDialog({void Function(String) callBack}) async {
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    }
  }

  static void show({bool force = false}) {
    if (force || (_showIsActivated && _ruleToShow())) {
      _onShow();
    }
  }

  static Future dontShowMore({bool daysAndLaunchers = false}) async {
    _showIsActivated = false;
    await _HiveData.setValue('showIsActivated', _showIsActivated);
    if (daysAndLaunchers) {
      daysElapsed = 0;
      await _HiveData.setValue('daysElapsed', daysElapsed);
      launchesElapsed = 0;
      await _HiveData.setValue('launchesElapsed', launchesElapsed);
    }
  }

  static void reset() {
    _showIsActivated = true;
    _HiveData.setValue('showIsActivated', _showIsActivated);
  }

  // ignore: prefer_function_declarations_over_variables
  static bool _defaultRule() {
    const int minDays = 7;
    const int minLaunches = 10;
    const int remindDays = 7;
    const int remindLaunches = 10;
    final bool byDays = daysElapsed >= minDays && daysElapsed % remindDays == 0;
    final bool byLaunchers =
        launchesElapsed >= minLaunches && launchesElapsed % remindLaunches == 0;
    return byDays || byLaunchers;
  }
}

class _HiveData {
  static Box _hiveDataBox;

  static String get _keyPrefix => 'SRMApp_';

  static Future init() async {
    _hiveDataBox = await Hive.openBox('SRMApp');
  }

  static bool showIsActivated() {
    return getValue('showIsActivated', defaultValue: true) as bool;
  }

  static int daysElapsed() {
    DateTime firstDay = getValue('daysElapsed') as DateTime;
    if (firstDay == null) {
      firstDay = DateTime.now();
      setValue('daysElapsed', firstDay);
    }
    return firstDay.difference(DateTime.now()).inDays;
  }

  static int launchesElapsed() {
    int launchers = getValue('launchesElapsed', defaultValue: 0) as int;
    launchers += 1;
    setValue('launchesElapsed', launchers);
    return launchers;
  }

  static Future setValue(String key, value) async {
    await _hiveDataBox.put(_keyPrefix + key, value);
  }

  static dynamic getValue(String key, {defaultValue}) {
    return _hiveDataBox.get('$_keyPrefix$key', defaultValue: defaultValue);
  }
}
