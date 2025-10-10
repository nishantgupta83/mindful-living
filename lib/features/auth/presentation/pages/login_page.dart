import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pastel_card.dart';
import '../../../../shared/widgets/pastel_button.dart';
import '../widgets/auth_text_field.dart';
import 'signup_page.dart';
import '../../../../shared/widgets/main_navigation.dart';
import '../../data/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authService = Provider.of<AuthService>(context, listen: false);

      final result = await authService.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (result != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainNavigation()),
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authService.errorMessage ?? 'Login failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);

    final result = await authService.signInWithGoogle();

    if (mounted) {
      setState(() => _isLoading = false);

      if (result != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.errorMessage ?? 'Google sign-in failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loginWithApple() async {
    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);

    final result = await authService.signInWithApple();

    if (mounted) {
      setState(() => _isLoading = false);

      if (result != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.errorMessage ?? 'Apple sign-in failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendPasswordReset() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);

    final success = await authService.sendPasswordReset(
      email: _emailController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Password reset email sent. Please check your inbox.'
                : authService.errorMessage ?? 'Failed to send reset email',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.createGradient(AppColors.dreamGradient),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.08),
                
                // Welcome Section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // App Icon/Logo Placeholder
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.mistyWhite,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowLight,
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.self_improvement,
                          size: 40,
                          color: AppColors.deepLavender,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      Text(
                        'Welcome Back',
                        style: AppTypography.headlineLarge.copyWith(
                          color: AppColors.deepLavender,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Continue your mindful journey',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.softCharcoal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: size.height * 0.06),
                
                // Login Form
                SlideTransition(
                  position: _slideAnimation,
                  child: PastelCard.elevated(
                    backgroundColor: AppColors.mistyWhite,
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AuthTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value!)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          AuthTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Enter your password',
                            obscureText: _obscurePassword,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword 
                                    ? Icons.visibility_off_outlined 
                                    : Icons.visibility_outlined,
                                color: AppColors.softCharcoal,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your password';
                              }
                              if (value!.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _sendPasswordReset,
                              child: Text(
                                'Forgot Password?',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.deepLavender,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Login Button
                          PastelButton.gradient(
                            text: 'Sign In',
                            onPressed: _isLoading ? null : _login,
                            gradientColors: AppColors.oceanGradient,
                            isLoading: _isLoading,
                            size: PastelButtonSize.large,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Divider
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.paleGray)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.lightGray,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.paleGray)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Social Login Options
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    children: [
                      Expanded(
                        child: PastelButton(
                          text: 'Google',
                          onPressed: _isLoading ? null : _loginWithGoogle,
                          style: PastelButtonStyle.secondary,
                          icon: Icons.g_mobiledata,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PastelButton(
                          text: 'Apple',
                          onPressed: _isLoading ? null : _loginWithApple,
                          style: PastelButtonStyle.secondary,
                          icon: Icons.apple,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Sign Up Link
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.softCharcoal,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.deepLavender,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}