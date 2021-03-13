import 'dart:io';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class SimpleRateMyApp {
  static late void Function() _onShow;
  static late bool Function() _canShow;
  static final InAppReview _inAppReview = InAppReview.instance;

  static int get daysElapsed => _Data.daysElapsed;
  static int get launchesElapsed => _Data.launchesElapsed;
  static bool get showIsActivated => _Data.showIsActivated;

  static Future init({
    void Function() onShow = openPlatformRateDialog,
    bool Function() canShow = _defaultRuleToShow,
  }) async {
    _onShow = onShow;
    _canShow = canShow;
    await _Data.init();
  }

  static Future openStore(
      {String? appStoreId, String? microsoftStoreId}) async {
    if (Platform.isIOS || Platform.isMacOS) assert(appStoreId != null);
    _inAppReview.openStoreListing(
        appStoreId: appStoreId, microsoftStoreId: microsoftStoreId);
  }

  static Future openPlatformRateDialog() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
    }
  }

  static void show({bool force = false}) {
    if (force || (showIsActivated && _canShow())) {
      _onShow();
    }
  }

  static Future dontShowMore() async =>
      _Data.setValue('showIsActivated', false);

  static Future reset() => _Data.setValue('showIsActivated', true);

  static bool _defaultRuleToShow() {
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

class _Data {
  static late Box _dataBox;

  static String get _keyPrefix => 'SRMApp_';

  static Future init() async {
    final Directory appDocumentDir =
        await path_provider.getApplicationDocumentsDirectory();
    try {
      await Hive.initFlutter(appDocumentDir.path);
    } catch (_) {}
    _dataBox = await Hive.openBox('SRMApp');
  }

  static bool get showIsActivated =>
      getValue('showIsActivated', defaultValue: true) as bool;

  static int get daysElapsed {
    final DateTime firstDay =
        getValue('daysElapsed', defaultValue: DateTime.now()) as DateTime;
    return firstDay.difference(DateTime.now()).inDays;
  }

  static int get launchesElapsed {
    int launchers = getValue('launchesElapsed') as int;
    launchers += 1;
    setValue('launchesElapsed', launchers);
    return launchers;
  }

  static Future setValue(String key, value) async {
    await _dataBox.put('$_keyPrefix$key', value);
  }

  static dynamic? getValue(String key, {defaultValue}) =>
      _dataBox.get('$_keyPrefix$key', defaultValue: defaultValue);
}
