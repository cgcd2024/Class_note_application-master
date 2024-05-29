import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:class_note/components/custom_app_bar.dart';
import 'package:class_note/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:class_note/components/build_text_field.dart';
import 'package:class_note/tasks/presentation/pages/upload_voice_screen.dart';
import 'package:class_note/tasks/presentation/widget/task_item_view.dart';
import 'package:class_note/utils/color_palette.dart';
import 'package:class_note/utils/util.dart';
import '../../../components/widgets.dart';
import '../../../routes/pages.dart';
import '../../../utils/font_sizes.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    context.read<TasksBloc>().add(FetchTaskEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        child: ScaffoldMessenger(
            child: Scaffold(
          backgroundColor: kWhiteColor,
          appBar: CustomAppBar(
            title: 'CLASS NOTE',
            showBackArrow: false,
            actionWidgets: [
              PopupMenuButton<int>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 1,
                onSelected: (value) {
                  switch (value) {
                    case 0:
                      {
                        context
                            .read<TasksBloc>()
                            .add(SortTaskEvent(sortOption: 0));
                        break;
                      }
                    case 1:
                      {
                        context
                            .read<TasksBloc>()
                            .add(SortTaskEvent(sortOption: 1));
                        break;
                      }
                    case 2:
                      {
                        context
                            .read<TasksBloc>()
                            .add(SortTaskEvent(sortOption: 2));
                        break;
                      }
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<int>(
                      value: 0,
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/svgs/calender.svg',
                            width: 15,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          buildText(
                              '날짜순 정렬',
                              kBlackColor,
                              textSmall,
                              FontWeight.normal,
                              TextAlign.start,
                              TextOverflow.clip)
                        ],
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 1,
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/svgs/task_checked.svg',
                            width: 15,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          buildText(
                              '완료된 수업',
                              kBlackColor,
                              textSmall,
                              FontWeight.normal,
                              TextAlign.start,
                              TextOverflow.clip)
                        ],
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 2,
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/svgs/task.svg',
                            width: 15,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          buildText(
                              '진행중 수업',
                              kBlackColor,
                              textSmall,
                              FontWeight.normal,
                              TextAlign.start,
                              TextOverflow.clip)
                        ],
                      ),
                    ),
                  ];
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: SvgPicture.asset('assets/svgs/filter.svg'),
                ),
              ),
            ],
          ),
          body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: BlocConsumer<TasksBloc, TasksState>(
                      listener: (context, state) {
                    if (state is LoadTaskFailure) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(getSnackBar(state.error, kRed));
                    }

                    if (state is AddTaskFailure || state is UpdateTaskFailure) {
                      context.read<TasksBloc>().add(FetchTaskEvent());
                    }
                  }, builder: (context, state) {
                    if (state is TasksLoading) {
                      return const Center(
                        child: CupertinoActivityIndicator(),
                      );
                    }

                    if (state is LoadTaskFailure) {
                      return Center(
                        child: buildText(
                            state.error,
                            kBlackColor,
                            textMedium,
                            FontWeight.normal,
                            TextAlign.center,
                            TextOverflow.clip),
                      );
                    }

                    if (state is FetchTasksSuccess) {
                      return state.tasks.isNotEmpty || state.isSearching
                          ? Column(
                              children: [
                                BuildTextField(
                                    hint: "수업 검색하기",
                                    controller: searchController,
                                    inputType: TextInputType.text,
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: kGrey2,
                                    ),
                                    fillColor: kWhiteColor,
                                    onChange: (value) {
                                      context.read<TasksBloc>().add(
                                          SearchTaskEvent(keywords: value));
                                    }),
                                const SizedBox(
                                  height: 20,
                                ),
                                Expanded(
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: state.tasks.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => UploadVoiceScreen(
                                                  // Pass task data to the UploadVoiceScreen
                                                  taskModel: state.tasks[index],
                                                ),
                                              ),
                                            );
                                          },
                                          child: TaskItemView(
                                            taskModel: state.tasks[index],
                                          ),
                                        );
                                      },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const Divider(
                                      color: kGrey3,
                                    );
                                  },
                                ))
                              ],
                            )
                          : Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/svgs/tasks.svg',
                                    height: size.height * .20,
                                    width: size.width,
                                  ),
                                  const SizedBox(
                                    height: 50,
                                  ),
                                  buildText(
                                      '수업 등록하기',
                                      kBlackColor,
                                      textBold,
                                      FontWeight.w600,
                                      TextAlign.center,
                                      TextOverflow.clip),
                                  buildText(
                                      '시간표를 등록하고, 녹음하여 유용한 정보를 받아보세요',
                                      kBlackColor.withOpacity(.5),
                                      textSmall,
                                      FontWeight.normal,
                                      TextAlign.center,
                                      TextOverflow.clip),
                                ],
                              ),
                            );
                    }
                    return Container();
                  }))),
          floatingActionButton: FloatingActionButton(
              child: const Icon(
                Icons.add_circle,
                color: kPrimaryColor,
              ),
              onPressed: () {
                Navigator.pushNamed(context, Pages.createNewTask);
              }),
        )));
  }
}
