import 'package:example/model/feature_model.dart';
import 'package:example/widget/feature_widget.dart';
import 'package:flutter/material.dart';

class FeaturesScreen extends StatefulWidget {
  const FeaturesScreen({super.key});

  @override
  State<FeaturesScreen> createState() => _FeaturesScreenState();
}

class _FeaturesScreenState extends State<FeaturesScreen> {
  List<FeatureModel> features = [
    FeatureModel(
      title: 'HLS Video Player',
      desc: 'Video Player with resolution and subtitle',
      key: 'HLS_VIDEO_PLAYER',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('List of Feature')),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 10),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return GestureDetector(
            onTap: () async {
              switch (feature.key) {
                case 'HLS_VIDEO_PLAYER':
                  Navigator.of(context).pushNamed('/');
                  break;
              }
            },
            child: ItemFeatureWidget(
              feature: features[index],
            ),
          );
        },
      ),
    );
  }
}
