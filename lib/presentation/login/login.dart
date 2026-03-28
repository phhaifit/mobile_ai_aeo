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

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //text controllers:-----------------------------------------------------------
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final FormStore _formStore = getIt<FormStore>();
  final UserStore _userStore = getIt<UserStore>();

  //focus node:-----------------------------------------------------------------
  late FocusNode _passwordFocusNode;

  //state variables:------------------------------------------------------------
  bool _isPasswordVisible = false;

  // Định nghĩa màu cam chuẩn doanh nghiệp (hơi trầm và sang hơn cam chói)
  final Color _primaryOrange = Colors.orange.shade600;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      appBar: EmptyAppBar(),
      // Sử dụng Observer bọc ngoài Scaffold body để nền thay đổi mượt theo Theme
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
                    child:
                        _buildWelcomeBanner(), // Thêm banner chào mừng cho màn hình ngang
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
            return _userStore.success
                ? navigate(context)
                : _showErrorMessage(_formStore.errorStore.errorMessage);
          },
        ),
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

  // --- NỀN GIAO DIỆN HIỆN ĐẠI ---
  Widget _buildBackground() {
    bool isDark = _themeStore.darkMode;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F8),
        // Thêm họa tiết nền mờ ảo (tùy chọn, ở đây dùng gradient siêu nhẹ để không bị phẳng)
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

  // --- BANNER CHO MÀN HÌNH NGANG (TABLET/WEB) ---
  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_rounded, size: 60, color: _primaryOrange),
          const SizedBox(height: 24),
          Text(
            "Authorized\nEconomic Operator",
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
            "Streamlining global trade with enhanced security and efficiency for certified businesses.",
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

  // --- FORM ĐĂNG NHẬP CHÍNH ---
  Widget _buildRightSide() {
    bool isDark = _themeStore.darkMode;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Container(
          constraints: const BoxConstraints(
              maxWidth: 450), // Giới hạn độ rộng form cho gọn gàng
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
            padding: const EdgeInsets.all(
                40.0), // Padding rộng rãi tạo cảm giác thoáng
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildHeader(isDark),
                const SizedBox(height: 40.0),
                _buildUserIdField(),
                const SizedBox(height: 20.0),
                _buildPasswordField(),
                const SizedBox(height: 16.0),
                _buildActionButtons(),
                const SizedBox(height: 32.0),
                _buildSignInButton()
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
        // Logo Badge
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: _primaryOrange.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Icon(
            Icons.shield_outlined, // Icon khiên thể hiện AEO Security
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

  Widget _buildUserIdField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: AppLocalizations.of(context).translate('login_et_user_email'),
          inputType: TextInputType.emailAddress,
          icon: Icons.business_center_outlined, // Icon phù hợp với doanh nghiệp
          iconColor: _themeStore.darkMode
              ? Colors.grey.shade400
              : Colors.blueGrey.shade400,
          textController: _userEmailController,
          inputAction: TextInputAction.next,
          autoFocus: false,
          onChanged: (value) {
            _formStore.setUserId(_userEmailController.text);
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
                  .translate('login_et_user_password'),
              isObscure: !_isPasswordVisible,
              padding: const EdgeInsets.only(top: 16.0),
              icon: Icons.lock_outline,
              iconColor: _themeStore.darkMode
                  ? Colors.grey.shade400
                  : Colors.blueGrey.shade400,
              textController: _passwordController,
              focusNode: _passwordFocusNode,
              errorText: _formStore.formErrorStore.password,
              onChanged: (value) {
                _formStore.setPassword(_passwordController.text);
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
                  color: _themeStore.darkMode
                      ? Colors.grey.shade500
                      : Colors.blueGrey.shade300,
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
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            "Create Account",
            style: TextStyle(
              color: _primaryOrange,
              fontWeight: FontWeight.w600,
              fontSize: 14.0,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pushNamed(Routes.register);
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            AppLocalizations.of(context).translate('login_btn_forgot_password'),
            style: TextStyle(
              color: _themeStore.darkMode
                  ? Colors.grey.shade400
                  : Colors.blueGrey.shade600,
              fontWeight: FontWeight.w500,
              fontSize: 14.0,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pushNamed(Routes.forgotPassword);
          },
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RoundedButtonWidget(
          buttonText:
              AppLocalizations.of(context).translate('login_btn_sign_in'),
          buttonColor: _primaryOrange,
          textColor: Colors.white,
          onPressed: () async {
            if (_formStore.canLogin) {
              DeviceUtils.hideKeyboard(context);
              _userStore.login(
                  _userEmailController.text, _passwordController.text);
            } else {
              _showErrorMessage('Please enter valid corporate credentials');
            }
          },
        ),
        const SizedBox(height: 16.0),
        _buildGoogleSignInButton(),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    bool isDark = _themeStore.darkMode;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _showErrorMessage('Google Sign-In - Mock Implementation');
          // Mock Google Sign-In
          Future.delayed(const Duration(seconds: 1), () {
            _userStore.login('user@google.com', 'mock_password');
          });
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.g_mobiledata,
                size: 24.0,
                color: Colors.red.shade400,
              ),
              const SizedBox(width: 12.0),
              Text(
                'Continue with Google',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget navigate(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(Preferences.is_logged_in, true);
    });

    Future.delayed(const Duration(milliseconds: 0), () {
      Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.home, (Route<dynamic> route) => false);
    });

    return Container();
  }

  // General Methods:-----------------------------------------------------------
  _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 0), () {
        if (message.isNotEmpty) {
          FlushbarHelper.createError(
            message: message,
            title: AppLocalizations.of(context).translate('home_tv_error'),
            duration: const Duration(seconds: 3),
          )..show(context);
        }
      });
    }
    return const SizedBox.shrink();
  }

  // dispose:-------------------------------------------------------------------
  @override
  void dispose() {
    _userEmailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
