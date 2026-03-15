import 'package:flutter/material.dart';
import '../../screens/settings_screen.dart';
import 'voice_search_dialog.dart';

class GoogleSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;
  final Function(bool) onFocusChanged;
  final bool isResultsMode;
  final VoidCallback? onBackFromResults;

  const GoogleSearchBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onFocusChanged,
    this.isResultsMode = false,
    this.onBackFromResults,
  });

  @override
  State<GoogleSearchBar> createState() => _GoogleSearchBarState();
}

class _GoogleSearchBarState extends State<GoogleSearchBar> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    widget.onFocusChanged(_focusNode.hasFocus);
    setState(() {});
  }

  void _onTextChanged() {
    setState(() {});
  }

  bool get _hasText => widget.controller.text.isNotEmpty;
  bool get _isFocused => _focusNode.hasFocus;

  @override
  Widget build(BuildContext context) {
    if (widget.isResultsMode) {
      return _buildResultsBar();
    }
    return _buildNormalBar();
  }

  // ── 通常の検索バー ──
  Widget _buildNormalBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          // 左アイコン: フォーカス時は戻る矢印、通常はメニュー
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                _isFocused ? Icons.arrow_back : Icons.menu,
                key: ValueKey(_isFocused),
                color: Colors.grey[700],
              ),
            ),
            onPressed: () {
              if (_isFocused) {
                widget.controller.clear();
                _focusNode.unfocus();
              }
            },
          ),
          // テキストフィールド
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onSubmitted: widget.onSubmitted,
              decoration: const InputDecoration(
                hintText: '場所を検索',
                border: InputBorder.none,
              ),
            ),
          ),
          // クリアボタン（テキスト入力時にアニメーション表示, 0.15s）
          AnimatedOpacity(
            opacity: _hasText ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: AnimatedScale(
              scale: _hasText ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 150),
              child: _hasText
                  ? IconButton(
                      icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
                      onPressed: () {
                        widget.controller.clear();
                      },
                    )
                  : const SizedBox(width: 0),
            ),
          ),
          // 音声検索ボタン（常に表示）
          IconButton(
            icon: Icon(Icons.mic_none, color: Colors.grey[700]),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const VoiceSearchDialog(),
              );
            },
          ),
          // プロフィールアイコン（フォーカス時は非表示）
          if (!_isFocused) ...[
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()),
                  );
                },
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.orange[300],
                  child: const Text(
                    'R',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }

  // ── 検索結果モードのバー ──
  Widget _buildResultsBar() {
    return GestureDetector(
      onTap: () {
        widget.onBackFromResults?.call();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
              onPressed: widget.onBackFromResults,
            ),
            Expanded(
              child: Text(
                widget.controller.text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.grey[700]),
              onPressed: () {
                widget.controller.clear();
                widget.onBackFromResults?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}
