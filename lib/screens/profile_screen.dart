import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade900, Colors.blue.shade700],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 200, // cố định chiều cao header
                      width: double.infinity,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(),
                      child: Image.asset(
                        'assets/sky_header.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter, // luôn căn trên
                      ),
                    ),
                    // mây bay động (Lottie)
                    Positioned(
                      bottom: 60,
                      left: 50,
                      child: Transform.scale(
                        scale: 0.6, // nhỏ hơn
                        child: Lottie.asset(
                          'assets/clouds.json',
                          height: 80,
                          repeat: true,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 80,
                      right: 40,
                      child: Transform.scale(
                        scale: 0.5,
                        child: Lottie.asset(
                          'assets/clouds.json',
                          height: 70,
                          repeat: true,
                        ),
                      ),
                    ),
                    // Avatar user
                    const Positioned(
                      bottom: -30,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.teal,
                            child: Text(
                              "M",
                              style: TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 40),
                        ],
                      ),
                    )
                    ,
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20),
          // Thông tin user
          Text(
            "Mota",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            "Thành viên Zenlife",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),

          SizedBox(height: 20),

          // Danh sách menu
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text("Thông tin cơ bản"),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.flag_outlined),
                  title: Text("Mục tiêu của tôi"),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.favorite_outline),
                  title: Text("Chăm sóc người thân"),
                  trailing: Icon(Icons.chevron_right),
                ),
                ListTile(
                  leading: Icon(Icons.local_hospital_outlined),
                  title: Text("Bệnh viện / bác sĩ"),
                  trailing: Icon(Icons.chevron_right),
                ),
                ListTile(
                  leading: Icon(Icons.alarm_outlined),
                  title: Text("Báo thức"),
                  trailing: Icon(Icons.chevron_right),
                ),
                ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text("Cài đặt nâng cao"),
                  trailing: Icon(Icons.chevron_right),
                ),
                ListTile(
                  leading: Icon(Icons.people_outline),
                  title: Text("Giới thiệu bạn bè"),
                  trailing: Icon(Icons.chevron_right),
                ),
                ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text("Hỗ trợ và phản hồi"),
                  trailing: Icon(Icons.chevron_right),
                ),
                const ListTile(
                  title: Text(
                    "Điền Nhật Nam.\nZenlife 1.1.2 (2)",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
