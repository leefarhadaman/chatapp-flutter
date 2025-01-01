import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controller.dart';

// Custom Color Theme
class AppTheme {
  static const primaryColor = Color(0xFF2D3250);
  static const accentColor = Color(0xFF7077A1);
  static const backgroundColor = Color(0xFF1A1B26);
  static const consoleColor = Color(0xFF282A36);
  static const textColor = Color(0xFFF6F6F8);
  static const codeHighlightColor = Color(0xFF50FA7B);
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.put(ChatController());

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'DevFaru Chat',
          style: GoogleFonts.firaCode(
            color: AppTheme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
                  () => ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  final isUserMessage = index % 2 == 0;
                  final isCodeMessage = message.trim().startsWith('```') &&
                      message.trim().endsWith('```');

                  return MessageContainer(
                    message: message,
                    isUserMessage: isUserMessage,
                    isCodeMessage: isCodeMessage,
                  );
                },
              ),
            ),
          ),
          _buildInputArea(controller),
        ],
      ),
    );
  }

  Widget _buildInputArea(ChatController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.consoleColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentColor, width: 1),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.accentColor,
                    size: 20,
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
                      style: GoogleFonts.firaCode(
                        color: AppTheme.textColor,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(
                          color: AppTheme.textColor.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.code, color: AppTheme.accentColor),
                    onPressed: () {
                      final currentText = controller.messageController.text;
                      if (!currentText.startsWith('```')) {
                        controller.messageController.text = '```\n$currentText\n```';
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildSendButton(controller),
        ],
      ),
    );
  }

  Widget _buildSendButton(ChatController controller) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.accentColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.send, color: AppTheme.textColor),
        onPressed: controller.sendMessage,
      ),
    );
  }
}

class MessageContainer extends StatelessWidget {
  final String message;
  final bool isUserMessage;
  final bool isCodeMessage;

  const MessageContainer({
    super.key,
    required this.message,
    required this.isUserMessage,
    required this.isCodeMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment:
          isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUserMessage ? Icons.person : Icons.computer,
                  size: 16,
                  color: AppTheme.accentColor,
                ),
                const SizedBox(width: 8),
                Text(
                  isUserMessage ? 'You' : 'Assistant',
                  style: GoogleFonts.firaCode(
                    color: AppTheme.accentColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            isCodeMessage
                ? _buildCodeConsole()
                : _buildRegularMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildRegularMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUserMessage ? AppTheme.primaryColor : AppTheme.accentColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.firaCode(
                color: AppTheme.textColor,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: AppTheme.textColor),
            onPressed: () => _copyToClipboard(message),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeConsole() {
    final codeContent = message.trim().replaceAll('```', '').trim();
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.consoleColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildConsoleHeader(),
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              codeContent,
              style: GoogleFonts.firaCode(
                color: AppTheme.codeHighlightColor,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsoleHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildDot(Colors.red),
              const SizedBox(width: 6),
              _buildDot(Colors.yellow),
              const SizedBox(width: 6),
              _buildDot(Colors.green),
            ],
          ),
          Row(
            children: [
              Text(
                'CODE',
                style: GoogleFonts.firaCode(
                  color: AppTheme.textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.copy,
                  size: 16,
                  color: AppTheme.textColor,
                ),
                onPressed: () => _copyToClipboard(message.trim().replaceAll('```', '').trim()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      'Message copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.accentColor,
      colorText: AppTheme.textColor,
      duration: const Duration(seconds: 2),
    );
  }
}
