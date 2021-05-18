import 'package:flutter/material.dart';
import 'package:pwviewer/avatar/avatar.dart';
import 'package:pwviewer/models/account.dart';
import 'package:pwviewer/user_details/user_details.dart';

class UserItem extends StatelessWidget {
  final Account userAccount;

  UserItem(this.userAccount);

  Widget _buildAvatar(BuildContext context) {
    return Avatar(userAccount, 48);
  }

  Widget _buildNames(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userAccount.displayName,
          style:
              Theme.of(context).textTheme.bodyText1?.apply(fontWeightDelta: 1),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '@${userAccount.acct}',
          style: Theme.of(context).textTheme.caption,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          final args = UserDetailsArguments(userAccount.id);
          Navigator.pushNamed(context, UserDetails.routeName, arguments: args);
        },
        child: Container(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Flexible(
                flex: 0,
                child: _buildAvatar(context),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(left: 16),
                  child: _buildNames(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
