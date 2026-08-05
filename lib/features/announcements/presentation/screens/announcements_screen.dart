import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart';
import '../bloc/announcement_bloc.dart';
import '../bloc/announcement_event.dart';
import '../bloc/announcement_state.dart';
import '../widgets/announcement_card.dart';
import '../../domain/entities/announcement_entity.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }
    final user = authState.user;

    return BlocProvider(
      create: (_) => sl<AnnouncementBloc>()
        ..add(
          LoadAnnouncementsRequested(schoolId: user.schoolId, operatorUser: user),
        ),
      child: const _AnnouncementsBody(),
    );
  }
}

class _AnnouncementsBody extends StatefulWidget {
  const _AnnouncementsBody();

  @override
  State<_AnnouncementsBody> createState() => _AnnouncementsBodyState();
}

class _AnnouncementsBodyState extends State<_AnnouncementsBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Published'),
            Tab(text: 'Drafts'),
          ],
        ),
      ),
      body: BlocConsumer<AnnouncementBloc, AnnouncementState>(
        listener: (context, state) {
          if (state is AnnouncementActionDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AnnouncementLoading || state is AnnouncementInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AnnouncementError) {
            return Center(child: Text(state.message));
          }
          if (state is! AnnouncementLoaded) {
            return const SizedBox.shrink();
          }

          final all = state.announcements;
          final published = all
              .where((a) => a.status == AnnouncementStatus.published)
              .toList();
          final drafts = all
              .where((a) => a.status == AnnouncementStatus.draft)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _AnnouncementList(announcements: all),
              _AnnouncementList(announcements: published),
              _AnnouncementList(announcements: drafts),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<AnnouncementBloc, AnnouncementState>(
        builder: (context, state) {
          if (state is! AnnouncementLoaded || !state.canManage) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton(
            onPressed: () => context.push('/staff/more/announcements/new'),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}

class _AnnouncementList extends StatelessWidget {
  final List<AnnouncementEntity> announcements;

  const _AnnouncementList({required this.announcements});

  @override
  Widget build(BuildContext context) {
    if (announcements.isEmpty) {
      return const EmptyState(
        icon: Icons.campaign_outlined,
        title: 'No announcements',
        message: 'There are no announcements to show here yet.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: announcements.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final announcement = announcements[index];
        return AnnouncementCard(
          announcement: announcement,
          onTap: () =>
              context.push('/staff/more/announcements/${announcement.id}'),
        );
      },
    );
  }
}
