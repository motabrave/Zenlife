class Article {
  final String title;
  final String summary;
  final String content;

  Article({required this.title, required this.summary, required this.content});
}

final sampleArticles = <Article>[
  Article(
    title: "Thói quen ngủ lành mạnh trong 7 ngày",
    summary: "Một kế hoạch nhỏ giúp cơ thể thích nghi giờ ngủ đều đặn và chất lượng.",
    content: '''
**Ngày 1–2:** Cố định giờ đi ngủ & thức dậy, lệch không quá 30 phút.
**Ngày 3–4:** Tắt màn hình 45 phút trước khi ngủ, đọc sách nhẹ.
**Ngày 5–6:** Giảm đường và cafein sau 15:00, vận động nhẹ buổi chiều.
**Ngày 7:** Tổng kết và duy trì. Ghi chú cảm nhận vào An Giấc.
''',
  ),
  Article(
    title: "Giảm đường thông minh",
    summary: "Mẹo thay thế đồ ngọt và kiểm soát cơn thèm.",
    content: '''
- Ưu tiên trái cây nguyên quả thay vì nước ép.
- Nếu thèm đồ ngọt buổi tối, uống nước ấm hoặc trà thảo mộc.
- Đọc nhãn dinh dưỡng: tránh siro bắp HFCS, maltose, dextrose...
''',
  ),
  Article(
    title: "Thư giãn thần kinh trước khi ngủ",
    summary: "2 kỹ thuật đơn giản: thở 4-7-8 và quét cơ thể.",
    content: '''
**Thở 4-7-8:** Hít 4s, giữ 7s, thở 8s. Lặp lại 4 lần.
**Body scan:** Nhắm mắt, chú ý lần lượt từng nhóm cơ từ chân lên đầu, thả lỏng.
''',
  ),
];
