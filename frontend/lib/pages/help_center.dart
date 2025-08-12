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
          children: [
            // User Section
            HelpSection(
              title: "User",
              faqs: [
                HelpFaq(
                  question: "How to edit my profile?",
                  answer: """
1. Open the app and go to your profile page.
2. Tap on the "Edit" icon at the top right of the profile page.
3. Modify the details such as your name, username, profile picture, etc.
4. After making changes, tap the "Save" button to update your profile.
""",
                ),
                HelpFaq(
                  question: "How to change my password?",
                  answer: """
1. Go to the settings section of the app.
2. Tap on "Change Password."
3. Enter your current password for verification.
4. Enter the new password and confirm it by typing it again.
5. Tap "Save" to update your password.
""",
                ),
                HelpFaq(
                  question: "How to delete my account?",
                  answer: """
1. Open the settings page from the profile menu.
2. Scroll down and select "Delete Account."
3. Enter your password to verify.
4. Confirm that you want to permanently delete your account.
5. Your account will be deleted after confirmation, and you will be logged out of the app.
""",
                ),
                HelpFaq(
                  question: "How to recover my password?",
                  answer: """
1. Tap on the "Forgot Password" link on the login page.
2. Enter your email address associated with the account.
3. You will receive a password reset link via email.
4. Open the email and click the reset link.
5. Create a new password and confirm it.
6. Log in with your new password.
""",
                ),
                HelpFaq(
                  question: "How to update my email address?",
                  answer: """
1. Go to the profile page and tap the "Edit" icon.
2. Select the option to change your email address.
3. Enter your new email address and verify it.
4. Save the changes and a verification email will be sent to your new email.
5. Confirm the change by clicking on the link in your email.
""",
                ),
              ],
            ),
            // Post Section
            HelpSection(
              title: "Post",
              faqs: [
                HelpFaq(
                  question: "How to create a post?",
                  answer: """
1. Tap the '+' button located at the bottom center of the screen.
2. Choose a type of post (Text, Image, etc.).
3. Add a title and description for the post.
4. If applicable, attach media like images or videos.
5. Tap "Post" to share your content with others.
""",
                ),
                HelpFaq(
                  question: "How to edit a post?",
                  answer: """
1. Navigate to the post you want to edit.
2. Tap the three dots at the top right corner of the post.
3. Select "Edit" from the menu.
4. Make changes to your title, description, or media.
5. Tap "Save" to update the post.
""",
                ),
                HelpFaq(
                  question: "How to delete a post?",
                  answer: """
1. Go to the post you wish to delete.
2. Tap the three dots at the top right corner.
3. Select the "Delete" option from the menu.
4. A confirmation message will appear.
5. Tap "Confirm" to permanently delete the post.
""",
                ),
                HelpFaq(
                  question: "How to add tags to my post?",
                  answer: """
1. While creating a post, you will see an option to add tags.
2. Tap on the "Add Tags" button.
3. Enter keywords that relate to your post.
4. Tap "Done" or "Save" to attach tags to your post.
""",
                ),
                HelpFaq(
                  question: "How to share a post?",
                  answer: """
1. Open the post you want to share.
2. Tap the "Share" icon, usually represented by an arrow.
3. Choose your preferred sharing method (social media, messaging, etc.).
4. Select the recipient or platform and tap "Share."
""",
                ),
              ],
            ),
            // Feedback Section
            HelpSection(
              title: "Feedback",
              faqs: [
                HelpFaq(
                  question: "How to give feedback?",
                  answer: """
1. Open the app and go to settings.
2. Tap on "Give Feedback" under the Help section.
3. Choose the type of feedback (suggestion, bug report, etc.).
4. Enter your feedback in the provided text box.
5. Tap "Submit" to send your feedback to the support team.
""",
                ),
                HelpFaq(
                  question: "How to check feedback status?",
                  answer: """
1. Go to the settings page of the app.
2. Tap on "My Feedback."
3. View the status of your submitted feedback (Pending, Reviewed, etc.).
4. If your feedback has been resolved, you will be notified.
""",
                ),
                HelpFaq(
                  question: "Can I edit my feedback?",
                  answer: """
1. Once submitted, feedback cannot be edited.
2. If you need to modify your feedback, submit a new feedback entry with the updated information.
3. You can contact support if it's an urgent update.
""",
                ),
                HelpFaq(
                  question: "How to contact support for further assistance?",
                  answer: """
1. In the settings, tap on "Contact Support."
2. Choose the preferred method of communication (Email, Phone, etc.).
3. Enter your issue and submit it.
4. The support team will reach out to you with a resolution.
""",
                ),
                HelpFaq(
                  question: "How to rate the app?",
                  answer: """
1. Open the settings page.
2. Tap on "Rate App."
3. Choose a rating (1 to 5 stars).
4. Optionally, leave a comment.
5. Tap "Submit" to send your rating to the app store.
""",
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
  // ignore: library_private_types_in_public_api
  _HelpSectionState createState() => _HelpSectionState();
}

class _HelpSectionState extends State<HelpSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: Icon(
              _isExpanded
                  ? Icons.remove_circle_outline
                  : Icons.add_circle_outline,
              color: Colors.blue.shade600,
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded) ...widget.faqs.map((faq) => HelpFaqCard(faq: faq)),
        ],
      ),
    );
  }
}

class HelpFaqCard extends StatelessWidget {
  final HelpFaq faq;

  const HelpFaqCard({required this.faq, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            faq.question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            faq.answer,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class HelpFaq {
  final String question;
  final String answer;

  HelpFaq({required this.question, required this.answer});
}
