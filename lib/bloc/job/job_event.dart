part of 'job_bloc.dart';

abstract class JobEvent extends Equatable {
  const JobEvent();

  @override
  List<Object> get props => [];
}

class LoadJobs extends JobEvent {}

class StreamJobs extends JobEvent {}

class CreateJob extends JobEvent {
  final Job job;

  const CreateJob(this.job);

  @override
  List<Object> get props => [job];
}