import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

typedef HeaderWidgetBuild = Widget Function(BuildContext context, int position);
typedef FooterWidgetBuild = Widget Function(BuildContext context, int position);
typedef ItemWidgetBuild = Widget Function(BuildContext context, int position);

class ListPage extends StatefulWidget {
  List headerList;
  List listData;
  ItemWidgetBuild itemWidgetCreator;
  HeaderWidgetBuild headerCreator;
  FooterWidgetBuild footerCreator;

  ScrollController scrollController;
  bool have_footer;

  ListPage(
    List this.listData, {
    Key key,
    List this.headerList,
    bool this.have_footer = true,
    ItemWidgetBuild this.itemWidgetCreator,
    HeaderWidgetBuild this.headerCreator,
    ScrollController this.scrollController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ListPageState();
  }
}

class ListPageState extends State<ListPage> {
  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      controller: widget.scrollController,
      itemBuilder: (BuildContext context, int position) {
        return buildItemWidget(context, position);
      },
      itemCount: _getListCount(),
      crossAxisCount:
      MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4,
      staggeredTileBuilder: (int index) => getStaggerCount(index),
    );
    return Container(
      child: ListView.builder(
        itemBuilder: (BuildContext context, int position) {
          return buildItemWidget(context, position);
        },
        itemCount: _getListCount(), // 参数决定调用 itemBuilder 中回调函数的次数
      ),
    );
  }

  /**
   * 权重
   */
  StaggeredTile getStaggerCount(int position){
    if (position < _getHeaderCount()) {
      return StaggeredTile.count(2, 1);   //占两个位置  有一个view
    }else if(position == _getListCount() - _getFooterCount()){
      return StaggeredTile.fit(2);
    }else{
      //return StaggeredTile.count(1, position.isEven ? 2 : 1);
      return StaggeredTile.count(1,1);
    }
  }

  int _getListCount() {
    int itemCount = widget.listData.length;
    return itemCount + _getHeaderCount() + _getFooterCount();
  }

  int _getHeaderCount() {
    int headerCount = widget.headerList != null ? widget.headerList.length : 0;
    return headerCount;
  }

  int _getFooterCount() {
    if (widget.have_footer) {
      return 1;
    }
    return 0;
  }

  Widget _headerItemWidget(BuildContext context, int position) {
    if (widget.headerCreator != null) {
      return widget.headerCreator(context, position);
    } else {
      return GestureDetector(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Text('banner item $position'),
        ),
        onTap: () => print('header click $position --------------------'),
      );
    }
  }

  Widget _footerItemWidget(BuildContext context, int position) {
    if (widget.footerCreator != null) {
      return widget.footerCreator(context, position);
    } else {
      return Container(
          padding: const EdgeInsets.all(12.0),
          alignment: Alignment.center,
          child: SizedBox(
              width: 24.0,
              height: 24.0,
              child: CircularProgressIndicator(strokeWidth: 2.0))
      );
    }
  }

  Widget _ItemWidget(BuildContext context, int position) {
    if (widget.itemWidgetCreator != null) {
      return widget.itemWidgetCreator(context, position);
    } else {
      return GestureDetector(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Text('item $position'),
        ),
        onTap: () => print('item click $position --------------------'),
      );
    }
  }

  Widget buildItemWidget(BuildContext context, int position) {
    if (position < _getHeaderCount()) {
      return _headerItemWidget(context, position);
    }else if(position == _getListCount() - _getFooterCount()){
      return _footerItemWidget(context, position);
    } else {
      int pos = position - _getHeaderCount();
      return _ItemWidget(context, pos);
    }
  }
}
