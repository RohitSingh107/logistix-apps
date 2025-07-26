import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/bloc/user_bloc.dart';

class CreateProfileScreen extends StatefulWidget {
  final String phone;
  
  const CreateProfileScreen({
    Key? key,
    required this.phone,
  }) : super(key: key);

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _firstNameError;
  String? _lastNameError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    bool isValid = true;
    
    // Reset all errors
    setState(() {
      _firstNameError = null;
      _lastNameError = null;
    });
    
    // Validate first name
    if (_firstNameController.text.isEmpty) {
      setState(() {
        _firstNameError = 'Please enter your first name';
      });
      isValid = false;
    }
    
    // Validate last name
    if (_lastNameController.text.isEmpty) {
      setState(() {
        _lastNameError = 'Please enter your last name';
      });
      isValid = false;
    }
    
    return isValid;
  }

  void _createProfile() {
    if (!_validateInputs()) {
      return;
    }

    context.read<UserBloc>().add(UpdateUserProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Profile'),
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserLoaded) {
            // Navigate to home screen after profile creation
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border: const OutlineInputBorder(),
                    errorText: _firstNameError,
                  ),
                  onChanged: (value) {
                    if (_firstNameError != null) {
                      setState(() {
                        _firstNameError = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: const OutlineInputBorder(),
                    errorText: _lastNameError,
                  ),
                  onChanged: (value) {
                    if (_lastNameError != null) {
                      setState(() {
                        _lastNameError = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is UserLoading
                          ? null
                          : _createProfile,
                      child: state is UserLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.0),
                            )
                          : const Text('Create Profile'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 