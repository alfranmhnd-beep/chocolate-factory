import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SaveService {
  static const key = 'factory_save_v1';
  Future<void> save(Map<String, dynamic> data) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(key, jsonEncode(data));
  }
  Future<Map<String, dynamic>?> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(key);
    if (raw == null) return null;
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }
}
