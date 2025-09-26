import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:job/models/response/get_all_jobs.dart';
import 'package:job/utils/enums.dart';

import '../../bloc/job/job_bloc.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({Key? key}) : super(key: key);

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _minSalaryController = TextEditingController();
  final TextEditingController _maxSalaryController = TextEditingController();

  // Form fields
  String _workFormat = 'remote';
  String _employmentType = 'full_time';
  String _salaryPeriod = 'per_month';
  String _currency = 'USD';
  List<String> _selectedSkills = [];
  Map<String, String> _languages = {'English': 'Native'};

  // Predefined skills
  final List<String> _availableSkills = [
    'JavaScript', 'Python', 'React', 'Node.js',
    'SQL', 'AWS', 'Docker', 'Git',
    'TypeScript', 'Java', 'C++', 'Go',
    'Kubernetes', 'MongoDB', 'PostgreSQL', 'Redis'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _skillsController.dispose();
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _saveAsDraft() {
    _submitJob(isDraft: true);
  }

  void _submitJob({bool isDraft = false}) {
    if (_formKey.currentState!.validate()) {
      // Prepare full description with skills and languages
      String fullDescription = _descriptionController.text;
      if (_selectedSkills.isNotEmpty) {
        fullDescription += '\n\nRequired Skills: ${_selectedSkills.join(', ')}';
      }
      if (_languages.isNotEmpty) {
        fullDescription += '\n\nLanguages: ${_languages.entries
            .map((e) => '${e.key} (${e.value})')
            .join(', ')}';
      }

      // Create GetAllJobsResponse object
      final job = GetAllJobsResponse(
        id: null,
        postedByUser: null, // Will be set in repository
        postedByDisplayName: _companyController.text,
        title: _titleController.text,
        description: fullDescription,
        location: _locationController.text,
        employmentType: _employmentType,
        salaryMin: int.tryParse(_minSalaryController.text),
        salaryMax: int.tryParse(_maxSalaryController.text),
        currency: _currency,
        status: isDraft ? 'draft' : 'published',  // Changed from 'active' to 'published'
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        searchTsv: '${_titleController.text} ${_descriptionController.text}',
        userId: null, // Will be set in repository
      );

      // Dispatch create job event
      context.read<JobBloc>().add(CreateJob(job));

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isDraft ? 'Job saved as draft!' : 'Job posted successfully!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobBloc, JobState>(
      listener: (context, state) {
        if (state.status == Status.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'An error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Create Job Post',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // Step Indicator
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(
                    'Step ${_currentStep + 1} of 3 - ${_getStepTitle()}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12),
                  // Progress indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        width: 80,
                        height: 4,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index <= _currentStep
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            // Form Content
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Basic Information';
      case 1:
        return 'Requirements & Skills';
      case 2:
        return 'Compensation & Review';
      default:
        return '';
    }
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'Job Title',
            controller: _titleController,
            hint: 'e.g. Senior Software Engineer',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter job title';
              }
              return null;
            },
          ),
          SizedBox(height: 24),
          _buildTextField(
            label: 'Company Name',
            controller: _companyController,
            hint: 'Your company name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter company name';
              }
              return null;
            },
          ),
          SizedBox(height: 24),
          _buildTextField(
            label: 'Location',
            controller: _locationController,
            hint: 'City, State',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter location';
              }
              return null;
            },
          ),
          SizedBox(height: 24),
          _buildLabel('Work Format'),
          SizedBox(height: 12),
          _buildRadioGroup(
            options: ['remote', 'onsite', 'hybrid'],
            groupValue: _workFormat,
            onChanged: (value) {
              setState(() {
                _workFormat = value!;
              });
            },
          ),
          SizedBox(height: 24),
          _buildLabel('Employment Type'),
          SizedBox(height: 12),
          // Employment Type - 2 rows for better layout
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('Full-time', style: TextStyle(fontSize: 14)),
                      value: 'full_time',
                      groupValue: _employmentType,
                      onChanged: (value) {
                        setState(() {
                          _employmentType = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('Part-time', style: TextStyle(fontSize: 14)),
                      value: 'part_time',
                      groupValue: _employmentType,
                      onChanged: (value) {
                        setState(() {
                          _employmentType = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('Contract', style: TextStyle(fontSize: 14)),
                      value: 'contract',
                      groupValue: _employmentType,
                      onChanged: (value) {
                        setState(() {
                          _employmentType = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('Freelance', style: TextStyle(fontSize: 14)),
                      value: 'freelance',
                      groupValue: _employmentType,
                      onChanged: (value) {
                        setState(() {
                          _employmentType = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildTextField(
            label: 'Job Description',
            controller: _descriptionController,
            hint: 'Describe the role, responsibilities, and requirements...',
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter job description';
              }
              return null;
            },
          ),
          SizedBox(height: 32),
          _buildNavigationButtons(showPrevious: false),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Required Skills'),
          SizedBox(height: 12),
          _buildSkillsInput(),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSkills.map((skill) {
              final isSelected = _selectedSkills.contains(skill);
              return FilterChip(
                label: Text(skill),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSkills.add(skill);
                    } else {
                      _selectedSkills.remove(skill);
                    }
                  });
                },
                backgroundColor: Colors.grey[200],
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                checkmarkColor: Theme.of(context).primaryColor,
              );
            }).toList(),
          ),
          SizedBox(height: 32),
          _buildLabel('Languages'),
          SizedBox(height: 12),
          _buildLanguageSection(),
          SizedBox(height: 32),
          _buildLabel('Salary Range'),
          SizedBox(height: 12),
          _buildSalarySection(),
          SizedBox(height: 32),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Job Post',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          _buildReviewCard(),
          SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saveAsDraft,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey),
                  ),
                  child: Text(
                    'Save as Draft',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _submitJob(isDraft: false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB8D64A),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Post Job',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextButton(
            onPressed: _previousStep,
            child: Text('← Back to Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      '$text *',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildRadioGroup({
    required List<String> options,
    required String groupValue,
    required Function(String?) onChanged,
  }) {
    final displayText = {
      'remote': 'Remote',
      'onsite': 'Onsite',
      'hybrid': 'Hybrid',
    };

    return Row(
      children: options.map((option) {
        return Expanded(
          child: RadioListTile<String>(
            title: Text(
              displayText[option] ?? option,
              style: TextStyle(fontSize: 14),
            ),
            value: option,
            groupValue: groupValue,
            onChanged: onChanged,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSkillsInput() {
    return TextField(
      controller: _skillsController,
      decoration: InputDecoration(
        hintText: 'Add skills',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        suffixIcon: IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            if (_skillsController.text.isNotEmpty) {
              setState(() {
                _selectedSkills.add(_skillsController.text);
                _skillsController.clear();
              });
            }
          },
        ),
      ),
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          setState(() {
            _selectedSkills.add(value);
            _skillsController.clear();
          });
        }
      },
    );
  }

  Widget _buildLanguageSection() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: _languages.entries.map((entry) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: entry.value,
                          underline: Container(),
                          items: ['Native', 'Fluent', 'Intermediate', 'Basic']
                              .map((level) => DropdownMenuItem(
                            value: level,
                            child: Text(
                              level,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14),
                            ),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _languages[entry.key] = value!;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() {
                            _languages.remove(entry.key);
                          });
                        },
                      ),
                    ],
                  ),
                  if (entry.key != _languages.keys.last) Divider(),
                ],
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 12),
        TextButton.icon(
          onPressed: () {
            _showAddLanguageDialog();
          },
          icon: Icon(Icons.add),
          label: Text('Add language'),
        ),
      ],
    );
  }

  void _showAddLanguageDialog() {
    String newLanguage = '';
    String level = 'Intermediate';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Language',
                hintText: 'e.g. Spanish, French, etc.',
              ),
              onChanged: (value) => newLanguage = value,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: level,
              decoration: InputDecoration(labelText: 'Level'),
              items: ['Native', 'Fluent', 'Intermediate', 'Basic']
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (value) => level = value!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newLanguage.isNotEmpty) {
                setState(() {
                  _languages[newLanguage] = level;
                });
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildSalarySection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minSalaryController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Min',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _maxSalaryController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Max',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _currency,
                  underline: SizedBox(),
                  items: ['USD', 'EUR', 'GBP', 'INR']
                      .map((currency) => DropdownMenuItem(
                    value: currency,
                    child: Text(currency),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _currency = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Radio<String>(
                value: 'per_month',
                groupValue: _salaryPeriod,
                onChanged: (value) {
                  setState(() {
                    _salaryPeriod = value!;
                  });
                },
              ),
              Text('Per month'),
              SizedBox(width: 24),
              Radio<String>(
                value: 'per_hour',
                groupValue: _salaryPeriod,
                onChanged: (value) {
                  setState(() {
                    _salaryPeriod = value!;
                  });
                },
              ),
              Text('Per hour'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewItem('Job Title', _titleController.text),
          _buildReviewItem('Company', _companyController.text),
          _buildReviewItem('Location', _locationController.text),
          _buildReviewItem('Work Format', _workFormat),
          _buildReviewItem('Employment Type', _employmentType),
          _buildReviewItem('Description', _descriptionController.text),
          if (_selectedSkills.isNotEmpty)
            _buildReviewItem('Skills', _selectedSkills.join(', ')),
          if (_languages.isNotEmpty)
            _buildReviewItem(
              'Languages',
              _languages.entries
                  .map((e) => '${e.key} (${e.value})')
                  .join(', '),
            ),
          if (_minSalaryController.text.isNotEmpty ||
              _maxSalaryController.text.isNotEmpty)
            _buildReviewItem(
              'Salary Range',
              '$_currency ${_minSalaryController.text} - ${_maxSalaryController.text} $_salaryPeriod',
            ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    final displayText = {
      'remote': 'Remote',
      'onsite': 'Onsite',
      'hybrid': 'Hybrid',
      'full_time': 'Full-time',
      'part_time': 'Part-time',
      'contract': 'Contract',
      'freelance': 'Freelance',
      'per_month': 'Per month',
      'per_hour': 'Per hour',
    };

    String displayValue = displayText[value] ?? value;

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            displayValue,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons({bool showPrevious = true}) {
    return Row(
      children: [
        if (showPrevious)
          Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey),
              ),
              child: Text(
                'Previous',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        if (showPrevious) SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saveAsDraft,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey),
                  ),
                  child: Text(
                    'Save as Draft',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB8D64A),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}