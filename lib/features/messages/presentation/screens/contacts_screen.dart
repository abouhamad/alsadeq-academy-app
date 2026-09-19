import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/sign_out_button.dart';
import '../../data/models/contact_model.dart';
import '../providers/messages_provider.dart';

/// Search-first contact picker rather than a full roster listing: a parent
/// or teacher types a name (their own, a colleague's, or a child's) and
/// only matching contacts appear, instead of dumping every allowed contact
/// on screen up front.
class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ContactModel> _filter(List<ContactModel> contacts) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return const [];
    return contacts.where((contact) {
      final name = contact.name.toLowerCase();
      final studentName = contact.studentName?.toLowerCase() ?? '';
      return name.contains(query) || studentName.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(contactsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages'), actions: const [SignOutButton()]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by teacher, parent, or child name',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AsyncValueView(
                value: contacts,
                onRetry: () => ref.invalidate(contactsListProvider),
                data: (context, list) {
                  if (_query.trim().isEmpty) {
                    return const Center(
                      child: Text(
                        'Start typing a name to find who to message.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  final results = _filter(list);
                  if (results.isEmpty) {
                    return const Center(
                      child: Text(
                        'No matching contacts.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final contact = results[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            child: Icon(contact.kind == 'teacher' ? Icons.school_outlined : Icons.family_restroom),
                          ),
                          title: Text(contact.name),
                          subtitle: contact.studentName != null ? Text(contact.studentName!) : null,
                          onTap: () => context.push(
                            '/messages/thread',
                            extra: {'userId': contact.userId, 'name': contact.name},
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
