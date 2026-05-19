import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/data/communication/contacts_service.dart';
import 'package:aula_extra/core/data/communication/dtos/contact_user_summary_dto.dart';
import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/features/aluno/chats/constants/chats_constants.dart';
import 'package:aula_extra/features/aluno/chats/models/chat_bootstrap_args.dart';
import 'package:aula_extra/features/aluno/chats/pages/chat_mobile_conversation_screen.dart';
import 'package:aula_extra/features/aluno/chats/widgets/chats_mobile_conversation_tile.dart';
import 'package:aula_extra/features/aluno/chats/widgets/chats_mobile_intro.dart';
import 'package:aula_extra/features/aluno/chats/widgets/chats_mobile_search_bar.dart';
import 'package:aula_extra/features/aluno/chats/widgets/chats_card.dart';
import 'package:flutter/material.dart';

class ChatsContentSection extends StatelessWidget {
  const ChatsContentSection({super.key, this.initialChat});

  final ChatBootstrapArgs? initialChat;

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    if (isMobile) {
      return _MobileChatsListSection(initialChat: initialChat);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ChatsConstants.horizontalPadding,
        vertical: ChatsConstants.verticalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AlunoMenuNav(),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 0),
                const Text('Chats', style: ChatsConstants.titleStyle),
                const SizedBox(height: 11.154),
                const Text(
                  'Converse com seus apoios',
                  style: ChatsConstants.subtitleStyle,
                ),
                const SizedBox(height: 44.617),
                SizedBox(
                  height: 836.571,
                  width: double.infinity,
                  child: ChatsCard(initialChat: initialChat),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileChatsListSection extends StatefulWidget {
  const _MobileChatsListSection({this.initialChat});

  final ChatBootstrapArgs? initialChat;

  @override
  State<_MobileChatsListSection> createState() =>
      _MobileChatsListSectionState();
}

class _MobileChatsListSectionState extends State<_MobileChatsListSection> {
  final ContactsService _contactsService = ContactsService();

  String _query = '';
  bool _isLoading = true;
  bool _hasAppliedInitialChat = false;
  bool _isBootstrappingInitialChat = false;
  String? _errorMessage;
  List<ContactUserSummaryDto> _contacts = const <ContactUserSummaryDto>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadContacts());
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final contacts = await _contactsService.getMyContacts();
      if (!mounted) {
        return;
      }
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
      await _bootstrapInitialChatIfNeeded(contacts);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  ContactUserSummaryDto? _findInitialContact(List<ContactUserSummaryDto> contacts) {
    final contactUserId = widget.initialChat?.contactUserId.trim();
    final contactUsername = widget.initialChat?.contactUsername?.trim().toLowerCase();

    for (final contact in contacts) {
      if (contactUserId != null &&
          contactUserId.isNotEmpty &&
          contact.contactUserId.trim().toLowerCase() == contactUserId.toLowerCase()) {
        return contact;
      }
      if (contactUsername != null &&
          contactUsername.isNotEmpty &&
          (contact.username?.trim().toLowerCase() == contactUsername)) {
        return contact;
      }
    }

    return null;
  }

  Future<List<ContactUserSummaryDto>> _createInitialContact() async {
    final contactUserId = widget.initialChat?.contactUserId.trim();
    final contactUsername = widget.initialChat?.contactUsername?.trim();

    if (contactUserId != null && contactUserId.isNotEmpty) {
      try {
        return await _contactsService.addContactByUserId(contactUserId);
      } catch (_) {
        if (contactUsername == null || contactUsername.isEmpty) rethrow;
      }
    }

    if (contactUsername != null && contactUsername.isNotEmpty) {
      await _contactsService.addContactByUsername(contactUsername);
      return _contactsService.acceptInviteByUsername(contactUsername);
    }

    throw Exception('Não foi possível criar o contacto.');
  }

  Future<void> _bootstrapInitialChatIfNeeded(
    List<ContactUserSummaryDto> contacts,
  ) async {
    if (_hasAppliedInitialChat || _isBootstrappingInitialChat) return;
    final initialChat = widget.initialChat;
    if (initialChat == null) {
      _hasAppliedInitialChat = true;
      return;
    }

    _isBootstrappingInitialChat = true;

    try {
      var selected = _findInitialContact(contacts);

      if (selected == null) {
        final updatedContacts = await _createInitialContact();
        if (!mounted) return;
        setState(() {
          _contacts = updatedContacts;
        });
        selected = _findInitialContact(updatedContacts);
      }

      _hasAppliedInitialChat = true;
      if (!mounted || selected == null) return;

      final initialMessage = initialChat.initialMessage?.trim();
      final selectedForConversation =
          ((selected.username?.trim().isNotEmpty ?? false) ||
                  (initialChat.contactUsername?.trim().isEmpty ?? true))
              ? selected
              : ContactUserSummaryDto(
                  contactId: selected.contactId,
                  contactUserId: selected.contactUserId,
                  status: selected.status,
                  username: initialChat.contactUsername?.trim(),
                  displayName: selected.displayName,
                  profileImageUrl: selected.profileImageUrl,
                  lastMessage: selected.lastMessage,
                  lastMessageAt: selected.lastMessageAt,
                );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ChatMobileConversationScreen(
              contact: selectedForConversation,
              initialMessage: initialMessage,
            ),
          ),
        );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      _isBootstrappingInitialChat = false;
    }
  }

  List<ContactUserSummaryDto> get _filteredContacts {
    final normalizedQuery = _query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return _contacts;
    }

    return _contacts
        .where((contact) {
          final displayName = _displayNameFor(contact).toLowerCase();
          final username = (contact.username ?? '').toLowerCase();
          final status = contact.status.toLowerCase();
          return displayName.contains(normalizedQuery) ||
              username.contains(normalizedQuery) ||
              status.contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  String _displayNameFor(ContactUserSummaryDto contact) {
    final displayName = contact.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final username = contact.username?.trim();
    if (username != null && username.isNotEmpty) {
      return username;
    }

    return 'Utilizador';
  }

  String _initialsFor(ContactUserSummaryDto contact) {
    final parts = _displayNameFor(contact)
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return 'U';
    }
    if (parts.length == 1) {
      final value = parts.first;
      return value.substring(0, value.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String _subtitleFor(ContactUserSummaryDto contact) {
    final lastMessage = contact.lastMessage?.trim();
    if (lastMessage != null && lastMessage.isNotEmpty) {
      return lastMessage;
    }

    final username = contact.username?.trim();
    if (username != null && username.isNotEmpty) {
      return '@$username';
    }
    return 'Toque para abrir a conversa';
  }

  _StatusPresentation _statusPresentation(String status) {
    final normalizedStatus = status.trim().toLowerCase();
    switch (normalizedStatus) {
      case 'accepted':
        return const _StatusPresentation(
          label: 'Ativo',
          backgroundColor: Color(0xFFE8FFF3),
          textColor: ChatsConstants.mobileSuccessColor,
        );
      case 'pending':
        return const _StatusPresentation(
          label: 'Pendente',
          backgroundColor: Color(0xFFFFF4E5),
          textColor: ChatsConstants.mobilePendingColor,
        );
      case 'blocked':
      case 'rejected':
        return const _StatusPresentation(
          label: 'Indisponível',
          backgroundColor: Color(0xFFFFEAEA),
          textColor: ChatsConstants.mobileDangerColor,
        );
      default:
        return const _StatusPresentation(
          label: 'Conversa',
          backgroundColor: Color(0xFFF2F4F7),
          textColor: ChatsConstants.mobileMutedColor,
        );
    }
  }

  Color _avatarColor(int index) {
    const palette = <Color>[
      Color(0xFFFF6900),
      Color(0xFF2B7FFF),
      Color(0xFF12B76A),
      Color(0xFF7A5AF8),
    ];
    return palette[index % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final filteredContacts = _filteredContacts;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ChatsConstants.mobileHorizontalPadding,
        vertical: ChatsConstants.mobileVerticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ChatsMobileIntro(
            title: 'Chats',
            subtitle: 'Converse com os seus apoios',
          ),
          const SizedBox(height: ChatsConstants.mobileSectionSpacing),
          ChatsMobileSearchBar(
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: ChatsConstants.mobileSectionSpacing),
          const Text(
            'Conversas',
            style: ChatsConstants.mobileSectionTitleStyle,
          ),
          const SizedBox(height: 12),
          if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(height: 12),
          ],
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (filteredContacts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ChatsConstants.mobileSurfaceColor,
                borderRadius: BorderRadius.circular(
                  ChatsConstants.mobileCardRadius,
                ),
                border: Border.all(color: ChatsConstants.mobileBorderColor),
              ),
              child: Text(
                _query.trim().isEmpty
                    ? 'Ainda não tens conversas disponíveis.'
                    : 'Nenhuma conversa corresponde à tua pesquisa.',
                style: ChatsConstants.mobileBodyStyle,
              ),
            )
          else
            ...filteredContacts.asMap().entries.map((entry) {
              final index = entry.key;
              final contact = entry.value;
              final status = _statusPresentation(contact.status);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ChatsMobileConversationTile(
                  initials: _initialsFor(contact),
                  avatarColor: _avatarColor(index),
                  photoUrl: contact.profileImageUrl,
                  title: _displayNameFor(contact),
                  subtitle: _subtitleFor(contact),
                  statusLabel: status.label,
                  statusBackgroundColor: status.backgroundColor,
                  statusTextColor: status.textColor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            ChatMobileConversationScreen(contact: contact),
                      ),
                    );
                  },
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _StatusPresentation {
  const _StatusPresentation({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
}
