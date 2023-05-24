import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/size_system.dart';

import 'model/select_status_model.dart' as StatusModel;

class SelectState extends StatefulWidget {
  static final GlobalKey<_SelectStateState> globalKey = GlobalKey();

  // final ValueChanged<String> onCountryChanged;
  final ValueChanged<String> onStateChanged;
  final ValueChanged<String> onCityChanged;
  final VoidCallback? onCountryTap;
  final String? Function(String?)? stateValidator;
  final String? Function(String?)? cityValidator;
  final VoidCallback? onStateTap;
  final Widget zipCode;
  final Widget cityTextField;
  final VoidCallback? onCityTap;
  final TextStyle? style;
  final FocusNode? cityNode;
  final FocusNode? stateNode;
  final Color? dropdownColor;
  final InputDecoration decoration;
  final double spacing;
  final String? initState;
  final String? initCity;

  SelectState({
    Key? key,
    // required this.onCountryChanged,
    required this.onStateChanged,
    required this.onCityChanged,
    required this.zipCode,
    required this.cityNode,
    required this.stateNode,
    required this.stateValidator,
    required this.cityValidator,
    this.decoration =
    const InputDecoration(contentPadding: EdgeInsets.all(0.0)),
    this.spacing = 0.0,
    this.style,
    this.dropdownColor,
    this.onCountryTap,
    this.onStateTap,
    this.onCityTap,
    this.initState,
    this.initCity,
    required this.cityTextField,
  }) : super(key: globalKey);

  @override
  _SelectStateState createState() => _SelectStateState();
}

class _SelectStateState extends State<SelectState> {
  List<String> _cities = ["Choose City"];
  final List<String> _country = ["Choose Country"];
  String _selectedCity = "Choose City";
  String _selectedCountry = "🇺🇸    United States";
  String _selectedState = "Choose State/Province";
  List<String> _states = ["Choose State/Province"];
  String initStateSelected = '';
  String initCitySelected = '';
  var responses;

  @override
  void initState() {
    getCounty().then((value) {
      _onSelectedCountry("🇺🇸    United States");
    });
    if (widget.initState != null) initStateSelected = widget.initState!;
    if (widget.initCity != null) initCitySelected = widget.initCity!;

    super.initState();
  }

  Future getResponse() async {
    var res = await rootBundle.loadString('assets/jsons/country.json');
    return jsonDecode(res);
  }

  Future getCounty() async {
    var countryres = await getResponse() as List;
    countryres.forEach((data) {
      var model = StatusModel.StatusModel();
      model.name = data['name'];
      model.emoji = data['emoji'];
      if (!mounted) return;
      setState(() {
        _country.add(model.emoji! + "    " + model.name!);
      });
    });

    return _country;
  }

  Future getState() async {
    var response = await getResponse();
    var takestate = response
        .map((map) => StatusModel.StatusModel.fromJson(map))
        .where((item) => item.emoji + "    " + item.name == _selectedCountry)
        .map((item) => item.state)
        .toList();
    var states = takestate as List;
    states.forEach((f) {
      if (!mounted) return;
      setState(() {
        var name = f.map((item) => item.name).toList();
        for (var statename in name) {
          _states.add(statename.toString());
        }
        _states.sort((a, b) => a.compareTo(b));
        if (widget.initState != null &&
            widget.initState!.isNotEmpty &&
            name.contains(widget.initState ?? "")) {
          onSelectedState(widget.initState!);
        }
      });
    });

    return _states;
  }

  Future getCity() async {
    var response = await getResponse();
    var takestate = response
        .map((map) => StatusModel.StatusModel.fromJson(map))
        .where((item) => item.emoji + "    " + item.name == _selectedCountry)
        .map((item) => item.state)
        .toList();
    var states = takestate as List;
    states.forEach((f) {
      var name = f.where((item) => item.name == _selectedState);
      var cityname = name.map((item) => item.city).toList();
      cityname.forEach((ci) {
        if (!mounted) return;
        setState(() {
          var citiesname = ci.map((item) => item.name).toList();
          for (var citynames in citiesname) {
            _cities.add(citynames.toString());
          }
          if (widget.initCity != null &&
              widget.initCity!.isNotEmpty &&
              _cities.contains(widget.initCity ?? "")) {
            onSelectedCity(widget.initCity!);
          }
        });
      });
    });
    return _cities;
  }

  void _onSelectedCountry(String value) {
    if (!mounted) return;
    setState(() {
      _selectedState = "Choose State/Province";
      _states = ["Choose State/Province"];
      _selectedCountry = value;
      // this.widget.onCountryChanged(value);
      getState();
    });
  }

  void onSelectedState(String value) {
    if (!mounted) return;
    setState(() {
      _selectedCity = "Choose City";
      _cities = ["Choose City"];
      if (value == "CA") {
        _selectedState = "California";
      } else {
        _selectedState = value;
      }
      this.widget.onStateChanged(value);
      getCity();
    });
  }

