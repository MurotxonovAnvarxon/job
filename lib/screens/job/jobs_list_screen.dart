import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/job/job_bloc.dart';
import 'components/app_bar.dart';
import 'components/home_list.dart';
import 'create_job_screen.dart';

class JobsListScreen extends StatefulWidget {
  const JobsListScreen({super.key});

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<JobBloc>().add(StreamJobs());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userEmail = authState is AuthAuthenticated
        ? authState.user.email
        : '';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,

            backgroundColor: const Color(0xFF9FC348),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF9FC348), Color(0xFF7FA02E)],
                  ),
                ),
                child: AppBarHome(userEmail: userEmail),
              ),
              centerTitle: true,
            ),

            leading: SizedBox(),
          ),

          SliverPadding(
            padding: const EdgeInsets.only(top: 16),
            sliver: HomeList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateJobScreen()),
          );
        },
        backgroundColor: const Color(0xFF9FC348),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Job', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
