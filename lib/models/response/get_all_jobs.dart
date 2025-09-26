class GetAllJobsResponse {
  final int? id;
  final String? postedByUser;
  final String? postedByDisplayName;
  final String? title;
  final String? description;
  final String? location;
  final String? employmentType;
  final int? salaryMin;
  final int? salaryMax;
  final String? currency;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? searchTsv;
  final String? userId;

  GetAllJobsResponse({
    required this.id,
    required this.postedByUser,
    required this.postedByDisplayName,
    required this.title,
    required this.description,
    required this.location,
    required this.employmentType,
    required this.salaryMin,
    required this.salaryMax,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.searchTsv,
    this.userId,
  });

  factory GetAllJobsResponse.fromJson(Map<String, dynamic> json) {
    return GetAllJobsResponse(
      id: json['id'],
      postedByUser: json['posted_by_user'],
      postedByDisplayName: json['posted_by_display_name'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      employmentType: json['employment_type'],
      salaryMin: json['salary_min'],
      salaryMax: json['salary_max'],
      currency: json['currency'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      searchTsv: json['search_tsv'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'posted_by_user': postedByUser,
      'posted_by_display_name': postedByDisplayName,
      'title': title,
      'description': description,
      'location': location,
      'employment_type': employmentType,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'currency': currency,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'search_tsv': searchTsv,
      'user_id': userId,
    };
  }

  @override
  String toString() {
    return 'GetAllJobsResponse(id: $id, title: $title, postedByDisplayName: $postedByDisplayName, location: $location, salaryMin: $salaryMin, salaryMax: $salaryMax, currency: $currency)';
  }

}