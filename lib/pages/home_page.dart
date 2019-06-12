import 'package:flutter/material.dart';
import 'package:qianliao_shop/config/service_method.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  int page = 1;
  List<Map> hotGoodsList = [];
  @override
  void initState() {
    // TODO: implement initState 
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("百姓生活+"),
        ),
        body: FutureBuilder(
          future: request('homePageContent',
              formData: {'lon': '115.02932', 'lat': '35.76189'}),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = json.decode(snapshot.data.toString());

              List<Map> swiperDataList =
                  (data['data']['slides'] as List).cast();
              List<Map> NaviLst = (data['data']['category'] as List).cast();
              String advertesPic =
                  data['data']['advertesPicture']['PICTURE_ADDRESS'];
              String leaderImage = data['data']['shopInfo']['leaderImage'];
              String leaderPhone = "13713851213";
              List<Map> recommendList =
                  (data['data']['recommend'] as List).cast();
              String floor1Title = data['data']['floor1Pic']['PICTURE_ADDRESS'];
              String floor2Title = data['data']['floor2Pic']['PICTURE_ADDRESS'];
              String floor3Title = data['data']['floor3Pic']['PICTURE_ADDRESS'];
              List<Map> floor1 = (data['data']['floor1'] as List).cast();
              List<Map> floor2 = (data['data']['floor2'] as List).cast();
              List<Map> floor3 = (data['data']['floor3'] as List).cast();
              if (NaviLst.length > 10) {
                NaviLst.removeRange(10, NaviLst.length);
              }
             GlobalKey<RefreshFooterState> _footKey = new GlobalKey<RefreshFooterState>();
              return EasyRefresh(
                refreshFooter: ClassicsFooter(
                  bgColor: Colors.white,
                  textColor: Colors.pink,
                  moreInfoColor: Colors.pink,
                  showMore: true,
                  noMoreText: "",
                  moreInfo: "加载中......",
                  loadReadyText: "上拉加载",
                  key: _footKey,
                ),
                child: ListView(
                  children: <Widget>[
                    SwiperDiy(swiperDataList: swiperDataList),
                    TopNavigator(
                      navigatorList: NaviLst,
                    ),
                    AdBanner(advertesPic: advertesPic),
                    LeaderPhone(
                      leaderImage: leaderImage,
                      leaderPhone: leaderPhone,
                    ),
                    RecommendList(recommendList: recommendList),
                    FloorTitle(picture_address: floor1Title),
                    FloorContent(floorGoodsList: floor1),
                    FloorTitle(picture_address: floor2Title),
                    FloorContent(floorGoodsList: floor2),
                    FloorTitle(picture_address: floor3Title),
                    FloorContent(floorGoodsList: floor3),
                    _hotGoods(),
                  ],
                ),
                loadMore: () async {
                  print("开始加载更多。。。。。。。。。。。。。。。。。");
                  var formPage = {'page': page};
                await  request("homePageBelowConten", formData: formPage)
                      .then((val) {
                    var data = json.decode(val.toString());
                    List<Map> newhotgoods = (data['data'] as List).cast();
                    setState(() {
                      hotGoodsList.addAll(newhotgoods);
                      page++;
                    });
                  });
                },
              );
            } else {
              return Center(
                child: Text("加载中................."),
              );
            }
          },
        ));
  }

  //火爆专区,获取数据
  _getHotGoods() {
    var formPage = {'page': page};
    request("homePageBelowConten", formData: formPage).then((val) {
      var data = json.decode(val.toString());
      List<Map> newhotgoods = (data['data'] as List).cast();
      setState(() {
        hotGoodsList.addAll(newhotgoods);
        page++;
      });
    });
  }

  //火爆专区标题
  Widget hotTitle = Container(
    margin: EdgeInsets.only(top: 2.0),
    padding: EdgeInsets.all(4.0),
    alignment: Alignment.center,
    color: Colors.transparent,
    child: Text(
      "火爆专区",
      style: TextStyle(color: Colors.pink),
    ),
  );

  //火爆专区流失布局,数据长度不能为0
  Widget _hotgoodsWrapList() {
    if (hotGoodsList != 0) {
      List<Widget> listWiget = hotGoodsList.map((val) {
        return InkWell(
          onTap: null,
          child: Container(
            width: ScreenUtil().setWidth(370),
            color: Colors.white,
            padding: EdgeInsets.all(5.0),
            margin: EdgeInsets.only(bottom: 5.0),
            child: Column(
              children: <Widget>[
                Image.network(
                  val['image'],
                  width: ScreenUtil().setWidth(368),
                ),
                Text(
                  val['name'],
                  style: TextStyle(
                      color: Colors.pink, fontSize: ScreenUtil().setSp(24)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('￥${val['mallPrice']}'),
                    Text(
                      '￥${val['price']}',
                      style: TextStyle(
                          color: Colors.black26,
                          decoration: TextDecoration.lineThrough,
                          fontSize: ScreenUtil().setSp(24)),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }).toList();

      return Wrap(
        spacing: 2, //每行的列数
        children: listWiget,
      );
    } else {
      return Text("");
    }
  }

  Widget _hotGoods() {
    return Container(
      child: Column(
        children: <Widget>[hotTitle, _hotgoodsWrapList()],
      ),
    );
  }
}

//楼层标题组件
class FloorTitle extends StatelessWidget {
  String picture_address;
  FloorTitle({this.picture_address}) : super();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Image.network(picture_address),
    );
  }
}

//楼层商品组件的编写
class FloorContent extends StatelessWidget {
  List floorGoodsList;
  FloorContent({this.floorGoodsList}) : super();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _firstRow(),
          _otherGoods(),
        ],
      ),
    );
  }

  //第一行商品
  Widget _firstRow() {
    return Row(
      children: <Widget>[
        _goodsItem(floorGoodsList[0]),
        Column(
          children: <Widget>[
            _goodsItem(floorGoodsList[1]),
            _goodsItem(floorGoodsList[2]),
          ],
        )
      ],
    );
  }

//其他行的商品
  Widget _otherGoods() {
    return Row(
      children: <Widget>[
        _goodsItem(floorGoodsList[3]),
        _goodsItem(floorGoodsList[4]),
      ],
    );
  }

  Widget _goodsItem(Map goods) {
    return Container(
      width: ScreenUtil().setWidth(375),
      child: InkWell(
        onTap: null,
        child: Image.network(goods['image']),
      ),
    );
  }
}

