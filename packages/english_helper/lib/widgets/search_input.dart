import 'package:flutter/material.dart';

class SearchInput extends StatefulWidget {
  late final TextEditingController wordController;
  final Function()? onSearch;

  SearchInput({TextEditingController? wordController, this.onSearch, super.key})
    : wordController = wordController ?? TextEditingController();

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focusNode.hasFocus
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.wordController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.text_fields,
                    color: _focusNode.hasFocus
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 24,
                  ),
                  hintText: 'Enter word...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
                cursorColor: theme.colorScheme.primary,
                onSubmitted: (_) async => await widget.onSearch?.call(),
              ),
            ),
            SizedBox(
              width: 44,
              height: 44,
              child: IconButton(
                onPressed: widget.onSearch?.call,
                icon: const Icon(Icons.search_rounded, size: 24),
                style: IconButton.styleFrom(
                  foregroundColor: _focusNode.hasFocus
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  animationDuration: Duration.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
