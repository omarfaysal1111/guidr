// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:guidr/core/theme/app_colors.dart';
import '../bloc/subscription_bloc.dart';
import '../../domain/entities/payment_record.dart';
import 'subscription_screen.dart' show PlanMeta;

// ─── Screen ──────────────────────────────────────────────────────────────────

class PaymentSubmitScreen extends StatefulWidget {
  final dynamic plan; // PlanMeta — kept dynamic to avoid circular import issues

  const PaymentSubmitScreen({super.key, required this.plan});

  @override
  State<PaymentSubmitScreen> createState() => _PaymentSubmitScreenState();
}

class _PaymentSubmitScreenState extends State<PaymentSubmitScreen> {
  String _selectedMethod = 'VODAFONE_CASH';
  XFile? _screenshot;
  bool _submitted = false;

  PlanMeta get _plan => widget.plan as PlanMeta;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state is PaymentSuccess) {
          _showResult(context, state.record);
        }
        if (state is PaymentFailed) {
          _showError(context, state.message);
          setState(() => _submitted = false);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Upgrade to ${_plan.name}',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary),
          ),
        ),
        body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
          builder: (context, state) {
            final loading = state is PaymentSubmitting;
            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  children: [
                    _PlanSummaryCard(plan: _plan),
                    const SizedBox(height: 24),
                    _PaymentInstructions(
                      plan: _plan,
                      selectedMethod: _selectedMethod,
                      onMethodChanged: loading
                          ? null
                          : (m) => setState(() => _selectedMethod = m),
                    ),
                    const SizedBox(height: 24),
                    _ScreenshotUploader(
                      screenshot: _screenshot,
                      enabled: !loading,
                      onPick: _pickScreenshot,
                    ),
                    const SizedBox(height: 16),
                    _DisclaimerNote(),
                  ],
                ),
                // Submit button pinned at bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _SubmitBar(
                    plan: _plan,
                    loading: loading,
                    canSubmit: _screenshot != null && !loading,
                    onSubmit: _submit,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<void> _pickScreenshot() async {
    final picker = ImagePicker();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.photo_library_outlined,
                    color: AppColors.primary, size: 20),
              ),
              title: const Text('Choose from Gallery',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              onTap: () async {
                Navigator.pop(ctx);
                final file = await picker.pickImage(
                    source: ImageSource.gallery, imageQuality: 90);
                if (file != null) setState(() => _screenshot = file);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.camera_alt_outlined,
                    color: AppColors.primary, size: 20),
              ),
              title: const Text('Take a Photo',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              onTap: () async {
                Navigator.pop(ctx);
                final file = await picker.pickImage(
                    source: ImageSource.camera, imageQuality: 90);
                if (file != null) setState(() => _screenshot = file);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_screenshot == null || _submitted) return;
    setState(() => _submitted = true);

    final bytes = await _screenshot!.readAsBytes();
    final price = double.tryParse(
            _plan.price.replaceAll(RegExp(r'[^0-9.]'), '')) ??
        0;

    if (!mounted) return;
    context.read<SubscriptionBloc>().add(SubmitPayment(
          desiredPlan: _plan.key,
          paymentMethod: _selectedMethod,
          transferredAmount: price,
          imageBytes: bytes,
          fileName: _screenshot!.name,
        ));
  }

  void _showResult(BuildContext context, PaymentRecord record) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(
        record: record,
        plan: _plan,
        onDone: () {
          Navigator.of(context).pop(); // close dialog
          Navigator.of(context).pop(); // back to subscription screen
          // Reload subscription status
          context.read<SubscriptionBloc>().add(LoadSubscription());
        },
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}

// ─── Plan summary card ────────────────────────────────────────────────────────

