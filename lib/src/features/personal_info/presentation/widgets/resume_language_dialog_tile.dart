import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:portfolio/src/features/personal_info/domain/resume.dart';
import 'package:portfolio/src/utils/launch_url_helper.dart';
import 'package:portfolio/src/utils/scaffold_messenger_helper.dart';

class ResumeLanguageDialogTile extends ConsumerWidget {
  const ResumeLanguageDialogTile({super.key, required this.resume});
  final Resume resume;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        final resumeUrl = resume.url;
        if (resumeUrl == null) return;
        _onPressed(context, resumeUrl: resumeUrl);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: _buildResumeLanguageTileContent(
              context,
              ref,
              resume: resume,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildResumeLanguageTileContent(
  BuildContext context,
  WidgetRef ref, {
  required Resume resume,
}) {
  //final languages = ref.watch(languageRepositoryProvider).getLanguages();
  final role = resume.role ?? "";

  return Text(
    tr(role),
    style: Theme.of(context).textTheme.titleMedium,
  );
}

void _onPressed(BuildContext context, {required String resumeUrl}) async {
  try {
    await LaunchUrlHelper.launchURL(resumeUrl);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessengerHelper.showLaunchUrlError(context, url: resumeUrl);
    }
  }
  if (context.mounted) {
    Navigator.of(context).pop();
  }
}
