import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:job/models/response/get_all_jobs.dart';
import 'package:job/utils/enums.dart';
import '../../repositories/job_repository.dart';

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
        final createdJob = await _jobRepository.createJob(event.job);

        // Show success and reload jobs
        emit(state.copyWith(
            status: Status.success,
            message: 'Job created successfully!'
        ));

        // Reload jobs after creating
        final jobs = await _jobRepository.getJobs();
        emit(state.copyWith(jobs: jobs, status: Status.success));
      } catch (e) {
        // Parse error message for better user feedback
        String errorMessage = e.toString();
        if (errorMessage.contains('User not authenticated')) {
          errorMessage = 'Please login to create a job post';
        } else if (errorMessage.contains('posted_by_user')) {
          errorMessage = 'Unable to identify user. Please logout and login again.';
        }

        emit(state.copyWith(
            status: Status.error,
            message: errorMessage
        ));
      }
    });

    on<StreamJobs>((event, emit) async {
      emit(state.copyWith(status: Status.loading));
      try {
        await emit.forEach(
          _jobRepository.getJobsStream(),
          onData: (List<GetAllJobsResponse> jobs) => state.copyWith(
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