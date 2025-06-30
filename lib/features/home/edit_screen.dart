import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:quiz/data/models/quiz_attempt.dart';
import 'package:quiz/data/models/user_progress.dart';
import '../../data/models/user_profile.dart';
import '../home/home_screen.dart';
import '../../data/local/json_loader.dart';

class EditScreen extends ConsumerStatefulWidget {
  final String? initialUsername;
  final String? initialCountry;

  const EditScreen({super.key, this.initialUsername, this.initialCountry});

  @override
  ConsumerState<EditScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<EditScreen> {
  @override
  void initState() {
    super.initState();
    _username = widget.initialUsername ?? "";
    _selectedCountry = widget.initialCountry ?? "USA";
  }

  final _formKey = GlobalKey<FormState>();
  String _username = "";
  String _selectedCountry = "USA";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B1E3D), // deep blue
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "select_username".tr(),
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                style: TextStyle(color: Colors.white),
                initialValue: _username,
                decoration: InputDecoration(
                  hintText: tr("select_username"),
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? tr("select_username")
                    : null,
                onSaved: (value) => _username = value ?? "",
              ),

              SizedBox(height: 30),
              Text(
                "select_country".tr(),
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),

              DropdownButtonFormField<String>(
                dropdownColor: Color(0xFF1A2A52), // dark dropdown
                iconEnabledColor: Colors.white,
                value: _selectedCountry,
                items:
                    [
                          {"name": "USA", "flag": "🇺🇸"},
                          {"name": "United Kingdom", "flag": "🇬🇧"},
                          {"name": "Sweden", "flag": "🇸🇪"},
                        ]
                        .map(
                          (country) => DropdownMenuItem<String>(
                            value: country["name"],
                            child: Text(
                              "${country["flag"]} ${country["name"]}",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() => _selectedCountry = value ?? "USA");
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(border: InputBorder.none),
              ),
              Spacer(),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 8,
                  ),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Color(0xFF1A2A52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            tr("confirm_reset_title"),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            tr("confirm_reset_message"),
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(
                                    tr("cancel"),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                Spacer(),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(tr("confirm")),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmed == true) {
                      final profileBox = Hive.box<UserProfile>('profileBox');
                      final progressBox = Hive.box<UserProgress>('progressBox');
                      final attemptsBox = Hive.box<QuizAttempt>('attemptsBox');

                      await profileBox.clear();
                      await progressBox.clear();
                      await attemptsBox.clear();

                      context.setLocale(Locale('en'));
                      await QuestionLoader.loadQuestionsFromJson('en');

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => EditScreen()),
                      );
                    }
                  },
                  child: Text(
                    tr("reset_account"),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 54),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                    backgroundColor: Color(0xFFFFC107), // gold
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 8,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      final box = Hive.box<UserProfile>('profileBox');
                      await box.put(
                        'user',
                        UserProfile(
                          username: _username,
                          country: _selectedCountry,
                        ),
                      );

                      final locale = _selectedCountry == "Sweden"
                          ? Locale('sv')
                          : Locale('en');
                      context.setLocale(locale);

                      await QuestionLoader.loadQuestionsFromJson(
                        locale.languageCode,
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => HomeScreen()),
                      );
                    }
                  },
                  child: Text(
                    "continue".tr(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
