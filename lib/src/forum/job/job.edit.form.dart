import '../../../fireflutter.dart';
import 'package:flutter/material.dart';

class JobEditForm extends StatefulWidget {
  const JobEditForm({
    Key? key,
    required this.onError,
  }) : super(key: key);

  final Function onError;

  @override
  State<JobEditForm> createState() => _JobEditFormState();
}

class _JobEditFormState extends State<JobEditForm> {
  final companyName = TextEditingController();
  final phoneNumber = TextEditingController();
  final mobileNumber = TextEditingController();
  final email = TextEditingController();
  final jobCategory = TextEditingController();
  final workingHours = TextEditingController();
  final provinceOrCity = TextEditingController();
  final cityOrDistrict = TextEditingController();
  final detailAddress = TextEditingController();
  final aboutUs = TextEditingController();
  final numberOfHiring = TextEditingController();
  final jobDescription = TextEditingController();
  final requirement = TextEditingController();
  final duty = TextEditingController();
  final salary = TextEditingController();
  final benefit = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Create a job opening'),
        TextField(
          controller: companyName,
          decoration: InputDecoration(
            labelText: "Company name",
          ),
        ),
        TextField(
          controller: mobileNumber,
          decoration: InputDecoration(
            labelText: "Mobile phone number",
          ),
        ),
        TextField(
          controller: phoneNumber,
          decoration: InputDecoration(
            labelText: "Office phone number",
          ),
        ),
        TextField(
          controller: email,
          decoration: InputDecoration(
            labelText: "Email address",
          ),
        ),
        TextField(
          controller: provinceOrCity,
          decoration: InputDecoration(
            labelText: "Province / City",
          ),
        ),
        TextField(
          controller: cityOrDistrict,
          decoration: InputDecoration(
            labelText: "City",
          ),
        ),
        TextField(
          controller: detailAddress,
          decoration: InputDecoration(
            labelText: "Detail address",
          ),
        ),
        TextField(
          controller: jobCategory,
          decoration: InputDecoration(
            labelText: "Job category(industry) - @todo select box",
          ),
        ),
        TextField(
          controller: aboutUs,
          decoration: InputDecoration(
            labelText: "About us",
          ),
        ),
        TextField(
          controller: numberOfHiring,
          decoration: InputDecoration(
            labelText: "Number of hiring",
          ),
        ),
        TextField(
          controller: workingHours,
          decoration: InputDecoration(
            labelText: "Working hours",
          ),
        ),
        TextField(
          controller: jobDescription,
          decoration: InputDecoration(
            labelText: "Job description(details of what workers will do)",
          ),
        ),
        TextField(
          controller: requirement,
          decoration: InputDecoration(
            labelText: "Requirements and qualifications",
          ),
        ),
        TextField(
          controller: duty,
          decoration: InputDecoration(
            labelText: "Duties and responsibilities",
          ),
        ),
        TextField(
          controller: salary,
          decoration: InputDecoration(
            labelText: "Salary",
          ),
        ),
        TextField(
          controller: benefit,
          decoration: InputDecoration(
            labelText: "benefits(free meals, dormitory, transporation, etc)",
          ),
        ),
        Divider(),
        ElevatedButton(
          onPressed: () async {
            try {
              await PostApi.instance.create(category: 'job_openings', extra: {
                'companyName': companyName.text,
                'phoneNumber': phoneNumber.text,
                'mobileNumber': mobileNumber.text,
                'email': email.text,
                'jobCategory': jobCategory.text,
                'workingHours': workingHours.text,
                'provinceOrCity': provinceOrCity.text,
                'cityOrDistrict': cityOrDistrict.text,
                'detailAddress': detailAddress.text,
                'aboutUs': aboutUs.text,
                'numberOfHiring': numberOfHiring.text,
                'jobDescription': jobDescription.text,
                'requirement': requirement.text,
                'duty': duty.text,
                'salary': salary.text,
                'benefit': benefit.text,
              });
            } catch (e) {
              widget.onError(e);
            }
          },
          child: Text('Submit'),
        )
      ],
    );
  }
}
