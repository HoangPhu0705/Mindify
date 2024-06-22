import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';

class CategorySelectionForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final List<String> categories;
  final String? currentCategory;
  final ValueChanged<String?> onChanged;

  const CategorySelectionForm({
    Key? key,
    required this.formKey,
    required this.categories,
    required this.currentCategory,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<CategorySelectionForm> createState() => _CategorySelectionFormState();
}

class _CategorySelectionFormState extends State<CategorySelectionForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          AppSpacing.largeVertical,
          const Align(
            alignment: Alignment.topLeft,
            child: Text(
              "1.",
              style: TextStyle(
                color: AppColors.cream,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          const Text(
            "What category are you interested in teaching?*",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          AppSpacing.mediumVertical,
          Text(
            "Select the category that best applies to the first class you would like to teach. You can add more categories later.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[200],
              fontWeight: FontWeight.w400,
            ),
          ),
          AppSpacing.mediumVertical,
          FormField(
            builder: (FormFieldState state) {
              return DropdownButtonHideUnderline(
                child: SizedBox(
                  width: double.infinity,
                  child: DropdownButtonFormField2<String>(
                    dropdownStyleData: const DropdownStyleData(
                      maxHeight: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                    iconStyleData: const IconStyleData(
                      icon: Icon(
                        CupertinoIcons.chevron_down_circle,
                      ),
                      iconSize: 18,
                      iconEnabledColor: AppColors.cream,
                    ),
                    isExpanded: true,
                    hint: const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Text(
                        'Select an option',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.cream,
                        ),
                      ),
                    ),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(right: 10),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.cream,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.cream,
                        ),
                      ),
                      errorStyle: TextStyle(
                        color: Colors.red,
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red,
                        ),
                      ),
                    ),
                    selectedItemBuilder: (context) {
                      return widget.categories
                          .map((String item) => Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.cream,
                                  ),
                                ),
                              ))
                          .toList();
                    },
                    items: widget.categories
                        .map(
                          (String item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    value: widget.currentCategory,
                    onChanged: widget.onChanged,
                    buttonStyleData: const ButtonStyleData(
                      height: 40,
                      width: double.infinity,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
