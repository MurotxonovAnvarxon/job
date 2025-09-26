import 'package:job/models/response/get_all_jobs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JobRepository {
  final _supabase = Supabase.instance.client;

  Future<List<GetAllJobsResponse>> getJobs() async {
    try {
      final response = await _supabase
          .from('jobs')
          .select()
          .order('created_at', ascending: false);

      var data = (response as List)
          .map((job) => GetAllJobsResponse.fromJson(job))
          .toList();
      print("====================");
      print("${data.toString()}");
      print("====================");
      return data;
    } catch (e) {
      throw Exception('Failed to load jobs: $e');
    }
  }

  Future<GetAllJobsResponse> createJob(GetAllJobsResponse job) async {
    try {
      // Get current user - REQUIRED
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated. Please login to create a job.');
      }

      // Get user email - REQUIRED
      final userEmail = user.email;
      if (userEmail == null) {
        throw Exception('User email not found. Please login again.');
      }

      // Prepare job data with all required fields
      final jobData = {
        'title': job.title ?? '',
        'posted_by_display_name': job.postedByDisplayName ?? userEmail.split('@')[0],
        'posted_by_user': userEmail,  // Required - user's email
        'description': job.description ?? '',
        'location': job.location ?? '',
        'employment_type': job.employmentType ?? 'full_time',
        'salary_min': job.salaryMin ?? 0,
        'salary_max': job.salaryMax ?? 0,
        'currency': job.currency ?? 'USD',
        'status': job.status ?? 'published',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'search_tsv': job.searchTsv ?? '${job.title} ${job.description}',
        'user_id': user.id,  // Required - user's ID
      };

      print("Creating job with data: $jobData");

      final response = await _supabase
          .from('jobs')
          .insert(jobData)
          .select()
          .single();

      return GetAllJobsResponse.fromJson(response);
    } catch (e) {
      print("Error creating job: $e");
      throw Exception('Failed to create job: $e');
    }
  }

  Future<GetAllJobsResponse> updateJob(int jobId, Map<String, dynamic> updates) async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated.');
      }

      // Add updated_at timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('jobs')
          .update(updates)
          .eq('id', jobId)
          .eq('user_id', user.id)  // Ensure user can only update their own jobs
          .select()
          .single();

      return GetAllJobsResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update job: $e');
    }
  }

  Future<void> deleteJob(int jobId) async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated.');
      }

      await _supabase
          .from('jobs')
          .delete()
          .eq('id', jobId)
          .eq('user_id', user.id);  // Ensure user can only delete their own jobs
    } catch (e) {
      throw Exception('Failed to delete job: $e');
    }
  }

  Future<List<GetAllJobsResponse>> getUserJobs() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated.');
      }

      final response = await _supabase
          .from('jobs')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((job) => GetAllJobsResponse.fromJson(job))
          .toList();
    } catch (e) {
      throw Exception('Failed to load user jobs: $e');
    }
  }

  Stream<List<GetAllJobsResponse>> getJobsStream() {
    return _supabase
        .from('jobs')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((job) => GetAllJobsResponse.fromJson(job)).toList());
  }

  Stream<List<GetAllJobsResponse>> getUserJobsStream() {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _supabase
        .from('jobs')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .map((data) => data.map((job) => GetAllJobsResponse.fromJson(job)).toList());
  }
}