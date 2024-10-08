// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ndialog/ndialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';

class PersonalDetail extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneNumberController;
  final TextEditingController countryNameController;
  final TextEditingController dobController;
  final Function(String) onIdCardSelected;

  PersonalDetail({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneNumberController,
    required this.countryNameController,
    required this.dobController,
    required this.onIdCardSelected,
  });

  @override
  State<PersonalDetail> createState() => _PersonalDetailState();
}

class _PersonalDetailState extends State<PersonalDetail> {
  //Variables
  DateTime? _selectedDate;
  XFile? idCard;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void selectIdCard() async {
    XFile? image = await pickSingleImage(ImageSource.gallery);
    if (image != null) {
      setState(() {
        idCard = image;
      });
      widget.onIdCardSelected(image.path);
    }
  }

  void takePhoto() async {
    XFile? image = await pickSingleImage(ImageSource.camera);
    if (image != null) {
      setState(() {
        idCard = image;
      });
      widget.onIdCardSelected(image.path);
    }
  }

  Future<XFile?> pickSingleImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    return await _imagePicker.pickImage(source: source);
  }

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
                    inputAction: TextInputAction.next,
                    hintText: "First Name",
                    controller: widget.firstNameController,
                    keyboardType: TextInputType.name,
                    validator: _validateFirstName,
                  ),
                ),
                AppSpacing.extraLargeHorizontal,
                Expanded(
                  child: _buildTextField(
                    onTap: () {},
                    inputAction: TextInputAction.next,
                    hintText: "Last Name",
                    controller: widget.lastNameController,
                    keyboardType: TextInputType.name,
                    validator: _validateLastName,
                  ),
                ),
              ],
            ),
            AppSpacing.mediumVertical,
            _buildTextField(
              hintText: "Phone Number",
              inputAction: TextInputAction.next,
              onTap: () {},
              controller: widget.phoneNumberController,
              keyboardType: TextInputType.phone,
              validator: _validatePhoneNumber,
            ),
            AppSpacing.mediumVertical,
            _buildTextField(
              inputAction: TextInputAction.next,
              onTap: () async {
                final picked = await countryPicker.showPicker(context: context);
                // Null check
                if (picked != null) {
                  setState(() {
                    widget.countryNameController.text = picked.name;
                  });
                }
              },
              hintText: "Country",
              readOnly: true,
              controller: widget.countryNameController,
              keyboardType: TextInputType.name,
              validator: _validateCountry,
            ),
            AppSpacing.mediumVertical,
            _buildTextField(
              inputAction: TextInputAction.done,
              onTap: () async {
                NDialog(
                  dialogStyle: DialogStyle(
                    titleDivider: false,
                    contentPadding: EdgeInsets.zero,
                    elevation: 0,
                    backgroundColor: AppColors.deepSpace,
                  ),
                  content: DatePickerWidget(
                    looping: false, // default is not looping
                    lastDate: DateTime.now().subtract(
                      const Duration(days: 365 * 18),
                    ), //At least 18 years old

                    dateFormat:
                        // "MM-dd(E)",
                        "dd/MMMM/yyyy",
                    onChange: (DateTime newDate, _) {
                      setState(() {
                        _selectedDate = newDate;
                      });
                      log(_selectedDate.toString());
                    },

                    pickerTheme: const DateTimePickerTheme(
                      showTitle: true,
                      backgroundColor: AppColors.deepSpace,
                      itemTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      dividerColor: AppColors.cream,
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () {
                        if (_selectedDate == null) {
                          _selectedDate = DateTime.now().subtract(
                            const Duration(days: 365 * 18),
                          );
                          widget.dobController.text =
                              "${DateTime.now().day}/${_selectedDate!.month}/${_selectedDate!.year}";
                        } else {
                          setState(
                            () {
                              widget.dobController.text =
                                  "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
                            },
                          );
                        }

                        Navigator.pop(context);
                      },
                    ),
                  ],
                ).show(context);
              },
              hintText: "Date of birth (DDMMYYY)",
              readOnly: true,
              controller: widget.dobController,
              keyboardType: TextInputType.datetime,
              validator: _validateBirthday,
            ),
            AppSpacing.mediumVertical,
            // Upload or take ID cards

            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_card_outlined,
                  color: Colors.grey,
                ),
                AppSpacing.mediumHorizontal,
                Text(
                  "Upload your ID card photo*",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

            AppSpacing.mediumVertical,

            FocusedMenuHolder(
              onPressed: () => debugPrint('Tap on the icon'),
              openWithTap: true,
              menuWidth: MediaQuery.of(context).size.width * 0.92,
              menuOffset: 5,
              menuItems: [
                FocusedMenuItem(
                  title: const Text('Take photo'),
                  backgroundColor: Colors.white,
                  trailingIcon: const Icon(CupertinoIcons.photo_camera),
                  onPressed: () {
                    takePhoto();
                  },
                ),
                FocusedMenuItem(
                  title: const Text('Open photos'),
                  backgroundColor: Colors.white,
                  trailingIcon: const Icon(CupertinoIcons.photo_on_rectangle),
                  onPressed: () {
                    selectIdCard();
                  },
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: idCard == null ? Colors.grey : Colors.green,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                width: double.infinity,
                child: idCard == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            color: Colors.grey,
                          ),
                          Text(
                            "Card's front",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      )
                    : Image.file(
                        File(
                          idCard!.path,
                        ),
                      ),
              ),
            ),
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

  String? _validateBirthday(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your birthday';
    }
    return null;
  }

  Widget _buildTextField({
    required String hintText,
    bool? readOnly,
    required Function onTap,
    required TextEditingController controller,
    required TextInputAction inputAction,
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
      textInputAction: inputAction,
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
