import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/models/user_profile.dart';
import '../home/home_screen.dart';
import '../../data/local/json_loader.dart'; // make sure you have this

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = "";
  String _selectedCountry = "USA";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("app_title".tr())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("select_username".tr(), style: TextStyle(fontSize: 18)),
              TextFormField(
                decoration: InputDecoration(hintText: tr("select_username")),
                validator: (value) => (value == null || value.isEmpty)
                    ? tr("select_username")
                    : null,
                onSaved: (value) => _username = value ?? "",
              ),
              SizedBox(height: 20),
              Text("select_country".tr(), style: TextStyle(fontSize: 18)),
              DropdownButtonFormField<String>(
                value: _selectedCountry,
                items:
                    [
                          {"name": "USA", "flag": "🇺🇸"},
                          {"name": "England", "flag": "🇬🇧"},
                          {"name": "Sweden", "flag": "🇸🇪"},
                        ]
                        .map(
                          (country) => DropdownMenuItem<String>(
                            value: country["name"],
                            child: Text(
                              "${country["flag"]} ${country["name"]}",
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() => _selectedCountry = value ?? "USA");
                },
              ),
              Spacer(),
              Center(
                child: ElevatedButton(
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

                      // Load your questions in the chosen language
                      await QuestionLoader.loadQuestionsFromJson(
                        locale.languageCode,
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => HomeScreen()),
                      );
                    }
                  },
                  child: Text("continue".tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
