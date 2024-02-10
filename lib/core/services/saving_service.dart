import 'package:finman/core/models/saving.dart';
import 'package:hive/hive.dart';

class SavingService {
  static final SavingService _singleton = SavingService._internal();

  factory SavingService() {
    return _singleton;
  }

  SavingService._internal();

  Future<Box<Saving>> _openBox() async {
    return await Hive.openBox<Saving>('savings');
  }

  Future<int> _findIndex(Saving saving) async {
    final Box<Saving> box = await _openBox();
    final List<Saving> savings = box.values.toList();
    return savings.indexWhere((e) => e.id == saving.id);
  }

  Future<void> _update(Saving saving) async {
    final Box<Saving> box = await _openBox();
    final index = await _findIndex(saving);
    if (index == -1) return;

    await box.putAt(index, saving);
  }

  Future<void> save(Saving saving) async {
    if (await _findIndex(saving) != -1) {
      _update(saving);
      return;
    }
    final Box<Saving> box = await _openBox();
    await box.add(saving);
  }

  Future<List<Saving>> fetchAll() async {
    final Box<Saving> box = await _openBox();
    return box.values.toList();
  }

  Future<void> delete(Saving saving) async {
    final Box<Saving> box = await _openBox();
    final index = await _findIndex(saving);
    if (index == -1) return;

    await box.deleteAt(index);
  }
}