import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:namma_ooru_ai/shared/widgets/priority_indicator.dart';
import 'package:namma_ooru_ai/shared/widgets/status_badge.dart';
import 'package:namma_ooru_ai/shared/widgets/metric_card.dart';
import 'package:namma_ooru_ai/shared/widgets/empty_state.dart';
import 'package:namma_ooru_ai/features/profile/presentation/screens/profile_screen.dart';
import 'package:namma_ooru_ai/core/localization/app_localizations.dart';
import 'package:namma_ooru_ai/core/theme/app_colors.dart';

void main() {
  testWidgets('StatusBadge renders correct labels and icons',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              StatusBadge(status: 'submitted'),
              StatusBadge(status: 'in_progress'),
              StatusBadge(status: 'resolved'),
              StatusBadge(status: 'rejected'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Submitted'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Resolved'), findsOneWidget);
    expect(find.text('Rejected'), findsOneWidget);
  });

  testWidgets(
      'PriorityIndicator renders critical and high priorities correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              PriorityIndicator(priority: 'critical'),
              PriorityIndicator(priority: 'high'),
              PriorityIndicator(priority: 'medium'),
              PriorityIndicator(priority: 'low'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Critical'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('Low'), findsOneWidget);
  });

  testWidgets('MetricCard displays title, value, and subtitle properly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MetricCard(
            title: 'Total Complaints',
            value: '1,420',
            subtitle: '+12% from yesterday',
            icon: Icons.assignment_outlined,
            iconColor: AppColors.primary,
          ),
        ),
      ),
    );

    expect(find.text('Total Complaints'), findsOneWidget);
    expect(find.text('1,420'), findsOneWidget);
    expect(find.text('+12% from yesterday'), findsOneWidget);
    expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
  });

  testWidgets('EmptyState renders message and action button',
      (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            title: 'No Complaints Found',
            description: 'All civic issues in your area have been resolved.',
            icon: Icons.check_circle_outline,
            actionLabel: 'Report Issue',
            onAction: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('No Complaints Found'), findsOneWidget);
    expect(find.text('All civic issues in your area have been resolved.'),
        findsOneWidget);
    expect(find.text('Report Issue'), findsOneWidget);

    await tester.tap(find.text('Report Issue'));
    expect(tapped, isTrue);
  });

  testWidgets('ProfileScreen renders user details, role badge and ward information',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'app_language_code': 'en'});
    await LanguageController().setLanguage('en');

    final mockCitizen = {
      'id': 'test-citizen-1',
      'full_name': 'Kavitha Ramachandran',
      'email': 'kavitha@test.com',
      'phone': '+91 98401 23456',
      'role': 'citizen',
      'city': 'Chennai',
      'municipality': 'Greater Chennai Corporation (GCC)',
      'zone': 'Zone 8 (Anna Nagar)',
      'ward_number': 'Ward 104',
      'ward_name': 'Aminjikarai',
    };

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: ProfileScreen(
            initialProfile: mockCitizen,
            onLogout: () {},
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Kavitha Ramachandran'), findsOneWidget);
    expect(find.text('+91 98401 23456 • Chennai'), findsOneWidget);
    expect(find.text('kavitha@test.com'), findsOneWidget);
    expect(find.text('Greater Chennai Corporation (GCC)'), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) =>
          widget is Text &&
          (widget.data == 'Verified Resident Citizen' ||
              widget.data == 'சரிபார்க்கப்பட்ட குடிமகன்')),
      findsOneWidget,
    );
  });
}
