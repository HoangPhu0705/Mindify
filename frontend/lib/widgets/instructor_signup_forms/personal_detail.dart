// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';

class PersonalDetail extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const PersonalDetail({
    Key? key,
    required this.formKey,
  }) : super(key: key);

  @override
  State<PersonalDetail> createState() => _PersonalDetailState();
}

class _PersonalDetailState extends State<PersonalDetail> {
  //Variables
  String? country;

  //Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _countryNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //Setup country picker
    final countryPicker = FlCountryCodePicker(
      countryTextStyle: const TextStyle(
        fontSize: 16,
        fontFamily: "Poppins",
      ),
      dialCodeTextStyle: const TextStyle(
        fontSize: 16,
        fontFamily: "Poppins",
      ),
      title: Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          "Select Country",
          style: TextStyle(
            fontSize: 24,
            fontFamily: "Poppins",
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      showDialCode: false,
      searchBarDecoration: InputDecoration(
        hintText: "Search",
        hintStyle: const TextStyle(
          fontSize: 16,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w500,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.blue),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.blue, width: 2),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );

    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppSpacing.largeVertical,
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "2.",
                style: TextStyle(
                  color: AppColors.cream,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Tell us about yourself?*",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            AppSpacing.mediumVertical,
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Please provide your detailed information.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[200],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            AppSpacing.largeVertical,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: _buildTextField(
                    onTap: () {},
                    hintText: "First Name",
                    controller: _firstNameController,
                    keyboardType: TextInputType.name,
                    validator: _validateFirstName,
                  ),
                ),
                AppSpacing.extraLargeHorizontal,
                Expanded(
                  child: _buildTextField(
                    onTap: () {},
                    hintText: "Last Name",
                    controller: _lastNameController,
                    keyboardType: TextInputType.name,
                    validator: _validateLastName,
                  ),
                ),
              ],
            ),
            AppSpacing.mediumVertical,
            _buildTextField(
              hintText: "Phone Number",
              onTap: () {},
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              validator: _validatePhoneNumber,
            ),
            AppSpacing.mediumVertical,
            _buildTextField(
              onTap: () async {
                final picked = await countryPicker.showPicker(context: context);
                // Null check
                if (picked != null) {
                  setState(() {
                    _countryNameController.text = picked.name;
                  });
                }
              },
              hintText: "Country",
              readOnly: true,
              controller: _countryNameController,
              keyboardType: TextInputType.name,
              validator: _validateCountry,
            ),
            Container(
              height: 1000,
            )
          ],
        ),
      ),
    );
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your first name';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your last name';
    }
    return null;
  }

  //validate phone number
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    if (value.length < 10) {
      return 'Invalid phone number';
    }
    return null;
  }

  // validate country
  String? _validateCountry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your country';
    }
    return null;
  }

  Widget _buildTextField({
    required String hintText,
    bool? readOnly,
    required Function onTap,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      onTap: () {
        onTap();
      },
      readOnly: readOnly ?? false,
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: <TextInputFormatter>[
        keyboardType == TextInputType.phone
            ? FilteringTextInputFormatter.digitsOnly
            : FilteringTextInputFormatter.singleLineFormatter,
      ],
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.cream),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.cream, width: 2),
        ),
      ),
      cursorColor: AppColors.cream,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
