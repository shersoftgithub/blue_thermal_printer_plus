import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
class ArabicShaper {
  static const Map<String, List<String>> arabicForms = {
    "ا": ["ا", "ﺎ", "ﺎ", "ﺎ"],
    "ب": ["ب", "ﺑ", "ﺒ", "ﺒ"],
    "ت": ["ت", "ﺗ", "ﺘ", "ﺘ"],
    "ث": ["ث", "ﺛ", "ﺜ", "ﺜ"],
    "ج": ["ج", "ﺟ", "ﺠ", "ﺠ"],
    "ح": ["ح", "ﺣ", "ﺤ", "ﺤ"],
    "خ": ["خ", "ﺧ", "ﺨ", "ﺨ"],
    "د": ["د", "ﺪ", "ﺪ", "ﺪ"],
    "ذ": ["ذ", "ﺬ", "ﺬ", "ﺬ"],
    "ر": ["ر", "ﺮ", "ﺮ", "ﺮ"],
    "ز": ["ز", "ﺰ", "ﺰ", "ﺰ"],
    "س": ["س", "ﺳ", "ﺴ", "ﺴ"],
    "ش": ["ش", "ﺷ", "ﺸ", "ﺸ"],
    "ص": ["ص", "ﺻ", "ﺼ", "ﺼ"],
    "ض": ["ض", "ﺿ", "ﻀ", "ﻀ"],
    "ط": ["ط", "ﻃ", "ﻄ", "ﻄ"],
    "ظ": ["ظ", "ﻇ", "ﻈ", "ﻈ"],
    "ع": ["ع", "ﻋ", "ﻌ", "ﻌ"],
    "غ": ["غ", "ﻏ", "ﻐ", "ﻐ"],
    "ف": ["ف", "ﻓ", "ﻔ", "ﻔ"],
    "ق": ["ق", "ﻗ", "ﻘ", "ﻘ"],
    "ك": ["ك", "ﻛ", "ﻜ", "ﻜ"],
    "ل": ["ل", "ﻟ", "ﻠ", "ﻠ"],
    "م": ["م", "ﻣ", "ﻤ", "ﻤ"],
    "ن": ["ن", "ﻧ", "ﻨ", "ﻨ"],
    "ه": ["ه", "ﻫ", "ﻬ", "ﻬ"],
    "و": ["و", "ﻮ", "ﻮ", "ﻮ"],
    "ي": ["ي", "ﻳ", "ﻴ", "ﻴ"],
  };

  static String shapeArabic(String text) {
    String shapedText = "";

    for (int i = 0; i < text.length; i++) {
      String char = text[i];

      if (arabicForms.containsKey(char)) {
        bool hasPrev = i > 0 && arabicForms.containsKey(text[i - 1]);
        bool hasNext = i < text.length - 1 && arabicForms.containsKey(text[i + 1]);

        if (!hasPrev && !hasNext) {
          shapedText += arabicForms[char]![0]; // Isolated form
        } else if (hasPrev && hasNext) {
          shapedText += arabicForms[char]![2]; // Medial form
        } else if (hasPrev) {
          shapedText += arabicForms[char]![3]; // Final form
        } else {
          shapedText += arabicForms[char]![1]; // Initial form
        }
      } else {
        shapedText += char; // Non-Arabic characters stay the same
      }
    }

    return shapedText;
  }
}


class BlueThermalPrinter {
  static const int STATE_OFF = 10;
  static const int STATE_TURNING_ON = 11;
  static const int STATE_ON = 12;
  static const int STATE_TURNING_OFF = 13;
  static const int STATE_BLE_TURNING_ON = 14;
  static const int STATE_BLE_ON = 15;
  static const int STATE_BLE_TURNING_OFF = 16;
  static const int ERROR = -1;
  static const int CONNECTED = 1;
  static const int DISCONNECTED = 0;
  static const int DISCONNECT_REQUESTED = 2;

  static const String namespace = 'blue_thermal_printer';

  static const MethodChannel _channel =
      const MethodChannel('$namespace/methods');

  static const EventChannel _readChannel =
      const EventChannel('$namespace/read');

  static const EventChannel _stateChannel =
      const EventChannel('$namespace/state');

  final StreamController<MethodCall> _methodStreamController =
      new StreamController.broadcast();

  //Stream<MethodCall> get _methodStream => _methodStreamController.stream;

  BlueThermalPrinter._() {
    _channel.setMethodCallHandler((MethodCall call) async {
      _methodStreamController.add(call);
    });
  }

