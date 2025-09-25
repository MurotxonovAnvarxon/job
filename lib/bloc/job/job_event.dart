part of 'job_bloc.dart';

abstract class JobEvent extends Equatable {
  const JobEvent();

  @override
  List<Object?> get props => [];
}

class LoadJobs extends JobEvent {
  const LoadJobs();
}

class StreamJobs extends JobEvent {
  const StreamJobs();
}

class CreateJob extends JobEvent {
  final Job job;

  const CreateJob(this.job);}