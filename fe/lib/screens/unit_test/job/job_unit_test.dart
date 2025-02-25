import 'package:flutter/material.dart';

import 'package:fireflutter/fireflutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JobUnitTestController {
  late _JobUnitTestState state;
}

class JobUnitTest extends StatefulWidget {
  const JobUnitTest({Key? key, this.controller}) : super(key: key);
  final JobUnitTestController? controller;

  @override
  State<JobUnitTest> createState() => _JobUnitTestState();
}

class _JobUnitTestState extends State<JobUnitTest> with FirestoreMixin, UnitTestMixin {
  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller!.state = this;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        clearLogs();
        runTests();
      },
      child: Text('Job Unit Test'),
    );
  }

  runTests() async {
    await jobInputTest();
    await jobEditSuccess();
  }

  jobInputTest() async {
    final data = JobModel.empty();

    // not logged in
    await FirebaseAuth.instance.signOut();
    dynamic re = await submit(data.edit());
    expect(re == ERROR_EMPTY_UID, "Cannot create job opening without signing in - $re");

    // Logged in, empty data
    await signIn(d);
    re = await submit(data.edit());
    expect(
        re == "ERROR_EMPTY_COMPANY_NAME", "Cannot create job opening without company name - $re");

    // no siNm
    data.companyName = 'ABC Inc.';
    await signIn(d);
    re = await submit(data.edit());
    expect(re == "ERROR_EMPTY_SINM", "Cannot create job opening without siNm location - $re");

    // no sggNm
    data.siNm = 'aa';
    await signIn(d);
    re = await submit(data.edit());
    expect(re == "ERROR_EMPTY_SGGNM", "Cannot create job opening without sggNm location - $re");

    // no detailed address
    data.sggNm = 'aa';
    await signIn(d);
    re = await submit(data.edit());
    expect(
      re == "ERROR_EMPTY_COMPANY_DETAIL_ADDRESS",
      "Cannot create job opening without detailed address - $re",
    );

    // no mobile number
    data.detailAddress = 'aa';
    await signIn(d);
    re = await submit(data.edit());
    expect(
      re == "ERROR_EMPTY_COMPANY_MOBILE_NUMBER",
      "Cannot create job opening without company mobile number - $re",
    );

    // no phone number
    data.mobileNumber = '+23223';
    await signIn(d);
    re = await submit(data.edit());
    expect(
      re == "ERROR_EMPTY_COMPANY_OFFICE_PHONE_NUMBER",
      "Cannot create job opening without company mobile number - $re",
    );

    // no email address
    data.phoneNumber = '+23223';
    await signIn(d);
    re = await submit(data.edit());
    expect(
      re == "ERROR_EMPTY_COMPANY_EMAIL_ADDRESS",
      "Cannot create job opening without company email address - $re",
    );

    // no about us
    data.email = 'a@a.com';
    await signIn(d);
    re = await submit(data.edit());
    expect(
      re == "ERROR_EMPTY_COMPANY_ABOUT_US",
      "Cannot create job opening without company about us - $re",
    );

    // no job category
    data.aboutUs = 'about us';
    await signIn(d);
    re = await submit(data.edit());
    expect(
      re == "ERROR_EMPTY_JOB_CATEGORY",
      "Cannot create job opening without category - $re",
    );

    // no number of working days
    data.category = 'construction';
    await signIn(d);
    re = await submit(data.edit());
    expect(
      re == "ERROR_EMPTY_JOB_WORKING_DAYS",
      "Cannot create job opening without working days specified - $re",
    );

    // no number of working hours
    data.workingDays = 2;
    await signIn(d);
    re = await submit(data.edit());
    expect(
      re == "ERROR_EMPTY_JOB_WORKING_HOURS",
      "Cannot create job opening without working hours specified - $re",
    );

    // no salary
    data.workingHours = 6;
    await signIn(d);
    re = await submit(data.edit());
    expect(
      re == "ERROR_EMPTY_JOB_SALARY",
      "Cannot create job opening without salary specified - $re",
    );

    // no number of hiring
    data.salary = '100k';
    await signIn(d);
    re = await submit(data.edit());
    expect(
      re == "ERROR_EMPTY_JOB_NUMBER_OF_HIRING",
      "Cannot create job opening without number of hiring - $re",
    );

    // no description
    data.numberOfHiring = '5';
    await signIn(d);
    re = await submit(data.edit());
    expect(
      re == "ERROR_EMPTY_JOB_DESCRIPTION",
      "Cannot create job opening without description - $re",
    );

    // no requirement
    data.description = 'some description';
    await signIn(d);
    re = await submit(data.edit());
    expect(
      re == "ERROR_EMPTY_JOB_REQUIREMENT",
      "Cannot create job opening without requirements - $re",
    );

    // no duty
    data.requirement = 'some requirements';
    await signIn(d);
    re = await submit(data.edit());
    expect(
      re == "ERROR_EMPTY_JOB_DUTY",
      "Cannot create job opening without duty - $re",
    );
  }

  jobEditSuccess() async {
    final jobDocs = await jobs.where('uid', isEqualTo: UserService.instance.uid).get();

    final jobOpening = JobModel.fromJson(
      jobDocs.docs.first.data() as Map<String, dynamic>,
      jobDocs.docs.first.id,
    );
    jobOpening.companyName = DateTime.now().millisecondsSinceEpoch.toString();
    jobOpening.status = "N";
    final re = await submit(jobOpening.edit());
    expect(re['companyName'] == jobOpening.companyName, "Success editting job.");
  }
}
