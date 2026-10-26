import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:desilynks/models/chat_model.dart';
import 'package:desilynks/viewmodels/chat/chat_viewmodel.dart';
import 'package:desilynks/viewmodels/auth/auth_viewmodel.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/views/chat/chat_detail_view.dart';
import 'package:desilynks/widgets/skeleton/skeleton.dart';

/// Messages & Conversations List View using Provider MVVM architecture.
/// Listens to [ChatViewModel] for instant real-time conversation, unread count,
/// online status indicators, and in-app popup notifications.
class ChatView extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const ChatView({super.key, this.onMenuPressed});

  void _confirmDeleteConversation(
    BuildContext parentContext,
    ChatConversationModel chat,
    ChatViewModel viewModel,
  ) {
    showDialog(
      context: parentContext,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Conversation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: AppStrings.fontInter,
          ),
        ),
        content: Text(
          'Are you sure you want to delete the conversation with ${chat.userName}?',
          style: const TextStyle(
            color: Color(0xFF475569),
            fontFamily: AppStrings.fontInter,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(parentContext);
              Navigator.pop(ctx);
              final success = await viewModel.deleteConversation(chat.id);
              messenger.showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    success
                        ? 'Conversation deleted successfully'
                        : 'Failed to delete conversation',
                  ),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChatViewModel>();
    final authViewModel = context.watch<AuthViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authViewModel.isAuthenticated) {
        viewModel.initChatView();
      }
    });

    final conversations = viewModel.conversations;

    if (viewModel.isLoading && conversations.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, viewModel),
              const Expanded(child: ChatSkeleton()),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // // In-App Notification Popup Banner when a new message arrives from outside
            // _buildIncomingNotificationBanner(context, viewModel),

            // 1. Header (Messages Title & Total Unread Count)
            _buildHeader(context, viewModel),

            // 2. Search Messages Bar
            _buildSearchBar(context, viewModel),

            const SizedBox(height: 12),

            // 3. Filter Pills Row (All, Unread, Groups, Archived)
            _buildFilterTabs(context, viewModel),

            const SizedBox(height: 12),

            // 4. Conversation Items List
            Expanded(
              child: _buildConversationList(context, viewModel, conversations),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // In-App Notification Popup Banner
  // ──────────────────────────────────────────────────────────────────────────
  // Widget _buildIncomingNotificationBanner(
  //   BuildContext context,
  //   ChatViewModel viewModel,
  // ) {
  //   final msg = viewModel.incomingNotificationMessage;
  //   if (msg == null) return const SizedBox.shrink();

  //   final isSmall = context.isSmall;
  //   final sender = msg.sender;
  //   final senderName = sender?.fullName ?? 'New Message';
  //   final avatarUrl =
  //       sender?.profilePhotoUrl ??
  //       'https://ui-avatars.com/api/?name=${Uri.encodeComponent(senderName)}&background=0D8ABC&color=fff';

  //   return AnimatedContainer(
  //     duration: const Duration(milliseconds: 300),
  //     margin: EdgeInsets.fromLTRB(isSmall ? 12 : 16, 8, isSmall ? 12 : 16, 4),
  //     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFF0F172A),
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.18),
  //           blurRadius: 16,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         Stack(
  //           clipBehavior: Clip.none,
  //           children: [
  //             CircleAvatar(
  //               radius: 18,
  //               backgroundImage: avatarUrl.startsWith('http')
  //                   ? NetworkImage(avatarUrl)
  //                   : null,
  //               backgroundColor: const Color(0xFF334155),
  //               child: !avatarUrl.startsWith('http')
  //                   ? SvgPicture.asset(
  //                       AppIcons.personSvg,
  //                       width: 18,
  //                       height: 18,
  //                       colorFilter: const ColorFilter.mode(
  //                         Colors.white,
  //                         BlendMode.srcIn,
  //                       ),
  //                     )
  //                   : null,
  //             ),
  //             Positioned(
  //               right: 0,
  //               bottom: 0,
  //               child: Container(
  //                 width: 9,
  //                 height: 9,
  //                 decoration: BoxDecoration(
  //                   color: const Color(0xFF22C55E),
  //                   shape: BoxShape.circle,
  //                   border: Border.all(
  //                     color: const Color(0xFF0F172A),
  //                     width: 1.5,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: InkWell(
  //             onTap: () {
  //               final matchedConv = viewModel.conversations.firstWhere(
  //                 (c) =>
  //                     c.id == msg.conversationId ||
  //                     c.otherParticipant.id == msg.senderId,
  //                 orElse: () => ChatConversationModel(
  //                   id: msg.conversationId,
  //                   otherParticipant:
  //                       sender ??
  //                       ChatParticipantModel(
  //                         id: msg.senderId,
  //                         firstName: senderName,
  //                         lastName: '',
  //                       ),
  //                   updatedAt: DateTime.now(),
  //                   createdAt: DateTime.now(),
  //                 ),
  //               );
  //               viewModel.clearIncomingNotification();
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (_) => ChatDetailView(conversation: matchedConv),
  //                 ),
  //               );
  //             },
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Flexible(
  //                       child: Text(
  //                         senderName,
  //                         style: const TextStyle(
  //                           color: Colors.white,
  //                           fontSize: 13,
  //                           fontWeight: FontWeight.bold,
  //                           fontFamily: AppStrings.fontInter,
  //                         ),
  //                         maxLines: 1,
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                     ),
  //                     const SizedBox(width: 6),
  //                     const Text(
  //                       '• Now',
  //                       style: TextStyle(
  //                         color: Color(0xFF94A3B8),
  //                         fontSize: 11,
  //                         fontFamily: AppStrings.fontInter,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 2),
  //                 Text(
  //                   msg.content,
  //                   style: const TextStyle(
  //                     color: Color(0xFFCBD5E1),
  //                     fontSize: 12,
  //                     fontFamily: AppStrings.fontInter,
  //                   ),
  //                   maxLines: 1,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         IconButton(
  //           icon: SvgPicture.asset(
  //             AppIcons.crossSmallSvg,
  //             width: 18,
  //             height: 18,
  //             colorFilter: const ColorFilter.mode(
  //               Color(0xFF94A3B8),
  //               BlendMode.srcIn,
  //             ),
  //           ),
  //           onPressed: () {
  //             viewModel.clearIncomingNotification();
  //           },
  //           padding: EdgeInsets.zero,
  //           constraints: const BoxConstraints(),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ──────────────────────────────────────────────────────────────────────────
  // 1. Header Area
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, ChatViewModel viewModel) {
    final isSmall = context.isSmall;
    final isLarge = context.isLarge;

    return Padding(
      padding: EdgeInsets.only(
        left: isSmall ? 16 : 20,
        right: isSmall ? 16 : 20,
        top: isSmall ? 12 : 16,
        bottom: isSmall ? 8 : 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Messages',
            style: TextStyle(
              fontSize: isSmall ? 20 : (isLarge ? 26 : 24),
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.5,
              fontFamily: AppStrings.fontInter,
            ),
          ),
          if (onMenuPressed != null)
            GestureDetector(
              onTap: onMenuPressed,
              child: Container(
                width: isSmall ? 36 : 38,
                height: isSmall ? 36 : 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppIcons.menuSvg,
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF475569),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 2. Search Bar
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context, ChatViewModel viewModel) {
    final isSmall = context.isSmall;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 16 : 20),
      child: Container(
        height: isSmall ? 42 : 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomTextField(
          controller: viewModel.searchController,
          hintText: "Search messages...",
          fillColor: Colors.transparent,
          border: InputBorder.none,
          fontSize: isSmall ? 13 : 14,
          prefixIcon: SizedBox(
            width: isSmall ? 40 : 44,
            height: isSmall ? 40 : 44,
            child: Center(
              child: SvgPicture.asset(
                AppIcons.searchSvg,
                width: isSmall ? 20 : 24,
                height: isSmall ? 20 : 24,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF94A3B8),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          onChanged: (query) {
            viewModel.setSearchQuery(query);
          },
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 3. Filter Pills Tabs
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildFilterTabs(BuildContext context, ChatViewModel viewModel) {
    final isSmall = context.isSmall;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 14 : 20),
      child: Row(
        children: [
          _buildFilterPill(context, 'All', viewModel),
          SizedBox(width: isSmall ? 6 : 8),
          _buildFilterPill(
            context,
            'Unread',
            viewModel,
            count: viewModel.totalUnreadCount,
          ),
          SizedBox(width: isSmall ? 6 : 8),
          _buildFilterPill(context, 'Groups', viewModel),
          SizedBox(width: isSmall ? 6 : 8),
          _buildFilterPill(context, 'Archived', viewModel),
        ],
      ),
    );
  }

  Widget _buildFilterPill(
    BuildContext context,
    String label,
    ChatViewModel viewModel, {
    int count = 0,
  }) {
    final bool isSelected = viewModel.selectedTab == label;
    final isSmall = context.isSmall;

    return GestureDetector(
      onTap: () => viewModel.setSelectedTab(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 16,
          vertical: isSmall ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0F172A)
                : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isSmall ? 12 : 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
                fontFamily: AppStrings.fontInter,
              ),
            ),
            if (count > 0 && !isSelected) ...[
              SizedBox(width: isSmall ? 4 : 6),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 5 : 6,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmall ? 9.5 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 4. Conversation Items List
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildConversationList(
    BuildContext context,
    ChatViewModel viewModel,
    List<ChatConversationModel> conversations,
  ) {
    if (viewModel.isLoading && conversations.isEmpty) {
      return const ChatSkeleton();
    }

    final isSmall = context.isSmall;
    final isLoggedIn = context.watch<AuthViewModel>().isAuthenticated;

    return RefreshIndicator(
      backgroundColor: AppColors.backgroundOffWhite,
      color: AppColors.vibrantBlue,
      onRefresh: () async {
        if (isLoggedIn) {
          await viewModel.fetchConversations();
        }
      },
      child: conversations.isEmpty
          ? Center(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppIcons.chatRoundSvg,
                          height: isSmall ? 48 : 56,
                          width: isSmall ? 48 : 56,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF94A3B8),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isLoggedIn
                              ? 'No messages found'
                              : 'Sign in to access your messages',
                          style: TextStyle(
                            fontSize: isSmall ? 14 : 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                            fontFamily: AppStrings.fontInter,
                          ),
                        ),
                        if (!isLoggedIn) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.login);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.vibrantBlue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.only(top: 4, bottom: 20),
              itemCount: conversations.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                color: const Color(0xFFF8FAFC),
                indent: isSmall ? 68 : 86,
              ),
              itemBuilder: (ctx, idx) {
                final chat = conversations[idx];
                return _buildChatItem(context, chat, viewModel);
              },
            ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5. Single Chat Item Tile (Matches Provided UI Screenshot Exactly)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildChatItem(
    BuildContext context,
    ChatConversationModel chat,
    ChatViewModel viewModel,
  ) {
    final bool hasUnread = chat.unreadCount > 0;
    final lastMessageText = chat.lastMessage?.content ?? 'No messages yet';
    final bool isOnline =
        viewModel.isUserOnline(chat.otherParticipant.id) || chat.isOnline;
    final isSmall = context.isSmall;

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatDetailView(conversation: chat)),
        );
        if (context.mounted) {
          viewModel.fetchConversations();
        }
      },
      onLongPress: () {
        _confirmDeleteConversation(context, chat, viewModel);
      },
      highlightColor: const Color(0xFFF1F5F9),
      splashColor: const Color(0xFFF1F5F9),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 14 : 20,
          vertical: isSmall ? 10 : 12,
        ),
        child: Row(
          children: [
            // Left Avatar with Green Online Indicator Dot (matching screenshot)
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: isSmall ? 22 : 26,
                  backgroundImage: chat.avatarUrl.startsWith('http')
                      ? NetworkImage(chat.avatarUrl)
                      : null,
                  backgroundColor: AppColors.slate200,
                  child: !chat.avatarUrl.startsWith('http')
                      ? SvgPicture.asset(
                          AppIcons.personSvg,
                          height: isSmall ? 22 : 26,
                          width: isSmall ? 22 : 26,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF94A3B8),
                            BlendMode.srcIn,
                          ),
                        )
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: isSmall ? 12 : 14,
                      height: isSmall ? 12 : 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: isSmall ? 1.8 : 2.2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: isSmall ? 10 : 14),

            // Middle Column (User Name & Last Message Preview)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.userName,
                    style: TextStyle(
                      fontSize: isSmall ? 14 : 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                      fontFamily: AppStrings.fontInter,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessageText,
                    style: TextStyle(
                      fontSize: isSmall ? 12 : 13,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                      color: hasUnread
                          ? const Color(0xFF334155)
                          : const Color(0xFF64748B),
                      fontFamily: AppStrings.fontInter,
                      fontStyle: chat.lastMessage?.isDeleted == true
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: isSmall ? 8 : 10),

            // Right Column (Timestamp in blue if unread, plus Blue Unread Counter Pill)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.formattedTime,
                  style: TextStyle(
                    fontSize: isSmall ? 11 : 12,
                    fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
                    color: hasUnread
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF94A3B8),
                    fontFamily: AppStrings.fontInter,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isSmall ? 4 : 6),
                if (hasUnread)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: isSmall ? 18 : 20,
                      minHeight: isSmall ? 18 : 20,
                    ),
                    child: Center(
                      child: Text(
                        '${chat.unreadCount}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmall ? 10 : 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(height: isSmall ? 18 : 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
