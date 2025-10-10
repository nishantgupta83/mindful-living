import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;
  final int maxLines;
  final EdgeInsetsGeometry? contentPadding;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.contentPadding,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _focusColorAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _focusColorAnimation = ColorTween(
      begin: AppColors.paleGray,
      end: AppColors.deepLavender,
    ).animate(_animationController);

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
        if (_isFocused) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: AppTypography.labelMedium.copyWith(
            color: _isFocused ? AppColors.deepLavender : AppColors.softCharcoal,
            fontWeight: FontWeight.w600,
          ),
          child: Text(widget.label),
        ),
        
        const SizedBox(height: 8),
        
        // Text Field
        AnimatedBuilder(
          animation: _focusColorAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.mistyWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _focusColorAnimation.value ?? AppColors.paleGray,
                  width: _isFocused ? 2 : 1,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.withOpacity(AppColors.deepLavender, 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                validator: widget.validator,
                onTap: widget.onTap,
                readOnly: widget.readOnly,
                maxLines: widget.maxLines,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.deepCharcoal,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.lightGray,
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _isFocused 
                              ? AppColors.deepLavender 
                              : AppColors.softCharcoal,
                        )
                      : null,
                  suffixIcon: widget.suffixIcon,
                  border: InputBorder.none,
                  contentPadding: widget.contentPadding ?? 
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}