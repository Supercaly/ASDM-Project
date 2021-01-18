import 'package:aspdm_project/application/bloc/task_form_bloc.dart';
import 'package:aspdm_project/domain/entities/label.dart';
import 'package:aspdm_project/domain/entities/user.dart';
import 'package:aspdm_project/domain/values/unique_id.dart';
import 'package:aspdm_project/domain/values/user_values.dart';
import 'package:aspdm_project/locator.dart';
import 'package:aspdm_project/presentation/widgets/checklist_widget.dart';
import 'package:aspdm_project/presentation/widgets/label_widget.dart';
import 'package:aspdm_project/presentation/widgets/new_task_form_widget.dart';
import 'package:aspdm_project/presentation/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:aspdm_project/services/navigation_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';

class TaskFormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // TODO(#35): Pass the task obtained from arguments to TaskFormBloc
      // Obtain a Task from the NavigationService arguments and pass
      // it to the bloc so he can use it.
      //
      // Note: After #27 this should return a Maybe<Task>.
      create: (context) => TaskFormBloc(null),
      child: TaskFormPageScaffold(),
    );
  }
}

class TaskFormPageScaffold extends StatefulWidget {
  @override
  _TaskFormPageScaffoldState createState() => _TaskFormPageScaffoldState();
}

class _TaskFormPageScaffoldState extends State<TaskFormPageScaffold> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TODO: Change page title depending on mode
        // change the title of task form page depending on the editing
        // mode: display "New Task" if we are creating a new task,
        // "Edit Task" if we are editing an old one.
        title: Text("New Task"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => locator<NavigationService>().pop(),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                if (_formKey.currentState.validate())
                  await context.read<TaskFormBloc>().saveTask();
              }),
        ],
      ),
      body: BlocBuilder<TaskFormBloc, TaskFormState>(
        // TODO: Build only when save changes
        buildWhen: (p, c) => p.isSaving != c.isSaving,
        builder: (context, state) => LoadingOverlay(
          color: Colors.black45,
          isLoading: state.isSaving,
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                NewTaskFormWidget(),
                Card(
                  child: Column(
                    children: [
                      BlocBuilder<TaskFormBloc, TaskFormState>(
                        buildWhen: (p, c) =>
                            p.taskPrimitive.expireDate != c.taskPrimitive.expireDate,
                        builder: (context, state) => ListTile(
                          // TODO: Add a trailing icon that removes the previously selected date
                          leading: Icon(FeatherIcons.calendar),
                          title: (state.taskPrimitive.expireDate != null)
                              ? Text(DateFormat("dd MMM y HH:mm")
                                  .format(state.taskPrimitive.expireDate))
                              : Text("Expiration Date..."),
                          onTap: () async {
                            // TODO: Replace date picker with date-time picker
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate:
                                  state.taskPrimitive.expireDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2030),
                            );
                            if (pickedDate != null &&
                                pickedDate != state.taskPrimitive.expireDate)
                              context
                                  .read<TaskFormBloc>()
                                  .dateChanged(pickedDate);
                          },
                        ),
                      ),
                      BlocBuilder<TaskFormBloc, TaskFormState>(
                        buildWhen: (p, c) => p.taskPrimitive.members != c.taskPrimitive.members,
                        builder: (context, state) => ListTile(
                          leading: Icon(FeatherIcons.users),
                          title: (state.taskPrimitive.members != null)
                              ? Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children: state.taskPrimitive.members
                                      .map((e) => UserAvatar(
                                            user: e,
                                            size: 32.0,
                                          ))
                                      .toList())
                              : Text("Members..."),
                          onTap: () {
                            context.read<TaskFormBloc>().membersChanged([
                              User(UniqueId("user1"), UserName("Jonny"),
                                  EmailAddress("aa@bb.com"), Colors.red),
                              User(UniqueId("user2"), UserName("Lucas"),
                                  EmailAddress("bb@bb.com"), Colors.green),
                              User(UniqueId("user3"), UserName("Michael"),
                                  EmailAddress("cc@bb.com"), Colors.blue),
                            ]);
                          },
                        ),
                      ),
                      BlocBuilder<TaskFormBloc, TaskFormState>(
                        builder: (context, state) => ListTile(
                          leading: Icon(FeatherIcons.tag),
                          title: (state.taskPrimitive.labels != null)
                              ? Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children: state.taskPrimitive.labels
                                      .map((e) => LabelWidget(label: e))
                                      .toList(),
                                )
                              : Text("Labels..."),
                          onTap: () {
                            context.read<TaskFormBloc>().labelsChanged([
                              Label(UniqueId("label 1"), Colors.yellow,
                                  "label 1"),
                              Label(
                                  UniqueId("label 2"), Colors.green, "label 1"),
                              Label(
                                  UniqueId("label 3"), Colors.blue, "label 1"),
                            ]);
                          },
                        ),
                      ),
                      ListTile(
                        leading: Icon(FeatherIcons.checkCircle),
                        title: Text("Add checklist..."),
                        onTap: () {
                          context.read<TaskFormBloc>().addChecklist();
                        },
                      )
                    ],
                  ),
                ),
                BlocBuilder<TaskFormBloc, TaskFormState>(
                  buildWhen: (p, s) => p.taskPrimitive.checklists != s.taskPrimitive.checklists,
                  builder: (context, state) => Column(
                    children: state.taskPrimitive.checklists
                        .map((e) => EditChecklist(checklist: e))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}