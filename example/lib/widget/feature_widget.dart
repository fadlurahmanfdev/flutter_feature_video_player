import 'package:example/model/feature_model.dart';
import 'package:flutter/material.dart';

class ItemFeatureWidget extends StatelessWidget {
  final FeatureModel feature;
  const ItemFeatureWidget({
    super.key,
    required this.feature,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(Icons.developer_mode),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(feature.title),
                Text(feature.desc),
              ],
            ),
          )
        ],
      ),
    );
  }
}