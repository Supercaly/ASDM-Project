import 'package:aspdm_project/model/checklist.dart';
import 'package:flutter/material.dart';

/// Widget that displays a single [Checklist].
class DisplayChecklist extends StatefulWidget {
  /// The [Checklist] object to display.
  final Checklist checklist;
  final void Function(int, bool) onItemChange;

  const DisplayChecklist({
    Key key,
    this.checklist,
    this.onItemChange,
  }) : super(key: key);

  @override
  _DisplayChecklistState createState() => _DisplayChecklistState();
}

class _DisplayChecklistState extends State<DisplayChecklist> {
  bool _showItems;

  @override
  void initState() {
    super.initState();

    _showItems = true;
  }

  @override
  Widget build(BuildContext context) {
    final hasItems =
        widget.checklist.items != null && widget.checklist.items.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.check_circle_outline),
              SizedBox(width: 8.0),
              Text(
                widget.checklist.title,
                style: Theme.of(context).textTheme.headline6,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                        _showItems ? Icons.expand_less : Icons.expand_more),
                    onPressed: () {
                      setState(() {
                        _showItems = !_showItems;
                      });
                    },
                  ),
                ),
              ),
            ]),
            SizedBox(height: 8.0),
            LinearProgressIndicator(
              value: _getChecklistProgress(widget.checklist.items),
              backgroundColor: Color(0xFFE5E5E5),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B24A)),
            ),
            SizedBox(height: 8.0),
            if (_showItems && hasItems)
              Column(
                children: widget.checklist.items
                    .mapIndexed((idx, i) => Row(
                          children: [
                            Checkbox(
                              value: i.complete,
                              onChanged: (value) {
                                widget.onItemChange?.call(idx, value);
                              },
                            ),
                            Text(i.item ?? ""),
                          ],
                        ))
                    .toList(),
              )
          ],
        ),
      ),
    );
  }

  double _getChecklistProgress(List<ChecklistItem> items) {
    if (items == null || items.isEmpty) return 0.0;
    final checkedItems = items.where((element) => element.complete);
    if (checkedItems.isEmpty) return 0.0;
    return checkedItems.length / items.length;
  }
}

/// Extension class over [Iterable].
extension MapIndexed<E> on Iterable<E> {
  /// Implements a function that maps every element to
  /// another type using a [transform] function that has
  /// the current element and his index.
  Iterable<R> mapIndexed<R>(R transform(int idx, E e)) sync* {
    int currentIdx = 0;
    for (final element in this) {
      yield transform(currentIdx, element);
      currentIdx++;
    }
  }
}
