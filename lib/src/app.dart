import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:portfolio/src/constants/themes.dart' as themes;
import 'package:portfolio/src/features/general/presentation/general_section.dart';
import 'package:portfolio/src/features/general/provider/dark_mode_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:portfolio/src/localization/generated/locale_keys.g.dart';
import 'package:portfolio/src/visitor_tracker.dart';
// Import your visitor tracker service here
// import 'path/to/visitor_tracker.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Log the visitor as soon as the root app widget initializes
    VisitorTracker.logVisit();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (_) => tr(LocaleKeys.name),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: themes.lightTheme,
      darkTheme: themes.darkTheme,
      themeMode: ref.watch(darkModeProvider).maybeWhen(
            data: (darkMode) => darkMode ? ThemeMode.dark : ThemeMode.light,
            orElse: () => ThemeMode.system,
          ),
      home: const GeneralSection(),
    );
  }
}
