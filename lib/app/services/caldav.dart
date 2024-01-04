import 'package:caldav_client/caldav_client.dart';
import 'package:todark/app/data/calendar.dart';

class CalDav {
  Future<List<Calendar>> findAllCalendars() async {
    var client = CalDavClient(
      baseUrl: 'http://192.168.178.81:8080',
      headers: Authorization('admin', 'admin').basic(),
    );

    var principalPath = await client.getPrincipal('/remote.php/dav');
    var calHomesetPath = await client.getCalendarHomeSet(principalPath);

    var allCalendars = await client.getCalendars(calHomesetPath);

    return allCalendars
        .map((e) =>
            Calendar(title: e.displayName, taskColor: 0000001, href: e.href))
        .toList();
  }

  Future<void> getEvents(CalDavClient client, List<String> calendars) async {
    var getObjectsResult = await client.getEvents(calendars.first);

    for (var result in getObjectsResult.multistatus!.responses) {
      print('PATH: ${result.href}');

      if (result.status.contains('200')) {
        print('CALENDAR DATA:\n${result.propstat?.prop['calendar-data']}');
        print('ETAG: ${result.propstat?.prop['getetag']}');
      }
      print('Bad prop status');
    }
  }
}
