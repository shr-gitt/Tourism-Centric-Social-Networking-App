import 'package:flutter/material.dart';
import 'package:frontend/pages/settings.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Settings()),
          ),
        ),
        title: const Text('Help Center'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            HelpSection(
              title: "User",
              faqs: [
                HelpFaq(
                  question: "How do I edit my profile?",
                  answer: """1. Tap your profile icon at the bottom right.
2. On your profile page, tap the edit icon (pencil) in the top right.
3. Edit your name, bio, username, or profile picture.
4. Tap Save to apply changes.""",
                ),
                HelpFaq(
                  question: "How do I change my password?",
                  answer: """1. Go to Settings > Account > Change Password.
2. Enter your current password, then your new password.
3. Confirm the new password.
4. Tap Save. You’ll see a confirmation if successful.""",
                ),
                HelpFaq(
                  question: "How do I delete my account?",
                  answer: """1. Navigate to Settings > Account > Delete Account.
2. Read the warning — this action is permanent.
3. Enter your password to confirm your identity.
4. Tap Delete. Your account and all content will be removed.""",
                ),
                HelpFaq(
                  question: "How do I recover a forgotten password?",
                  answer: """1. On the login screen, tap Forgot Password?
2. Enter the email linked to your account.
3. Check your inbox for a password reset link.
4. Tap the link, set a new password, and confirm it.
5. Log in with your new password.""",
                ),
                HelpFaq(
                  question: "How do I update my email?",
                  answer: """1. Go to Profile > Edit > Email Address.
2. Enter your new email and confirm it.
3. A verification link will be sent to the new address.
4. Open the email and tap Verify.
5. Your email will be updated once verified.""",
                ),
              ],
            ),
            HelpSection(
              title: "Post",
              faqs: [
                HelpFaq(
                  question: "How do I create a post?",
                  answer: """1. Tap the + button at the bottom center.
2. Select a post type: Text, Image, or Video.
3. Add a title, description, and optional media.
4. Choose privacy (Public/Private) and tags.
5. Tap Post to publish.""",
                ),
                HelpFaq(
                  question: "How do I edit a post?",
                  answer: """1. Open the post you want to update.
2. Tap the three dots (⋮) at the top right.
3. Select Edit.
4. Modify content, images, or tags.
5. Tap Save to update the post.""",
                ),
                HelpFaq(
                  question: "How do I delete a post?",
                  answer: """1. Go to your post.
2. Tap the three dots (⋮) > Delete.
3. Confirm deletion in the popup.
4. The post will be permanently removed.""",
                ),
                HelpFaq(
                  question: "How do I add tags?",
                  answer:
                      """1. While creating or editing a post, scroll to the Tags section.
2. Tap Add Tag, and enter relevant keywords (e.g., “fitness”, “travel”).
3. Tap Done to save your tags.
4. Tags improve visibility and searchability.""",
                ),
                HelpFaq(
                  question: "How do I share a post?",
                  answer: """1. Tap on the post to open it fully.
2. Tap the Share icon (arrow or box with arrow).
3. Choose an app (e.g., WhatsApp, Instagram, Email).
4. Follow the platform's steps to share.""",
                ),
              ],
            ),
            HelpSection(
              title: "Feedback",
              faqs: [
                HelpFaq(
                  question: "How do I give feedback?",
                  answer: """1. Go to Settings > Help & Support > Give Feedback.
2. Choose a feedback type: Bug Report, Feature Request, General Feedback.
3. Describe your issue or suggestion in the form.
4. Optionally attach a screenshot.
5. Tap Submit. You’ll get an acknowledgment.""",
                ),
                HelpFaq(
                  question: "How do I check feedback status?",
                  answer: """1. Go to Settings > Help & Support > My Feedback.
2. You’ll see a list of your feedback entries.
3. Each will show a status: Pending, Reviewed, or Resolved.
4. Tap any entry to view the details.""",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HelpSection extends StatefulWidget {
  final String title;
  final List<HelpFaq> faqs;

  const HelpSection({required this.title, required this.faqs, super.key});

  @override
  State<HelpSection> createState() => _HelpSectionState();
}

class _HelpSectionState extends State<HelpSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.blue,
            ),
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
            },
          ),
          if (_isExpanded) ...widget.faqs.map((faq) => HelpFaqTile(faq: faq)),
        ],
      ),
    );
  }
}

class HelpFaqTile extends StatefulWidget {
  final HelpFaq faq;

  const HelpFaqTile({required this.faq, super.key});

  @override
  State<HelpFaqTile> createState() => _HelpFaqTileState();
}

class _HelpFaqTileState extends State<HelpFaqTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              widget.faq.question,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            trailing: Icon(
              _isExpanded
                  ? Icons.remove_circle_outline
                  : Icons.add_circle_outline,
              color: Colors.grey[600],
            ),
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
            },
          ),
          if (_isExpanded)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.faq.answer,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
              ),
            ),
        ],
      ),
    );
  }
}

class HelpFaq {
  final String question;
  final String answer;

  const HelpFaq({required this.question, required this.answer});
}