  void onSelectedCity(String value) {
    if (!mounted) return;
    print("this is cityq ${value}");
    setState(() {
      _selectedCity = value;
      this.widget.onCityChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // InputDecorator(
        //   decoration: widget.decoration,
        //   child: DropdownButtonHideUnderline(
        //       child: DropdownButton<String>(
        //     dropdownColor: widget.dropdownColor,
        //     isExpanded: true,
        //     items: _country.map((String dropDownStringItem) {
        //       return DropdownMenuItem<String>(
        //         value: dropDownStringItem,
        //         child: Row(
        //           children: [
        //             Flexible(
        //               child: Text(
        //                 dropDownStringItem,
        //                 style: widget.style,
        //                 overflow: TextOverflow.ellipsis,
        //               ),
        //             )
        //           ],
        //         ),
        //       );
        //     }).toList(),
        //     // onTap: ,
        //     // onChanged: (value) => _onSelectedCountry(value!),
        //     // onTap: widget.onCountryTap,
        //     // onChanged: (value) => _onSelectedCountry(value!),
        //     value: _selectedCountry,
        //   )),
        // ),
        // SizedBox(
        //   height: widget.spacing,
        // ),

        Row(
          children: [
            // Expanded(
            //   child: DropdownButtonHideUnderline(
            //       child: DropdownButtonFormField<String>(
            //     decoration: InputDecoration(
            //       labelText: 'City',
            //       alignLabelWithHint: false,
            //       hintText: "San Francisco",
            //       hintStyle: TextStyle(
            //         color: ColorSystem.greyDark,
            //         fontSize: SizeSystem.size18,
            //       ),
            //       floatingLabelBehavior: FloatingLabelBehavior.always,
            //       constraints: BoxConstraints(),
            //       contentPadding:
            //           EdgeInsets.symmetric(vertical: 10, horizontal: 0),
            //       labelStyle: TextStyle(
            //         color: ColorSystem.greyDark,
            //       ),
            //       errorStyle: TextStyle(
            //           color: ColorSystem.lavender3,
            //           fontWeight: FontWeight.w400),
            //       focusedBorder: UnderlineInputBorder(
            //         borderSide: BorderSide(
            //           color: ColorSystem.greyDark,
            //           width: 1,
            //         ),
            //       ),
            //       border: UnderlineInputBorder(
            //         borderSide: BorderSide(
            //           color: ColorSystem.greyDark,
            //           width: 1,
            //         ),
            //       ),
            //       enabledBorder: UnderlineInputBorder(
            //         borderSide: BorderSide(
            //           color: ColorSystem.greyDark,
            //           width: 1,
            //         ),
            //       ),
            //       errorBorder: UnderlineInputBorder(
            //         borderSide: BorderSide(
            //           color: ColorSystem.lavender3,
            //           width: 1,
            //         ),
            //       ),
            //       focusedErrorBorder: UnderlineInputBorder(
            //         borderSide: BorderSide(
            //           color: ColorSystem.lavender3,
            //           width: 1,
            //         ),
            //       ),
            //     ),
            //     focusNode: widget.cityNode,
            //     icon: Icon(
            //       Icons.expand_more,
            //       color: ColorSystem.greyDark,
            //     ),
            //     isDense: true,
            //     isExpanded: true,
            //     validator: widget.cityValidator,
            //     items: _cities.map((String dropDownStringItem) {
            //       return DropdownMenuItem<String>(
            //         value: dropDownStringItem,
            //         child: Row(
            //           children: [
            //             Flexible(
            //               child: Text(
            //                 dropDownStringItem,
            //                 style: widget.style,
            //                 overflow: TextOverflow.ellipsis,
            //               ),
            //             )
            //           ],
            //         ),
            //       );
            //     }).toList(),
            //     onChanged: (value) => onSelectedCity(value!),
            //     onTap: widget.onCityTap,
            //     value: _selectedCity,
            //   )),
            // ),
            Expanded(child: widget.cityTextField),
            SizedBox(width: 15),
            Expanded(child: widget.zipCode)
          ],
        ),
        SizedBox(height: 10),
        DropdownButtonHideUnderline(
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'State',
              alignLabelWithHint: false,
              hintText: "California",
              hintStyle: TextStyle(
                color: ColorSystem.greyDark,
                fontSize: SizeSystem.size18,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              constraints: BoxConstraints(),
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              labelStyle: TextStyle(
                color: ColorSystem.greyDark,
              ),
              errorStyle: TextStyle(
                  color: ColorSystem.lavender3, fontWeight: FontWeight.w400),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: ColorSystem.greyDark,
                  width: 1,
                ),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: ColorSystem.greyDark,
                  width: 1,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: ColorSystem.greyDark,
                  width: 1,
                ),
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: ColorSystem.lavender3,
                  width: 1,
                ),
              ),
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: ColorSystem.lavender3,
                  width: 1,
                ),
              ),
            ),
            focusNode: widget.stateNode,
            icon: Icon(
              Icons.expand_more,
              color: ColorSystem.greyDark,
            ),
            isDense: true,
            isExpanded: true,
            validator: widget.stateValidator,
            items: _states.map((String dropDownStringItem) {
              return DropdownMenuItem<String>(
                value: dropDownStringItem,
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        dropDownStringItem,
                        style: widget.style,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => onSelectedState(value!),
            onTap: widget.onStateTap,
            value: _selectedState,
          ),
        ),
      ],
    );
  }
}
