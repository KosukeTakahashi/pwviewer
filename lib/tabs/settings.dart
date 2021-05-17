import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pwviewer/constants/constants.dart';
import 'package:pwviewer/utils/query_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _authKey = SHARED_PREFERENCES_UNSET_AUTHORIZATION_KEY;
  int _tlLength = SHARED_PREFERENCES_DEFAULT_TIMELINE_LENGTH;

  Widget _buildAuthorization(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1.0,
            color: Colors.grey.shade300,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(Icons.vpn_key),
        title: Text('認証キー'),
        subtitle: Text(
          _authKey.isEmpty ? '<未設定>' : _authKey,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () async {
          final newKey = await showDialog(
            context: context,
            builder: (context) {
              return _AuthKeyEditorDialog(_authKey);
            },
          );

          if (newKey != null) {
            setState(() {
              _authKey = newKey;
            });

            final prefs = await SharedPreferences.getInstance();
            prefs.setString(SHARED_PREFERENCES_KEY_AUTHORIZATION_KEY, newKey);

            final snackBar = SnackBar(
              content: Container(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Text('認証キーを設定しました'),
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
      ),
    );
  }

  Widget _buildClearAuthKey(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.0, color: Colors.grey.shade300),
        ),
      ),
      child: ListTile(
        leading: Icon(Icons.clear),
        title: Text('認証キーをクリア'),
        onTap: () async {
          final doClear = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('認証キーをクリア'),
                content: Text('認証キーをしますか？'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: Text('クリアしない'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Text('クリアする'),
                  ),
                ],
              );
            },
          );

          if (doClear ?? false) {
            final prefs = await SharedPreferences.getInstance();
            prefs.setString(SHARED_PREFERENCES_KEY_AUTHORIZATION_KEY, '');

            setState(() {
              _authKey = '';
            });

            final snackBar = SnackBar(
              content: Container(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Text('認証キーをクリアしました'),
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
      ),
    );
  }

  Widget _buildTimelineLength(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.0, color: Colors.grey.shade300),
        ),
      ),
      child: ListTile(
        leading: Icon(Icons.format_list_numbered),
        title: Text('タイムラインの長さ'),
        subtitle: Text('$_tlLength'),
        onTap: () async {
          final newLength = await showDialog(
            context: context,
            builder: (context) {
              return _TlLengthEditorDialog(_tlLength);
            },
          );

          if (newLength != null) {
            setState(() {
              _tlLength = newLength;
            });
          }
        },
      ),
    );
  }

  Future _restorePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _authKey = prefs.getString(SHARED_PREFERENCES_KEY_AUTHORIZATION_KEY) ??
          SHARED_PREFERENCES_UNSET_AUTHORIZATION_KEY;
      _tlLength = prefs.getInt(SHARED_PREFERENCES_KEY_TIMELINE_LENGTH) ??
          SHARED_PREFERENCES_DEFAULT_TIMELINE_LENGTH;
    });
  }

  @override
  void initState() {
    super.initState();

    _restorePreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: [
          _buildAuthorization(context),
          _buildClearAuthKey(context),
          _buildTimelineLength(context),
        ],
      ),
      // child: _buildAuthorization(context),
    );
  }
}

class _AuthKeyEditorDialog extends StatefulWidget {
  final String _prevAuthKey;

  _AuthKeyEditorDialog(this._prevAuthKey);

  @override
  __AuthKeyEditorDialogState createState() => __AuthKeyEditorDialogState();
}

class __AuthKeyEditorDialogState extends State<_AuthKeyEditorDialog> {
  String _inputKey = '';
  bool _isConfirming = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _inputKey = widget._prevAuthKey;
      _isConfirming = false;
      _isValid = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('認証キー'),
      content: Container(
        child: TextFormField(
          enabled: true,
          obscureText: false,
          maxLines: 1,
          decoration: InputDecoration(
            icon: Icon(Icons.vpn_key),
            labelText: '認証キー',
            errorText: _isValid ? null : '無効な認証キーです',
          ),
          onChanged: (str) {
            setState(() {
              _inputKey = str;
            });
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('キャンセル'),
        ),
        TextButton(
          onPressed: _isConfirming
              ? null
              : () async {
                  setState(() {
                    _isConfirming = true;
                  });

                  final uri = Uri.parse(getAccountVerificationUrl());
                  final res = await http.get(
                    uri,
                    headers: {
                      REQUEST_HEADER_AUTHORIZATION:
                          REQUEST_HEADER_AUTHORIZATION_PREFIX + _inputKey,
                    },
                  );

                  if (res.statusCode == 200) {
                    // Valid token
                    setState(() {
                      _isConfirming = false;
                      _isValid = true;
                    });
                    Navigator.pop(context, _inputKey);
                  } else {
                    // Invalid token
                    setState(() {
                      _isConfirming = false;
                      _isValid = false;
                    });
                  }
                },
          child: Text('OK'),
        ),
      ],
    );
  }
}

class _TlLengthEditorDialog extends StatefulWidget {
  final int _prevTlLength;

  _TlLengthEditorDialog(this._prevTlLength);

  @override
  __TlLengthEditorDialogState createState() => __TlLengthEditorDialogState();
}

class __TlLengthEditorDialogState extends State<_TlLengthEditorDialog> {
  int _tlLength = 10;

  @override
  void initState() {
    super.initState();

    setState(() {
      _tlLength = widget._prevTlLength;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('タイムラインの長さ'),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text('$_tlLength'),
            ),
            Slider(
              label: '$_tlLength',
              min: 10,
              max: 100,
              value: _tlLength.toDouble(),
              divisions: 18,
              onChanged: (v) {
                setState(() {
                  _tlLength = v.toInt();
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('キャンセル'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _tlLength);
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}
