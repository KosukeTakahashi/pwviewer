import 'package:flutter/material.dart';
import 'package:pwviewer/models/account.dart';
import 'package:pwviewer/user_details/user_details.dart';

class Avatar extends StatelessWidget {
  final Account account;
  final double size;
  final bool allowJumpToProfile;

  Avatar(this.account, this.size, [this.allowJumpToProfile = true]);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!allowJumpToProfile) return;
        final args = UserDetailsArguments(account.id);

        Navigator.pushNamed(
          context,
          UserDetails.routeName,
          arguments: args,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: Image.network(
          account.avatar,
          width: size,
          height: size,
        ),
      ),
    );
  }
}
