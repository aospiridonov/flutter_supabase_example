import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({Key? key}) : super(key: key);

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  bool _loading = true;
  final _usernameController = TextEditingController();
  final _websiteController = TextEditingController();

  @override
  void initState() {
    _loadProfile();
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const CircularProgressIndicator()
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(label: Text('Username')),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(label: Text('Website')),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: () async {
                    try {
                      setState(() {
                        _loading = false;
                      });
                      final userId =
                          Supabase.instance.client.auth.currentUser!.id;
                      final username = _usernameController.text;
                      final website = _websiteController.text;
                      await Supabase.instance.client.from('profile').upsert({
                        'id': userId,
                        'username': username,
                        'website': website,
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Saved profile'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Error saving profile'),
                        backgroundColor: Colors.red,
                      ));
                    }
                    setState(() {
                      _loading = true;
                    });
                  },
                  child: const Text('Save')),
              const SizedBox(height: 16),
              TextButton(
                  onPressed: () => Supabase.instance.client.auth.signOut(),
                  child: const Text('Sign Out')),
            ],
          );
  }

  void _loadProfile() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final data = (await Supabase.instance.client
          .from('profiles')
          .select()
          .match({'id': userId}).maybeSingle()) as Map?;
      if (data != null) {
        setState(() {
          _usernameController.text = data['username'];
          _websiteController.text = data['website'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error occured while getting profile'),
        backgroundColor: Colors.red,
      ));
    }
    setState(() {
      _loading = false;
    });
  }
}
