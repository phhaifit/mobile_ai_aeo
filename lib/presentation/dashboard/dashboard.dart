import 'package:boilerplate/utils/routes/routes.dart';
import 'package:boilerplate/presentation/all_posts/all_posts_screen.dart';
import 'package:boilerplate/presentation/ai_writer/ai_writer_screen.dart';
import 'package:boilerplate/presentation/auto_generation/auto_generation_screen.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigation'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              _buildTitle('Select to navigate'),
              SizedBox(height: 40),
              SizedBox(height: 20),
              _buildNavigationButton(
                context,
                title: 'Overview',
                description: 'Overview',
                icon: Icons.dashboard,
                color: Colors.purple,
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.overview);
                },
              ),
              SizedBox(height: 20),
              _buildNavigationButton(
                context,
                title: 'Template Library',
                description: 'Writing Styles & Analysis',
                icon: Icons.style,
                color: Colors.teal,
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.templateLibrary);
                },
              ),
              SizedBox(height: 20),
              _buildNavigationButton(
                context,
                title: 'Login',
                description: 'Login',
                icon: Icons.login,
                color: Colors.orange,
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.login);
                },
              ),
              SizedBox(height: 20),
              _buildNavigationButton(
                context,
                title: 'All Posts',
                description: 'View all posts',
                icon: Icons.list,
                color: Colors.blue,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AllPostsScreen()),
                  );
                },
              ),
              SizedBox(height: 20),
              _buildNavigationButton(
                context,
                title: 'AI Writer',
                description: 'Generate content with AI',
                icon: Icons.edit_note,
                color: Colors.green,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AiWriterScreen()),
                  );
                },
              ),
              SizedBox(height: 20),
              _buildNavigationButton(
                context,
                title: 'Auto Generation',
                description: 'Automate content generation',
                icon: Icons.autorenew,
                color: Colors.red,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => AutoGenerationScreen()),
                  );
                },
              ),
              SizedBox(height: 20),
              _buildNavigationButton(
                context,
                title: 'Cronjob Automation',
                description: 'Manage scheduled automation jobs',
                icon: Icons.schedule,
                color: Colors.teal,
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.cronjobList);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.05),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
