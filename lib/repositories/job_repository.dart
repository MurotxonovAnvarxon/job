import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job_model.dart';

class JobRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Job>> getJobs() async {
    try {
      final response = await _supabase
          .from('jobs')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((job) => Job.fromJson(job))
          .toList();
    } catch (e) {
      throw Exception('Failed to load jobs: $e');
    }
  }

  Future<Job> createJob(Job job) async {
    try {
      final response = await _supabase
          .from('jobs')
          .insert(job.toJson())
          .select()
          .single();

      return Job.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create job: $e');
    }
  }

  Stream<List<Job>> getJobsStream() {
    return _supabase
        .from('jobs')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((job) => Job.fromJson(job)).toList());
  }
}