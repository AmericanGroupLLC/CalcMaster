import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/ai_chat_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_text.dart';
import '../../l10n/generated/app_localizations.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send(AiChatProvider chat) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    chat.sendMessage(text).then((_) => _scrollToBottom());
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AiChatProvider(),
      child: Consumer<AiChatProvider>(
        builder: (context, chat, _) {
          return Scaffold(
            backgroundColor: AppColors.bg,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: chat.messages.isEmpty
                        ? _buildEmptyState(chat)
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.lg,
                              vertical: Spacing.md,
                            ),
                            itemCount: chat.messages.length,
                            itemBuilder: (context, index) =>
                                _buildMessage(chat.messages[index]),
                          ),
                  ),
                  if (chat.error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                      child: Text(
                        chat.error!,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  _buildInputBar(chat),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.sm),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Go back',
            icon: const Icon(Icons.chevron_left, color: AppColors.text, size: 28),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.aiChatTitle,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AiChatProvider chat) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentPrimary.withValues(alpha: 0.3),
                    const Color(0xFF5CE0A8).withValues(alpha: 0.3),
                  ],
                ),
                border: Border.all(
                  color: AppColors.accentPrimary.withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.accentPrimary,
                size: 36,
              ),
            ),
            const SizedBox(height: Spacing.xl),
            GlowText(
              'CalcMaster AI',
              glowColor: AppColors.accentPrimary,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              AppLocalizations.of(context)!.aiChatEmpty,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: Spacing.xxl),
            Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip(chat, 'Convert 5 miles to km'),
                _buildSuggestionChip(chat, 'Calculate 15% tip on \$85'),
                _buildSuggestionChip(chat, 'What is compound interest?'),
                _buildSuggestionChip(chat, 'BMI for 70kg, 175cm'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(AiChatProvider chat, String text) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      glowRim: true,
      onTap: () {
        _controller.text = text;
        _send(chat);
      },
      child: Text(
        text,
        style: const TextStyle(color: AppColors.text, fontSize: 13),
      ),
    );
  }

  Widget _buildMessage(ChatMessage msg) {
    final isUser = msg.role == 'user';

    if (msg.isLoading) {
      return Padding(
        padding: const EdgeInsets.only(bottom: Spacing.md),
        child: Row(
          children: [
            GlassCard(
              padding: const EdgeInsets.all(Spacing.md),
              child: SizedBox(
                width: 40,
                child: _TypingIndicator(),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: Spacing.sm, top: 4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.accentPrimary, Color(0xFF5CE0A8)],
                ),
              ),
              child: const Icon(Icons.auto_awesome,
                  color: Colors.white, size: 16),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.accentPrimary.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(Radii.cardThumb),
                  topRight: const Radius.circular(Radii.cardThumb),
                  bottomLeft: Radius.circular(isUser ? Radii.cardThumb : 4),
                  bottomRight: Radius.circular(isUser ? 4 : Radii.cardThumb),
                ),
                border: Border.all(
                  color: isUser
                      ? AppColors.accentPrimary.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: SelectableText(
                msg.content,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildInputBar(AiChatProvider chat) {
    return Container(
      padding: EdgeInsets.only(
        left: Spacing.lg,
        right: Spacing.sm,
        top: Spacing.md,
        bottom: MediaQuery.of(context).padding.bottom + Spacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: const TextStyle(color: AppColors.text, fontSize: 15),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.aiChatHint,
                hintStyle:
                    const TextStyle(color: AppColors.textDim, fontSize: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Radii.pill),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Spacing.lg,
                  vertical: Spacing.md,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(chat),
              maxLines: null,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.accentPrimary, Color(0xFF5CE0A8)],
              ),
            ),
            child: IconButton(
              tooltip: 'Send message',
              icon: chat.isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: chat.isSending ? null : () => _send(chat),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final t = ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
            final y = -4.0 * (1.0 - (2.0 * t - 1.0) * (2.0 * t - 1.0));
            return Transform.translate(
              offset: Offset(0, y),
              child: Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentPrimary.withValues(alpha: 0.4 + 0.6 * t),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
