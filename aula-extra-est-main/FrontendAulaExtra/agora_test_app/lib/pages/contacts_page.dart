import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'chat_room_page.dart';

/// Page for managing user contacts with invite system
class ContactsPage extends StatefulWidget {
  const ContactsPage({
    super.key,
    required this.userId,
    required this.displayName,
  });

  final String userId;
  final String displayName;

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  
  List<Contact> _contacts = [];
  List<ContactRequest> _pendingRequests = [];
  List<ContactRequest> _sentRequests = [];
  
  bool _loadingContacts = true;
  bool _loadingPending = true;
  bool _loadingSent = true;
  String? _error;
  bool _roomCreated = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadContacts(),
      _loadPendingRequests(),
      _loadSentRequests(),
    ]);
  }

  Future<void> _loadContacts() async {
    setState(() {
      _loadingContacts = true;
      _error = null;
    });

    try {
      final contacts = await _apiService.getContacts(widget.userId);
      setState(() {
        // Only show accepted contacts (not pending)
        _contacts = contacts.where((c) => !c.isPending).toList();
        _loadingContacts = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loadingContacts = false;
      });
    }
  }

  Future<void> _loadPendingRequests() async {
    setState(() => _loadingPending = true);

    try {
      final requests = await _apiService.getPendingContactRequests(widget.userId);
      setState(() {
        _pendingRequests = requests;
        _loadingPending = false;
      });
    } catch (e) {
      setState(() => _loadingPending = false);
    }
  }

  Future<void> _loadSentRequests() async {
    setState(() => _loadingSent = true);

    try {
      final requests = await _apiService.getSentContactRequests(widget.userId);
      setState(() {
        _sentRequests = requests.where((r) => r.isPending).toList();
        _loadingSent = false;
      });
    } catch (e) {
      setState(() => _loadingSent = false);
    }
  }

  void _sendContactRequest() async {
    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => _SendRequestDialog(),
    );

    if (result == null) return;

    try {
      await _apiService.sendContactRequest(
        fromUserId: widget.userId,
        toUserId: result['userId']!,
        fromDisplayName: widget.displayName,
        message: result['message'],
      );
      _loadSentRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido de contacto enviado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar: $e')),
        );
      }
    }
  }

  void _acceptRequest(ContactRequest request) async {
    try {
      await _apiService.acceptContactRequest(request.requestId, widget.displayName);
      _loadAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${request.fromDisplayName} aceite como contacto')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao aceitar: $e')),
        );
      }
    }
  }

  void _rejectRequest(ContactRequest request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejeitar Pedido'),
        content: Text('Rejeitar pedido de ${request.fromDisplayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rejeitar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _apiService.rejectContactRequest(request.requestId);
      _loadPendingRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido rejeitado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao rejeitar: $e')),
        );
      }
    }
  }

  void _cancelRequest(ContactRequest request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Pedido'),
        content: Text('Cancelar pedido enviado para ${request.toUserId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancelar Pedido'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _apiService.cancelContactRequest(request.requestId, widget.userId);
      _loadSentRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido cancelado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cancelar: $e')),
        );
      }
    }
  }

  void _removeContact(Contact contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Contacto'),
        content: Text('Remover ${contact.displayName} dos contactos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _apiService.removeContact(widget.userId, contact.contactUserId);
      _loadContacts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contacto removido')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover: $e')),
        );
      }
    }
  }

  void _startChat(Contact contact) async {
    try {
      final room = await _apiService.createDirectMessage(
        widget.userId,
        contact.contactUserId,
      );

      _roomCreated = true;

      if (mounted) {
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar chat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _roomCreated),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Contactos'),
                  if (_contacts.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.blue,
                        child: Text(
                          '${_contacts.length}',
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Recebidos'),
                  if (_pendingRequests.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Text(
                          '${_pendingRequests.length}',
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Enviados'),
                  if (_sentRequests.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.orange,
                        child: Text(
                          '${_sentRequests.length}',
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAll,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContactsTab(),
          _buildPendingTab(),
          _buildSentTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendContactRequest,
        tooltip: 'Enviar Pedido de Contacto',
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildContactsTab() {
    if (_loadingContacts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.contacts_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Nenhum contacto ainda',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Envie pedidos de contacto para iniciar conversas',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _sendContactRequest,
              icon: const Icon(Icons.person_add),
              label: const Text('Enviar Pedido'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadContacts,
      child: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                contact.displayName.isNotEmpty 
                    ? contact.displayName[0].toUpperCase()
                    : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(contact.displayName),
            subtitle: Text(contact.contactUserId),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chat),
                  onPressed: () => _startChat(contact),
                  tooltip: 'Iniciar Chat',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeContact(contact),
                  tooltip: 'Remover',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPendingTab() {
    if (_loadingPending) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pendingRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum pedido pendente',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPendingRequests,
      child: ListView.builder(
        itemCount: _pendingRequests.length,
        itemBuilder: (context, index) {
          final request = _pendingRequests[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Text(
                          request.fromDisplayName.isNotEmpty 
                              ? request.fromDisplayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.fromDisplayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              request.fromUserId,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (request.message != null && request.message!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '"${request.message}"',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => _rejectRequest(request),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Rejeitar'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => _acceptRequest(request),
                        child: const Text('Aceitar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSentTab() {
    if (_loadingSent) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sentRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum pedido enviado',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSentRequests,
      child: ListView.builder(
        itemCount: _sentRequests.length,
        itemBuilder: (context, index) {
          final request = _sentRequests[index];
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.hourglass_empty, color: Colors.white),
            ),
            title: Text(request.toUserId),
            subtitle: Text('Enviado em ${_formatDate(request.sentAt)}'),
            trailing: IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: () => _cancelRequest(request),
              tooltip: 'Cancelar Pedido',
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SendRequestDialog extends StatefulWidget {
  @override
  State<_SendRequestDialog> createState() => _SendRequestDialogState();
}

class _SendRequestDialogState extends State<_SendRequestDialog> {
  final _userIdController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enviar Pedido de Contacto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _userIdController,
            decoration: const InputDecoration(
              labelText: 'ID do Utilizador',
              hintText: 'Ex: user123',
              prefixIcon: Icon(Icons.person),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Mensagem (opcional)',
              hintText: 'Ex: Olá, quero adicionar-te!',
              prefixIcon: Icon(Icons.message),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final userId = _userIdController.text.trim();
            if (userId.isNotEmpty) {
              Navigator.pop(context, {
                'userId': userId,
                'message': _messageController.text.trim().isEmpty 
                    ? null 
                    : _messageController.text.trim(),
              });
            }
          },
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}
