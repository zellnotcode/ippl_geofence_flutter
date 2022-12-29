import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stable_geo_fence/flutter_stable_geo_fence.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ippl/detail_presensi.dart';
import 'package:ippl/formabsen_page.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import 'login_page.dart';

class DetailPage extends StatefulWidget {
  final String role;
  final String matkul;
  const DetailPage({Key? key, required this.matkul, required this.role})
      : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  String username = '';
  final geoFenceService = GeoFenceService();
  double latitude = 0;
  double longitude = 0;
  double radius = 0;
  StreamSubscription? _subscription;
  String status = '';

  @override
  void initState() {
    super.initState();
    getLatLongRad();
  }

  void getLatLongRad() async {
    FirebaseFirestore.instance
        .collection('course')
        .doc(widget.matkul)
        .get()
        .then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      latitude = double.parse(data['latitude']);
      longitude = double.parse(data['longitude']);
      radius = double.parse(data['radius']);
      initGeoFenceService();
    });
  }

  void initGeoFenceService() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.denied) {
        startService();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(milliseconds: 500),
          content: Text('Tidak bisa mengakses lokasi'),
          backgroundColor: Colors.black,
        ));
      }
    } else {
      startService();
    }
  }

  void startService() async {
    await geoFenceService.startService(
      fenceCenterLatitude: latitude,
      fenceCenterLongitude: longitude,
      radius: radius,
    );
    _subscription = geoFenceService.geoFenceStatusListener.listen((event) {});
  }

  @override
  void dispose() {
    super.dispose();
    geoFenceService.stopFenceService();
    _subscription?.cancel();
  }

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
                              username =
                                  (snapshot.data as DocumentSnapshot)['name'];
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
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text("Loading...");
                                }
                                if (snapshot.data == null) {
                                  return Text('Koneksi Bermasalah');
                                }
                                return Column(
                                  children: [
                                    Text(
                                      (snapshot.data
                                          as DocumentSnapshot)['name'],
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
                                        (snapshot.data
                                            as DocumentSnapshot)['desc'],
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                          const SizedBox(
                            height: 15,
                          ),
                          GestureDetector(
                            onTap: () {
                              if (widget.role == '1') {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FormPage(
                                              matkul: widget.matkul,
                                            )));
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  duration: Duration(milliseconds: 500),
                                  content: Text('Kamu tidak punya izin'),
                                  backgroundColor: Colors.black,
                                ));
                              }
                            },
                            child: Container(
                              width: 120,
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: const Color.fromRGBO(130, 49, 139, 1),
                              ),
                              child: const Center(
                                child: Text(
                                  'Buat Absen',
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Poppins',
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('course')
                                .doc(widget.matkul)
                                .collection('presensi')
                                .snapshots(),
                            builder: (context, snapPresensi) {
                              if (snapPresensi.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              if (snapPresensi.data!.docs.isEmpty ||
                                  snapPresensi.data == null) {
                                return const SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: Text('Belum ada presensi tersedia!'),
                                  ),
                                );
                              }
                              return Column(
                                children: snapPresensi.data!.docs.map((data) {
                                  var docID = data.id;
                                  DateTime endtime =
                                      DateTime.parse('${data['endtime']}');
                                  final timenow = DateTime.parse(
                                      DateFormat('yyyy-MM-dd KK:mm:ss')
                                          .format(DateTime.now()));
                                  return Column(
                                    children: [
                                      Container(
                                        width: 250,
                                        height: 200,
                                        padding: const EdgeInsets.all(15.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.25),
                                                blurRadius: 10.0)
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Alert'),
                                                          content: const Text(
                                                              'Anda yakin ingin megnhapus ?'),
                                                          actions: [
                                                            TextButton(
                                                                onPressed: () {
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'course')
                                                                      .doc(widget
                                                                          .matkul)
                                                                      .collection(
                                                                          'presensi')
                                                                      .doc(
                                                                          docID)
                                                                      .delete();
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: const Text(
                                                                    'Yakin')),
                                                            TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    const Text(
                                                                        'Tidak'))
                                                          ],
                                                        );
                                                      });
                                                },
                                                child: const Icon(
                                                  Icons.delete,
                                                  size: 18,
                                                  color: Color.fromRGBO(
                                                      130, 49, 139, 1),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '${data['desc']}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 18.0,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10.0,
                                            ),
                                            Text(
                                              'End Time',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14.0,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10.0,
                                            ),
                                            Text(
                                              '${data['endtime']}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14.0,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 30.0,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                LayoutBuilder(
                                                  builder:
                                                      (context, constraints) {
                                                    if (timenow
                                                        .isAfter(endtime)) {
                                                      return Container(
                                                        width: 90.0,
                                                        height: 30.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color: const Color
                                                                  .fromRGBO(
                                                              239, 56, 56, 1),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            'Timeout',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        12.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                        ),
                                                      );
                                                    }

                                                    // Button Presensi
                                                    return InkWell(
                                                      onTap: () {
                                                        if (data['listHadir']
                                                            .contains(
                                                                username)) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  const SnackBar(
                                                            duration: Duration(
                                                                milliseconds:
                                                                    500),
                                                            content: Text(
                                                                'Kamu sudah hadir!'),
                                                            backgroundColor:
                                                                Colors.black,
                                                          ));
                                                        } else if (geoFenceService
                                                                .getStatus()
                                                                .toString() ==
                                                            'Status.ENTER') {
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'course')
                                                              .doc(
                                                                  widget.matkul)
                                                              .collection(
                                                                  'presensi')
                                                              .doc(docID)
                                                              .update({
                                                            'listHadir':
                                                                FieldValue
                                                                    .arrayUnion([
                                                              username
                                                            ])
                                                          });
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  const SnackBar(
                                                            content: Text(
                                                                'Anda berhasil melakukan presensi'),
                                                            backgroundColor:
                                                                Colors.black,
                                                          ));
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  const SnackBar(
                                                            content: Text(
                                                                'Anda di luar lokasi'),
                                                            backgroundColor:
                                                                Colors.black,
                                                          ));
                                                        }
                                                      },
                                                      child: Container(
                                                        width: 90.0,
                                                        height: 30.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color: const Color
                                                                  .fromRGBO(
                                                              130, 49, 139, 1),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            'Presensi',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        12.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    if (widget.role == '1') {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  DetailPresensi(
                                                                    docID:
                                                                        docID,
                                                                    matkul: widget
                                                                        .matkul,
                                                                  )));
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                        duration: Duration(
                                                            milliseconds: 500),
                                                        content: Text(
                                                            'Anda tidak punya izin'),
                                                        backgroundColor:
                                                            Colors.black,
                                                      ));
                                                    }
                                                  },
                                                  child: Container(
                                                    width: 90.0,
                                                    height: 30.0,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color:
                                                          const Color.fromRGBO(
                                                              130, 49, 139, 1),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        'Detail Presensi',
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 10.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 21.0,
                                      ),
                                    ],
                                  );
                                }).toList(),
                              );
                            },
                          ),
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
