import 'package:caldav_client/caldav_client.dart';

class CalDav {
  Future<void> request() async {
    var client = CalDavClient(
      baseUrl: 'http://192.168.178.81:8080',
      headers: Authorization('admin', 'admin').basic(),
    );

    var principalPath = await client.getPrincipal('/remote.php/dav');
    var calHomesetPath = await client.getCalendarHomeSet(principalPath);

    var allCaledendars = await client.getCalendars(calHomesetPath);

    var calendars = <String>[];

    // Print calendars and save calendars path
    for (var cal in allCaledendars) {
      print('PATH: ${cal.displayName} - ${cal.supportedCalendarComponentSet}');
    }

    // Print calendar objects info
    if (calendars.isNotEmpty) {
      await getEvents(client, calendars);
    }
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
