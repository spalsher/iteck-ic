import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/models/user.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../shared/widgets/glassmorphic_container.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/config/environment.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];
  List<String> _existingContactIds = [];
  bool _isSearching = false;
  bool _isLoadingContacts = true;

  @override
  void initState() {
    super.initState();
    _loadExistingContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingContacts() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final response = await http.get(
        Uri.parse('${Environment.baseUrl}/users/me'),
        headers: authService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user']);
        setState(() {
          _existingContactIds = user.contacts;
          _isLoadingContacts = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingContacts = false);
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final url = '${Environment.baseUrl}/users/search?username=$query';
      
      final response = await http.get(
        Uri.parse(url),
        headers: authService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = (data['users'] as List)
            .map((json) => User.fromJson(json))
            .where((user) => !_existingContactIds.contains(user.id)) // Filter out existing contacts
            .toList();
        
        setState(() {
          _searchResults = users;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _addContact(User user) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final url = '${Environment.baseUrl}/users/contacts/${user.id}';
      
      final response = await http.post(
        Uri.parse(url),
        headers: authService.getHeaders(),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contact added successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? 'Failed to add contact';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add contact: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Contact'),
        backgroundColor: AppColors.primaryCyan,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.of(context).pushNamed('/qr-scanner');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryCyan.withOpacity(0.1),
              AppColors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.all(Responsive.padding(context)),
              child: GlassmorphicContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search by username...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.6),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.primaryCyan,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    _searchUsers(value);
                  },
                ),
              ),
            ),
            
            // Search results
            Expanded(
              child: _isLoadingContacts
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryCyan,
                      ),
                    )
                  : _isSearching
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryCyan,
                          ),
                        )
                      : _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_search,
                                size: 80,
                                color: AppColors.textSecondary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isEmpty
                                    ? 'Search for users by username'
                                    : 'No users found',
                                style: TextStyle(
                                  fontSize: Responsive.fontSize(context, 16),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.padding(context),
                          ),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final user = _searchResults[index];
                            return _buildUserItem(user);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserItem(User user) {
    return GlassmorphicCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primaryCyan,
          child: user.avatar.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    user.avatar,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                )
              : Text(
                  user.displayName[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        title: Text(
          user.displayName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '@${user.username}',
          style: const TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () => _addContact(user),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryCyan,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Add'),
        ),
      ),
    );
  }
}
