import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/models/community_enums.dart';
import 'package:desilynks/viewmodels/community/community_viewmodel.dart';
import 'package:desilynks/widgets/custom_text_field.dart';

class CreateGroupView extends StatelessWidget {
  const CreateGroupView({super.key});

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.slate800,
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CommunityViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Bar
            _buildHeader(context),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Cover Photo Section
                    _buildFieldLabel('Cover Photo (Optional)'),
                    _buildCoverPhotoBox(context, vm),
                    const SizedBox(height: 22),

                    // 3. Group Name Field
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFieldLabel('Group Name', isRequired: true),
                        Text(
                          '${vm.createGroupNameController.text.length}/100',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.slate400,
                          ),
                        ),
                      ],
                    ),
                    CustomTextField(
                      controller: vm.createGroupNameController,
                      borderRadius: BorderRadius.circular(12),
                      hintText: 'e.g. Pakistanis in Madrid, Desi Tech Club...',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          AppIcons.pcommunitySvg,
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            AppColors.slate400,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      fillColor: Colors.white,
                      onChanged: (_) => (context as Element).markNeedsBuild(),
                    ),
                    const SizedBox(height: 20),

                    // 4. Group Description Field
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFieldLabel('Group Description', isRequired: true),
                        Text(
                          '${vm.createGroupDescController.text.length}/1000',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.slate400,
                          ),
                        ),
                      ],
                    ),
                    CustomTextField(
                      controller: vm.createGroupDescController,
                      borderRadius: BorderRadius.circular(12),
                      hintText: 'Tell members what this group is about, rules, and who should join...',
                      maxLines: 4,
                      fillColor: Colors.white,
                      onChanged: (_) => (context as Element).markNeedsBuild(),
                    ),
                    const SizedBox(height: 20),

                    // 5. Group Category Field
                    _buildFieldLabel('Category', isRequired: true),
                    Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: vm.createGroupCategory != null
                              ? AppColors.vibrantBlue
                              : const Color(0xFFCBD5E1),
                          width: vm.createGroupCategory != null ? 1.5 : 1.0,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<CommunityGroupCategory>(
                          dropdownColor: Colors.white,
                          value: vm.createGroupCategory,
                          hint: const Text(
                            'Select Group Category...',
                            style: TextStyle(
                              color: AppColors.slate400,
                              fontSize: 14,
                            ),
                          ),
                          isExpanded: true,
                          icon: SvgPicture.asset(
                            AppIcons.arrowDropDownSvg,
                            height: 20,
                            width: 20,
                            colorFilter: const ColorFilter.mode(
                              AppColors.slate400,
                              BlendMode.srcIn,
                            ),
                          ),
                          items: CommunityGroupCategory.values.map((cat) {
                            return DropdownMenuItem<CommunityGroupCategory>(
                              value: cat,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _getCategoryColor(cat),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    cat.displayName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.slate800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: vm.setCreateGroupCategory,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 6. Privacy Field (Two Selectable Cards)
                    _buildFieldLabel('Privacy Setting', isRequired: true),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPrivacyCard(
                            title: 'Public',
                            subtitle: 'Anyone can view & join',
                            iconSvg: AppIcons.globeSvg,
                            isSelected: vm.createGroupPrivacy.isPublic,
                            onTap: () => vm.setCreateGroupPrivacy(CommunityGroupPrivacy.PUBLIC),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPrivacyCard(
                            title: 'Private',
                            subtitle: 'Admin approval required',
                            iconSvg: AppIcons.lockSvg,
                            isSelected: !vm.createGroupPrivacy.isPublic,
                            onTap: () => vm.setCreateGroupPrivacy(CommunityGroupPrivacy.PRIVATE),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 7. Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            AppIcons.infoSvg,
                            height: 18,
                            width: 18,
                            colorFilter: const ColorFilter.mode(
                              AppColors.vibrantBlue,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'As the creator, you will automatically be assigned as Group Admin and can moderate posts and manage group members.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.35,
                                color: Color(0xFF1E40AF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 8. Create Group Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: vm.isCreatingGroup ? null : () => vm.createGroup(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.vibrantBlue,
                          disabledBackgroundColor: AppColors.vibrantBlue.withValues(alpha: 0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: vm.isCreatingGroup
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.group_add_rounded, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Create Group',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(CommunityGroupCategory category) {
    switch (category) {
      case CommunityGroupCategory.FUN:
        return const Color(0xFFF59E0B);
      case CommunityGroupCategory.SPORT:
        return const Color(0xFF10B981);
      case CommunityGroupCategory.EDUCATIONAL:
        return const Color(0xFF6366F1);
      case CommunityGroupCategory.OTHER:
        return const Color(0xFF64748B);
    }
  }

  Widget _buildPrivacyCard({
    required String title,
    required String subtitle,
    required String iconSvg,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.vibrantBlue : const Color(0xFFCBD5E1),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.vibrantBlue.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(
                  iconSvg,
                  height: 20,
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    isSelected ? AppColors.vibrantBlue : AppColors.slate500,
                    BlendMode.srcIn,
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.vibrantBlue : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.vibrantBlue : AppColors.slate300,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.vibrantBlue : AppColors.slate800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.slate500,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              'Create New Group',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
          ),

          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildCoverPhotoBox(BuildContext context, CommunityViewModel vm) {
    final coverPhoto = vm.createGroupCoverPhoto;

    if (coverPhoto != null) {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(coverPhoto, fit: BoxFit.cover),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => vm.pickCreateGroupCoverPhoto(context),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          AppIcons.gallerySvg,
                          height: 16,
                          width: 16,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: vm.removeCreateGroupCoverPhoto,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          AppIcons.crossSmallSvg,
                          height: 16,
                          width: 16,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => vm.pickCreateGroupCoverPhoto(context),
      child: Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.vibrantBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppIcons.gallerySvg,
                height: 26,
                width: 26,
                colorFilter: const ColorFilter.mode(
                  AppColors.vibrantBlue,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add Group Cover Photo',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.slate700,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Upload from Gallery · Recommended: 1200×400',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.slate400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
