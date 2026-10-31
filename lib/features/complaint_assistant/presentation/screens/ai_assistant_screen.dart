import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/priority_indicator.dart';

enum MessageSender { user, bot }

class ChatMessage {
  final MessageSender sender;
  final String text;
  final Widget? customWidget;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.text,
    this.customWidget,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AIAssistantScreen extends StatefulWidget {
  final VoidCallback? onComplaintSubmitted;

  const AIAssistantScreen({super.key, this.onComplaintSubmitted});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  bool _isProcessingAI = false;
  bool _isVoiceRecording = false;

  @override
  void initState() {
    super.initState();
    LanguageController().addListener(_onLanguageChanged);
    _addInitialGreeting();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    LanguageController().removeListener(_onLanguageChanged);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addInitialGreeting() {
    _messages.add(
      ChatMessage(
        sender: MessageSender.bot,
        text:
            'வணக்கம்! நான் உங்கள் நம்ம ஊரு AI உதவியாளர். உங்கள் பகுதியில் உள்ள குடிநீர், சாலை, குப்பை, தெருவிளக்கு போன்ற புகார்களை தமிழ் அல்லது ஆங்கிலத்தில் தட்டச்சு செய்யலாம் அல்லது பேசி பதிவு செய்யலாம்.',
      ),
    );
    _messages.add(
      ChatMessage(
        sender: MessageSender.bot,
        text:
            'Hello! You can describe any civic problem using Tamil or English. You can also attach photos or use voice recording.',
      ),
    );
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

  void _handleUserSendMessage(String input) {
    if (input.trim().isEmpty) return;

    final userText = input.trim();
    _textController.clear();

    setState(() {
      _messages.add(ChatMessage(sender: MessageSender.user, text: userText));
      _isProcessingAI = true;
    });
    _scrollToBottom();

    // Call real backend AI Multi-stage pipeline processing
    ApiService().classifyAI(userText).then((aiRes) {
      if (!mounted) return;

      final category = aiRes['predicted_category'] as String? ?? 'other';
      final confidence =
          (aiRes['category_confidence'] as num?)?.toDouble() ?? 0.95;
      final priority = aiRes['predicted_priority'] as String? ?? 'high';
      final dept = aiRes['recommended_department_name'] as String? ??
          'General Administration';
      final summary = aiRes['summary'] as String? ?? 'Civic issue reported.';
      final categoryLabel = category.replaceAll('_', ' ').toUpperCase();

      setState(() {
        _isProcessingAI = false;
        _messages.add(
          ChatMessage(
            sender: MessageSender.bot,
            text:
                'நன்றி! உங்கள் புகாரை Namma Ooru AI ஆய்வு செய்து வகைப்படுத்தியுள்ளது:',
            customWidget: _buildAIClassificationCard(
              userText: userText,
              category: category,
              categoryLabel: categoryLabel,
              department: dept,
              priority: priority,
              confidence: confidence,
              summary: summary,
            ),
          ),
        );
      });
      _scrollToBottom();
    }).catchError((_) {
      if (!mounted) return;
      setState(() => _isProcessingAI = false);
    });
  }

  Widget _buildAIClassificationCard({
    required String userText,
    required String category,
    required String categoryLabel,
    required String department,
    required String priority,
    required double confidence,
    required String summary,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.roundedMd,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        color: AppColors.primary, size: 18),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'AI Classification Result',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: AppSpacing.roundedPill,
                  ),
                  child: Text(
                    '${(confidence * 100).toInt()}% Confidence',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              'Category: $categoryLabel',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Department: $department',
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text('Assessed Priority: ',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                PriorityIndicator(priority: priority),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: AppSpacing.roundedSm,
              ),
              child: Text(
                'AI Summary: $summary',
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Location Confirmation Section
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: AppSpacing.roundedSm,
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.location_on, color: Color(0xFF2563EB), size: 20),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'GPS Location: Anna Nagar 2nd Ave (Ward 102, Zone 5, Chennai)',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E40AF)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Confirm & Submit / சமர்ப்பி',
                    leadingIcon: Icons.check_circle_outline,
                    onPressed: () async {
                      // Submit to real backend
                      final created = await ApiService().createComplaint(
                        title: userText.length > 50
                            ? userText.substring(0, 50)
                            : userText,
                        description: userText,
                        category: category,
                        priority: priority,
                        latitude: 13.0850,
                        longitude: 80.2101,
                        address:
                            'Plot 42, 2nd Avenue, Anna Nagar East, Chennai',
                        wardNumber: 'Ward 102',
                        zone: 'Zone 5',
                      );
                      _showSuccessSubmissionDialog(created.complaintNumber);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () {
                    _messages.add(
                      ChatMessage(
                        sender: MessageSender.bot,
                        text:
                            'தயவுசெய்து சரியான துறை அல்லது விவரத்தை மீண்டும் தட்டச்சு செய்யவும். Please type corrections or change category.',
                      ),
                    );
                    setState(() {});
                    _scrollToBottom();
                  },
                  child: const Text('Edit / திருத்து'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSubmissionDialog([String? complaintNumber]) {
    final ticketNo = complaintNumber ?? 'NOA-2026-00192';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedLg),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.check, color: AppColors.success, size: 40),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'புகார் வெற்றிகரமாக பதிவானது!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const Text(
                'Complaint Submitted Successfully',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: AppSpacing.roundedSm,
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  ticketNo,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'You will receive SMS & Push notifications as the zonal engineer updates the progress.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Track Status / நிலையைக் காண்க',
                onPressed: () {
                  Navigator.of(context).pop();
                  if (widget.onComplaintSubmitted != null) {
                    widget.onComplaintSubmitted!();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: AppSpacing.roundedSm,
              ),
              child: const Icon(Icons.auto_awesome,
                  color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Complaint Assistant',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                Text(
                  'தமிழ் & English Voice / Photo / Text',
                  style:
                      TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear Chat',
            onPressed: () {
              setState(() {
                _messages.clear();
                _addInitialGreeting();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick prompt chips
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              children: [
                _buildQuickChip('🚰 குடிநீர் குழாய் உடைந்துள்ளது'),
                _buildQuickChip('🗑️ குப்பை தேங்கியுள்ளது'),
                _buildQuickChip('💡 தெருவிளக்கு எரியவில்லை'),
                _buildQuickChip('🕳️ சாலை பள்ளம் ஏற்பட்டுள்ளது'),
              ],
            ),
          ),
          const Divider(height: 1),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.sender == MessageSender.user;

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.85,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(AppSpacing.radiusMd),
                        topRight: const Radius.circular(AppSpacing.radiusMd),
                        bottomLeft:
                            Radius.circular(isUser ? AppSpacing.radiusMd : 2),
                        bottomRight:
                            Radius.circular(isUser ? 2 : AppSpacing.radiusMd),
                      ),
                      border:
                          isUser ? null : Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          style: TextStyle(
                            fontSize: 14,
                            color: isUser
                                ? AppColors.textInverse
                                : AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                        if (message.customWidget != null) message.customWidget!,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isProcessingAI)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'AI Analyzing complaint in Tamil & English...',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

          // Input Bar with Mic & Camera
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined,
                        color: AppColors.primary),
                    tooltip: 'Attach Photo / படம் இணைக்கவும்',
                    onPressed: () {
                      _messages.add(
                        ChatMessage(
                          sender: MessageSender.user,
                          text: '[Attached Photo: Road Damage / சாலை படம்]',
                        ),
                      );
                      _handleUserSendMessage(
                          'சாலையில் ஆழமான பள்ளம் ஏற்பட்டுள்ளது. வாகனங்கள் செல்வது சிரமமாக உள்ளது.');
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      _isVoiceRecording ? Icons.mic : Icons.mic_none,
                      color: _isVoiceRecording
                          ? AppColors.error
                          : AppColors.primary,
                    ),
                    tooltip: 'Speak in Tamil or English',
                    onPressed: () {
                      setState(() => _isVoiceRecording = !_isVoiceRecording);
                      if (_isVoiceRecording) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Listening in Tamil / தமிழில் பேசவும்...'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted && _isVoiceRecording) {
                            setState(() => _isVoiceRecording = false);
                            _textController.text =
                                "எங்கள் தெருவில் குடிநீர் குழாய் உடைந்து தண்ணீர் வீணாகிறது";
                          }
                        });
                      }
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Type complaint / புகாரை உள்ளிடவும்...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 8),
                      ),
                      onSubmitted: _handleUserSendMessage,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primary),
                    onPressed: () =>
                        _handleUserSendMessage(_textController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 12)),
        backgroundColor: AppColors.surfaceSubtle,
        side: const BorderSide(color: AppColors.border),
        onPressed: () => _handleUserSendMessage(text),
      ),
    );
  }
}
