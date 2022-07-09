import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo/shared/components/components.dart';
import 'package:todo/shared/cubit/cubit.dart';
import 'package:todo/shared/cubit/states.dart';

class ScreenLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  //   createDatabase();
  // }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
          listener: (BuildContext context, AppStates state) {
        if (state is AppInsertDatabaseState) {
          Navigator.pop(context);
        }
      }, builder: (BuildContext context, AppStates state) {
        AppCubit cubit = AppCubit.get(context);
        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            title: Text(cubit.titles[cubit.currentIndex]),
          ),
          body: ConditionalBuilder(
            condition: state is! AppGetDatabaseLoadingState,
            builder: (context) => cubit.screens[cubit.currentIndex],
            fallback: (context) =>
                const Center(child: CircularProgressIndicator()),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (cubit.isBottomSheetShown) {
                if (formKey.currentState!.validate()) {
                  cubit.insertDatabase(
                    title: titleController.text,
                    date: dateController.text,
                    time: timeController.text,
                  );
                  // insertDatabase(
                  //   title: titleController.text,
                  //   date: dateController.text,
                  //   time: timeController.text,
                  // )
                  //     .then((value) {
                  //   getDataFromDatabase(database).then((value) {
                  //     Navigator.pop(context);
                  //
                  //     // setState(() {
                  //     //   fabIcon = Icons.edit;
                  //     //   tasks = value;
                  //     //   isBottomSheetShown = false;
                  //     // });
                  //   });
                  // });
                }
              } else {
                scaffoldKey.currentState!
                    .showBottomSheet(
                      elevation: 20.0,
                      (context) => Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              defaultFormField(
                                controller: titleController,
                                type: TextInputType.text,
                                label: 'Task Title',
                                prefix: Icons.title,
                                validate: (String value) {
                                  if (value.isEmpty) {
                                    return 'title must not be empty';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 15.0,
                              ),
                              defaultFormField(
                                controller: timeController,
                                type: TextInputType.datetime,
                                label: 'Task Time',
                                prefix: Icons.watch_later_outlined,
                                validate: (String value) {
                                  if (value.isEmpty) {
                                    return 'time must not be empty';
                                  }
                                  return null;
                                },
                                onTap: () {
                                  showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  ).then((value) {
                                    timeController.text =
                                        value!.format(context).toString();
                                  }).catchError((error) {});
                                },
                              ),
                              const SizedBox(
                                height: 15.0,
                              ),
                              defaultFormField(
                                controller: dateController,
                                type: TextInputType.datetime,
                                label: 'Task date',
                                prefix: Icons.calendar_today,
                                validate: (String value) {
                                  if (value.isEmpty) {
                                    return 'date must not be empty';
                                  }
                                  return null;
                                },
                                onTap: () {
                                  showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.parse('2023-07-01'),
                                  ).then(
                                    (value) {
                                      dateController.text =
                                          DateFormat.yMMMd().format(value!);
                                    },
                                  ).catchError((error) {
                                    print(error);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .closed
                    .then((value) {
                  cubit.changeBottomSheetState(
                    isShow: false,
                    icon: Icons.edit,
                  );
                  //isBottomSheetShown = false;
                  // setState(() {
                  //   fabIcon = Icons.edit;
                  // });
                });
                cubit.changeBottomSheetState(
                  isShow: true,
                  icon: Icons.add,
                );
                //isBottomSheetShown = true;
                // setState(() {
                //   fabIcon = Icons.add;
                // });
              }
            },
            child: Icon(cubit.fabIcon),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: cubit.currentIndex,
            onTap: (index) {
              cubit.changeIndex(index);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.menu),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle_outline),
                label: 'Done',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.archive_outlined),
                label: 'Archive',
              ),
            ],
          ),
        );
      }),
    );
  }
}
