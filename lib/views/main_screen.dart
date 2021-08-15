import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodlistdicoding/model/restaurant_model.dart';
import 'package:foodlistdicoding/widget/search_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'detail_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Restaurant> allList = [];
  List<Restaurant> list = [];
  List<dynamic> data;
  bool isLoading = false;
  String query = '';
  String hintText = 'Search...';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: isLoading
              ? Center(
              child: CircularProgressIndicator())
              : list.length == 0 ? Center(child: Text("No Data Available"),) : SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ConstrainedBox(
              constraints: BoxConstraints(),
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Discover',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 40)),
                      Text('Restaurant List',
                          style: TextStyle(color: Colors.grey, fontSize: 18)),
                      buildSearch(),
                      SizedBox(height: 20),
                      buildList(list)
                    ],
                  )),
            ),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    setState(() {
      isLoading = true;
    });

    var dataInfo = await rootBundle.loadString('assets/raw/local_restaurant.json');
    RestaurantModel restaurantModel = RestaurantModel.fromJson(json.decode(dataInfo.toString()));

    allList.addAll(restaurantModel.restaurants);
    list = allList;

    setState(() {
      isLoading = false;
    });


  }

  String formatDate(dateString) {
    initializeDateFormatting('id_ID', null);
    DateTime date = DateTime.parse(dateString);
    String formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(date);
    return formattedDate;
  }

  void searchData(String query) {
    final list = allList.where((list) {
      final titleLower = list.name.toLowerCase();
      final searchLower = query.toLowerCase();

      return titleLower.contains(searchLower);
    }).toList();

    setState(() {
      this.query = query;
      this.list = list;
    });
  }

  Widget buildSearch() =>
      SearchWidget(text: query, onChanged: searchData, hintText: hintText);

  Widget buildList(List<Restaurant> list) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return DetailScreen(list[index]);
            }));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: CachedNetworkImage(
                        height: 100,
                        imageUrl: list[index].pictureId,
                        placeholder: (context, url) => Image.asset(
                          'images/food.png',
                          height: 200,
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          'images/food.png',
                          height: 200,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(list[index].name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16)),
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.pin_drop),
                            Text(
                              '${list[index].city}',
                              style: TextStyle(fontSize: 14),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.star,color: Colors.yellow,),
                            Text(
                              '${list[index].rating.toString()}',
                              style: TextStyle(fontSize: 14),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      itemCount: list.length,
    );
  }
}
