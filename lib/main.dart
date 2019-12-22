import 'dart:ui';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Stack Cards Album'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String imageUrl = "image1.jpeg";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage("assets/$imageUrl"),
                fit: BoxFit.cover,
              )),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                child: Container(
                  decoration:
                      BoxDecoration(color: Colors.white.withOpacity(0.0)),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CardStack(
                    onCardChanged: (url) {
                      setState(() {
                        imageUrl = url;
                      });
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CardStack extends StatefulWidget {
  final Function onCardChanged;

  CardStack({this.onCardChanged});

  @override
  _CardStackState createState() => _CardStackState();
}

class _CardStackState extends State<CardStack>
    with SingleTickerProviderStateMixin {
  var cards = [
    DiscCard(index: 0, imageUrl: "image1.jpeg"),
    DiscCard(index: 1, imageUrl: "image2.jpeg"),
    DiscCard(index: 2, imageUrl: "image3.jpeg"),
    DiscCard(index: 3, imageUrl: "image4.jpeg"),
    DiscCard(index: 4, imageUrl: "image5.jpeg"),
  ];
  int currentIndex;
  AnimationController controller;
  CurvedAnimation curvedAnimation;
  Animation<Offset> _translationAnimation;
  Animation<Offset> _moveAnimation;
  Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    currentIndex = 0;

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 150));

    curvedAnimation =
        CurvedAnimation(parent: controller, curve: Curves.easeOut);

    _translationAnimation =
        Tween(begin: Offset(0.0, 0.0), end: Offset(-1000.0, 0.0))
            .animate(controller);

    _scaleAnimation = Tween(begin: 0.7, end: 1.0).animate(controller);

    _moveAnimation = Tween(begin: Offset(0.0, 0.05), end: Offset(0.0, 0.0))
        .animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: cards.reversed.map((card) {
        if (cards.indexOf(card) <= 2) {
          return GestureDetector(
              onHorizontalDragEnd: _horizontalDragEnd,
              child: Transform.translate(
                  offset: _getFlickTransformOffset(card), // top card goes left
                  child: FractionalTranslation(
                    translation: _getStackedCardOffset(card),// next card goes up
                    child: Transform.scale(
                      scale: _getStackedCardScale(card), // next card scale up
                      child: card,
                    ),
                  )));
        }
        return Container();
      }).toList(),
    );
  }

  Offset _getStackedCardOffset(DiscCard card) {
    int diff = card.index - currentIndex;
    if (card.index == currentIndex + 1) {
      return _moveAnimation.value;
    } else if (diff > 0 && diff <= 2) {
      return Offset(0.0, 0.05 * diff);
    } else {
      return Offset(0.0, 0.0);
    }
  }

  double _getStackedCardScale(DiscCard card) {
    int diff = card.index - currentIndex;
    print(diff);
    if (card.index == currentIndex) return 1.0;// card changed
    if (card.index == currentIndex + 1) return _scaleAnimation.value;
    return (1 - (0.035 * diff.abs()));
  }

  Offset _getFlickTransformOffset(DiscCard card) {
    if (card.index == currentIndex) {
      return _translationAnimation.value;
    }
    return Offset(0.0, 0.0);
  }

  void _horizontalDragEnd(DragEndDetails details) {
    if (details.primaryVelocity < 0) {
      // Swiped Right to Left
      controller.forward().whenComplete(() {
        controller.reset();
        DiscCard removedCard = cards.removeAt(0);
        cards.add(removedCard);
        currentIndex = cards[0].index;
        if (widget.onCardChanged != null)
          widget.onCardChanged(cards[0].imageUrl);
      });
    }
  }
}

class DiscCard extends StatelessWidget {
  final int index;
  final String
      imageUrl; // TODO: should be moved to the corresponding model class.
  DiscCard({this.index, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle =
        Theme.of(context).textTheme.title.copyWith(fontSize: 24.0);
    TextStyle subtitleStyle =
        Theme.of(context).textTheme.subtitle.copyWith(color: Colors.grey);
    TextStyle buttonStyle =
        Theme.of(context).textTheme.button.copyWith(color: Colors.white);

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: Column(
          children: <Widget>[
            Image.asset(
              "assets/$imageUrl",
              width: 400,
            ),
            FractionalTranslation(
              translation: Offset(1.7, 0.5),
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.yellow,
                child: Icon(Icons.star),
                onPressed: () {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "One of the greatest numbers",
                style: titleStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Enjoy Hachimitsu Rocket!!",
                style: subtitleStyle,
              ),
            ),
            RaisedButton(
              elevation: 2.0,
              color: Colors.blue,
              child: Text(
                "Explore",
                style: buttonStyle,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}
