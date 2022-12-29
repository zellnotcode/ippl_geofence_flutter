import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ippl/matakul_page.dart';
import 'login_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  List dataMatkul = [];
  String matkulChoose = "";
  String role = "";

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/background.jpg'),
              fit: BoxFit.cover,
              alignment: Alignment.center),
        ),
        child: SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  width: 350,
                  color: Colors.white70,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Nama User
                          FutureBuilder<Object>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text("Loading...");
                                }
                                if (snapshot.data == null) {
                                  return Text('Koneksi Bermasalah');
                                }
                                return Text(
                                  (snapshot.data as DocumentSnapshot)['name'],
                                  style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                );
                              }),
                          const Spacer(),
                          // Logout Button
                          GestureDetector(
                            onTap: () async {
                              await FirebaseAuth.instance.signOut();
                              if (FirebaseAuth.instance.currentUser == null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color.fromARGB(255, 239, 56, 56),
                              ),
                              width: 100,
                              height: 30,
                              child: Center(
                                child: Text(
                                  'Logout',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        constraints: const BoxConstraints(
                          minHeight: 600,
                        ),
                        padding: const EdgeInsets.all(10),
                        width: 350,
                        color: Colors.white,
                        child: Column(
                          children: [
                            Text(
                              'Mata Kuliah',
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            // print(data);
                            // data.forEach((item) {
                            //   Text(item.toString());
                            // })
                            FutureBuilder<Object>(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(uid)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }
                                  role = (snapshot.data
                                      as DocumentSnapshot)['role'];
                                  dataMatkul = (snapshot.data
                                      as DocumentSnapshot)['enrolledCourses'];
                                  if (snapshot.data == null) {
                                    return const SizedBox(
                                      height: 200,
                                      child: Center(
                                        child: Text("Koneksi Bermasalah"),
                                      ),
                                    );
                                  }
                                  return GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 1,
                                            crossAxisSpacing: 5,
                                            mainAxisSpacing: 5,
                                            mainAxisExtent: 230),
                                    itemCount: dataMatkul.length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          matkulChoose = dataMatkul
                                              .elementAt(index)
                                              .toString();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DetailPage(
                                                matkul: matkulChoose,
                                                role: role,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          child: Column(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(16.0),
                                                  topRight:
                                                      Radius.circular(16.0),
                                                ),
                                                child: Image.asset(
                                                  "images/bgmatkul.jpg",
                                                  height: 170,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "${dataMatkul.elementAt(index)}",
                                                      style: const TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 8.0,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
