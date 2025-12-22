import 'dart:math';
import '../constants.dart';

/// 用户数据模型
class UserModel {
  final String id;
  final String nickname;
  final String avatarUrl;

  UserModel({
    required this.id,
    required this.nickname,
    required this.avatarUrl,
  });

  /// 创建一个示例用户
  factory UserModel.sample(int index) {
    final random = Random(Constants.RANDOM_SEED + index);
    
    // 名字列表
    final List<String> firstNames = [
      '小', '大', '老', '张', '王', '李', '赵', '钱', '孙', '周', 
      '吴', '郑', '冯', '陈', '楚', '魏', '蒋', '沈', '韩', '杨'
    ];
    
    final List<String> lastNames = [
      '明', '亮', '华', '强', '伟', '杰', '磊', '超', '涛', '斌',
      '芳', '娜', '静', '敏', '艳', '丽', '婷', '玲', '洁', '倩'
    ];
    
    final List<String> nicknamePrefixes = [
      'Dream✨', '追梦人', '落尘_', '江湖故人', '无名花开', 
      '微光', '星辰', '暖阳', '清风', '明月', '山海', '晨曦',
      '流年', '時光', '心动', '寂静', '漫步', '雨季', '向阳', '静好'
    ];
    
    // 生成昵称
    String nickname;
    final nicknameType = random.nextInt(3);
    
    switch (nicknameType) {
      case 0:
        // 真实姓名风格
        nickname = '${firstNames[random.nextInt(firstNames.length)]}${lastNames[random.nextInt(lastNames.length)]}';
        break;
      case 1:
        // 网名风格
        nickname = nicknamePrefixes[random.nextInt(nicknamePrefixes.length)];
        if (random.nextBool()) {
          nickname += random.nextInt(100).toString();
        }
        break;
      default:
        // 字母+数字风格
        final char = String.fromCharCode(65 + random.nextInt(26));
        nickname = '$char${random.nextInt(1000)}';
    }
    
    return UserModel(
      id: 'user_$index',
      nickname: nickname,
      avatarUrl: '', // 使用空字符串，将在UI中生成头像
    );
  }
} 