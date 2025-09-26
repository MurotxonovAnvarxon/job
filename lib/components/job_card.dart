import 'package:flutter/material.dart';
import 'package:job/models/response/get_all_jobs.dart';
import '../models/job_model.dart';
import 'package:intl/intl.dart';

class JobCard extends StatelessWidget {
  final GetAllJobsResponse job;

  const JobCard({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    job.title??"",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // if (job.salaryMax != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9FC348).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "${job.salaryMin??0}-",
                          style: const TextStyle(
                            color: Color(0xFF9FC348),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${job.salaryMax??0}",
                          style: const TextStyle(
                            color: Color(0xFF9FC348),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          " ${job.currency}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (job.description != null) ...[
              const SizedBox(height: 12),
              Text(
                job.description!,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (job.createdAt != null) ...[
              const SizedBox(height: 12),
              Text(
                DateFormat('MMM dd, yyyy').format(job.createdAt!),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}