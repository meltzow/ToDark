import 'package:caldav_client/caldav_client.dart';
import 'package:caldav_client/src/utils.dart';

class CalDav {
  Future<void> request() async {
    var client = CalDavClient(
      baseUrl: 'http://192.168.178.81:8080',
      headers: Authorization('admin', 'admin').basic(),
    );

    var principal = await client.getPrincipal('/remote.php/dav');
    var calHomeset = await client.getCalendarHomeSet('/remote.php/dav');

    var initialSyncResult = await client.getCalendars('/remote.php/dav');

    var calendars = <String>[];

    // Print calendars and save calendars path
    for (var response in initialSyncResult.multistatus!.response) {
      print('PATH: ${response.href}');

      if (response.status.contains("200")) {
        var displayname = response.propstat?.prop['displayname'];
        var ctag = response.propstat?.prop['getctag'];

        if (displayname != null && ctag != null) {
          print('CALENDAR: $displayname');
          print('CTAG: $ctag');

          calendars.add(response.href);
        } else {
          print('This collection is not a calendar');
        }
      } else {
        print('Bad prop status');
      }
    }

    // Print calendar objects info
    if (calendars.isNotEmpty) {
      await getEvents(client, calendars);

      await generateEvent(client, calendars);
    }
  }

  Future<void> getEvents(CalDavClient client, List<String> calendars) async {
    var getObjectsResult = await client.getEvents(calendars.first);

    for (var result in getObjectsResult.multistatus!.response) {
      print('PATH: ${result.href}');

      if (result.status.contains('200')) {
        print('CALENDAR DATA:\n${result.propstat?.prop['calendar-data']}');
        print('ETAG: ${result.propstat?.prop['getetag']}');
      }
      print('Bad prop status');
    }
  }

  Future<void> generateEvent(
      CalDavClient client, List<String> calendars) async {
    var calendar = '''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//PYVOBJECT//NONSGML Version 1//EN
BEGIN:VEVENT
UID:test@example.com
DTSTART;VALUE=DATE:20190306
CLASS:PRIVATE
DESCRIPTION:Arman and Adrian released their SRT-file parser library for Dar
 t
DTSTAMP;X-VOBJ-FLOATINGTIME-ALLOWED=TRUE:20190306T000000
LOCATION:Heilbronn
PRIORITY:0
RRULE:FREQ=YEARLY
STATUS:CONFIRMED
SUMMARY:SRT-file Parser Release
URL:https://pub.dartlang.org/packages/srt_parser
END:VEVENT
END:VCALENDAR''';

    // Create calendar
    var createCalResponse =
        await client.putCal(join(calendars.first, '/example.ics'), calendar);

    if (createCalResponse.statusCode == 201) print('Created');
  }
}
