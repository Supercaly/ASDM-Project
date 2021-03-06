import 'package:tasky/application/bloc/auth_bloc.dart';
import 'package:tasky/domain/entities/task.dart';
import 'package:flutter/material.dart';
import '../task_info_page.dart';
import 'package:tasky/application/bloc/task_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'display_checklist.dart';

class TaskInfoPageContentMobile extends StatelessWidget {
  final Task task;
  final bool canModify;

  TaskInfoPageContentMobile({
    Key key,
    @required this.task,
    @required this.canModify,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (task != null) HeaderCard(task: task),
        DescriptionCard(task: task),
        if (task?.checklists != null && task.checklists.isNotEmpty)
          Column(
            children: task.checklists
                .map((checklist) => DisplayChecklist(
                    checklist: checklist,
                    onItemChange: canModify
                        ? (item, value) =>
                            context.read<TaskBloc>().completeChecklist(
                                  context
                                      .read<AuthBloc>()
                                      .state
                                      .user
                                      .map((u) => u.id),
                                  checklist.id,
                                  item.id,
                                  value,
                                )
                        : null))
                .asList(),
          ),
        if (task != null) CommentsCard(task: task),
      ],
    );
  }
}
