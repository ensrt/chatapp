import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendNotification(String fcmToken, String senderName, String message) async {
  final String serverKey = 'Your_FCM_Key';
  final String firebaseUrl = 'https://fcm.googleapis.com/fcm/send';

  final Map<String, dynamic> requestData = {
    'notification': {
      'title': senderName, // Burada gönderenin adını ekledik
      'body': message,
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
    },
    'priority': 'high',
    'data': {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'senderName': senderName, // Gönderenin adını data olarak ekledik
      'message': message, // Mesajı data olarak ekledik
    },
    'to': fcmToken,
  };

  final http.Response response = await http.post(
    Uri.parse(firebaseUrl),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    },
    body: jsonEncode(requestData),
  );

  if (response.statusCode == 200) {
    print('Bildirim başarıyla gönderildi.');
  } else {
    print('Bildirim gönderme başarısız: ${response.reasonPhrase}');
  }
}

