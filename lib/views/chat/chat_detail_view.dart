import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/core/extensions/context_extensions.dart';
import 'package:desilynks/core/utils/chat_date_utils.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:desilynks/models/chat_model.dart';
import 'package:desilynks/viewmodels/chat/chat_viewmodel.dart';
import 'package:desilynks/models/moderation_models.dart';
import 'package:desilynks/viewmodels/moderation/moderation_viewmodel.dart';
import 'package:desilynks/widgets/report_bottom_sheet.dart';
import 'package:desilynks/app/routes.dart';

/// Active 1-on-1 Chat Detail Screen using Provider MVVM architecture.
/// Reactive to WebSocket real-time messages, typing indicators, read receipts, online status,
/// and interactive offer cards.
class ChatDetailView extends StatelessWidget {
  final ChatConversationModel conversation;

  const ChatDetailView({super.key, required this.conversation});

  void _showDeleteMessageMenu(
    BuildContext context,
    ChatMessageModel msg,
    ChatViewModel viewModel,
  ) {
    final convId = viewModel.activeConversationId ?? conversation.id;
    final isSmall = context.isSmall;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isSmall ? 16 : 24,
            vertical: 24,
          ),
          child: Container(
            padding: EdgeInsets.all(isSmall ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Action Icon Badge
                Container(
                  width: isSmall ? 46 : 52,
                  height: isSmall ? 46 : 52,
                  decoration: BoxDecoration(
                    color: msg.isDeleted
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: msg.isDeleted
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFDBEAFE),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      msg.isDeleted
                          ? AppIcons.deleteSvg
                          : AppIcons.chatRoundSvg,
                      width: isSmall ? 20 : 24,
                      height: isSmall ? 20 : 24,
                      fit: BoxFit.scaleDown,
                      colorFilter: ColorFilter.mode(
                        msg.isDeleted
                            ? const Color(0xFFDC2626)
                            : AppColors.vibrantBlue,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isSmall ? 10 : 14),

                // Title
                Text(
                  'Message Options',
                  style: TextStyle(
                    fontSize: isSmall ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate900,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle
                Text(
                  'Choose an action for this message',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmall ? 12 : 13,
                    color: AppColors.slate500,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
                SizedBox(height: isSmall ? 16 : 20),

                // Copy Text (if not deleted and has content)
                if (!msg.isDeleted && msg.content.trim().isNotEmpty) ...[
                  _buildDeleteActionCard(
                    svg: AppIcons.Copy,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: AppColors.vibrantBlue,
                    title: 'Copy Text',
                    subtitle: 'Copy message text to clipboard',
                    isDestructive: false,
                    onTap: () {
                      Navigator.pop(ctx);
                      Clipboard.setData(ClipboardData(text: msg.content));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Message copied to clipboard'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],

                // Delete for Me
                _buildDeleteActionCard(
                  svg: AppIcons.personSvg,
                  iconBg: const Color(0xFFF1F5F9),
                  iconColor: AppColors.slate700,
                  title: 'Delete for Me',
                  subtitle: 'Removes this message from your chat only',
                  isDestructive: false,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await viewModel.deleteMessage(
                      convId,
                      msg.id,
                      DeleteScope.FOR_ME,
                    );
                  },
                ),

                // Delete for Everyone (if user is sender & not yet deleted)
                if (msg.isMe && !msg.isDeleted) ...[
                  const SizedBox(height: 10),
                  _buildDeleteActionCard(
                    svg: AppIcons.deleteSvg,
                    iconBg: const Color(0xFFFEF2F2),
                    iconColor: const Color(0xFFDC2626),
                    title: 'Delete for Everyone',
                    subtitle: 'Permanently deletes this message for all users',
                    isDestructive: true,
                    onTap: () async {
                      Navigator.pop(ctx);
                      await viewModel.deleteMessage(
                        convId,
                        msg.id,
                        DeleteScope.FOR_EVERYONE,
                      );
                    },
                  ),
                ],

                // Report Message (if message is from other user & not deleted)
                if (!msg.isMe && !msg.isDeleted) ...[
                  const SizedBox(height: 10),
                  _buildDeleteActionCard(
                    svg: AppIcons.warningTriangleSvg,
                    iconBg: const Color(0xFFFEF2F2),
                    iconColor: AppColors.primaryRed,
                    title: 'Report Message',
                    subtitle: 'Report offensive, scam, or abusive message',
                    isDestructive: true,
                    onTap: () {
                      Navigator.pop(ctx);
                      ReportBottomSheet.show(
                        context,
                        targetType: ReportTargetType.message,
                        targetId: msg.id,
                        targetOwnerId: conversation.otherParticipant.id,
                        targetTitle: 'Report Message',
                      );
                    },
                  ),
                ],

                const SizedBox(height: 16),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: isSmall ? 40 : 44,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF8FAFC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: isSmall ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate700,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeleteActionCard({
    required String svg,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDestructive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDestructive
                ? const Color(0xFFFFF1F2)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDestructive
                  ? const Color(0xFFFECDD3)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    svg,
                    width: 18,
                    height: 18,
                    fit: BoxFit.scaleDown,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? const Color(0xFFDC2626)
                            : AppColors.slate900,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.slate500,
                        fontFamily: AppStrings.fontInter,
                      ),
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                AppIcons.arrowForwardBasicSvg,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  isDestructive ? const Color(0xFFF87171) : AppColors.slate400,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChatViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.activeConversationId != conversation.id) {
        viewModel.initDetailView(conversation);
      }
    });

    final activeChat = viewModel.activeConversation ?? conversation;
    final messages = viewModel.activeMessages.isNotEmpty
        ? viewModel.activeMessages
        : activeChat.messages;
    final isTyping = viewModel.isActiveUserTyping;
    final isOnline = viewModel.isActiveUserOnline;

    viewModel.checkAutoScroll(messages.length);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          viewModel.clearActiveConversation();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        // 1. Custom Chat Detail App Bar with Live Online Status
        appBar: _buildAppBar(
          context,
          activeChat,
          isOnline,
          isTyping,
          viewModel,
        ),

        // 2. Chat Body
        body: SafeArea(
          child: Column(
            children: [
              // Loading more older messages indicator
              if (viewModel.isLoadingMore)
                const LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.vibrantBlue,
                  ),
                ),

              // Messages Scroll View
              Expanded(child: _buildMessagesList(context, messages, viewModel)),

              // Message Input Bar with Attachment (+) Button
              _buildInputBar(context, viewModel),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 1. Custom App Bar
  // ──────────────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ChatConversationModel chat,
    bool isOnline,
    bool isTyping,
    ChatViewModel viewModel,
  ) {
    final isSmall = context.isSmall;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: SvgPicture.asset(
          AppIcons.arrowBackBasicSvg,
          width: isSmall ? 18 : 20,
          height: isSmall ? 18 : 20,
          colorFilter: const ColorFilter.mode(
            AppColors.slate900,
            BlendMode.srcIn,
          ),
        ),
        onPressed: () {
          viewModel.clearActiveConversation();
          Navigator.pop(context);
        },
      ),
      titleSpacing: 0,
      title: InkWell(
        onTap: () {
          final otherUserId = chat.otherParticipant.id;
          if (otherUserId.isNotEmpty) {
            Navigator.pushNamed(
              context,
              AppRoutes.publicProfile,
              arguments: otherUserId,
            );
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            // Avatar with Live Green Online Dot
            Stack(
              children: [
                CircleAvatar(
                  radius: isSmall ? 16 : 18,
                  backgroundImage: chat.avatarUrl.startsWith('http')
                      ? NetworkImage(chat.avatarUrl)
                      : null,
                  backgroundColor: AppColors.slate200,
                  child: !chat.avatarUrl.startsWith('http')
                      ? SvgPicture.asset(
                          AppIcons.personSvg,
                          width: isSmall ? 16 : 18,
                          height: isSmall ? 16 : 18,
                          colorFilter: const ColorFilter.mode(
                            AppColors.slate500,
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
                      width: isSmall ? 8 : 10,
                      height: isSmall ? 8 : 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: isSmall ? 8 : 10),

            // User Name & Live Status Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    chat.userName,
                    style: TextStyle(
                      fontSize: isSmall ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                      fontFamily: AppStrings.fontInter,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isTyping && isOnline) ...[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          isTyping
                              ? 'typing...'
                              : (isOnline ? 'Online' : 'Offline'),
                          style: TextStyle(
                            fontSize: isSmall ? 10.5 : 11,
                            color: isTyping
                                ? AppColors.vibrantBlue
                                : (isOnline
                                      ? const Color(0xFF22C55E)
                                      : AppColors.slate400),
                            fontWeight: isTyping
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontFamily: AppStrings.fontInter,
                            fontStyle: isTyping
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Consumer<ModerationViewModel>(
          builder: (context, modVm, _) {
            final otherUserId = chat.otherParticipant.id;
            final isBlocked = modVm.isUserBlocked(otherUserId);
            return Theme(
              data: Theme.of(context).copyWith(
                popupMenuTheme: const PopupMenuThemeData(
                  color: Colors.white,
                  surfaceTintColor: Colors.transparent,
                ),
              ),
              child: PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: SvgPicture.asset(
                  AppIcons.moreVerticalSvg,
                  width: isSmall ? 18 : 20,
                  height: isSmall ? 18 : 20,
                  colorFilter: const ColorFilter.mode(
                    AppColors.slate900,
                    BlendMode.srcIn,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) async {
                  if (value == 'report') {
                    ReportBottomSheet.show(
                      context,
                      targetType: ReportTargetType.user,
                      targetId: otherUserId,
                      targetOwnerId: otherUserId,
                      targetTitle: 'Report ${chat.userName}',
                    );
                  } else if (value == 'block') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text('Block ${chat.userName}?'),
                        content: const Text(
                          "They won't be able to message you, view your profile, or see your posts and comments. You will not see their content either.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: AppColors.slate600),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryRed,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text(
                              'Block',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      final success = await modVm.blockUser(otherUserId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? '${chat.userName} has been blocked.'
                                  : (modVm.errorMessage ??
                                        'Failed to block user.'),
                            ),
                            backgroundColor: success
                                ? AppColors.slate900
                                : AppColors.primaryRed,
                          ),
                        );
                      }
                    }
                  } else if (value == 'unblock') {
                    final success = await modVm.unblockUser(otherUserId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? '${chat.userName} has been unblocked.'
                                : (modVm.errorMessage ??
                                      'Failed to unblock user.'),
                          ),
                          backgroundColor: success
                              ? AppColors.slate900
                              : AppColors.primaryRed,
                        ),
                      );
                    }
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem<String>(
                    value: 'report',
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.moreVerticalSvg,
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primaryRed,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Report User',
                          style: TextStyle(
                            color: AppColors.primaryRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: isBlocked ? 'unblock' : 'block',
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          isBlocked
                              ? AppIcons.blockShieldSvg
                              : AppIcons.blockSvg,
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            AppColors.slate700,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isBlocked ? 'Unblock User' : 'Block User',
                          style: const TextStyle(
                            color: AppColors.slate700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 2. Messages List
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildMessagesList(
    BuildContext context,
    List<ChatMessageModel> messages,
    ChatViewModel viewModel,
  ) {
    final isSmall = context.isSmall;

    if (viewModel.isLoadingMessages && messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.vibrantBlue),
        ),
      );
    }

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppIcons.chatRoundSvg,
              width: isSmall ? 48 : 56,
              height: isSmall ? 48 : 56,
              colorFilter: const ColorFilter.mode(
                AppColors.slate400,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: isSmall ? 14 : 15,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
                fontFamily: AppStrings.fontInter,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Say hello and start chatting!',
              style: TextStyle(
                fontSize: isSmall ? 12 : 13,
                color: Colors.grey.shade400,
                fontFamily: AppStrings.fontInter,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: viewModel.chatScrollController,
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 12 : 16,
        vertical: isSmall ? 8 : 12,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final bool showDateHeader =
            index == 0 ||
            !ChatDateUtils.isSameDay(
              messages[index - 1].createdAt,
              msg.createdAt,
            );

        return Column(
          children: [
            if (showDateHeader) _buildDateChip(context, msg.createdAt),
            _buildMessageBubble(context, msg, viewModel, messages),
          ],
        );
      },
    );
  }

  Widget _buildDateChip(BuildContext context, DateTime dt) {
    final label = ChatDateUtils.formatDateHeader(dt);
    final isSmall = context.isSmall;

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: isSmall ? 8 : 12),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 10 : 14,
          vertical: isSmall ? 4 : 5,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isSmall ? 10.5 : 11.5,
            color: const Color(0xFF475569),
            fontWeight: FontWeight.w600,
            fontFamily: AppStrings.fontInter,
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 3. Message Bubble & Offer Cards
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildMessageBubble(
    BuildContext context,
    ChatMessageModel msg,
    ChatViewModel viewModel,
    List<ChatMessageModel> allMessages,
  ) {
    final isDeleted = msg.isDeleted;
    final isOfferCard = !isDeleted && msg.isOfferMessage;
    final isSmall = context.isSmall;

    // Check if offer has already been accepted or rejected in conversation
    final bool isAccepted = allMessages.any(
      (m) =>
          m.content.toLowerCase().contains('offer accepted') &&
          m.createdAt.isAfter(msg.createdAt),
    );
    final bool isRejected = allMessages.any(
      (m) =>
          m.content.toLowerCase().contains('offer rejected') &&
          m.createdAt.isAfter(msg.createdAt),
    );

    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          _showDeleteMessageMenu(context, msg, viewModel);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.symmetric(
            horizontal: isOfferCard ? (isSmall ? 12 : 16) : (isSmall ? 12 : 14),
            vertical: isOfferCard ? (isSmall ? 10 : 12) : (isSmall ? 8 : 10),
          ),
          constraints: BoxConstraints(
            maxWidth: context.screenWidth * (isSmall ? 0.84 : 0.78),
          ),
          decoration: BoxDecoration(
            color: msg.isMe
                ? (isOfferCard ? Colors.white : AppColors.vibrantBlue)
                : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
              bottomRight: Radius.circular(msg.isMe ? 4 : 16),
            ),
            border: (isOfferCard || !msg.isMe)
                ? Border.all(
                    color: isOfferCard
                        ? const Color(0xFFBFDBFE)
                        : const Color(0xFFE2E8F0),
                    width: isOfferCard ? 1.5 : 1,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: msg.isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // Deleted Message Visual Style
              if (isDeleted)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppIcons.blockShieldAltSvg,
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        msg.isMe ? Colors.white70 : Colors.grey.shade600,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'This message was deleted',
                        style: TextStyle(
                          fontSize: isSmall ? 12 : 13,
                          fontStyle: FontStyle.italic,
                          color: msg.isMe
                              ? Colors.white70
                              : Colors.grey.shade600,
                          fontFamily: AppStrings.fontInter,
                        ),
                      ),
                    ),
                  ],
                )
              else ...[
                // Normal Text or Offer Details
                if (isOfferCard) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: SvgPicture.asset(
                          AppIcons.tickAltSvg,
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF2563EB),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'OFFER DETAILS',
                        style: TextStyle(
                          fontSize: isSmall ? 10 : 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2563EB),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                Text(
                  msg.content,
                  style: TextStyle(
                    fontSize: isSmall ? 13.5 : 14,
                    color: (msg.isMe && !isOfferCard)
                        ? Colors.white
                        : const Color(0xFF1E293B),
                    fontWeight: isOfferCard ? FontWeight.w600 : FontWeight.w400,
                    fontFamily: AppStrings.fontInter,
                  ),
                ),
              ],

              // Interactive Accept / Reject Buttons for Offers
              if (isOfferCard && !msg.isMe) ...[
                const SizedBox(height: 10),
                if (isAccepted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '✓ OFFER ACCEPTED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  )
                else if (isRejected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '✕ OFFER REJECTED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: isSmall ? 6 : 8,
                    runSpacing: 6,
                    children: [
                      ElevatedButton(
                        onPressed: () => viewModel.acceptOffer(msg),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmall ? 10 : 14,
                            vertical: isSmall ? 6 : 7,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Accept Offer',
                          style: TextStyle(
                            fontSize: isSmall ? 11 : 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => viewModel.rejectOffer(msg),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(
                            color: Color(0xFFDC2626),
                            width: 1.2,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmall ? 10 : 14,
                            vertical: isSmall ? 6 : 7,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Reject Offer',
                          style: TextStyle(
                            fontSize: isSmall ? 11 : 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],

              const SizedBox(height: 4),

              // Message Timestamp & Delivery/Read Checkmarks
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ChatDateUtils.formatMessageTime(msg.createdAt),
                    style: TextStyle(
                      fontSize: isSmall ? 9.5 : 10,
                      fontWeight: FontWeight.w500,
                      color: (msg.isMe && !isOfferCard)
                          ? Colors.white.withValues(alpha: 0.75)
                          : const Color(0xFF94A3B8),
                      fontFamily: AppStrings.fontInter,
                    ),
                  ),
                  if (msg.isMe) ...[
                    const SizedBox(width: 4),
                    _buildMessageStatusIcon(
                      msg: msg,
                      viewModel: viewModel,
                      isSmall: isSmall,
                      isOfferCard: isOfferCard,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds message receipt status checkmarks:
  /// - User offline / Sent: Single tick (✓)
  /// - User online / Delivered: Double tick (✓✓)
  /// - User seen / Read: Double blue tick (✓✓)
  Widget _buildMessageStatusIcon({
    required ChatMessageModel msg,
    required ChatViewModel viewModel,
    required bool isSmall,
    required bool isOfferCard,
  }) {
    // 1. Seen/Read: Recipient opened and read the message -> Double Blue Tick
    final bool isRead = msg.status == MessageStatus.READ;

    // 2. Delivered / Recipient Online: Delivered to recipient device or recipient is online -> Double Tick
    final bool isOnlineOrDelivered =
        msg.status == MessageStatus.DELIVERED ||
        viewModel.isActiveUserOnline ||
        viewModel.isRecipientOnlineForConversation(msg.conversationId);

    final String? iconData;
    final Color iconColor;

    if (isRead) {
      // Seen / Read: Double Blue Tick
      iconData = AppIcons.doubletickSvg;
      iconColor = (!isOfferCard)
          ? const Color(
              0xFF38BDF8,
            ) // Bright sky blue that pops on vibrant blue bubble
          : const Color(0xFF0284C7); // Rich cyan-blue on white offer card
    } else if (isOnlineOrDelivered) {
      // User is online / Message delivered: Double Tick (white / grey)
      iconData = AppIcons.doubletickSvg;
      iconColor = (!isOfferCard)
          ? Colors.white.withValues(alpha: 0.85)
          : const Color(0xFF94A3B8);
    } else {
      // User is offline / Message sent: Single Tick (white / grey)
      iconData = AppIcons.doubletickSvg;
      iconColor = (!isOfferCard)
          ? Colors.white.withValues(alpha: 0.65)
          : const Color(0xFF94A3B8);
    }

    return SvgPicture.asset(
      iconData,
      height: isSmall ? 14 : 15,
      width: isSmall ? 14 : 15,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 4. Message Input Bar with Attachment (+) Button
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildInputBar(BuildContext context, ChatViewModel viewModel) {
    final isSmall = context.isSmall;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 10 : 16,
        vertical: isSmall ? 8 : 10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: viewModel.messageController,
              hintText: 'Type a message...',
              fontSize: isSmall ? 13 : 14,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius24),
              onChanged: (text) => viewModel.onInputTextChanged(text),
              onFieldSubmitted: (_) => viewModel.handleSendMessage(),
            ),
          ),
          SizedBox(width: isSmall ? 6 : 8),
          GestureDetector(
            onTap: () => viewModel.handleSendMessage(),
            child: Container(
              width: isSmall ? 36 : 40,
              height: isSmall ? 36 : 40,
              decoration: const BoxDecoration(
                color: AppColors.vibrantBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: isSmall ? 18 : 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
