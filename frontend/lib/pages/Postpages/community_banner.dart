import 'package:flutter/material.dart';
import 'package:frontend/pages/Postpages/community.dart';
import 'package:getwidget/getwidget.dart';

class CommunityBanner extends StatefulWidget {
  final String data;
  final bool isPost;

  const CommunityBanner({super.key, required this.data, required this.isPost});

  @override
  State<CommunityBanner> createState() => _CommunityBannerState();
}

class _CommunityBannerState extends State<CommunityBanner> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isPost = widget.isPost;
    final data = widget.data;

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CommunityPage(communityName: data),
              ),
            );
          },
          child: GFAvatar(
            radius: isPost ? 12 : 25,
            backgroundImage: NetworkImage(
              'https://localhost:5259/Images/community.jpg',
            ),
          ),
        ),

        const SizedBox(width: 5),

        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            alignment: Alignment.centerLeft,
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CommunityPage(communityName: data),
            ),
          ),

          child: Text(
            data,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
