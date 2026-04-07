import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/core/theme/appText_styles.dart';
import 'package:unflappable/core/theme/app_colors.dart';
import 'package:unflappable/core/utils/screen_utils.dart';
import 'package:unflappable/features/Home/Provider/home_provider.dart';
import 'package:unflappable/features/Home/Provider/mission_provider.dart';
import 'package:unflappable/features/widgets/Common/buttons.dart';
import 'package:unflappable/features/widgets/Common/helping_appBar.dart';

class NewMissionScreen extends ConsumerWidget {
  const NewMissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const HelpingAppBar(title: 'New Mission'),
            const Expanded(child: _MissionBody()),
            const _MissionBottomButton(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BODY
// ─────────────────────────────────────────────────────────────────────────────

class _MissionBody extends ConsumerStatefulWidget {
  const _MissionBody();

  @override
  ConsumerState<_MissionBody> createState() => _MissionBodyState();
}

class _MissionBodyState extends ConsumerState<_MissionBody> {
  late final TextEditingController _objectiveCtrl;

  // Local lists drive UI rendering immediately on tap
  final List<TextEditingController> _taskCtrls = [];
  final List<FocusNode> _taskFocusNodes = [];

  // Tracks whether each slot has been committed to the provider
  final List<bool> _taskCommitted = [];

  @override
  void initState() {
    super.initState();
    _objectiveCtrl = TextEditingController();
    _objectiveCtrl.addListener(() {
      ref.read(newMissionProvider.notifier).setObjective(_objectiveCtrl.text);
    });
  }

  @override
  void dispose() {
    _objectiveCtrl.dispose();
    for (final c in _taskCtrls) {
      c.dispose();
    }
    for (final f in _taskFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _addTask() {
    // Guard using local list length, not provider state
    if (_taskCtrls.length >= kMaxTasks) return;

    final ctrl = TextEditingController();
    final focus = FocusNode();
    final taskIndex = _taskCtrls.length; // capture index at creation time

    ctrl.addListener(() {
      final committed = _taskCommitted[taskIndex];
      final text = ctrl.text;

      if (!committed && text.trim().isNotEmpty) {
        // First character typed — commit to provider
        _taskCommitted[taskIndex] = true;
        ref.read(newMissionProvider.notifier).addTask(text.trim());
      } else if (committed) {
        // Already committed — keep provider in sync
        // Find actual provider index (only committed tasks are in provider)
        final providerIndex = _committedIndexFor(taskIndex);
        if (providerIndex != -1) {
          ref.read(newMissionProvider.notifier).updateTask(providerIndex, text);
        }
      }
    });

    setState(() {
      _taskCtrls.add(ctrl);
      _taskFocusNodes.add(focus);
      _taskCommitted.add(false); // not yet committed to provider
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focus.requestFocus();
    });
  }

  /// Returns how many slots before [uiIndex] are committed (= provider index).
  int _committedIndexFor(int uiIndex) {
    int count = 0;
    for (int i = 0; i < uiIndex; i++) {
      if (_taskCommitted[i]) count++;
    }
    return _taskCommitted[uiIndex] ? count : -1;
  }

  void _removeTask(int uiIndex) {
    final notifier = ref.read(newMissionProvider.notifier);
    final wasCommitted = _taskCommitted[uiIndex];

    // Find provider index BEFORE mutating local lists
    final providerIndex = _committedIndexFor(uiIndex);

    setState(() {
      _taskCtrls[uiIndex].dispose();
      _taskFocusNodes[uiIndex].dispose();
      _taskCtrls.removeAt(uiIndex);
      _taskFocusNodes.removeAt(uiIndex);
      _taskCommitted.removeAt(uiIndex);
    });

    // Only remove from provider if this slot was committed
    if (wasCommitted && providerIndex != -1) {
      notifier.removeTask(providerIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider only for canSubmit / taskCount display
    ref.watch(newMissionProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtils.authHorizontalMargin,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Mission Objective ──────────────────────────────────────────────
          Text(
            'Mission Objective',
            style: AppTextStyles.headingSM.copyWith(
              color: AppColors.headingText,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: ScreenUtils.vSm),

          TextField(
            controller: _objectiveCtrl,
            maxLines: 2,
            style: AppTextStyles.bodyMD.copyWith(color: AppColors.labelText),
            decoration: InputDecoration(
              hintText: 'e.g. Which features should we prioritize...',
              hintStyle: AppTextStyles.bodyMD.copyWith(
                color: AppColors.bodyText,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: ScreenUtils.md,
                vertical: ScreenUtils.vMd,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.borderGrey),
              ),

              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),

          SizedBox(height: ScreenUtils.vXl),

          // ── Key Tasks ─────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Key Tasks (Max $kMaxTasks)',
                style: AppTextStyles.labelMD.copyWith(
                  color: AppColors.headingText,
                ),
              ),
              // Use local list length for immediate counter update
              Text(
                '${_taskCtrls.length}/$kMaxTasks',
                style: AppTextStyles.labelMD.copyWith(
                  color: AppColors.headingText,
                ),
              ),
            ],
          ),

          SizedBox(height: ScreenUtils.vMd),

          // ── Task Rows — driven by local list, not provider ─────────────────
          ...List.generate(
            _taskCtrls.length, // ← local length, renders immediately on tap
            (i) => _TaskRow(
              index: i,
              controller: _taskCtrls[i],
              focusNode: _taskFocusNodes[i],
              onChanged: (v) {
                // onChanged is handled by the ctrl listener in _addTask,
                // but we keep this for any direct updates if needed
              },
              onRemove: () => _removeTask(i),
            ),
          ),

          // ── Add New Button ─────────────────────────────────────────────────
          if (_taskCtrls.length < kMaxTasks)
            GestureDetector(
              onTap: _addTask,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: ScreenUtils.vSm),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: ScreenUtils.iconSm,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: ScreenUtils.xs),
                    Text(
                      'Add New',
                      style: AppTextStyles.labelMD.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TASK ROW
// ─────────────────────────────────────────────────────────────────────────────

class _TaskRow extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onRemove;

  const _TaskRow({
    required this.index,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtils.vSm),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ScreenUtils.sm),
            decoration: BoxDecoration(
              color: AppColors.borderGrey.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: AppTextStyles.headingSM.copyWith(
                color: AppColors.headingText,
              ),
            ),
          ),
          SizedBox(width: ScreenUtils.sm),
          Expanded(
            child: SizedBox(
              height: ScreenUtils.inputHeight,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                style: AppTextStyles.bodyMD.copyWith(
                  color: AppColors.labelText,
                ),
                decoration: InputDecoration(
                  hintText: 'Task ${index + 1}',
                  hintStyle: AppTextStyles.bodyMD.copyWith(
                    color: AppColors.bodyText,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ScreenUtils.md,
                    vertical: ScreenUtils.vMd,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
                    borderSide: BorderSide(color: AppColors.borderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ScreenUtils.radiusMd),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: ScreenUtils.sm),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: ScreenUtils.iconMd,
              color: AppColors.headingText,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _MissionBottomButton extends ConsumerWidget {
  const _MissionBottomButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newMissionProvider);

    // canSubmit requires non-empty objective AND at least 1 committed task
    final canStart = state.canSubmit;

    return Padding(
      padding: EdgeInsets.only(
        left: ScreenUtils.authHorizontalMargin,
        right: ScreenUtils.authHorizontalMargin,
        bottom: ScreenUtils.vXxl,
        top: ScreenUtils.vMd,
      ),
      child: PrimaryButton(
        label: 'Start Mission',
        isLoading: false,
        onTap: canStart
            ? () {
                final mission = ref
                    .read(newMissionProvider.notifier)
                    .buildMission();
                ref.read(homeProvider.notifier).setMission(mission);
                ref.read(newMissionProvider.notifier).reset();
                context.pop();
              }
            : null,
      ),
    );
  }
}
