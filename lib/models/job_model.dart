import 'package:equatable/equatable.dart';

class Job extends Equatable {
  final String? id;
  final String title;
  final String? description;
  final String? salary;
  final String? userId;
  final DateTime? createdAt;

  const Job({
    this.id,
    required this.title,
    this.description,
    this.salary,
    this.userId,
    this.createdAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      salary: json['salary'],
      userId: json['user_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'salary': salary,
    };
  }

  @override
  List<Object?> get props => [id, title, description, salary, userId, createdAt];
}