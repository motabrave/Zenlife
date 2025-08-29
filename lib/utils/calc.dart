class CalcUtils {
  /// Tính số giờ ngủ từ 2 thời điểm (phút từ 0..1439), xử lý qua ngày.
  static double hoursBetween(int sleepMinutes, int wakeMinutes) {
    int duration = wakeMinutes - sleepMinutes;
    if (duration < 0) duration += 24 * 60;
    return duration / 60.0;
  }

  /// Công thức tính điểm An Giấc (0..100)
  static int computeScore({
    required int sweetUnits,   // 0..10 (đơn vị tùy bạn quy ước)
    required int stressLevel,  // 0..10
    required double hoursSlept,
  }) {
    int score = 100;
    score = score - (sweetUnits * 5);          // đồ ngọt
    score = score - (stressLevel * 3);         // stress
    if (hoursSlept < 7) {
      score = score - ((7 - hoursSlept) * 5).toInt(); // thiếu ngủ
    }
    if (score < 0) score = 0;
    if (score > 100) score = 100;
    return score;
  }

  static String adviceForScore(int score) {
    if (score >= 80) {
      return "Giấc ngủ tốt — bạn đang duy trì thói quen lành mạnh. Tiếp tục kiểm soát đồ ngọt và thư giãn trước khi ngủ.";
    } else if (score >= 50) {
      return "Trung bình — hãy giảm đồ ngọt, thử bài thở 4-7-8 hoặc thiền 10 phút trước khi ngủ.";
    } else {
      return "Kém — nên thiết lập giờ ngủ cố định, hạn chế cafein/điện thoại buổi tối và trao đổi thêm với chuyên gia nếu cần.";
    }
  }

  static String bandName(int score) {
    if (score >= 80) return "Happy Happy Happy";
    if (score >= 50) return "Cũng cũng ổn";
    return "Ổn lòi lìa";
  }
}
