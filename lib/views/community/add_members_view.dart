import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/viewmodels/community/group_members_viewmodel.dart';
import 'package:desilynks/widgets/custom_text_field.dart';

class AddMembersView extends StatelessWidget {
  final Map<String, dynamic>? group;

  const AddMembersView({super.key, this.group});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GroupMembersViewModel>();
    final filteredPeople = vm.filteredSuggestedPeople;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Bar (Back, Title, Done)
            _buildHeader(context),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Search Bar
                    _buildSearchBar(vm),
                    const SizedBox(height: 16),

                    // 3. Selection Banner
                    if (vm.selectedAddMemberNames.isNotEmpty) ...[
                      _buildSelectionBanner(vm),
                      const SizedBox(height: 20),
                    ],

                    // 4. Suggested Section Label
                    const Text(
                      'SUGGESTED',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate400,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 5. Suggested People List Cards or Empty State
                    if (filteredPeople.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 36.0),
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                AppIcons.personSvg,
                                height: 36,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.slate400,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                vm.addMemberSearchQuery.isNotEmpty
                                    ? 'No members matching "${vm.addMemberSearchQuery}"'
                                    : 'No members to suggest',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.slate500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...filteredPeople.map((person) {
                        final name = person['name']!;
                        final isSelected = vm.selectedAddMemberNames.contains(
                          name,
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
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
                                    color: AppColors.vibrantBlue.withValues(
                                      alpha: 0.6,
                                    ),
                                    width: 1.5,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      (person['imageUrl'] != null &&
                                          person['imageUrl']!.isNotEmpty)
                                      ? NetworkImage(person['imageUrl']!)
                                      : null,
                                  child:
                                      (person['imageUrl'] == null ||
                                          person['imageUrl']!.isEmpty)
                                      ? SvgPicture.asset(
                                          AppIcons.personSvg,
                                          height: 18,
                                          colorFilter: const ColorFilter.mode(
                                            AppColors.slate400,
                                            BlendMode.srcIn,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Name
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.slate800,
                                  ),
                                ),
                              ),

                              // Add / Added Toggle Button
                              ElevatedButton(
                                onPressed: () =>
                                    vm.toggleAddMemberSelection(name),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected
                                      ? AppColors.vibrantBlue
                                      : AppColors.vibrantBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  minimumSize: const Size(60, 32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  isSelected ? 'Add' : 'Add',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),

            // 6. Bottom Add Selected Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0052FF), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      final count = vm.selectedAddMemberNames.length;
                      vm.resetAddMembers();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '$count member(s) added successfully!',
                          ),
                          backgroundColor: AppColors.vibrantBlue,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Add Selected (${vm.selectedAddMemberNames.length})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final vm = context.read<GroupMembersViewModel>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  AppIcons.arrowBackSvg,
                  colorFilter: const ColorFilter.mode(
                    AppColors.slate800,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),

          // Centered Title
          const Expanded(
            child: Text(
              'Add Members',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
          ),

          // Right Done Button
          TextButton(
            onPressed: () {
              if (vm.selectedAddMemberNames.isNotEmpty) {
                final count = vm.selectedAddMemberNames.length;
                vm.resetAddMembers();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$count member(s) added successfully!',
                    ),
                    backgroundColor: AppColors.vibrantBlue,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Done',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.vibrantBlue,
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
        controller: vm.addMemberSearchController,
        onChanged: vm.setAddMemberSearchQuery,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius24),
        hintText: 'Search People......',
        maxLines: 1,
        fillColor: const Color(0xFF9CA3AF).withValues(alpha: 0.12),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 15, right: 5),
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

  Widget _buildSelectionBanner(GroupMembersViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${vm.selectedAddMemberNames.length} People Selected',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.vibrantBlue,
            ),
          ),
          GestureDetector(
            onTap: vm.clearSelectedAddMembers,
            child: const Text(
              'Clear',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.vibrantBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
