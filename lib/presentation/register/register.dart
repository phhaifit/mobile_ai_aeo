import 'package:another_flushbar/flushbar_helper.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/progress_indicator_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/utils/device/device_utils.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../di/service_locator.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //text controllers:-----------------------------------------------------------
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final FormStore _formStore = getIt<FormStore>();
  final UserStore _userStore = getIt<UserStore>();

  //focus nodes:----------------------------------------------------------------
  late FocusNode _passwordFocusNode;
  late FocusNode _confirmPasswordFocusNode;

  //state variables:------------------------------------------------------------
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      appBar: EmptyAppBar(),
      body: _buildBody(),
    );
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        // Background với LinearGradient giống Login
        _buildBackground(),
        // Main Content
        MediaQuery.of(context).orientation == Orientation.landscape
            ? Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: SizedBox.shrink(),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildRightSide(),
                  ),
                ],
              )
            : Center(child: _buildRightSide()),
        // Observer cho success/error
        Observer(
          builder: (context) {
            return _userStore.success
                ? navigate(context)
                : _showErrorMessage(_formStore.errorStore.errorMessage);
          },
        ),
        // Observer cho loading indicator
        Observer(
          builder: (context) {
            return Visibility(
              visible: _userStore.isLoading,
              child: CustomProgressIndicatorWidget(),
            );
          },
        )
      ],
    );
  }

  Widget _buildBackground() {
    // Sử dụng Gradient màu cam/đen tạo cảm giác chuyên nghiệp, bảo mật cho hệ thống AEO
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade800,
            Colors.orange.shade500,
            Colors.black87,
          ],
          stops: [0.0, 0.4, 1.0],
        ),
      ),
    );
  }

  Widget _buildRightSide() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Card(
          elevation: 12.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          color: _themeStore.darkMode ? Colors.grey[900] : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // --- PHẦN BRANDING AEO ---
                Center(
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.security_rounded,
                      size: 48.0,
                      color: Colors.orange,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  "AEO PORTAL",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  "Empowering Secure & Efficient Trade",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontStyle: FontStyle.italic,
                    color: _themeStore.darkMode
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
                // --- KẾT THÚC PHẦN BRANDING ---

                SizedBox(height: 36.0),
                // Tiêu đề "Create Account"
                Text(
                  AppLocalizations.of(context).translate('register_title') ??
                      'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    color:
                        _themeStore.darkMode ? Colors.white : Colors.grey[800],
                  ),
                ),
                SizedBox(height: 24.0),

                // Form fields
                _buildEmailField(),
                SizedBox(height: 12.0),
                _buildPasswordField(),
                SizedBox(height: 12.0),
                _buildConfirmPasswordField(),
                SizedBox(height: 24.0),

                // Submit button
                _buildRegisterButton(),
                SizedBox(height: 16.0),

                // Login link
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: AppLocalizations.of(context).translate('register_et_email') ??
              'Email Address',
          inputType: TextInputType.emailAddress,
          icon: Icons.email_outlined,
          iconColor: Colors.orange,
          textController: _emailController,
          inputAction: TextInputAction.next,
          autoFocus: false,
          onChanged: (value) {
            _formStore.setUserId(_emailController.text);
          },
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
          errorText: _formStore.formErrorStore.userEmail,
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return Observer(
      builder: (context) {
        return Stack(
          alignment: Alignment.centerRight,
          children: [
            TextFieldWidget(
              hint: AppLocalizations.of(context)
                      .translate('register_et_password') ??
                  'Password',
              isObscure: !_isPasswordVisible,
              padding: EdgeInsets.only(top: 16.0),
              icon: Icons.lock_outline,
              iconColor: Colors.orange,
              textController: _passwordController,
              focusNode: _passwordFocusNode,
              errorText: _formStore.formErrorStore.password,
              inputAction: TextInputAction.next,
              onChanged: (value) {
                _formStore.setPassword(_passwordController.text);
              },
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
              },
            ),
            Positioned(
              top: 16.0,
              right: 0.0,
              child: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.orange,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextFieldWidget(
          hint: AppLocalizations.of(context)
                  .translate('register_et_confirm_password') ??
              'Confirm Password',
          isObscure: !_isConfirmPasswordVisible,
          padding: EdgeInsets.only(top: 16.0),
          icon: Icons.lock_reset,
          iconColor: Colors.orange,
          textController: _confirmPasswordController,
          focusNode: _confirmPasswordFocusNode,
          inputAction: TextInputAction.done,
          onChanged: (value) {
            // Có thể thêm validation xác nhận mật khẩu ở đây
          },
          onFieldSubmitted: (value) {
            DeviceUtils.hideKeyboard(context);
          },
          errorText: '',
        ),
        Positioned(
          top: 16.0,
          right: 0.0,
          child: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: Colors.orange,
            ),
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return RoundedButtonWidget(
      buttonText:
          AppLocalizations.of(context).translate('register_btn_register') ??
              'Register',
      buttonColor: Colors.orange,
      textColor: Colors.white,
      onPressed: () async {
        // Kiểm tra xác nhận mật khẩu
        if (_passwordController.text != _confirmPasswordController.text) {
          _showErrorMessage('Passwords do not match');
          return;
        }

        if (_formStore.canRegister) {
          DeviceUtils.hideKeyboard(context);
          // TODO: Gọi _userStore.register() với email, password
          // _userStore.register(_emailController.text, _passwordController.text);
        } else {
          _showErrorMessage('Please fill in all fields');
        }
      },
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)
                    .translate('register_already_account') ??
                'Already have an account? ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _themeStore.darkMode
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(50, 30),
            ),
            child: Text(
              AppLocalizations.of(context).translate('register_login_link') ??
                  'Login',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget navigate(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(Preferences.is_logged_in, true);
    });

    Future.delayed(Duration(milliseconds: 0), () {
      Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.home, (Route<dynamic> route) => false);
    });

    return Container();
  }

  // General Methods:-----------------------------------------------------------
  _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 0), () {
        if (message.isNotEmpty) {
          FlushbarHelper.createError(
            message: message,
            title: AppLocalizations.of(context).translate('home_tv_error') ??
                'Error',
            duration: Duration(seconds: 3),
          )..show(context);
        }
      });
    }

    return SizedBox.shrink();
  }

  // dispose:-------------------------------------------------------------------
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }
}
