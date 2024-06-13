import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TransportCard extends StatelessWidget {
  final String transportType;
  final String svgAssetPath;
  final VoidCallback onTap;
  final Color SVGColor;
  final Color BGcolor ; 
final double width ; 
final double height ; 


  const TransportCard({
    required this.transportType,
    required this.svgAssetPath,
    required this.onTap,
    required this.SVGColor,
    required this.BGcolor , 
    required this.width , 
    required this.height , 
    
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: BGcolor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              // Use SvgPicture.asset to display SVG from asset
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  transportType,
                  style: const TextStyle(
                  color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic
                  ),
                ),
              ),
              SvgPicture.asset(
                svgAssetPath,
                width: width,
                height: height,
                color: SVGColor,
                 // Customize SVG color here
              ),
            ],
          ),
        ),
      ),
    );
  }
}