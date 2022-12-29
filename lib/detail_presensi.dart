import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';

class DetailPresensi extends StatefulWidget {
  final String docID;
  final String matkul;
  const DetailPresensi({Key? key, required this.docID, required this.matkul})
      : super(key: key);

  @override
  State<DetailPresensi> createState() => _DetailPresensiState();
}

class _DetailPresensiState extends State<DetailPresensi> {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                          FutureBuilder<Object>(
                              future: FirebaseFirestore.instance
                                  .collection('course')
                                  .doc(widget.matkul)
                                  .collection('presensi')
                                  .doc(widget.docID)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                List listHadir = (snapshot.data
                                    as DocumentSnapshot)['listHadir'];
                                return Column(
                                  children: [
                                    Text(
                                      (snapshot.data
                                          as DocumentSnapshot)['desc'],
                                      style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(
                                        widget.docID,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(40.0),
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          if (listHadir.isEmpty) {
                                            return const SizedBox(
                                              height: 200,
                                              child: Center(
                                                  child: Text(
                                                      'Belum ada yang hadir!')),
                                            );
                                          }
                                          return ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: listHadir.length,
                                            itemBuilder: (context, index) {
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    '${listHadir[index]}',
                                                    style: const TextStyle(
                                                      fontFamily: 'Poppins',
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const Text(
                                                    'Hadir',
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
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
}
