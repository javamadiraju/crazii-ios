import 'package:flutter/material.dart';

class TeacherListComponent extends StatelessWidget {
  final List<TeacherData> teachers;

  TeacherListComponent({
    Key? key,
    this.teachers = const [
      TeacherData('MA', 'Michael Angelo', 'https://dashboard.codeparrot.ai/api/image/Z5imv4IayXWIU-Dc/ma.png', '#798827'),
      TeacherData('SB', 'Sophia Bennett', '', '#b3ce1a'),
      TeacherData('ER', 'Ethan Reynolds', '', '#1a23ce'),
      TeacherData('OP', 'Olivia Parker', '', '#ce1a47'),
      TeacherData('NF', 'Noah Foster', '', '#1aaace'),
      TeacherData('ES', 'Emma Sullivan', '', '#798827'),
    ],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: teachers.map((teacher) => TeacherCard(teacher: teacher)).toList(),
      ),
    );
  }
}

class TeacherCard extends StatelessWidget {
  final TeacherData teacher;

  const TeacherCard({Key? key, required this.teacher}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(16),
      ),
      height: 81,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Center(
                child: teacher.imageUrl.isNotEmpty
                    ? Image.network(
                        teacher.imageUrl,
                        width: 26,
                        height: 14,
                      )
                    : Text(
                        teacher.initials,
                        style: TextStyle(
                          fontFamily: 'Exo',
                          fontSize: 24,
                          color: Color(int.parse('0xFF${teacher.color.substring(1)}')),
                        ),
                      ),
              ),
            ),
            SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Teacher',
                  style: TextStyle(
                    fontFamily: 'Exo',
                    fontSize: 10,
                    color: Colors.black,
                  ),
                ),
                Text(
                  teacher.name,
                  style: TextStyle(
                    fontFamily: 'Exo',
                    fontSize: 10,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3F66B3),  // Corrected from 'primary' to 'backgroundColor'
                minimumSize: Size(97, 22),  // Set minimum button size
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              child: Text(
                'Set meeting on Zoom',
                style: TextStyle(
                  fontFamily: 'Exo',
                  fontSize: 8,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TeacherData {
  final String initials;
  final String name;
  final String imageUrl;
  final String color;

  const TeacherData(this.initials, this.name, this.imageUrl, this.color);
}