  static BlueThermalPrinter _instance = new BlueThermalPrinter._();

  static BlueThermalPrinter get instance => _instance;

  ///onStateChanged()
  Stream<int?> onStateChanged() async* {
    yield await _channel.invokeMethod('state').then((buffer) => buffer);

    yield* _stateChannel.receiveBroadcastStream().map((buffer) => buffer);
  }

  ///onRead()
  Stream<String> onRead() =>
      _readChannel.receiveBroadcastStream().map((buffer) => buffer.toString());

  Future<bool?> get isAvailable async =>
      await _channel.invokeMethod('isAvailable');

  Future<bool?> get isOn async => await _channel.invokeMethod('isOn');

  Future<bool?> get isConnected async =>
      await _channel.invokeMethod('isConnected');

  Future<bool?> get openSettings async =>
      await _channel.invokeMethod('openSettings');

  ///getBondedDevices()
  Future<List<BluetoothDevice>> getBondedDevices() async {
    final List list = await (_channel.invokeMethod('getBondedDevices'));
    return list.map((map) => BluetoothDevice.fromMap(map)).toList();
  }

  ///isDeviceConnected(BluetoothDevice device)
  Future<bool?> isDeviceConnected(BluetoothDevice device) =>
      _channel.invokeMethod('isDeviceConnected', device.toMap());

  ///connect(BluetoothDevice device)
  Future<dynamic> connect(BluetoothDevice device) =>
      _channel.invokeMethod('connect', device.toMap());

  ///disconnect()
  Future<dynamic> disconnect() => _channel.invokeMethod('disconnect');

  ///write(String message)
  Future<dynamic> write(String message) =>
      _channel.invokeMethod('write', {'message': message});

  ///writeBytes(Uint8List message)
  Future<dynamic> writeBytes(Uint8List message) =>
      _channel.invokeMethod('writeBytes', {'message': message});

  ///printCustom(String message, int size, int align,{String? charset})
  Future<dynamic> printCustom(String message, int size, int align,
          {String? charset}) =>
      _channel.invokeMethod('printCustom', {
        'message': message,
        'size': size,
        'align': align,
        'charset': charset
      });

    void printArabicText() {
  String arabicText = "مرحبا بكم في المتجر";
  String shapedText = ArabicShaper.shapeArabic(arabicText); // Fix Arabic shaping

  // bluetooth.printCustom(shapedText, Enu.Size.medium.val, Enu.Align.center.val);
}     

  ///printNewLine()
  Future<dynamic> printNewLine() => _channel.invokeMethod('printNewLine');

  ///paperCut()
  Future<dynamic> paperCut() => _channel.invokeMethod('paperCut');

  ///drawerPin5()
  Future<dynamic> drawerPin2() => _channel.invokeMethod('drawerPin2');

  ///drawerPin5()
  Future<dynamic> drawerPin5() => _channel.invokeMethod('drawerPin5');

  ///printImage(String pathImage)
  Future<dynamic> printImage(String pathImage) =>
      _channel.invokeMethod('printImage', {'pathImage': pathImage});

  ///printImageBytes(Uint8List bytes)
  Future<dynamic> printImageBytes(Uint8List bytes) =>
      _channel.invokeMethod('printImageBytes', {'bytes': bytes});

  ///printQRcode(String textToQR, int width, int height, int align)
  Future<dynamic> printQRcode(
          String textToQR, int width, int height, int align) =>
      _channel.invokeMethod('printQRcode', {
        'textToQR': textToQR,
        'width': width,
        'height': height,
        'align': align
      });
   

  ///printLeftRight(String string1, String string2, int size,{String? charset, String? format})
  Future<dynamic> printLeftRight(String string1, String string2, int size,
          {String? charset, String? format}) =>
      _channel.invokeMethod('printLeftRight', {
        'string1': string1,
        'string2': string2,
        'size': size,
        'charset': charset,
        'format': format
      });

  ///print3Column(String string1, String string2, String string3, int size,{String? charset, String? format})
  Future<dynamic> print3Column(
          String string1, String string2, String string3, int size,
          {String? charset, String? format}) =>
      _channel.invokeMethod('print3Column', {
        'string1': string1,
        'string2': string2,
        'string3': string3,
        'size': size,
        'charset': charset,
        'format': format
      });

