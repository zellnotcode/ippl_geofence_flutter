import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'login_page.dart';

class FormPage extends StatefulWidget {
  final String matkul;
  const FormPage({Key? key, required this.matkul}) : super(key: key);

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final absenRef = FirebaseFirestore.instance
      .collection('course')
      .doc('widget.matkul')
      .collection('presensi')
      .doc(DateTime.now().toString());
  TextEditingController descControl = TextEditingController();
  TextEditingController dateControl = TextEditingController();
  TextEditingController timeControl = TextEditingController();
  String dateNow = DateTime.now().toString();
  CollectionReference course = FirebaseFirestore.instance.collection('course');

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
                              'Form Membuat Absen',
                              style: GoogleFonts.poppins(
                                  fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 30),
                            //Deskripsi Form
                            Column(
                              children: [
                                Text(
                                  'Deskripsi',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: 250,
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  height: 40,
                                  child: TextField(
                                    controller: descControl,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                        color: Colors.black87, fontSize: 12),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Deskripsi',
                                        hintStyle: GoogleFonts.poppins()),
                                  ),
                                ),
                              ],
                            ),
                            //end deskripsi Form
                            const SizedBox(height: 15),
                            //Date Form
                            Column(
                              children: [
                                Text(
                                  'Tanggal Berakhir',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: 250,
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  height: 40,
                                  child: TextField(
                                    controller: dateControl,
                                    textAlign: TextAlign.center,
                                    readOnly: true,
                                    showCursor: false,
                                    style: GoogleFonts.poppins(
                                        color: Colors.black87, fontSize: 12),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Pilih Tanggal',
                                        hintStyle: GoogleFonts.poppins()),
                                    onTap: () async {
                                      DateTime? pickdate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2100),
                                      );
                                      String dateFormat =
                                          DateFormat('yyyy-MM-dd')
                                              .format(pickdate!);
                                      dateControl.text = dateFormat;
                                    },
                                  ),
                                ),
                                //end date form
                              ],
                            ),
                            const SizedBox(height: 15),
                            //Time Form
                            Column(
                              children: [
                                Text(
                                  'Waktu Berakhir',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: 250,
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  height: 40,
                                  child: TextField(
                                    controller: timeControl,
                                    textAlign: TextAlign.center,
                                    readOnly: true,
                                    showCursor: false,
                                    style: GoogleFonts.poppins(
                                        color: Colors.black87, fontSize: 12),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Pilih Waktu',
                                        hintStyle: GoogleFonts.poppins()),
                                    onTap: () async {
                                      TimeOfDay? picktime =
                                          await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now());
                                      String timeGet =
                                          picktime!.format(context).toString();
                                      DateTime fixTime =
                                          DateFormat.Hm().parse(timeGet);
                                      String fixBanget =
                                          DateFormat.Hms().format(fixTime);
                                      timeControl.text = fixBanget;
                                    },
                                  ),
                                ),
                                //end time form
                              ],
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (descControl.text.isNotEmpty &&
                                        dateControl.text.isNotEmpty &&
                                        timeControl.text.isNotEmpty) {
                                      course
                                          .doc(widget.matkul)
                                          .collection('presensi')
                                          .doc(dateNow)
                                          .set({
                                        'desc': descControl.text,
                                        'endtime':
                                            '${dateControl.text} ${timeControl.text}',
                                        'listHadir': []
                                      });
                                      Navigator.pop(context);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text('Lengkapi semua data!'),
                                        backgroundColor: Colors.black,
                                      ));
                                    }
                                  },
                                  child: Container(
                                    width: 120,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color:
                                          const Color.fromRGBO(0, 173, 17, 1),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Simpan',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Poppins',
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: 120,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color:
                                          const Color.fromRGBO(239, 56, 56, 1),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Poppins',
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
