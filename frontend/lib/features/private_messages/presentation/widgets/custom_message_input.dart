import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomMessageInput extends StatefulWidget {
  final TextEditingController contentController;
  final String? recipientUsername;
  final VoidCallback onSendMessage;
  final VoidCallback? onEditMessage;
  final bool isEditing;
  final bool readOnly;

  const CustomMessageInput({
    super.key,
    required this.contentController,
    required this.recipientUsername,
    required this.onSendMessage,
    this.onEditMessage,
    this.isEditing = false,
    this.readOnly = false,
  });

  @override
  CustomMessageInputState createState() => CustomMessageInputState();
}

class CustomMessageInputState extends State<CustomMessageInput> {
  late final FocusNode _focusNode;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(
      onKeyEvent: (FocusNode node, KeyEvent evt) {
        if (!HardwareKeyboard.instance.isShiftPressed &&
            evt.logicalKey == LogicalKeyboardKey.enter) {
          if (evt is KeyDownEvent &&
              widget.contentController.text.trim().isNotEmpty) {
            widget.isEditing
                ? widget.onEditMessage?.call()
                : widget.onSendMessage();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: widget.readOnly,
      controller: widget.contentController,
      focusNode: _focusNode,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      maxLines: null,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        labelText: widget.isEditing ? 'Edit Message' : null,
        hintText:
            'Reply to ${widget.recipientUsername ?? AppLocalizations.of(context)!.unknown}',
        suffixIcon: IconButton(
          icon: Icon(
            Icons.send,
            color: widget.contentController.text.trim().isNotEmpty
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).hintColor,
          ),
          onPressed: widget.contentController.text.trim().isNotEmpty
              ? () {
                  widget.isEditing
                      ? widget.onEditMessage?.call()
                      : widget.onSendMessage();
                }
              : null,
        ),
      ),
    );
  }
}
