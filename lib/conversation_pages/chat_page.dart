import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kartoyun/components/colors.dart';
import 'package:kartoyun/components/custom_background.dart';
import 'package:kartoyun/components/messaging.dart';
import 'package:kartoyun/components/send_notif.dart';

class ChatPage extends StatefulWidget {
  final String currentUid;
  final String uid;

  ChatPage({required this.currentUid, required this.uid});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String adSoyad = '';
  String? fcmToken;
  TextEditingController _messageController = TextEditingController();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  MyFirebaseMessaging _Messaging = MyFirebaseMessaging();
  late CollectionReference sohbetOdalariCollection;
  late Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream;

  @override
  void initState() {
    super.initState();
    sohbetOdalariCollection = FirebaseFirestore.instance.collection('SohbetOdalari');
    messagesStream = getMessagesStream();
    loadUserName();
    getFcmToken(widget.uid);

    _firebaseMessaging.getToken().then((token) {
      setState(() {
        fcmToken = token;
      });
    });

    _Messaging.setupFirebaseMessaging();
  }
  Future<String?> getFcmToken(String uid) async {
    String? token = await _firebaseMessaging.getToken();
    return token;
  }

  void loadUserName() async {
    String userName = await getUserName(widget.uid);
    String fcmToken = await getUserToken(widget.uid);
    setState(() {
      adSoyad = userName;
      fcmToken = fcmToken;
    });
  }

  Future<String> getUserName(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
          .collection('Kullanicilar')
          .doc(uid)
          .get();

      if (userSnapshot.exists) {
        // Kullanıcı varsa ad ve soyadı al
        String adSoyad = userSnapshot.get('adsoyad');
        print("adsoyad"+adSoyad);
        return adSoyad;

      } else {
        // Kullanıcı yoksa bir hata mesajı döndür
        return 'Kullanıcı bulunamadı';
      }
    } catch (e) {
      // Hata durumunda bir mesaj döndür
      return 'Hata oluştu: $e';
    }
  }

  Future<String> getUserToken(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
          .collection('Kullanicilar')
          .doc(uid)
          .get();

      if (userSnapshot.exists) {
        String fcmToken = userSnapshot.get('fcmToken');
        print("fcmtoken" + fcmToken);
        return fcmToken;

      } else {
        return 'Kullanıcı bulunamadı';
      }
    } catch (e) {
      return 'Hata oluştu: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(adSoyad),
            backgroundColor: Colors.transparent,
          ),
          backgroundColor: MyColors.acikyesil,
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: messagesStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Hata: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    List<QueryDocumentSnapshot<Map<String, dynamic>>> messages = snapshot.data!.docs;

                    return ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        bool isSentMessage = messages[index]['senderUid'] == widget.currentUid;

                        return Align(
                          alignment: isSentMessage ? Alignment.centerRight : Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSentMessage ? MyColors.acikyesil : MyColors.yesil,
                                borderRadius: isSentMessage
                                    ? BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                  bottomLeft: Radius.circular(18),
                                  bottomRight: Radius.circular(0),
                                )
                                    : BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                  bottomLeft: Radius.circular(0),
                                  bottomRight: Radius.circular(18),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.4),
                                    spreadRadius: 2,
                                    blurRadius: 4,
                                    offset: isSentMessage
                                        ? Offset(2, 2)
                                        : Offset(-2, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: isSentMessage ? MyColors.yesil : MyColors.yesil,
                                  width: 1.0,
                                ),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                messages[index]['message'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: isSentMessage ? MyColors.yesil : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(
                          color: MyColors.acikyesil,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Mesaj',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: MyColors.acikyesil,
                          ),
                          filled: true,
                          fillColor: MyColors.mesaj,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
                        ),
                      ),
                    ),
                    SizedBox(width: 6,),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: MyColors.mesaj,
                      ),
                      child: IconButton(
                        onPressed: () {
                          sendMessage();
                        },
                        icon: Icon(Icons.send_rounded),
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessagesStream() {
    String chatRoomId = generateChatRoomId(widget.currentUid, widget.uid);
    return sohbetOdalariCollection
        .doc(chatRoomId)
        .collection('Mesajlar')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  void sendMessage() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user == null) {
      return;
    }

    String yourCurrentUid = user.uid;
    String otherUid = widget.uid;
    String chatRoomId = generateChatRoomId(yourCurrentUid, otherUid);

    String message = _messageController.text.trim();
    String senderName = await getUserName(yourCurrentUid);

    if (message.isNotEmpty) {
      DocumentReference<Map<String, dynamic>> chatRoomDocRef =
      FirebaseFirestore.instance.collection('SohbetOdalari').doc(chatRoomId);

      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
          .collection('Kullanicilar')
          .doc(yourCurrentUid)
          .get();

      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('Kullanicilar').doc(yourCurrentUid).set({
          'Konuşmalar': [],
        });
      }

      await FirebaseFirestore.instance.collection('Kullanicilar').doc(yourCurrentUid).update({
        'Konuşmalar': FieldValue.arrayUnion([chatRoomId]),
      });

      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('Kullanicilar').doc(otherUid).set({
          'Konuşmalar': [],
        });
      }

      await FirebaseFirestore.instance.collection('Kullanicilar').doc(otherUid).update({
        'Konuşmalar': FieldValue.arrayUnion([chatRoomId]),
      });

      if (!(await chatRoomDocRef.get()).exists) {
        await chatRoomDocRef.set({
          'Uyeler': [yourCurrentUid, otherUid],
        });
      }

      await chatRoomDocRef.collection('Mesajlar').add({
        'senderUid': yourCurrentUid,
        'receiverUid': otherUid,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    }

    // Mesaj gönderildiğinde
    // Mesaj gönderildiğinde
    String receiverUid = widget.uid;

// Alıcı FCM token'ını al
    String? receiverFcmToken = await getUserToken(receiverUid);
    print("receiver token : $receiverFcmToken");

// Bildirim gönderme işlemini başlat
    if (receiverFcmToken != null && receiverFcmToken.isNotEmpty) {
      await sendNotification(receiverFcmToken, senderName, message);
    }
  }

  String generateChatRoomId(String uid1, String uid2) {
    List<String> uids = [uid1, uid2]..sort();
    return '${uids[0]}_${uids[1]}';
  }
}
