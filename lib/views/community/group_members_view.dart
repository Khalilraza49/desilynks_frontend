import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/models/community_enums.dart';
import 'package:desilynks/models/community_group_member_model.dart';
import 'package:desilynks/viewmodels/community/group_members_viewmodel.dart';
import 'package:desilynks/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/app/routes.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class GroupMembersView extends StatelessWidget {
  final Map<String, dynamic>? group;

  const GroupMembersView({super.key, this.group});

  String _extractGroupId(Map<String, dynamic>? data) {
    return data?['id'] as String? ??
        data?['groupId'] as String? ??
        '';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GroupMembersViewModel>();
    final groupId = _extractGroupId(group);

    if (groupId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        vm.initGroupIfNeeded(groupId);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Bar
            _buildHeader(context, groupId),

            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            Expanded(
              child: Builder(
                builder: (context) {
                  if (vm.isLoading && vm.members.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.vibrantBlue,
                        ),
                      ),
                    );
                  }

                  final admins = vm.filteredAdmins;
                  final members = vm.filteredMembers;

                  return RefreshIndicator(
                    color: AppColors.vibrantBlue,
                    onRefresh: () async {
                      if (groupId.isNotEmpty) {
                        await vm.refreshGroup(groupId);
                      }
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 2. Search Bar
                          _buildSearchBar(vm),
                          const SizedBox(height: 20),

                          if (vm.errorMessage != null && vm.members.isEmpty)
                            _buildErrorBanner(vm),

                          // 3. Admins Section
                          if (admins.isNotEmpty) ...[
                            Text(
                              'ADMINS (${admins.length})',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate400,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...admins.map(
                              (admin) => _buildMemberCard(
                                context,
                                admin,
                                vm,
                                groupId,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // 4. Members Section
                          if (members.isNotEmpty) ...[
                            Text(
                              'MEMBERS (${members.length})',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate400,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...members.map(
                              (member) => _buildMemberCard(
                                context,
                                member,
                                vm,
                                groupId,
                              ),
                            ),
                          ],

                          if (admins.isEmpty && members.isEmpty)
                            _buildEmptyState(vm),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String groupId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Back Button with SVG
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppIcons.arrowBackSvg,
                colorFilter: const ColorFilter.mode(
                  AppColors.slate800,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),

          // Centered Title
          const Expanded(
            child: Text(
              'Members',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
          ),

          // Right Plus Button
          GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(
                context,
                AppRoutes.addMembers,
                arguments: group,
              );
              if (context.mounted && groupId.isNotEmpty) {
                context.read<GroupMembersViewModel>().initGroup(groupId);
              }
            },
            child: Container(
              width: 34,
              height: 34,
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                color: AppColors.vibrantBlue,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppIcons.plusSvg,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(GroupMembersViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: CustomTextField(
        controller: vm.membersSearchController,
        onChanged: (val) => vm.setSearchQuery(val),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius24),
        hintText: 'Search Members...',
        maxLines: 1,
        fillColor: AppColors.gray400.withValues(alpha: 0.12),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 15, right: 8),
          child: SvgPicture.asset(
            AppIcons.searchSvg,
            height: AppConstants.iconSize,
            width: AppConstants.iconSize,
            colorFilter: const ColorFilter.mode(
              AppColors.slate400,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    CommunityGroupMemberModel member,
    GroupMembersViewModel vm,
    String groupId,
  ) {
    final bool isOnline = member.isActive;
    final String roleTitle = member.isAdmin
        ? 'Admin'
        : member.isModerator
        ? 'Moderator'
        : 'Member';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // User Avatar
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: member.isAdmin
                    ? AppColors.vibrantBlue
                    : member.isModerator
                    ? const Color(0xFF10B981)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFE2E8F0),
              backgroundImage:
                  member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                  ? NetworkImage(member.avatarUrl!)
                  : null,
              child: member.avatarUrl == null || member.avatarUrl!.isEmpty
                  ? SvgPicture.asset(
                      AppIcons.personSvg,
                      height: 20,
                      width: 20,
                      colorFilter: const ColorFilter.mode(
                        AppColors.slate400,
                        BlendMode.srcIn,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // User Name & Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  roleTitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: member.isAdmin
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: member.isAdmin
                        ? AppColors.vibrantBlue
                        : member.isModerator
                        ? const Color(0xFF10B981)
                        : AppColors.slate400,
                  ),
                ),
              ],
            ),
          ),

          // Right Status Badge or Manage Action
          if (vm.canManageMembers && !member.isAdmin)
            IconButton(
              icon: SvgPicture.asset(
                AppIcons.moreVerticalSvg,
                height: 18,
                width: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.slate400,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () => _showMemberOptionsSheet(
                context,
                member,
                vm,
                groupId,
              ),
            )
          else if (isOnline)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Active',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF16A34A),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showMemberOptionsSheet(
    BuildContext context,
    CommunityGroupMemberModel member,
    GroupMembersViewModel vm,
    String groupId,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: SvgPicture.asset(
                    AppIcons.crownSvg,
                    height: 22,
                    width: 22,
                    colorFilter: const ColorFilter.mode(
                      AppColors.vibrantBlue,
                      BlendMode.srcIn,
                    ),
                  ),
                  title: Text(
                    member.isModerator
                        ? 'Promote to Admin'
                        : 'Promote to Moderator',
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final newRole = member.isModerator
                        ? CommunityGroupMemberRole.ADMIN
                        : CommunityGroupMemberRole.MODERATOR;
                    await vm.updateMemberRole(
                      groupId: groupId,
                      userId: member.userId,
                      role: newRole,
                    );
                  },
                ),
                ListTile(
                  leading: SvgPicture.asset(
                    AppIcons.blockShieldSvg,
                    height: 22,
                    width: 22,
                    colorFilter: const ColorFilter.mode(
                      Colors.orange,
                      BlendMode.srcIn,
                    ),
                  ),
                  title: const Text('Ban Member'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await vm.updateMemberStatus(
                      groupId: groupId,
                      userId: member.userId,
                      status: CommunityGroupMemberStatus.BANNED,
                    );
                  },
                ),
                ListTile(
                  leading: SvgPicture.asset(
                    AppIcons.deleteSvg,
                    height: 22,
                    width: 22,
                    colorFilter: const ColorFilter.mode(
                      Colors.red,
                      BlendMode.srcIn,
                    ),
                  ),
                  title: const Text(
                    'Remove from Group',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await vm.removeMember(
                      groupId: groupId,
                      userId: member.userId,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(GroupMembersViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            SvgPicture.asset(
              AppIcons.pcommunitySvg,
              height: 56,
              width: 56,
              colorFilter: const ColorFilter.mode(
                AppColors.slate300,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              vm.searchQuery.isNotEmpty
                  ? 'No members matching "${vm.searchQuery}"'
                  : 'No group members yet',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.slate500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(GroupMembersViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            AppIcons.errorSvg,
            height: 20,
            width: 20,
            colorFilter: const ColorFilter.mode(
              Colors.redAccent,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              vm.errorMessage ?? 'An error occurred',
              style: const TextStyle(fontSize: 12, color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
