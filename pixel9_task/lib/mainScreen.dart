import 'package:flutter/material.dart';
import 'package:pixel9_task/ModalClass/EmpModal.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State createState() => MainScreenState();
}

class MainScreenState extends State<Mainscreen> {
  String defaultC = 'Country';
  String defaultG = 'Gender';
  bool filter = true;
  bool sortId = false;

  var genderList = ['male', 'female'];
  var countryList = [
    //created a random list of country
    'India',
    'United States',
    'UK',
    'Sri Lanka',
  ];

  List<Empmodal> subEmpList = []; //list to show 10 elements
  List<Empmodal> empList = []; //use to store all data from api
  List<Empmodal> filterList =
      []; //to display the filtered data i.e. gender or country

  Widget genderDropDown() {
    return Container(
      height: 45,
      //width: 120,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black54),
          borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: DropdownButton(
          itemHeight: 50,
          menuMaxHeight: 100,
          hint: Text(defaultG),
          items: genderList.map((String items) {
            return DropdownMenuItem(value: items, child: Text(items));
          }).toList(),
          onChanged: (String? newGender) {
            filter = true;
            defaultG = newGender!;
            filterGender(newGender);
          },
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  filterGender(String gender) {
    setState(() {
      //print(gender);
      //print(filterList);
      //print(empList);
      subEmpList = filterList.where((emp) => emp.gender == gender).toList();
    });
  }

  filterCountry(String country) {
    setState(() {
      subEmpList = filterList.where((emp) => emp.country == country).toList();
    });
  }

  Widget countryDropDown() {
    return Container(
      height: 45,
      //width: 120,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black54),
          borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: DropdownButton(
          itemHeight: 50,
          menuMaxHeight: 100,
          hint: Text(defaultC),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.red,
          ),
          items: countryList.map((String items) {
            return DropdownMenuItem(
              value: items,
              child: Text(
                items,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
          onChanged: (String? newCountry) {
            setState(() {
              filter = true;
              defaultC = newCountry!;
              filterCountry(newCountry);
            });
          },
        ),
      ),
    );
  }

  int a = 0; //to set the limit of list elements to load
  int b = 0; //to skip the list
  int start = 0;
  int end = 0;

  void gethttps(int a, int b) async {
    this.a = a;
    this.b = b;
    var urlTemp = Uri.parse("https://dummyjson.com/users?limit=$a&skip=$b");
    final http.Response response = await http.get(urlTemp);
    final Map responseData = json.decode(response.body);

    responseData['users'].forEach((empModalObj) {
      final Empmodal emp = Empmodal(
          id: empModalObj['id'],
          firstName: empModalObj['firstName'],
          lastName: empModalObj['lastName'],
          image: empModalObj['image'],
          gender: empModalObj['gender'],
          age: empModalObj['age'],
          title: empModalObj['company']['title'],
          state: empModalObj['address']['state'],
          country: empModalObj['address']['country']);

      setState(() {
        empList.add(emp);
        subEmpList.add(emp);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    gethttps(10, 0);
  }

  Widget header() {
    //function that contain the filter part
    return Padding(
      padding: const EdgeInsets.only(left: 18.0, right: 18, bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "Employees",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                  onPressed: () {
                    setState(() {
                      filter = !filter;
                      if (!filter) {
                        defaultC = "Country";
                        defaultG = "Gender";
                        subEmpList = filterList;
                      }
                    });

                    //print(filter);
                  },
                  icon: (filter)
                      ? const Icon(
                          Icons.filter_alt,
                          color: Colors.red,
                        )
                      : const Icon(
                          Icons.filter_alt_off,
                          color: Colors.red,
                        )),
              const SizedBox(
                width: 10,
              ),
              countryDropDown(),
              const SizedBox(
                width: 10,
              ),
              genderDropDown()
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Pixel6 Task",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              //temperory icon button in appbar
              onPressed: () {},
              icon: const Icon(
                Icons.menu_rounded,
                color: Colors.red,
              ))
        ],
      ),
      body: Column(
        children: [
          header(),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                    borderRadius: BorderRadius.circular(20)),
                child: DataTable(
                    sortAscending: sortId,
                    sortColumnIndex: 0,
                    columns: [
                      DataColumn(
                        label: const Text("Id"),
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            sortId = !sortId;
                            if (sortId == true) {
                              subEmpList = subEmpList.reversed.toList();
                            } else {
                              subEmpList = filterList;
                            }
                          });
                        },
                      ),
                      const DataColumn(label: Text("Image")),
                      const DataColumn(
                        label: Text("Name"),
                      ),
                      const DataColumn(label: Text("Demography")),
                      const DataColumn(label: Text("Designation")),
                      const DataColumn(label: Text("Country")),
                    ],
                    rows: subEmpList
                        .map((data) => DataRow(cells: [
                              DataCell(Text("${data.id}")),
                              DataCell(SizedBox(
                                height: 40,
                                width: 40,
                                child: Image.network(data.image),
                              )),
                              DataCell(
                                  Text("${data.firstName} ${data.lastName}")),
                              DataCell(Text("${data.gender}/${data.age}")),
                              DataCell(Text(data.title)),
                              DataCell(Text("${data.state}, ${data.country}")),
                            ]))
                        .toList()),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("previous"),
              IconButton(
                  onPressed: () {
                    if (b > 0) {
                      b -= 10;
                      start -= 10;
                      end -= 10;
                      subEmpList = empList.sublist(start, end);
                      filterList = subEmpList;
                      gethttps(10, b);
                    }
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_rounded)),
              const SizedBox(
                width: 30,
              ),
              IconButton(
                  onPressed: () {
                    if (b >= 0) {
                      b += 10;
                      start += 10;
                      end += 10;
                      subEmpList = empList.sublist(start, end);
                      filterList = subEmpList;
                      gethttps(10, b);
                    }
                  },
                  icon: const Icon(Icons.arrow_forward_ios_rounded)),
              const Text("next")
            ],
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
