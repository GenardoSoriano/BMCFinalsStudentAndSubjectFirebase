import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  // ---------------------------------------------------------
  // STEP 1 - USER REGISTRATION
  // ---------------------------------------------------------

  final TextEditingController nameController = TextEditingController();
  final TextEditingController sectionController =
      TextEditingController();
  final TextEditingController courseController =
      TextEditingController();

  // ---------------------------------------------------------
  // STEP 2 - SUBJECT ENROLLMENT
  // ---------------------------------------------------------

  final List<TextEditingController> subjectControllers = [];
  final List<TextEditingController> timeControllers = [];

  int currentStep = 0;

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    // Start with two subjects like the whiteboard.
    addSubject();
  }

  // ---------------------------------------------------------
  // ADD SUBJECT
  // ---------------------------------------------------------

  void addSubject() {
    subjectControllers.add(TextEditingController());
    timeControllers.add(TextEditingController());

    setState(() {});
  }

  // ---------------------------------------------------------
  // REMOVE SUBJECT
  // ---------------------------------------------------------

  void removeSubject(int index) {
    subjectControllers[index].dispose();
    timeControllers[index].dispose();

    subjectControllers.removeAt(index);
    timeControllers.removeAt(index);

    setState(() {});
  }

  // ---------------------------------------------------------
  // SAVE TO FIREBASE
  // ---------------------------------------------------------

  Future<void> saveData() async {
    try {
      // Create subject list
      List<Map<String, dynamic>> subjects = [];

      for (int i = 0; i < subjectControllers.length; i++) {
        subjects.add({
          'subject': subjectControllers[i].text.trim(),
          'time': timeControllers[i].text.trim(),
        });
      }

      // Save everything to Firestore
      await firestore.collection('enrollments').add({
        'name': nameController.text.trim(),
        'section': sectionController.text.trim(),
        'course': courseController.text.trim(),
        'subjects': subjects,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enrollment saved successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the form after saving
      clearForm();

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving data: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ---------------------------------------------------------
  // CLEAR FORM
  // ---------------------------------------------------------

  void clearForm() {
    nameController.clear();
    sectionController.clear();
    courseController.clear();

    for (final controller in subjectControllers) {
      controller.clear();
    }

    for (final controller in timeControllers) {
      controller.clear();
    }

    setState(() {
      currentStep = 0;
    });
  }

  // ---------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------

  @override
  void dispose() {
    nameController.dispose();
    sectionController.dispose();
    courseController.dispose();

    for (final controller in subjectControllers) {
      controller.dispose();
    }

    for (final controller in timeControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  // ---------------------------------------------------------
  // TEXT FIELD
  // ---------------------------------------------------------

  Widget customTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  // ---------------------------------------------------------
  // STEP 1
  // ---------------------------------------------------------

  Widget registrationPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            'User Registration',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          customTextField(
            controller: nameController,
            label: 'Name'
          ),

          const SizedBox(height: 16),

          customTextField(
            controller: sectionController,
            label: 'Section'
          ),

          const SizedBox(height: 16),

          customTextField(
            controller: courseController,
            label: 'Course'
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    sectionController.text.isEmpty ||
                    courseController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please complete the fields.',
                      ),
                    ),
                  );

                  return;
                }

                setState(() {
                  currentStep = 1;
                });
              },
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // STEP 2
  // ---------------------------------------------------------

  Widget subjectEnrollmentPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            'Subject Enrollment',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: subjectControllers.length,
            itemBuilder: (context, index) {

              return Card(
                margin: const EdgeInsets.only(
                  bottom: 15,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [

                          Text(
                            'Subject ${index + 1}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          if (subjectControllers.length > 1)
                            IconButton(
                              onPressed: () {
                                removeSubject(index);
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      customTextField(
                        controller:
                            subjectControllers[index],
                        label: 'Subject'
                      ),

                      const SizedBox(height: 12),

                      customTextField(
                        controller:
                            timeControllers[index],
                        label: 'Time'
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 5),

          OutlinedButton.icon(
            onPressed: addSubject,
            icon: const Icon(Icons.add),
            label: const Text('Add Subject'),
          ),

          const SizedBox(height: 15),

          Row(
            children: [

              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      currentStep = 0;
                    });
                  },
                  child: const Text('Back'),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {

                    bool valid = true;

                    for (int i = 0;
                        i < subjectControllers.length;
                        i++) {

                      if (subjectControllers[i]
                              .text
                              .trim()
                              .isEmpty ||
                          timeControllers[i]
                              .text
                              .trim()
                              .isEmpty) {

                        valid = false;
                      }
                    }

                    if (!valid) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please complete all subjects.',
                          ),
                        ),
                      );

                      return;
                    }

                    setState(() {
                      currentStep = 2;
                    });
                  },
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // STEP 3 - VERIFICATION
  // ---------------------------------------------------------

  Widget verificationPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            'Subject Verification',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          verificationRow(
            'Name',
            nameController.text,
          ),

          verificationRow(
            'Section',
            sectionController.text,
          ),

          verificationRow(
            'Course',
            courseController.text,
          ),

          const SizedBox(height: 20),

          const Text(
            'Subjects',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: subjectControllers.length,
            itemBuilder: (context, index) {

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        'Subject ${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        subjectControllers[index].text,
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Time: ${timeControllers[index].text}',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          Row(
            children: [

              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      currentStep = 1;
                    });
                  },
                  child: const Text('Back'),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(
                  onPressed: saveData,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // VERIFICATION ROW
  // ---------------------------------------------------------

  Widget verificationRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          SizedBox(
            width: 90,
            child: Text(
              '$title:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Enrollment',
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: currentStep == 0
            ? registrationPage()
            : currentStep == 1
                ? subjectEnrollmentPage()
                : verificationPage(),
      ),
    );
  }
}