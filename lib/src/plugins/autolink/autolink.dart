import 'package:appflowy_editor/appflowy_editor.dart';

RegExp _hrefRegex = RegExp(
  r'https?://(?:www\.)?[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(?:/[^\s]*)?',
);
Future<void> autoLinkCurrentSelection(
  EditorState editorState,
) async {
  var selection = editorState.selection;
  if (selection == null) {
    return;
  }
  // IME
  // single line
  final node = editorState.getNodeAtPath(selection.start.path);
  if (node == null) {
    return;
  }
  autoLinkAtNode(editorState, node);
}

Future<void> autoLinkAtNode(
  EditorState editorState,
  Node node,
) async {
  final transaction = editorState.transaction;

  var paragraph = node.delta!.toPlainText();
  bool commit = false;
  if (_hrefRegex.hasMatch(paragraph)) {
    _hrefRegex.allMatches(paragraph).forEach((match) {
      bool hasUrlAttr = false;
      var slideDelta = node.delta!.slice(match.start, match.end);

      if (slideDelta.isNotEmpty) {
        var attrs = slideDelta.first.attributes;
        if (attrs != null) {
          hasUrlAttr = attrs[AppFlowyRichTextKeys.href] != null;
        }
      }
      var url = match.group(0);
      if (!hasUrlAttr && url != null) {
        transaction.formatText(
          node,
          match.start,
          match.end - match.start,
          {AppFlowyRichTextKeys.href: url},
        );
        commit = true;
      }
    });
  }
  if (commit) {
    await editorState.apply(transaction);
  }
}
