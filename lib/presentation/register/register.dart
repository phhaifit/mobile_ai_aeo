import 'package:another_flushbar/flushbar_helper.dart';
import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/progress_indicator_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/register/store/register_store.dart';
import 'package:boilerplate/utils/device/device_utils.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../di/service_locator.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //text controllers:-----------------------------------------------------------
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final RegisterStore _registerStore = getIt<RegisterStore>();
  final ErrorStore _errorStore = getIt<ErrorStore>();

  //focus nodes:----------------------------------------------------------------
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;

  //state variables:------------------------------------------------------------
  bool _isPasswordVisible = false;

  final Color _primaryOrange = Colors.orange.shade600;
  final Color _accentColor = Colors.orange.shade400;

  @override
  void initState() {
    super.initState();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      appBar: EmptyAppBar(),
      body: Observer(
        builder: (_) => _buildBody(),
      ),
    );
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        _buildBackground(),
        MediaQuery.of(context).orientation == Orientation.landscape
            ? Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: _buildWelcomeBanner(),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(child: _buildRightSide()),
                  ),
                ],
              )
            : Center(child: _buildRightSide()),
        Observer(
          builder: (context) {
            return _registerStore.success
                ? navigate(context)
                : _showErrorMessage(_errorStore.errorMessage);
          },
        ),
        Observer(
          builder: (context) {
            return Visibility(
              visible: _registerStore.isLoading,
              child: CustomProgressIndicatorWidget(),
            );
          },
        )
      ],
    );
  }

  Widget _buildBackground() {
    bool isDark = _themeStore.darkMode;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F8),
        gradient: isDark
            ? LinearGradient(
                colors: [Color(0xFF1A1A24), Color(0xFF121212)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFF4F6F8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security_rounded, size: 60, color: _primaryOrange),
          const SizedBox(height: 24),
          Text(
            "Create Account\nAEO PORTAL",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: _themeStore.darkMode
                  ? Colors.white
                  : Colors.blueGrey.shade900,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Secure Trade Compliance Platform. Join thousands of certified businesses.",
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: _themeStore.darkMode
                  ? Colors.grey.shade400
                  : Colors.blueGrey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightSide() {
    bool isDark = _themeStore.darkMode;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black38
                    : Colors.blueGrey.shade100.withOpacity(0.5),
                blurRadius: 30.0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildHeader(isDark),
                const SizedBox(height: 32.0),
                _buildFullnameField(),
                const SizedBox(height: 16.0),
                _buildEmailField(),
                const SizedBox(height: 16.0),
                _buildPasswordField(),
                const SizedBox(height: 24.0),
                _buildRegisterButton(),
                const SizedBox(height: 16.0),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: _primaryOrange.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Icon(
            Icons.shield_outlined,
            size: 42.0,
            color: _primaryOrange,
          ),
        ),
        const SizedBox(height: 20.0),
        Text(
          "JARVIS AEO",
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: isDark ? Colors.white : Colors.blueGrey.shade900,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          "Secure Trade Compliance",
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildFullnameField() {
    return TextFieldWidget(
      hint: 'Full Name',
      inputType: TextInputType.name,
      icon: Icons.person_outline,
      iconColor: _accentColor,
      textController: _fullnameController,
      inputAction: TextInputAction.next,
      autoFocus: true,
      onChanged: (value) {},
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_emailFocusNode);
      },
      errorText: '',
    );
  }

  Widget _buildEmailField() {
    return TextFieldWidget(
      hint: ' Email',
      inputType: TextInputType.emailAddress,
      icon: Icons.email_outlined,
      iconColor: _accentColor,
      textController: _emailController,
      focusNode: _emailFocusNode,
      inputAction: TextInputAction.next,
      autoFocus: false,
      onChanged: (value) {},
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      },
      errorText: '',
    );
  }

  Widget _buildPasswordField() {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextFieldWidget(
          hint: 'Password',
          isObscure: !_isPasswordVisible,
          padding: const EdgeInsets.only(top: 16.0),
          icon: Icons.lock_outline,
          iconColor: _accentColor,
          textController: _passwordController,
          focusNode: _passwordFocusNode,
          errorText: '',
          inputAction: TextInputAction.done,
          onChanged: (value) {},
          onFieldSubmitted: (value) {
            DeviceUtils.hideKeyboard(context);
          },
        ),
        Positioned(
          top: 16.0,
          right: 4.0,
          child: IconButton(
            splashRadius: 20.0,
            icon: Icon(
              _isPasswordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: _accentColor,
              size: 20.0,
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
  }

  Widget _buildRegisterButton() {
    return RoundedButtonWidget(
      buttonText: 'Create Account',
      buttonColor: _primaryOrange,
      textColor: Colors.white,
      onPressed: () async {
        DeviceUtils.hideKeyboard(context);

        if (_fullnameController.text.isEmpty) {
          _errorStore.setErrorMessage('Please enter your full name');
          _showErrorMessage('Please enter your full name');
          return;
        }

        if (_emailController.text.isEmpty) {
          _errorStore.setErrorMessage('Please enter your email');
          _showErrorMessage('Please enter your email');
          return;
        }

        if (_passwordController.text.isEmpty) {
          _errorStore.setErrorMessage('Please enter your password');
          _showErrorMessage('Please enter your password');
          return;
        }

        if (_passwordController.text.length < 6) {
          _errorStore.setErrorMessage('Password must be at least 6 characters');
          _showErrorMessage('Password must be at least 6 characters');
          return;
        }

        await _registerStore.register(
          _emailController.text,
          _passwordController.text,
          _passwordController.text,
        );
      },
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(
            fontSize: 13.0,
            color: _themeStore.darkMode
                ? Colors.grey.shade400
                : Colors.grey.shade600,
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Sign In',
            style: TextStyle(
              color: _primaryOrange,
              fontWeight: FontWeight.w600,
              fontSize: 14.0,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget navigate(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.home, (Route<dynamic> route) => false);
    });

    return Container();
  }

  _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 0), () {
        if (message.isNotEmpty) {
          FlushbarHelper.createError(
            message: message,
            title: 'Error',
            duration: const Duration(seconds: 3),
          )..show(context);
        }
      });
    }

    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _registerStore.dispose();
    super.dispose();
  }
}
