class GlobalMethods{
  static bool isSameDate(DateTime date1, DateTime date2) {
    bool isSameDate =
        date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
    return isSameDate;
  }
}