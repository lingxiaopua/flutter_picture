import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_picture/animation/CustomRoute.dart';
import 'package:flutter_picture/comon/ListPage.dart';
import 'package:flutter_picture/model/vertical_model_entity.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../GlobalProperties.dart';
import '../../HttpUtil.dart';
import '../../image_viewpager.dart';
class VerticalDetail extends StatefulWidget {
  String url;
  VerticalDetail({Key key,this.url}) :super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VerticalDetailState();
  }
}
class VerticalDetailState extends State<VerticalDetail>{
  List<VerticalModelResVertical> wallpaper = [];
  List<String> images = [];
  int skip = 0;
  ScrollController _scrollController;
  double scrollDistance = 0.0;
  final String _scrollDistanceIdentifier = 'scrollDistanceIndentifier'; //tag

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController?.removeListener(_handleScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        child: ListPage(
          wallpaper,
          itemWidgetCreator: getItemWidget,
          onLoadMore: (){
            print("加载更多RefreshIndicator");
            skip+=30;
            getData();
          },
        ),
        onRefresh: _handleRefresh);
  }

  Widget getItemWidget(BuildContext context, int position) {
    return GestureDetector(
      child: Hero(
        tag: GlobalProperties.HERO_TAG_LOAD_IMAGE + "$position",
        child: Card(
            color: Colors.white,
            elevation: 2.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            margin: EdgeInsets.all(4.0),
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: wallpaper[position].preview +
                  GlobalProperties.ImgRule_vertical_720,
              width: 300,
              height: 200,
              fit: BoxFit.cover,
            )),
      ),
      onTap: () {
        Navigator.push(
            context,
            CustomRoute(ImageViewPage(
              images: images,
              position: position,
            )));
      },
    );
  }

  Future<void> getData() async {
    var dio = HttpUtil.getDio();
    var response = await dio.get(widget.url,queryParameters: {
      'limit': GlobalProperties.limit,
      'skip': skip
    });
    Map map = jsonDecode(response.toString());
    VerticalModelEntity entity = VerticalModelEntity.fromJson(map);
    entity.res.vertical.forEach((f)=>{
      images.add(f.preview + GlobalProperties.ImgRule_vertical_1080)
    });

    setState(() {
      wallpaper.addAll(entity.res.vertical);
    });
  }

  Future<void> _handleRefresh() {
    wallpaper.clear();
    getData();
  }

  void _handleScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      //加载更多
      skip+=30;
      getData();
    }
    scrollDistance = _scrollController.position.pixels;
    PageStorage.of(context).writeState(context, scrollDistance,
        identifier: _scrollDistanceIdentifier);
    setState(() {});
  }
}