import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kartoyun/components/colors.dart';
import 'package:kartoyun/components/custom_background.dart';
import 'package:kartoyun/components/custom_navbar.dart';
import 'package:kartoyun/home_page.dart';
import 'package:kartoyun/profil_pages/profil.dart';

class KartOynama extends StatefulWidget {
  const KartOynama({Key? key}) : super(key: key);

  @override
  _KartOynamaState createState() => _KartOynamaState();
}

class _KartOynamaState extends State<KartOynama> {
  int _selectedIndex = 1;
  late String currentUid;
  List<dynamic> conversationsList = [];

  @override
  void initState() {
    super.initState();

    // Kullanıcının UID'sini al
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          currentUid = user.uid;
        });
        // Kullanıcının Konuşmalar listesini çek ve printle
        getConversationsList();
      }
    });
    getConversationsList();
  }

  void getConversationsList() async {
    try {
      // Kullanicilar koleksiyonundaki belirli bir belgeyi al
      DocumentSnapshot<Map<String, dynamic>> userDoc =
      await FirebaseFirestore.instance.collection('Kullanicilar').doc(currentUid).get();

      // Eğer belge varsa ve Konuşmalar listesi varsa setState kullanarak listeyi güncelle
      if (userDoc.exists && userDoc.data()?['Konuşmalar'] != null) {
        List<dynamic> newConversationsList = userDoc.data()?['Konuşmalar'];
        setState(() {
          conversationsList = newConversationsList;
        });
      }
    } catch (e) {
      print('Hata: $e');
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

              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => HomePage(), // Hedef sayfanızı belirtin
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
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  'Sohbetler',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    color: MyColors.yesil,
                    //fontWeight: FontWeight.bold,
                  ),
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
                  child: ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      // conversationsList içindeki her elemanı direkt olarak kullanabilirsiniz
                      String adSoyad = conversationsList[index];

                      return Card(
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
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
                            'adsyad', // Buraya uygun bir değeri eklemeniz gerekiyor
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: conversationsList.length, // itemCount, list uzunluğu kadar olmalıdır
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