//首页轮播组件的编写
class SwiperDiy extends StatelessWidget {
  List swiperDataList;
  SwiperDiy({this.swiperDataList}) : super();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(333.0),
      width: ScreenUtil().setWidth(750.0),
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return Image.network("${swiperDataList[index]['image']}",
              fit: BoxFit.fill);
        },
        itemCount: swiperDataList.length,
        pagination: new SwiperPagination(),
        autoplay: true,
      ),
    );
  }
}

//首页导航
class TopNavigator extends StatelessWidget {
  List navigatorList = [];
  TopNavigator({this.navigatorList}) : super();
  @override
  Widget build(BuildContext content) {
    return Container(
      height: ScreenUtil().setHeight(320),
      padding: EdgeInsets.all(3.0),
      child: GridView.count(
        crossAxisCount: 5,
        padding: EdgeInsets.all(4.0),
        children: navigatorList.map((item) {
          return _itemUi(content, item);
        }).toList(),
      ),
    );
  }

  Widget _itemUi(BuildContext content, item) {
    return InkWell(
      onTap: () {
        print("点击了分类....");
      },
      child: Column(
        children: <Widget>[
          Image.network(item['image'], width: ScreenUtil().setWidth(95)),
          Text(item['mallCategoryName'])
        ],
      ),
    );
  }
}

//广告图片
class AdBanner extends StatelessWidget {
  String advertesPic;
  AdBanner({this.advertesPic}) : super();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.network(
        advertesPic,
        width: ScreenUtil().setWidth(750),
      ),
    );
  }
}

//店长电话
class LeaderPhone extends StatelessWidget {
  String leaderImage, leaderPhone;
  LeaderPhone({this.leaderImage, this.leaderPhone}) : super();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: _launchUrl,
        child: Image.network(leaderImage),
      ),
    );
  }

  void _launchUrl() async {
    String url = 'tel:' + leaderPhone;
    print(leaderPhone);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "could not lauch =========== ${url}";
    }
  }
}

class RecommendList extends StatelessWidget {
  List recommendList;
  RecommendList({this.recommendList}) : super();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(420),
      margin: EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[_title(), _list()],
      ),
    );
  }

  //标题
  Widget _title() {
    return Container(
      alignment: Alignment.centerLeft,
      height: ScreenUtil().setHeight(40.0),
      padding: EdgeInsets.fromLTRB(10.0, 2.0, 0, 5.0),
      decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border(bottom: BorderSide(width: 0.5, color: Colors.black12))),
      child: Text(
        "商品推荐",
        style: TextStyle(
            color: Colors.pink,
            fontSize: ScreenUtil().setSp(
              30,
            )),
      ),
    );
  }

  //单个商品
  Widget _item(index) {
    return InkWell(
      onTap: null,
      child: Container(
        height: ScreenUtil().setHeight(370),
        width: ScreenUtil().setWidth(250),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(left: BorderSide(width: 1, color: Colors.black12))),
        child: Column(
          children: <Widget>[
            Image.network(recommendList[index]['image']),
            Text('￥${recommendList[index]['mallPrice']}'),
            Text(
              "￥${recommendList[index]['price']}",
              style: TextStyle(
                  color: Colors.grey, decoration: TextDecoration.lineThrough),
            )
          ],
        ),
      ),
    );
  }

  //多个商品
  Widget _list() {
    return Container(
      height: ScreenUtil().setHeight(370),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendList.length,
        itemBuilder: (context, index) {
          return _item(index);
        },
      ),
    );
  }
}
