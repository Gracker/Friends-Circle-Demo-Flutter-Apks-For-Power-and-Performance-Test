import 'package:flutter/material.dart';
import '../models/praise_model.dart';
import '../utils/asset_generator.dart';

/// 点赞区域组件
class PraiseSection extends StatelessWidget {
  final List<PraiseModel> praises;

  const PraiseSection({
    Key? key,
    required this.praises,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 点赞图标
        const Padding(
          padding: EdgeInsets.only(top: 2, right: 4),
          child: Icon(
            Icons.favorite,
            size: 14,
            color: Colors.red,
          ),
        ),
        
        // 点赞用户列表
        Expanded(
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: praises.asMap().entries.map((entry) {
              final index = entry.key;
              final praise = entry.value;
              
              // 显示逗号分隔符
              final showComma = index < praises.length - 1;
              
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    praise.user.nickname,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF576B95),
                    ),
                  ),
                  if (showComma)
                    const Text(
                      '，',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF333333),
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
} 