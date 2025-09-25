import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:job/utils/enums.dart';
import '../../repositories/job_repository.dart';
import '../../models/job_model.dart';

part 'job_event.dart';
part 'job_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  final JobRepository _jobRepository;

  JobBloc(this._jobRepository) : super(JobState()) {
    on<LoadJobs>((event, emit) async {
      emit(state.copyWith(status: Status.loading));
      try {
        final jobs = await _jobRepository.getJobs();
        emit(state.copyWith(jobs: jobs, status: Status.success));
      } catch (e) {
        emit(state.copyWith(status: Status.error, message: e.toString()));
      }
    });

    on<CreateJob>((event, emit) async {
      emit(state.copyWith(status: Status.loading));
      try {
        await _jobRepository.createJob(event.job);
        // Reload jobs after creating
        final jobs = await _jobRepository.getJobs();
        emit(state.copyWith(jobs: jobs, status: Status.success));
      } catch (e) {
        emit(state.copyWith(status: Status.error, message: e.toString()));
      }
    });

    on<StreamJobs>((event, emit) async {
      emit(state.copyWith(status: Status.loading));
      try {
        await emit.forEach(
          _jobRepository.getJobsStream(),
          onData: (List<Job> jobs) => state.copyWith(
            jobs: jobs,
            status: Status.success,
          ),
          onError: (error, stackTrace) => state.copyWith(
            status: Status.error,
            message: error.toString(),
          ),
        );
      } catch (e) {
        emit(state.copyWith(status: Status.error, message: e.toString()));
      }
    });
  }
}

