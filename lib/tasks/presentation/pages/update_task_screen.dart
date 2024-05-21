import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_app/components/widgets.dart';
import 'package:task_manager_app/tasks/data/local/model/task_model.dart';
import 'package:task_manager_app/utils/font_sizes.dart';

import '../../../components/custom_app_bar.dart';
import '../../../utils/color_palette.dart';
import '../../../utils/util.dart';
import '../bloc/tasks_bloc.dart';
import '../../../components/build_text_field.dart';

class UpdateTaskScreen extends StatefulWidget {
  final TaskModel taskModel;

  const UpdateTaskScreen({super.key, required this.taskModel});

  @override
  State<UpdateTaskScreen> createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();

  // CalendarFormat _calendarFormat = CalendarFormat.month;
  // DateTime _focusedDay = DateTime.now();
  // DateTime? _selectedDay;
  // DateTime? _rangeStart;
  // DateTime? _rangeEnd;

  // _onRangeSelected(DateTime? start, DateTime? end, DateTime focusDay) {
  //   setState(() {
  //     _selectedDay = null;
  //     _focusedDay = focusDay;
  //     _rangeStart = start;
  //     _rangeEnd = end;
  //   });
  // }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  void initState() {
    title.text = widget.taskModel.title;
    description.text = widget.taskModel.description;

    // _selectedDay = _focusedDay;
    // _rangeStart = widget.taskModel.startDateTime;
    // _rangeEnd = widget.taskModel.stopDateTime;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
            backgroundColor: kWhiteColor,
            appBar: const CustomAppBar(
              title: '과목 수정하기',
            ),
            body: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).unfocus(),
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: BlocConsumer<TasksBloc, TasksState>(
                        listener: (context, state) {
                      if (state is UpdateTaskFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            getSnackBar(state.error, kRed));
                      }
                      if (state is UpdateTaskSuccess) {
                        Navigator.pop(context);
                      }
                    }, builder: (context, state) {
                      return ListView(
                        children: [
                          // TableCalendar(
                          //   calendarFormat: _calendarFormat,
                          //   startingDayOfWeek: StartingDayOfWeek.monday,
                          //   availableCalendarFormats: const {
                          //     CalendarFormat.month: 'Month',
                          //     CalendarFormat.week: 'Week',
                          //   },
                          //   rangeSelectionMode: RangeSelectionMode.toggledOn,
                          //   focusedDay: _focusedDay,
                          //   firstDay: DateTime.utc(2023, 1, 1),
                          //   lastDay: DateTime.utc(2030, 1, 1),
                          //   onPageChanged: (focusDay) {
                          //     _focusedDay = focusDay;
                          //   },
                          //   selectedDayPredicate: (day) =>
                          //       isSameDay(_selectedDay, day),
                          //   rangeStartDay: _rangeStart,
                          //   rangeEndDay: _rangeEnd,
                          //   onFormatChanged: (format) {
                          //     if (_calendarFormat != format) {
                          //       setState(() {
                          //         _calendarFormat = format;
                          //       });
                          //     }
                          //   },
                          //   onRangeSelected: _onRangeSelected,
                          // ),
                          // const SizedBox(height: 20),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(
                          //       vertical: 10, horizontal: 20),
                          //   decoration: BoxDecoration(
                          //       color: kPrimaryColor.withOpacity(.1),
                          //       borderRadius:
                          //           const BorderRadius.all(Radius.circular(5))),
                          //   child: buildText(
                          //       _rangeStart != null && _rangeEnd != null
                          //           ? '시작일 ${formatDate(dateTime: _rangeStart.toString())} - ${formatDate(dateTime: _rangeEnd.toString())}'
                          //           : '기간을 선택하시오',
                          //       kPrimaryColor,
                          //       textSmall,
                          //       FontWeight.w400,
                          //       TextAlign.start,
                          //       TextOverflow.clip),
                          // ),
                          // const SizedBox(height: 20),
                          buildText(
                              '과목',
                              kBlackColor,
                              textMedium,
                              FontWeight.bold,
                              TextAlign.start,
                              TextOverflow.clip),
                          const SizedBox(
                            height: 10,
                          ),
                          BuildTextField(
                              hint: "과목명",
                              controller: title,
                              inputType: TextInputType.text,
                              fillColor: kWhiteColor,
                              onChange: (value) {}),
                          const SizedBox(
                            height: 20,
                          ),
                          buildText(
                              '메모',
                              kBlackColor,
                              textMedium,
                              FontWeight.bold,
                              TextAlign.start,
                              TextOverflow.clip),
                          const SizedBox(
                            height: 10,
                          ),
                          BuildTextField(
                              hint: "간단한 메모를 입력하시오",
                              controller: description,
                              inputType: TextInputType.multiline,
                              fillColor: kWhiteColor,
                              onChange: (value) {}),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: size.width,
                            child: ElevatedButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      WidgetStateProperty.all<Color>(
                                          Colors.white),
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          kPrimaryColor),
                                  shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10), // Adjust the radius as needed
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  var taskModel = TaskModel(
                                      id: widget.taskModel.id,
                                      title: title.text,
                                      description: description.text,
                                      completed: widget.taskModel.completed,
                                      makeDateTime: widget.taskModel.makeDateTime,
                                      // startDateTime: _rangeStart,
                                      // stopDateTime: _rangeEnd
                                  );
                                  context.read<TasksBloc>().add(
                                      UpdateTaskEvent(taskModel: taskModel));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: buildText(
                                      '수정',
                                      kWhiteColor,
                                      textMedium,
                                      FontWeight.w600,
                                      TextAlign.center,
                                      TextOverflow.clip),
                                )),
                          ),
                        ],
                      );
                    })))));
  }
}
