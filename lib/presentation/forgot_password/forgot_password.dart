
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/progress_indicator_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/forgot_password/store/forgot_password_store.dart';
import 'package:boilerplate/utils/device/device_utils.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../di/service_locator.dart';


class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  //text controllers:-----------------------------------------------------------
  final TextEditingController _emailController = TextEditingController();

  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final ForgotPasswordStore _forgotPasswordStore = getIt<ForgotPasswordStore>();

  final Color _primaryOrange = Colors.orange.shade600;

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
        Center(child: _buildRightSide()),
        Observer(
          builder: (context) {
            return _forgotPasswordStore.resetEmailSent
                ? _showSuccessMessage(
                    'Reset link sent to ${_emailController.text}')
                : _showErrorMessage(
                    _forgotPasswordStore.errorStore.errorMessage);
          },
        ),
        Observer(
          builder: (context) {
            return Visibility(
              visible: _forgotPasswordStore.isLoading,
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
                const SizedBox(height: 24.0),
                _buildDescription(),
                const SizedBox(height: 32.0),
                _buildEmailField(),
                const SizedBox(height: 24.0),
                _buildResetButton(),
                const SizedBox(height: 16.0),
                _buildBackToLoginLink(),
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
            Icons.lock_reset_rounded,
            size: 42.0,
            color: _primaryOrange,
          ),
        ),
        const SizedBox(height: 20.0),
        Text(
          "RESET PASSWORD",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: isDark ? Colors.white : Colors.blueGrey.shade900,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Center(
      child: Text(
        'Enter your business email and we\'ll send you a link to reset your password from your JARVIS AEO account.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.0,
          height: 1.6,
          color: _themeStore.darkMode
              ? Colors.grey.shade400
              : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFieldWidget(
      hint: 'Enter your business email',
      inputType: TextInputType.emailAddress,
      icon: Icons.email_outlined,
      iconColor: _primaryOrange,
      textController: _emailController,
      inputAction: TextInputAction.done,
      autoFocus: false,
      onChanged: (value) {
        _forgotPasswordStore.setResetEmail(value);
      },
      onFieldSubmitted: (value) {
        DeviceUtils.hideKeyboard(context);
        _handleResetPassword();
      },
      errorText: '',
    );
  }

  Widget _buildResetButton() {
    return RoundedButtonWidget(
      buttonText: 'Send Reset Link',
      buttonColor: _primaryOrange,
      textColor: Colors.white,
      onPressed: () {
        DeviceUtils.hideKeyboard(context);
        _handleResetPassword();
      },
    );
  }

  Future<void> _handleResetPassword() async {
    if (_emailController.text.isEmpty) {
      _forgotPasswordStore.errorStore
          .setErrorMessage('Please enter your email address');
      return;
    }
    await _forgotPasswordStore.sendPasswordReset(_emailController.text);
  }

  Widget _buildBackToLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Remember your password? ',
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
            'Back to Login',
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

  _showSuccessMessage(String message) {
    if (message.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 0), () {
        if (message.isNotEmpty) {
          FlushbarHelper.createSuccess(
            message: message,
            title: 'Success',
            duration: const Duration(seconds: 4),
          )..show(context);
        }
      });
    }

    return const SizedBox.shrink();
  }

  // dispose:-------------------------------------------------------------------
  @override
  void dispose() {
    _emailController.dispose();
    _forgotPasswordStore.dispose();
    super.dispose();
  }
}
