import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wellness_entry.dart';

class StorageService {
  static const String _entriesKey = 'entries_json';
  static const String _contactsKey = 'contacts_json';

  Future<List<WellnessEntry>> getAllEntries() async {
    return await loadEntries();
  }


  Future<List<WellnessEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_entriesKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List<dynamic> arr = json.decode(jsonStr);
    return arr.map((e) => WellnessEntry.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveEntries(List<WellnessEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(entries.map((e) => e.toMap()).toList());
    await prefs.setString(_entriesKey, jsonStr);
  }

  Future<void> addEntry(WellnessEntry entry) async {
    final list = await loadEntries();
    // chèn đầu danh sách
    list.insert(0, entry);
    await saveEntries(list);
  }

  Future<void> deleteEntryAt(int index) async {
    final list = await loadEntries();
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      await saveEntries(list);
    }
  }
}