class _PlanSummaryCard extends StatelessWidget {
  final PlanMeta plan;
  const _PlanSummaryCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: plan.gradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: plan.accentColor.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.verified_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                ),
                Text(
                  plan.clientLabel,
                  style: TextStyle(
                      fontSize: 13, color: Colors.white.withOpacity(0.85)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                plan.price,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              ),
              Text(
                plan.duration,
                style: TextStyle(
                    fontSize: 12, color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Payment instructions ─────────────────────────────────────────────────────

class _PaymentInstructions extends StatelessWidget {
  final PlanMeta plan;
  final String selectedMethod;
  final ValueChanged<String>? onMethodChanged;

  const _PaymentInstructions({
    required this.plan,
    required this.selectedMethod,
    this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final price = plan.price.replaceAll(RegExp(r'[^0-9.]'), '');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.payment_rounded,
                      color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Payment Method',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Method toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: _MethodChip(
                    label: 'Vodafone Cash',
                    icon: Icons.phone_android_rounded,
                    color: const Color(0xFFE60000),
                    selected: selectedMethod == 'VODAFONE_CASH',
                    onTap: () => onMethodChanged?.call('VODAFONE_CASH'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MethodChip(
                    label: 'InstaPay',
                    icon: Icons.account_balance_rounded,
                    color: const Color(0xFF0A3D22),
                    selected: selectedMethod == 'INSTAPAY',
                    onTap: () => onMethodChanged?.call('INSTAPAY'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.border),
          // Instructions
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                if (selectedMethod == 'VODAFONE_CASH')
                  _InstructionRow(
                    step: '1',
                    text: 'Open Vodafone Cash app or dial *9#',
                    icon: Icons.phone_rounded,
                  )
                else
                  _InstructionRow(
                    step: '1',
                    text: 'Open your bank app and navigate to InstaPay',
                    icon: Icons.account_balance_rounded,
                  ),
                const SizedBox(height: 10),
                _InstructionRow(
                  step: '2',
                  text: 'Transfer exactly $price EGP to:',
                  icon: Icons.send_rounded,
                ),
                const SizedBox(height: 8),
                _AccountBox(method: selectedMethod),
                const SizedBox(height: 10),
                _InstructionRow(
                  step: '3',
                  text: 'Take a screenshot of the transfer confirmation',
                  icon: Icons.screenshot_monitor_rounded,
                ),
                const SizedBox(height: 10),
                _InstructionRow(
                  step: '4',
                  text: 'Upload the screenshot below and tap Submit',
                  icon: Icons.upload_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  const _MethodChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? color : AppColors.textMuted),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? color : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionRow extends StatelessWidget {
  final String step;
  final String text;
  final IconData icon;

  const _InstructionRow(
      {required this.step, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountBox extends StatelessWidget {
  final String method;
  const _AccountBox({required this.method});

  @override
  Widget build(BuildContext context) {
    final isVF = method == 'VODAFONE_CASH';
    final label = isVF ? 'Vodafone Cash Number' : 'InstaPay Account';
    final value = isVF ? '010 XXXX XXXX' : 'guider@instapay';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label copied'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded,
                size: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── Screenshot uploader ─────────────────────────────────────────────────────

class _ScreenshotUploader extends StatelessWidget {
  final XFile? screenshot;
  final bool enabled;
  final VoidCallback onPick;

  const _ScreenshotUploader({
    required this.screenshot,
    required this.enabled,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.upload_file_rounded,
                      color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Transfer Receipt',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary),
                ),
                const Spacer(),
                if (screenshot != null)
                  TextButton.icon(
                    onPressed: enabled ? onPick : null,
                    icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                    label: const Text('Change',
                        style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: screenshot == null
                ? _UploadPlaceholder(enabled: enabled, onTap: onPick)
                : _ImagePreview(file: screenshot!, enabled: enabled),
          ),
        ],
      ),
    );
  }
}

class _UploadPlaceholder extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _UploadPlaceholder({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1.5,
            // dashed style via a container — simple dotted border
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_photo_alternate_outlined,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tap to upload screenshot',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              const Text(
                'JPG or PNG · Max 20 MB',
                style:
                    TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final XFile file;
  final bool enabled;
  const _ImagePreview({required this.file, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.file(
        File(file.path),
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

// ─── Disclaimer ──────────────────────────────────────────────────────────────

class _DisclaimerNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 16, color: AppColors.warning),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your plan activates automatically once our system verifies the transfer amount from your screenshot.',
              style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF92400E),
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Submit bar ───────────────────────────────────────────────────────────────

class _SubmitBar extends StatelessWidget {
  final PlanMeta plan;
  final bool loading;
  final bool canSubmit;
  final VoidCallback onSubmit;

  const _SubmitBar({
    required this.plan,
    required this.loading,
    required this.canSubmit,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: canSubmit ? onSubmit : null,
          style: FilledButton.styleFrom(
            backgroundColor: plan.accentColor,
            disabledBackgroundColor: AppColors.border,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            textStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          child: loading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : Text(
                  canSubmit
                      ? 'Submit Payment · ${plan.price}'
                      : 'Upload Receipt to Continue',
                ),
        ),
      ),
    );
  }
}

// ─── Result dialog ────────────────────────────────────────────────────────────

class _ResultDialog extends StatelessWidget {
  final PaymentRecord record;
  final PlanMeta plan;
  final VoidCallback onDone;

  const _ResultDialog({
    required this.record,
    required this.plan,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final approved = record.isApproved;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: approved
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                approved
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                size: 40,
                color: approved ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              approved ? 'Payment Verified!' : 'Verification Failed',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              approved
                  ? 'Your ${plan.name} plan is now active. Enjoy training up to ${plan.clientLabel.toLowerCase()}!'
                  : record.reviewNote ?? 'Unable to verify your payment. Please try again with a clearer screenshot.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5),
            ),
            if (approved) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.rocket_launch_rounded,
                        color: AppColors.success, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${plan.name} plan · ${plan.duration} · ${plan.clientLabel}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onDone,
                style: FilledButton.styleFrom(
                  backgroundColor:
                      approved ? AppColors.success : AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                child: Text(approved ? 'Start Training!' : 'Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
