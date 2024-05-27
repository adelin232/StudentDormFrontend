class User {
  final String id;
  final String userId;
  final String name;
  final String room;
  final String phone;
  final String email;

  User(
      {required this.id,
      required this.userId,
      required this.name,
      required this.room,
      required this.phone,
      required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      userId: json['userId'],
      name: json['name'],
      room: json['room'],
      phone: json['phone'],
      email: json['email'],
    );
  }
}

class Complaint {
  final String id;
  final String userId;
  final String subject;
  final String description;

  Complaint(
      {required this.id,
      required this.userId,
      required this.subject,
      required this.description});

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'].toString(),
      userId: json['userId'],
      subject: json['subject'],
      description: json['description'],
    );
  }
}

class Booking {
  final String id;
  final String userId;
  final String wmNo;
  final String startHour;

  Booking(
      {required this.id,
      required this.userId,
      required this.wmNo,
      required this.startHour});

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'].toString(),
      userId: json['userId'],
      wmNo: json['wmNo'],
      startHour: json['startHour'],
    );
  }
}

class Announcement {
  final String id;
  final String title;
  final String description;
  final String date;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'],
      date: json['date'],
    );
  }
}
