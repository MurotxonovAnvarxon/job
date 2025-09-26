part of 'job_bloc.dart';

class JobState {
  final List<GetAllJobsResponse>? jobs;
  final String? message;
  final Status? status;

  JobState({this.jobs, this.message, this.status});

  JobState copyWith({
    final List<GetAllJobsResponse>? jobs,
    final String? message,
    final Status? status,
  }) => JobState(
    jobs: jobs ?? this.jobs,
    message: message ?? this.message,
    status: status ?? this.status,
  );
}
