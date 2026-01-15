import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../shared/widgets/glassmorphic_container.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user.dart';
import '../../../core/config/environment.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<User> contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      print('🔄 Loading contacts from: ${Environment.baseUrl}/users/me');
      
      final response = await http.get(
        Uri.parse('${Environment.baseUrl}/users/me'),
        headers: authService.getHeaders(),
      );

      print('📥 Contacts response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user']);
        
        print('👥 Found ${user.contacts.length} contacts');
        
        // Fetch full contact details for each contact ID
        final List<User> fetchedContacts = [];
        for (String contactId in user.contacts) {
          try {
            final contactResponse = await http.get(
              Uri.parse('${Environment.baseUrl}/users/$contactId'),
              headers: authService.getHeaders(),
            );
            
            if (contactResponse.statusCode == 200) {
              final contactData = jsonDecode(contactResponse.body);
              final contact = User.fromJson(contactData['user']);
              fetchedContacts.add(contact);
              print('✅ Loaded contact: ${contact.username}');
            }
          } catch (e) {
            print('❌ Error fetching contact $contactId: $e');
          }
        }
        
        setState(() {
          contacts = fetchedContacts;
          _isLoading = false;
        });
        
        print('✅ Loaded ${contacts.length} contacts successfully');
      } else {
        print('❌ Failed to load contacts: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ Error loading contacts: $e');
      setState(() => _isLoading = false);
      
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load contacts: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: AppColors.primaryCyan,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              await Navigator.of(context).pushNamed('/contacts');
              // Reload contacts when returning from contacts screen
              _loadContacts();
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.of(context).pushNamed('/qr-scanner');
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                // Show profile
              } else if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryCyan,
                ),
              )
            : contacts.isEmpty
                ? _buildEmptyState()
                : _buildContactsList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed('/contacts');
          // Reload contacts when returning from contacts screen
          _loadContacts();
        },
        backgroundColor: AppColors.primaryCyan,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(32),
        margin: EdgeInsets.all(Responsive.padding(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppColors.primaryCyan,
            ),
            const SizedBox(height: 24),
            Text(
              'No Chats Yet',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 24),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add contacts to start chatting',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 16),
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    return ListView.builder(
      padding: EdgeInsets.all(Responsive.spacing(context)),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return _buildContactItem(contact);
      },
    );
  }

  Widget _buildContactItem(User contact) {
    return GlassmorphicCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () {
        Navigator.of(context).pushNamed(
          '/chat',
          arguments: contact,
        );
      },
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primaryCyan,
              child: contact.avatar.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        contact.avatar,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      contact.displayName[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            if (contact.isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          contact.displayName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          contact.isOnline ? 'Online' : 'Offline',
          style: TextStyle(
            color: contact.isOnline ? AppColors.success : AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}
