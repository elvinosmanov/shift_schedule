class Employee {
  int id;
  String firstName;
  String lastName;
  String role;
  List<String> dates;

  Employee(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.role,
      required this.dates});

  factory Employee.fromList(List<String> dataList) {
    String fullName = dataList[1];
    // Split full name by whitespace and assume first part is first name, rest is last name
    List<String> nameParts = fullName.split(" ");
    String firstName = nameParts[0];
    String lastName = nameParts.sublist(1).join(" ");

    return Employee(
      id: int.parse(dataList[0]),
      firstName: firstName,
      lastName: lastName,
      role: dataList[2],
      dates: dataList.sublist(3).cast<String>(),
    );
  }

Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'dates': dates.join(','),
    };
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    List<String> dates = (json['dates'] as String).split(',');
    List<dynamic> dataList = json.values.toList();
    return Employee(
      id: dataList[0],
      firstName: dataList[1],
      lastName: dataList[2],
      role: dataList[3],
      dates: dates,
    );
  }

  @override
  String toString() {
    return 'Employee(id: $id, firstName: $firstName, lastName: $lastName, role: $role, dates: ${dates.length})';
  }
}
