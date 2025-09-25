import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/job_repository.dart';
import '../../models/job_model.dart';

part 'job_event.dart';
part 'job_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  final JobRepository _jobRepository;

  JobBloc(this._jobRepository) : super(JobInitial()) {
    on<LoadJobs>(_onLoadJobs);
    on<CreateJob>(_onCreateJob);
    on<StreamJobs>(_onStreamJobs);
  }

  Future<void> _onLoadJobs(LoadJobs event, Emitter<JobState> emit) async {
    emit(JobLoading());
    try {
      final jobs = await _jobRepository.getJobs();
      emit(JobLoaded(jobs));
    } catch (e) {
      emit(JobError(e.toString()));
    }
  }

  Future<void> _onCreateJob(CreateJob event, Emitter<JobState> emit) async {
    try {
      await _jobRepository.createJob(event.job);
      add(LoadJobs());
    } catch (e) {
      emit(JobError(e.toString()));
    }
  }

  Future<void> _onStreamJobs(StreamJobs event, Emitter<JobState> emit) async {
    emit(JobLoading());
    await emit.forEach(
      _jobRepository.getJobsStream(),
      onData: (List<Job> jobs) => JobLoaded(jobs),
      onError: (error, stackTrace) => JobError(error.toString()),
    );
  }
}