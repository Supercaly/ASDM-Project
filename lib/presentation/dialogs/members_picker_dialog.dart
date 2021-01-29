import 'package:aspdm_project/application/bloc/members_bloc.dart';
import 'package:aspdm_project/core/ilist.dart';
import 'package:aspdm_project/domain/entities/user.dart';
import 'package:aspdm_project/domain/repositories/members_repository.dart';
import 'package:aspdm_project/locator.dart';
import 'package:aspdm_project/presentation/widgets/members_picker_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aspdm_project/services/navigation_service.dart';

/// Display a dialog that picks the members.
/// Passing an existing [List] of [members] to mark them as already selected.
/// Returns a [List] of all the selected [User]s.
Future<IList<User>> showMembersPickerDialog(
    BuildContext context, IList<User> members) {
  return showDialog(
    context: context,
    builder: (context) => MembersPickerDialog(members: members),
  );
}

/// Widget that display a dialog that picks members
class MembersPickerDialog extends StatefulWidget {
  final IList<User> members;

  MembersPickerDialog({Key key, this.members}) : super(key: key);

  @override
  _MembersPickerDialogState createState() => _MembersPickerDialogState();
}

class _MembersPickerDialogState extends State<MembersPickerDialog>
    with TickerProviderStateMixin {
  Set<User> _selected;

  @override
  void initState() {
    super.initState();

    // TODO: Fix this in #65
    if (widget.members != null && widget.members.isNotEmpty)
      _selected = Set<User>.from(widget.members.asList());
    else
      _selected = Set<User>.identity();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(40.0),
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
      title: Text("Select Members"),
      content: BlocProvider<MembersBloc>(
        create: (context) => MembersBloc(locator<MembersRepository>())..fetch(),
        child: BlocBuilder<MembersBloc, MembersState>(
          builder: (context, state) {
            Widget contentWidget;

            if (state.isLoading)
              contentWidget = ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 200.0,
                  maxWidth: 300.0,
                ),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            else if (state.hasError)
              contentWidget = ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 200.0,
                  maxWidth: 300.0,
                ),
                child: Center(
                  child: Text("No member to display!"),
                ),
              );
            else
              contentWidget = SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 800.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: state.members
                        .map(
                          (e) => MembersPickerItemWidget(
                            member: e,
                            selected: _selected.contains(e),
                            onSelected: (selected) => setState(() {
                              if (selected)
                                _selected.add(e);
                              else
                                _selected.remove(e);
                            }),
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
            return AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 300),
              child: contentWidget,
            );
          },
        ),
      ),
      actions: [
        TextButton(
          child: Text("SAVE"),
          onPressed: () {
            locator<NavigationService>().pop(
              result: IList.from(_selected.toList(growable: false)),
            );
          },
        ),
      ],
    );
  }
}
