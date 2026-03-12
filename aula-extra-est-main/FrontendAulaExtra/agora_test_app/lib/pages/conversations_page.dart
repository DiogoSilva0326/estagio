import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'chat_room_page.dart';
import 'contacts_page.dart';

/// Page displaying all conversations (DMs and groups) for the current user
class ConversationsPage extends StatefulWidget {
  const ConversationsPage({
    super.key,
    required this.userId,
    required this.displayName,
  });

  final String userId;
  final String displayName;

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService.instance;
  List<ChatRoom> _rooms = [];
  bool _loading = true;
  String? _error;
  StreamSubscription<DirectMessageNotification>? _dmSubscription;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadRooms();
  }

  @override
  void dispose() {
    _dmSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initNotifications() async {
    // Connect to notification service for real-time updates
    await _notificationService.connect(widget.userId);
    
    // Listen for new DM notifications
    _dmSubscription = _notificationService.dmNotifications.listen((notification) {
      // Reload rooms to update the list when a new message arrives
      _loadRooms();
      
      // Optionally show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nova mensagem de ${notification.senderName}'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Ver',
              onPressed: () {
                // Find and open the room
                final room = _rooms.firstWhere(
                  (r) => r.channelName == notification.channelName,
                  orElse: () => _rooms.first,
                );
                _openRoom(room);
              },
            ),
          ),
        );
      }
    });
    
    // Listen for unread count changes
    _notificationService.addListener(_onNotificationUpdate);
  }

  void _onNotificationUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadRooms() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final rooms = await _apiService.getChatRooms(widget.userId);
      setState(() {
        _rooms = rooms;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _openContacts() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ContactsPage(
          userId: widget.userId,
          displayName: widget.displayName,
        ),
      ),
    );

    if (result == true) {
      _loadRooms();
    }
  }

  void _openRoom(ChatRoom room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomPage(
          room: room,
          userId: widget.userId,
          displayName: widget.displayName,
        ),
      ),
    );
  }

  void _createGroup() async {
    // First, get contacts to select as members
    List<Contact> contacts = [];
    try {
      contacts = await _apiService.getContacts(widget.userId);
      // Filter to only accepted contacts
      contacts = contacts.where((c) => !c.isPending).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar contactos: $e')),
      );
      return;
    }

    if (contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione contactos primeiro antes de criar um grupo')),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _CreateGroupDialog(contacts: contacts),
    );

    if (result == null) return;

    final groupName = result['name'] as String;
    final selectedMembers = result['members'] as List<String>;

    if (groupName.isEmpty) return;

    try {
      // Include creator in member list
      final allMembers = [widget.userId, ...selectedMembers];
      
      final room = await _apiService.createGroup(
        creatorUserId: widget.userId,
        groupName: groupName,
        memberUserIds: allMembers,
      );

      _loadRooms();
      _openRoom(room);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar grupo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.contacts),
            onPressed: _openContacts,
            tooltip: 'Contactos',
          ),
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: _createGroup,
            tooltip: 'Criar Grupo',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRooms,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Erro: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRooms,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma conversa ainda',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openContacts,
              icon: const Icon(Icons.person_add),
              label: const Text('Adicionar Contacto'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRooms,
      child: ListView.builder(
        itemCount: _rooms.length,
        itemBuilder: (context, index) {
          final room = _rooms[index];
          return _RoomTile(
            room: room,
            currentUserId: widget.userId,
            onTap: () => _openRoom(room),
          );
        },
      ),
    );
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({
    required this.room,
    required this.currentUserId,
    required this.onTap,
  });

  final ChatRoom room;
  final String currentUserId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    String title;
    IconData icon;

    if (room.isGroup) {
      title = room.groupName ?? 'Grupo';
      icon = Icons.group;
    } else {
      // For DM, show the other user's display name
      final otherUserId = room.memberUserIds.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );
      title = otherUserId.isEmpty ? 'Chat' : room.getDisplayName(otherUserId);
      icon = Icons.person;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: room.isGroup ? Colors.blue : Colors.green,
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title),
      subtitle: room.lastMessageAt != null
          ? Text(
              'Última mensagem: ${_formatTime(room.lastMessageAt!)}',
              style: const TextStyle(color: Colors.grey),
            )
          : const Text(
              'Sem mensagens',
              style: TextStyle(color: Colors.grey),
            ),
      trailing: room.isGroup
          ? Text('${room.memberUserIds.length} membros')
          : null,
      onTap: onTap,
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${diff.inDays}d atrás';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h atrás';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m atrás';
    } else {
      return 'Agora';
    }
  }
}

class _CreateGroupDialog extends StatefulWidget {
  const _CreateGroupDialog({required this.contacts});

  final List<Contact> contacts;

  @override
  State<_CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<_CreateGroupDialog> {
  final _nameController = TextEditingController();
  final Set<String> _selectedMembers = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Criar Grupo'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Grupo',
                hintText: 'Ex: Equipa de Projeto',
                prefixIcon: Icon(Icons.group),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 20),
            const Text(
              'Selecionar Membros:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (widget.contacts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Nenhum contacto disponível',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.contacts.length,
                  itemBuilder: (context, index) {
                    final contact = widget.contacts[index];
                    final isSelected = _selectedMembers.contains(contact.contactUserId);
                    
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedMembers.add(contact.contactUserId);
                          } else {
                            _selectedMembers.remove(contact.contactUserId);
                          }
                        });
                      },
                      title: Text(contact.displayName),
                      subtitle: Text(contact.contactUserId),
                      secondary: CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 16,
                        child: Text(
                          contact.displayName.isNotEmpty 
                              ? contact.displayName[0].toUpperCase() 
                              : '?',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      dense: true,
                    );
                  },
                ),
              ),
            if (_selectedMembers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${_selectedMembers.length} membro(s) selecionado(s)',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _selectedMembers.isEmpty || _nameController.text.trim().isEmpty
              ? null
              : () => Navigator.pop(context, {
                    'name': _nameController.text.trim(),
                    'members': _selectedMembers.toList(),
                  }),
          child: const Text('Criar'),
        ),
      ],
    );
  }
}
