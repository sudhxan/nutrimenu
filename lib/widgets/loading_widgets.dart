// widgets/loading_widgets.dart
import 'package:flutter/material.dart';

class ProcessingImageWidget extends StatefulWidget {
  final String message;
  final String? subMessage;

  const ProcessingImageWidget({
    Key? key,
    this.message = 'Processing your image...',
    this.subMessage,
  }) : super(key: key);

  @override
  State<ProcessingImageWidget> createState() => _ProcessingImageWidgetState();
}

class _ProcessingImageWidgetState extends State<ProcessingImageWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_rotateController);
    
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: AnimatedBuilder(
                  animation: _rotateController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateAnimation.value * 2 * 3.14159,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(0.6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Main message
          Text(
            widget.message,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (widget.subMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.subMessage!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Progress indicator
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;

  const CustomLoadingIndicator({
    Key? key,
    this.size = 40,
    this.color,
  }) : super(key: key);

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            children: List.generate(3, (index) {
              return Positioned.fill(
                child: Transform.rotate(
                  angle: (index * 2.0 * 3.14159 / 3) + (_animation.value * 2.0 * 3.14159),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: widget.size * 0.2,
                      height: widget.size * 0.2,
                      decoration: BoxDecoration(
                        color: (widget.color ?? Theme.of(context).primaryColor)
                            .withOpacity(0.7 - (index * 0.2)),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorStateWidget({
    Key? key,
    required this.title,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: Colors.red.shade400,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FadeInSlideUp extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const FadeInSlideUp({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  State<FadeInSlideUp> createState() => _FadeInSlideUpState();
}

class _FadeInSlideUpState extends State<FadeInSlideUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PulseAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(seconds: 1),
  }) : super(key: key);

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}