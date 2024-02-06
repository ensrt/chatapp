import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kartoyun/auth_pages/login_page.dart';
import 'package:kartoyun/components/colors.dart';
import 'package:kartoyun/components/custom_navbar.dart';
import 'package:kartoyun/card_pages/play_card.dart';
import 'package:kartoyun/conversation_pages/chat_page.dart';
import 'package:kartoyun/profil_pages/profil.dart';
import 'package:kartoyun/components/custom_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> adSoyadList = []; // AdSoyad listesi
  List<String> statusList = [];

  int _selectedIndex = 0;
  String currentUserUid = ''; // Eklenen satır

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    // Kullanıcı durumunu "online" olarak güncelle
    updateStatus('online');

    // WidgetsBindingObserver'ı ekleyin
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Kullanıcı durumunu "offline" olarak güncelle
    updateStatus('offline');

    // WidgetsBindingObserver'ı kaldırın
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Uygulama durumu değiştiğinde çağrılır
    if (state == AppLifecycleState.resumed) {
      // Uygulama aktif duruma geçtiğinde
      updateStatus('online');
    } else {
      // Uygulama arka plana geçtiğinde veya kapandığında
      updateStatus('offline');
    }
  }

  Future<void> updateStatus(String status) async {
    try {
      await _firestore.collection('Kullanicilar').doc(currentUserUid).update({
        'status': status,
      });
    } catch (e) {
      print('Durum güncelleme hatası: $e');
    }
  }

  void _loadUserInfo() async {
    try {
      // Giriş yapan kullanıcının UID'sini al
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        currentUserUid = currentUser.uid;
      }

      // Tüm kullanıcıları çek
      QuerySnapshot allUsersSnapshot =
      await _firestore.collection('Kullanicilar').get();

      List<String> adSoyadList = [];
      List<String> statusList = [];

      // Her bir kullanıcı için adsoyad'ı al ve adSoyadList'e ekle
      if (allUsersSnapshot != true) {
        for (QueryDocumentSnapshot user in allUsersSnapshot.docs) {
          Map<String, dynamic>? userData =
          user.data() as Map<String, dynamic>?;

          if (userData != null && userData['adsoyad'] != null) {
            String adSoyad = userData['adsoyad'];
            String status = userData['status'];

            // Giriş yapan kullanıcının UID'si ile belirli bir belgeyi kontrol et
            if (user.id == currentUserUid) {
              // Giriş yapan kullanıcının belgesi çekilmedi
              continue;
            }

            adSoyadList.add(adSoyad);
            statusList.add(status);
          }
        }
      } else {
        print("Tüm kullanıcılar null, veri alınamadı.");
      }

      setState(() {
        this.adSoyadList = adSoyadList;
        this.statusList = statusList;
      });
    } catch (e) {
      print("Hata oluştu: $e");
    }
  }

  Future<String> getUidForUser(String username) async {
    try {
      // Firestore'dan kullanıcı bilgilerini çek
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Kullanicilar')
          .where('adsoyad', isEqualTo: username)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        String uid = userSnapshot.docs[0].id;
        return uid;
      } else {
        // Kullanıcı bulunamadıysa boş bir değer döndür
        return '';
      }
    } catch (e) {
      // Hata durumunda boş bir değer döndür
      print("Hata: $e");
      return '';
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();
      // Çıkış başarılı olduğunda yapılacak işlemleri buraya ekleyebilirsiniz
    } catch (e) {
      print('Çıkış yapma hatası: $e');
      // Hata durumunda yapılacak işlemleri buraya ekleyebilirsiniz
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: SafeArea(
        child: Scaffold(
          bottomNavigationBar: CustomBottomNavBar(
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });

              if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => const KartOynama(), // Hedef sayfanızı belirtin
                    transitionDuration: const Duration(seconds: 0), // Geçiş süresini ayarlayın
                  ),
                );

              } else if (index == 2) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => const Profil(), // Hedef sayfanızı belirtin
                    transitionDuration: const Duration(seconds: 0), // Geçiş süresini ayarlayın
                  ),
                );
              }
              // Diğer durumlar için gerekirse eklemeler yapabilirsiniz
            },
          ),
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0,vertical: 11),
                child: Row(
                  children: [
                    Text(
                      'Sohbetler',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        color: MyColors.yesil,
                      ),
                    ),
                    Spacer(), // Boşluğu genişletmek için
                    IconButton(
                      icon: Icon(
                        Icons.exit_to_app, // Çıkış yapma ikonu
                        color: MyColors.yesil,
                        size: 24,
                      ),
                      onPressed: () async {
                        await _signOut();
                        //_clearUserData(); // shared preferences'tan bilgileri temizle
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()), // LoginPage'e yönlendirme
                        );
                      },
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: MyColors.arama,
                  ),
                  child: Center(
                    child: TextFormField(
                      textAlign: TextAlign.start,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        color: MyColors.yesil,
                        //fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Ara',
                        hintStyle:
                        TextStyle(fontSize: 18, color: MyColors.yesil),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 22.0,
                          color: MyColors.yesil,
                          grade: 5,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              // Firestore'dan çekilen adsoyad'ları listeleyen kartlar
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: FutureBuilder<QuerySnapshot>(
                    future: _firestore.collection('Kullanicilar').get(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(); // Veri yüklenirken gösterilecek widget
                      }

                      if (snapshot.hasError) {
                        return Text('Veri alınamadı: ${snapshot.error}');
                      }

                      List<String> adSoyadList = [];
                      List<String> statusList = [];

                      snapshot.data!.docs.forEach((QueryDocumentSnapshot user) {
                        Map<String, dynamic>? userData = user.data() as Map<String, dynamic>?;

                        if (userData != null && userData['adsoyad'] != null) {
                          String adSoyad = userData['adsoyad'];
                          String status = userData['status'];

                          if (user.id == currentUserUid) {
                            return;
                          }

                          adSoyadList.add(adSoyad);
                          statusList.add(status);
                        }
                      });

                      return ListView.builder(
                        itemCount: adSoyadList.length,
                        itemBuilder: (BuildContext context, int index) {
                          String adSoyad = adSoyadList[index];
                          String status = statusList[index];
                          String uid = '';

                          return Card(
                            color: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              onTap: () async {
                                uid = await getUidForUser(adSoyad);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(currentUid: currentUserUid, uid: uid),
                                  ),
                                );
                              },
                              leading: const Icon(
                                Icons.person,
                                color: MyColors.yesil,
                                size: 36,
                              ),
                              title: Text(
                                adSoyad,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  color: MyColors.yesil,
                                ),
                              ),
                              subtitle: Text(
                                status,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
