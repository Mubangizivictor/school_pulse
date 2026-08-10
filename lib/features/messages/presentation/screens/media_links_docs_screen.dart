import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/presentation/messaging_context.dart';
import 'package:url_launcher/url_launcher.dart';

/// Matches bare URLs inside message text so the Links tab can list them
/// without needing a separate message type.
final RegExp _urlPattern = RegExp(r'https?://\S+');

class MediaLinksDocsScreen extends StatelessWidget {
  final String chatId;
  const MediaLinksDocsScreen({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Media, Links & Docs', style: AppTypography.titleLarge),
          bottom: TabBar(
            labelColor: AppColors.electricBlue,
            unselectedLabelColor: AppColors.textMuted(context),
            indicatorColor: AppColors.electricBlue,
            indicatorWeight: 3,
            labelStyle: AppTypography.titleSmall,
            tabs: const [
              Tab(text: 'Media'),
              Tab(text: 'Links'),
              Tab(text: 'Docs'),
            ],
          ),
        ),
        body: MessagingUserBuilder(
          builder: (context, user) => StreamBuilder<List<ChatMessage>>(
            stream: context.messages.watchAttachments(chatId, user.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: SchoolPulseLoader());
              }
              final attachments = snapshot.data!;
              return TabBarView(
                children: [
                  _buildMediaGrid(
                    context,
                    attachments
                        .where(
                          (m) =>
                              m.type == MessageType.image ||
                              m.type == MessageType.video,
                        )
                        .toList(),
                  ),
                  _buildLinksList(context, attachments),
                  _buildDocsList(
                    context,
                    attachments
                        .where(
                          (m) =>
                              m.type == MessageType.file ||
                              m.type == MessageType.audio,
                        )
                        .toList(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMediaGrid(BuildContext context, List<ChatMessage> media) {
    if (media.isEmpty) {
      return _buildEmpty(context, 'No photos or videos shared yet.');
    }

    // Grouped the way the chat itself reads - newest month first.
    final byMonth = <String, List<ChatMessage>>{};
    for (final message in media) {
      byMonth
          .putIfAbsent(_monthLabel(message.timestamp), () => [])
          .add(message);
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.m),
      children: [
        for (final entry in byMonth.entries) ...[
          _buildSectionHeader(context, entry.key.toUpperCase()),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: entry.value.length,
            itemBuilder: (context, index) {
              final message = entry.value[index];
              return GestureDetector(
                onTap: () => _openImage(context, message),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    message.mediaUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.l),
        ],
      ],
    );
  }

  Widget _buildLinksList(BuildContext context, List<ChatMessage> attachments) {
    final links = <({ChatMessage message, String url})>[];
    for (final message in attachments) {
      for (final match in _urlPattern.allMatches(message.content)) {
        links.add((message: message, url: match.group(0)!));
      }
    }
    if (links.isEmpty) return _buildEmpty(context, 'No links shared yet.');

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: links.length,
      itemBuilder: (context, index) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final link = links[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.s),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.electricBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.link, color: AppColors.electricBlue),
            ),
            title: Text(
              link.url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.electricBlue,
                decoration: TextDecoration.underline,
              ),
            ),
            subtitle: Text(
              '${link.message.senderName} • ${DateFormat('dd/MM/yy HH:mm').format(link.message.timestamp)}',
              style: AppTypography.labelSmall,
            ),
            onTap: () => _openUrl(context, link.url),
          ),
        );
      },
    );
  }

  Widget _buildDocsList(BuildContext context, List<ChatMessage> docs) {
    if (docs.isEmpty) return _buildEmpty(context, 'No documents shared yet.');

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final doc = docs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.s),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.picture_as_pdf, color: Colors.red),
            ),
            title: Text(
              doc.fileName ?? 'Attachment',
              style: AppTypography.titleSmall,
            ),
            subtitle: Text(
              '${doc.fileSize ?? ''} • ${DateFormat('dd/MM/yy • HH:mm').format(doc.timestamp)}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted(context),
              ),
            ),
            trailing: const Icon(Icons.file_download_outlined, size: 20),
            onTap: doc.mediaUrl == null
                ? null
                : () => _openUrl(context, doc.mediaUrl!),
          ),
        );
      },
    );
  }

  void _openImage(BuildContext context, ChatMessage message) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(message.mediaUrl!, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(dialogContext),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      context.showMessagingSnack('Could not open $url');
    }
  }

  Widget _buildEmpty(BuildContext context, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textMuted(context),
          ),
        ),
      ),
    );
  }

  String _monthLabel(DateTime date) {
    final now = DateTime.now();
    if (now.year == date.year && now.month == date.month) return 'This month';
    return DateFormat('MMMM yyyy').format(date);
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s, left: 4),
      child: Text(
        title,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textMuted(context),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
