import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nandiott_flutter/app/widgets/customappbar.dart';
import 'package:nandiott_flutter/features/profile/issueDropdown_widget.dart';
import 'package:nandiott_flutter/features/profile/tset_helperfocus.dart';
import 'package:nandiott_flutter/services/help_support_service.dart';
import 'package:nandiott_flutter/utils/Device_size.dart';
import 'package:nandiott_flutter/utils/appstyle.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final _formKey = GlobalKey<FormState>();
  String selectedIssue = 'Other issue';
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool isSubmitting = false;
  bool showFaqs = true;
  
  // Focus nodes for navigation and form fields
  List<FocusNode> _faqFocusNodes = [];
  final FocusNode _faqTabFocusNode = FocusNode();
  final FocusNode _reportTabFocusNode = FocusNode();
  final FocusNode _issueDropdownFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _descFocusNode = FocusNode();
  final FocusNode _submitButtonFocusNode = FocusNode();
  final FocusNode _reportProblemButtonFocusNode = FocusNode();
  final FocusNode _contactSection1FocusNode = FocusNode();
  final FocusNode _contactSection2FocusNode = FocusNode();
  final FocusNode _contactSection3FocusNode = FocusNode();
  
  // Scroll controller for scrolling the page
  final ScrollController _scrollController = ScrollController();
  
  // Expansion states for FAQ items
  List<bool> _expandedStates = [];

  // Sample FAQs for different issue types
  final Map<String, List<Map<String, String>>> faqsByCategory = {
    'Play back issue': [
      {
        'question': 'Why is my video buffering constantly?',
        'answer':
            'This could be due to slow internet connection. Try switching to a lower quality or connect to a stronger network.'
      },
      {
        'question': 'Video freezes but audio continues playing',
        'answer':
            'Try clearing app cache, restarting the app, or updating to the latest version.'
      },
    ],
    'Streaming issue': [
      {
        'question': 'Why can\'t I stream in HD?',
        'answer':
            'HD streaming requires a Premium subscription and a stable internet connection of at least 5Mbps.'
      },
      {
        'question': 'Content not available in my region',
        'answer':
            'Some content may be restricted in certain regions due to licensing agreements.'
      },
    ],
    'Download issue': [
      {
        'question': 'Downloads are failing',
        'answer':
            'Check your storage space and internet connection. Make sure you have the latest app version.'
      },
      {
        'question': 'Downloaded videos suddenly disappeared',
        'answer':
            'Downloads may expire after 48 hours or when you sign out of your account.'
      },
    ],
    'Payment issue': [
      {
        'question': 'My payment was charged but subscription not activated',
        'answer':
            'It may take up to 24 hours to activate. If still not working, please contact customer support.'
      },
      {
        'question': 'How do I update my payment method?',
        'answer':
            'Go to Profile > Subscription > Payment Methods to update your card or payment details.'
      },
    ],
    'Other issue': [
      {
        'question': 'How do I reset my password?',
        'answer':
            'Go to the login screen and click on "Forgot Password", then follow the instructions sent to your email.'
      },
      {
        'question': 'How do I delete my account?',
        'answer':
            'Go to Profile > Settings > Account > Delete Account. Please note all your data will be permanently lost.'
      },
    ],
  };
  
  @override
  void initState() {
    super.initState();
    
    // Initialize expansion states for FAQ items
    _resetExpansionStates();
      _initializeFaqFocusNodes();
    // Set up initial focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (showFaqs) {
        _faqTabFocusNode.requestFocus();
      } else {
        _reportTabFocusNode.requestFocus();
      }
    });
  }
  void _initializeFaqFocusNodes() {
  // Clear any existing nodes
  for (var node in _faqFocusNodes) {
    node.dispose();
  }
  _faqFocusNodes.clear();
  
  // Create new nodes for current FAQ items
  final faqs = faqsByCategory[selectedIssue] ?? [];
  for (int i = 0; i < faqs.length; i++) {
    _faqFocusNodes.add(FocusNode());
  }
  void _ensureVisible(FocusNode focusNode) {
  if (focusNode.context == null) return;
  
  // Schedule after frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Scrollable.ensureVisible(
      focusNode.context!,
      alignment: 0.5,
      duration: Duration(milliseconds: 300),
    );
  });
}
}
  
  void _resetExpansionStates() {
    _expandedStates = List.generate(
      faqsByCategory[selectedIssue]?.length ?? 0, 
      (_) => false
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    
    // Dispose all focus nodes
    _faqTabFocusNode.dispose();
    _reportTabFocusNode.dispose();
    _issueDropdownFocusNode.dispose();
    _emailFocusNode.dispose();
    _descFocusNode.dispose();
    _submitButtonFocusNode.dispose();
    _reportProblemButtonFocusNode.dispose();
    _contactSection1FocusNode.dispose();
    _contactSection2FocusNode.dispose();
    _contactSection3FocusNode.dispose();
    
    super.dispose();
  }

  void _submitIssue(String msg)async { 
    final sendIssue = await SupportService();

    if (_formKey.currentState!.validate()) {
      setState(() {
        isSubmitting = true;
      });

      final response = await sendIssue.sendSupportIssue(message: msg);

      // Here you would typically send the data to your backend
      // For demo purposes, we'll simulate a network request

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          isSubmitting = false;
        });

        // Show success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              // title: Text('Issue Submitted'),
              content: Text(
                  response['message'] ?? 'Issue submitted successfully!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _descriptionController.clear();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      });
    }
  }
  
  // Scroll to the top of the page
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  // Scroll to the contacts section
  void _scrollToContacts() {
    final contactPosition = _scrollController.position.maxScrollExtent - 300;
    _scrollController.animateTo(
      contactPosition > 0 ? contactPosition : 0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  // Scroll to the bottom of the page to see hours
  void _scrollToHours() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  // Handle keyboard navigation between tabs
  KeyEventResult _handleTabKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        setState(() {
          showFaqs = true;
          _faqTabFocusNode.requestFocus();
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        setState(() {
          showFaqs = false;
          _reportTabFocusNode.requestFocus();
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.select || 
                 event.logicalKey == LogicalKeyboardKey.enter) {
        setState(() {
          if (node == _faqTabFocusNode) {
            showFaqs = true;
          } else if (node == _reportTabFocusNode) {
            showFaqs = false;
          }
        });
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (showFaqs) {
          _issueDropdownFocusNode.requestFocus();
        } else {
          _emailFocusNode.requestFocus();
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
  
  // Handle keyboard events for the dropdown
KeyEventResult _handleDropdownKeyEvent(RawKeyEvent event) {
  if (event is RawKeyDownEvent) {
    if (event.logicalKey == LogicalKeyboardKey.select || 
        event.logicalKey == LogicalKeyboardKey.enter) {
      // Simulate dropdown tap
      _showIssueSelectionDialog();
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_faqFocusNodes.isNotEmpty) {
        // Focus on first FAQ item
        _faqFocusNodes[0].requestFocus();
      } else {
        _reportProblemButtonFocusNode.requestFocus();
      }
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _faqTabFocusNode.requestFocus();
      return KeyEventResult.handled;
    }
  }
  return KeyEventResult.ignored;
}
  
  // Show a dialog for issue selection (TV-friendly alternative to dropdown)
  void _showIssueSelectionDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final List<String> issues = [
      'Play back issue',
      'Streaming issue',
      'Download issue',
      'Payment issue',
      'Other issue'
    ];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          title: Text('Select Issue Type'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: issues.length,
              itemBuilder: (context, index) {
                final issue = issues[index];
                final isSelected = issue == selectedIssue;
                
                return ListTile(
                  title: Text(
                    issue,
                    style: TextStyle(
                      color: isSelected ? AppStyles.primaryColor : 
                             (isDarkMode ? Colors.white : Colors.black),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  leading: isSelected ? Icon(Icons.check, color: AppStyles.primaryColor) : null,
                  onTap: () {
                    setState(() {
                      selectedIssue = issue;
                      // Reset expansion states for the new category
                      _resetExpansionStates();
                      _initializeFaqFocusNodes();
                    });
                    Navigator.of(context).pop();
                  },
                  autofocus: isSelected,  // Auto-focus the currently selected item
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  
  // Toggle FAQ expansion
  void _toggleFaqExpansion(int index) {
    setState(() {
      _expandedStates[index] = !_expandedStates[index];
    });
  }

  @override
  Widget build(BuildContext context) {
  final istv = AppSizes.getDeviceType(context) == DeviceType.tv;

    // Check if we're in dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final focusHighlightColor = AppStyles.primaryColor;
    final unfocusedColor = isDarkMode ? Colors.grey[700] : Colors.grey[200];
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Help & Support',
        showBackButton: true,
        showActionIcon: false,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tabs for FAQ and Report Issue
              Container(
                decoration: BoxDecoration(
                  color: unfocusedColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Focus(
                          focusNode: _faqTabFocusNode,
                          onKey: _handleTabKeyEvent,
                          child: Builder(
                            builder: (context) {
                              final hasFocus = Focus.of(context).hasFocus;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    showFaqs = true;
                                  });
                                  _faqTabFocusNode.requestFocus();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: showFaqs
                                        ? AppStyles.primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                    border: hasFocus
                                        ? Border.all(color: focusHighlightColor, width: 2)
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'FAQs',
                                      style: TextStyle(
                                        color: showFaqs 
                                            ? Colors.white 
                                            : isDarkMode ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          ),
                        ),
                      ),
                      Expanded(
                        child: Focus(
                          focusNode: _reportTabFocusNode,
                          onKey: _handleTabKeyEvent,
                          child: Builder(
                            builder: (context) {
                              final hasFocus = Focus.of(context).hasFocus;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    showFaqs = false;
                                  });
                                  _reportTabFocusNode.requestFocus();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !showFaqs
                                        ? AppStyles.primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                    border: hasFocus
                                        ? Border.all(color: focusHighlightColor, width: 2)
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Report Issue',
                                      style: TextStyle(
                                        color: !showFaqs 
                                            ? Colors.white 
                                            : isDarkMode ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // FAQ Section
              if (showFaqs) ...[
                Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Select an issue type to see related FAQs:',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                
                // Improved Issue Dropdown with better focus handling
                Focus(
                  focusNode: _issueDropdownFocusNode,
                  onKey:(node, event) => _handleDropdownKeyEvent(event),
                  child: Builder(
                    builder: (context) {
                      final hasFocus = Focus.of(context).hasFocus;
                      return InkWell(
                        onTap: _showIssueSelectionDialog,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: hasFocus ? AppStyles.primaryColor : Colors.grey[400]!,
                              width: hasFocus ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedIssue,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  fontWeight: hasFocus ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down_circle_outlined,
                                color: hasFocus ? AppStyles.primaryColor : Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Direct faq items
                ...faqsByCategory[selectedIssue]!.asMap().entries.map((entry) {
  int index = entry.key;
  Map<String, String> faq = entry.value;
  return FocusableExpansionTile(
    title: faq['question']!,
    content: faq['answer']!,
    focusNode: _faqFocusNodes[index],
  );
}).toList(),
                
                SizedBox(height: 24),
                Center(
                  child: Text(
                    "Can't find what you're looking for?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Focus(
                    focusNode: _reportProblemButtonFocusNode,
                    onKey: (node, event) {
                      if (event is RawKeyDownEvent) {
                        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                          _issueDropdownFocusNode.requestFocus();
                          _scrollToTop();
                          return KeyEventResult.handled;
                        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                          _contactSection1FocusNode.requestFocus();
                          _scrollToContacts();
                          return KeyEventResult.handled;
                        } else if (event.logicalKey == LogicalKeyboardKey.select ||
                                  event.logicalKey == LogicalKeyboardKey.enter) {
                          setState(() {
                            showFaqs = false;
                            _reportTabFocusNode.requestFocus();
                          });
                          return KeyEventResult.handled;
                        }
                      }
                      return KeyEventResult.ignored;
                    },
                    child: Builder(
                      builder: (context) {
                        final hasFocus = Focus.of(context).hasFocus;
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            side: hasFocus
                                ? BorderSide(color: Colors.white, width: 2)
                                : null,
                          ),
                          onPressed: () {
                            setState(() {
                              showFaqs = false;
                              // Move focus to the report tab
                              _reportTabFocusNode.requestFocus();
                            });
                          },
                          child: Text('Report a Problem'),
                        );
                      }
                    ),
                  ),
                ),
              ],

              // Report Issue Form
              if (!showFaqs && !istv) ...[
             
                Column(
                  children: [
                    Text(
                      'Report an Issue',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: FocusTraversalGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16),
                        Text('Email Address:'),
                        SizedBox(height: 8),
                        _buildFocusableTextField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          hintText: 'Enter your email address',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          onKey: (FocusNode node, RawKeyEvent event) {
                            if (event is RawKeyDownEvent) {
                              if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                _descFocusNode.requestFocus();
                                return KeyEventResult.handled;
                              } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                                _reportTabFocusNode.requestFocus();
                                return KeyEventResult.handled;
                              }
                            }
                            return KeyEventResult.ignored;
                          },
                        ),
                        SizedBox(height: 16),
                        Text('Issue Description:'),
                        SizedBox(height: 8),
                        _buildFocusableTextField(
                          controller: _descriptionController,
                          focusNode: _descFocusNode,
                          hintText: 'Describe your issue in detail',
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please describe your issue';
                            }
                            if (value.length < 10) {
                              return 'Please provide more details';
                            }
                            return null;
                          },
                          onKey: (FocusNode node, RawKeyEvent event) {
                            if (event is RawKeyDownEvent) {
                              if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                _submitButtonFocusNode.requestFocus();
                                return KeyEventResult.handled;
                              } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                                _emailFocusNode.requestFocus();
                                return KeyEventResult.handled;
                              }
                            }
                            return KeyEventResult.ignored;
                          },
                        ),
                        SizedBox(height: 24),
                        Center(
                          child: Focus(
                            focusNode: _submitButtonFocusNode,
                            onKey: (node, event) {
                              if (event is RawKeyDownEvent) {
                                if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                                  _descFocusNode.requestFocus();
                                  return KeyEventResult.handled;
                                } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                  _contactSection1FocusNode.requestFocus();
                                  _scrollToContacts();
                                  return KeyEventResult.handled;
                                } else if (event.logicalKey == LogicalKeyboardKey.select ||
                                          event.logicalKey == LogicalKeyboardKey.enter) {
                                  if (!isSubmitting) {
                                    _submitIssue(_descriptionController.text);
                                  }
                                  return KeyEventResult.handled;
                                }
                              }
                              return KeyEventResult.ignored;
                            },
                            child: Builder(
                              builder: (context) {
                                final hasFocus = Focus.of(context).hasFocus;
                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppStyles.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                    minimumSize: Size(200, 50),
                                    side: hasFocus
                                        ? BorderSide(color: Colors.white, width: 2)
                                        : null,
                                  ),
                                  onPressed: !isSubmitting ? () => _submitIssue(_descriptionController.text) : null,
                                  child: isSubmitting
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text('Submit', style: TextStyle(fontSize: 16)),
                                );
                              }
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],

                istv?Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("To report a problem, please go to the Our website or open our app in mobile"),
                  ],
                ): SizedBox(height: 32),

              Divider(),
           SizedBox(height: 16),

              // Contact Info with focusable elements for TV navigation
              Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              _buildFocusableContactItem(
                Icons.email, 
                'Email', 
                'support@nandiott.com',
                _contactSection1FocusNode,
                onKeyEvent: (node, event) {
                  if (event is RawKeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                      _contactSection2FocusNode.requestFocus();
                      return KeyEventResult.handled;
                    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                      if (showFaqs) {
                        _reportProblemButtonFocusNode.requestFocus();
                        _scrollToTop();
                      } else {
                        _submitButtonFocusNode.requestFocus();
                        _scrollToTop();
                      }
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
              ),
              SizedBox(height: 8),
              _buildFocusableContactItem(
                Icons.call, 
                'Phone', 
                '+1 (800) 123-4567',
                _contactSection2FocusNode,
                onKeyEvent: (node, event) {
                  if (event is RawKeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                      _contactSection3FocusNode.requestFocus();
                      _scrollToHours();
                      return KeyEventResult.handled;
                    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                      _contactSection1FocusNode.requestFocus();
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
              ),
              SizedBox(height: 8),
              _buildFocusableContactItem(
                Icons.access_time, 
                'Hours', 
                'Mon-Fri: 9AM-6PM',
                _contactSection3FocusNode,
                onKeyEvent: (node, event) {
                  if (event is RawKeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                      _contactSection2FocusNode.requestFocus();
                      _scrollToContacts();
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
              ),
              // Add extra space at the bottom to allow scrolling the hours section into view
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildFocusableContactItem(
  IconData icon, 
  String title, 
  String detail, 
  FocusNode focusNode,
  {KeyEventResult Function(FocusNode, RawKeyEvent)? onKeyEvent}
) {
  return Focus(
    focusNode: focusNode,
    onKey: onKeyEvent,
    child: Builder(
      builder: (context) {
        final hasFocus = Focus.of(context).hasFocus;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: hasFocus 
                ? Border.all(color: AppStyles.primaryColor, width: 2)
                : null,
            color: hasFocus 
                ? (isDarkMode ? Colors.grey[800] : Colors.grey[100])
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                icon, 
                color: hasFocus ? AppStyles.primaryColor : AppStyles.primaryColor.withOpacity(0.7),
                size: hasFocus ? 24 : 22,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: hasFocus ? FontWeight.bold : FontWeight.w600,
                      color: hasFocus ? AppStyles.primaryColor : null,
                    ),
                  ),
                  Text(
                    detail,
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    ),
  );
}
Widget _buildFocusableTextField({
  required TextEditingController controller,
  required FocusNode focusNode,
  required String hintText,
  TextInputType? keyboardType,
  int maxLines = 1,
  String? Function(String?)? validator,
  KeyEventResult Function(FocusNode, RawKeyEvent)? onKey,
}) {
  return Focus(
    focusNode: focusNode,
    onKey: onKey,
    child: Builder(
      builder: (context) {
        final hasFocus = Focus.of(context).hasFocus;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppStyles.primaryColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasFocus ? AppStyles.primaryColor : (isDarkMode ? Colors.grey[600]! : Colors.grey[300]!),
                width: hasFocus ? 2 : 1,
              ),
            ),
            filled: hasFocus,
            fillColor: hasFocus 
                ? (isDarkMode 
                    ? AppStyles.primaryColor.withOpacity(0.1) 
                    : AppStyles.primaryColor.withOpacity(0.05))
                : null,
          ),
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
        );
      }
    ),
  );
}
}