  ///print4Column(String string1, String string2, String string3,String string4, int size,{String? charset, String? format})
  Future<dynamic> print4Column(String string1, String string2, String string3,
          String string4, int size,
          {String? charset, String? format}) =>
      _channel.invokeMethod('print4Column', {
        'string1': string1,
        'string2': string2,
        'string3': string3,
        'string4': string4,
        'size': size,
        'charset': charset,
        'format': format
      });

  ///print5Column(String string1, String string2, String string3,String string4,String string5, int size,{String? charset, String? format})
  Future<dynamic> print5Column(String string1, String string2, String string3,
          String string4, String string5, int size,
          {String? charset, String? format}) =>
      _channel.invokeMethod('print5Column', {
        'string1': string1,
        'string2': string2,
        'string3': string3,
        'string4': string4,
        'string5': string5,
        'size': size,
        'charset': charset,
        'format': format
      });

  ///print6Column(String string1, String string2, String string3,String string4,String string5,String string6, int size,{String? charset, String? format})
  Future<dynamic> print6Column(String string1, String string2, String string3,
          String string4, String string5, String string6, int size,
          {String? charset, String? format}) =>
      _channel.invokeMethod('print6Column', {
        'string1': string1,
        'string2': string2,
        'string3': string3,
        'string4': string4,
        'string5': string5,
        'string6': string6,
        'size': size,
        'charset': charset,
        'format': format
      });

  ///print7Column(String string1, String string2, String string3,String string4,String string5,String string6,String string7, int size,{String? charset, String? format})
  Future<dynamic> print7Column(
          String string1,
          String string2,
          String string3,
          String string4,
          String string5,
          String string6,
          String string7,
          int size,
          {String? charset,
          String? format}) =>
      _channel.invokeMethod('print7Column', {
        'string1': string1,
        'string2': string2,
        'string3': string3,
        'string4': string4,
        'string5': string5,
        'string6': string6,
        'string7': string7,
        'size': size,
        'charset': charset,
        'format': format
      });

  ///print8Column(String string1, String string2, String string3,String string4,String string5,String string6,String string7,String string8, int size,{String? charset, String? format})
  Future<dynamic> print8Column(
          String string1,
          String string2,
          String string3,
          String string4,
          String string5,
          String string6,
          String string7,
          String string8,
          int size,
          {String? charset,
          String? format}) =>
      _channel.invokeMethod('print8Column', {
        'string1': string1,
        'string2': string2,
        'string3': string3,
        'string4': string4,
        'string5': string5,
        'string6': string6,
        'string7': string7,
        'string8': string8,
        'size': size,
        'charset': charset,
        'format': format
      });

  ///print9Column(String string1, String string2, String string3,String string4,String string5,String string6,String string7,String string8,String string9, int size,{String? charset, String? format})
  Future<dynamic> print9Column(
          String string1,
          String string2,
          String string3,
          String string4,
          String string5,
          String string6,
          String string7,
          String string8,
          String string9,
          int size,
          {String? charset,
          String? format}) =>
      _channel.invokeMethod('print9Column', {
        'string1': string1,
        'string2': string2,
        'string3': string3,
        'string4': string4,
        'string5': string5,
        'string6': string6,
        'string7': string7,
        'string8': string8,
        'string9': string9,
        'size': size,
        'charset': charset,
        'format': format
      });

  ///print10Column(String string1, String string2, String string3,String string4,String string5,String string6,String string7,String string8,String string9,String string10, int size,{String? charset, String? format})
  Future<dynamic> print10Column(
          String string1,
          String string2,
          String string3,
          String string4,
          String string5,
          String string6,
          String string7,
          String string8,
          String string9,
          String string10,
          int size,
          {String? charset,
          String? format}) =>
      _channel.invokeMethod('print10Column', {
        'string1': string1,
        'string2': string2,
        'string3': string3,
        'string4': string4,
        'string5': string5,
        'string6': string6,
        'string7': string7,
        'string8': string8,
        'string9': string9,
        'string10': string10,
        'size': size,
        'charset': charset,
        'format': format
      });
}

class BluetoothDevice {
  final String? name;
  final String? address;
  final int type = 0;
  bool connected = false;

  BluetoothDevice(this.name, this.address);

  BluetoothDevice.fromMap(Map map)
      : name = map['name'],
        address = map['address'];

  Map<String, dynamic> toMap() => {
        'name': this.name,
        'address': this.address,
        'type': this.type,
        'connected': this.connected,
      };

  operator ==(Object other) {
    return other is BluetoothDevice && other.address == this.address;
  }

  @override
  int get hashCode => address.hashCode;
}
