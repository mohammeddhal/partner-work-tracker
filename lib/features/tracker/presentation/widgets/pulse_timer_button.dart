import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../application/tracker_controller.dart';
import '../../domain/work_session_model.dart';

class PulseTimerButton extends ConsumerStatefulWidget {
  final WorkSessionModel? activeSession;
  final bool isLoading;

  const PulseTimerButton({
    super.key,
    required this.activeSession,
    required this.isLoading,
  });

  @override
  ConsumerState<PulseTimerButton> createState() => _PulseTimerButtonState();
}

class _PulseTimerButtonState extends ConsumerState<PulseTimerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    if (widget.activeSession != null) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PulseTimerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeSession != null && !_animController.isAnimating) {
      _animController.repeat(reverse: true);
    } else if (widget.activeSession == null && _animController.isAnimating) {
      _animController.stop();
      _animController.reset();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.activeSession != null;
    final elapsedSeconds = ref.watch(liveElapsedSecondsProvider).value ?? 0;
    final timerString = DateTimeFormatter.formatSecondsToStopwatch(elapsedSeconds);

    final buttonColor = isActive ? AppColors.danger : AppColors.accent;
    final glowColor = isActive ? AppColors.danger.withAlpha(80) : AppColors.accent.withAlpha(60);

    return Column(
      children: [
        // Digital Live Counter (When Active)
        if (isActive) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(20),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.accent.withAlpha(80)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'مدة العمل الحالية: ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  timerString,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: AppColors.accentDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Animated Pulse Action Button
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final scale = isActive ? _pulseAnimation.value : 1.0;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: buttonColor,
                  boxShadow: [
                    BoxShadow(
                      color: glowColor,
                      blurRadius: isActive ? 24 : 12,
                      spreadRadius: isActive ? 6 : 2,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: widget.isLoading
                        ? null
                        : () {
                            if (isActive) {
                              ref
                                  .read(trackerControllerProvider.notifier)
                                  .endWork(context, widget.activeSession!);
                            } else {
                              ref
                                  .read(trackerControllerProvider.notifier)
                                  .startWork(context);
                            }
                          },
                    child: Center(
                      child: widget.isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3,
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isActive
                                      ? Icons.stop_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 64,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isActive
                                      ? AppStrings.endWork
                                      : AppStrings.startWork,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
