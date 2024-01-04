import 'package:isar/isar.dart';
import 'package:todark/app/data/schema.dart';

part 'calendar.g.dart';

@collection
class Calendar {
  Id id;
  String title;
  String description;
  int taskColor;
  bool archive;
  int? index;
  String href;

  final tasks = IsarLinks<Tasks>();

  Calendar(
      {this.id = Isar.autoIncrement,
      required this.title,
      this.description = '',
      this.archive = false,
      required this.taskColor,
      this.index,
      required this.href});
}
