import 'package:flutter/material.dart';
import 'package:test_login_sqlite/data/databasehelper.dart';
import 'package:intl/intl.dart';

import '../widget/custom_drawer.dart';

class ManagePromotionsPage extends StatefulWidget {
  @override
  _ManagePromotionsPageState createState() => _ManagePromotionsPageState();
}

class _ManagePromotionsPageState extends State<ManagePromotionsPage> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _promotions = [];
  List<Map<String, dynamic>> _filteredPromotions = [];
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPromotions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPromotions() async {
    final promotions = await dbHelper.getPromotions();
    setState(() {
      _promotions = promotions;
      _filterPromotions();
    });
  }

  void _filterPromotions() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredPromotions = List.from(_promotions);
      } else {
        _filteredPromotions = _promotions.where((promotion) {
          return promotion['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 promotion['description'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _addOrUpdatePromotion([Map<String, dynamic>? promotion]) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return PromotionDialog(promotion: promotion);
      },
    );

    if (result != null) {
      if (promotion == null) {
        await dbHelper.insertPromotion(result);
      } else {
        await dbHelper.updatePromotion(result);
      }
      _fetchPromotions();
    }
  }

  Future<void> _deletePromotion(int id) async {
    await dbHelper.deletePromotion(id);
    _fetchPromotions();
  }

  String _formatDateTime(String? dateString) {
    if (dateString == null) return 'N/A';
    final date = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm khuyến mãi...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _filterPromotions();
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _filterPromotions();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý khuyến mãi'),
        elevation: 0,
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              // Implement sorting functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Implement filtering functionality
            },
          ),
        ],
      ),
       drawer: CustomDrawer(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _filteredPromotions.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'Không có khuyến mãi nào.'
                          : 'Không tìm thấy khuyến mãi phù hợp.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredPromotions.length,
                    itemBuilder: (context, index) {
                      final promotion = _filteredPromotions[index];
                      return GestureDetector(
                        onTap: () => _addOrUpdatePromotion(promotion),
                        child: Card(
                          elevation: 2,
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  promotion['title'],
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(promotion['description'] ?? ''),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Từ: ${_formatDateTime(promotion['startDate'])}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    Text(
                                      'Đến: ${_formatDateTime(promotion['endDate'])}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deletePromotion(promotion['id']),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrUpdatePromotion(),
        icon: Icon(Icons.add),
        label: Text('Thêm khuyến mãi'),
        backgroundColor: Colors.blue[700],
      ),
    );
    
  }
}

class PromotionDialog extends StatefulWidget {
  final Map<String, dynamic>? promotion;

  PromotionDialog({this.promotion});

  @override
  _PromotionDialogState createState() => _PromotionDialogState();
}

class _PromotionDialogState extends State<PromotionDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.promotion?['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.promotion?['description'] ?? '');
    _startDate = widget.promotion?['startDate'] != null ? DateTime.parse(widget.promotion!['startDate']) : null;
    _startTime = _startDate != null ? TimeOfDay.fromDateTime(_startDate!) : null;
    _endDate = widget.promotion?['endDate'] != null ? DateTime.parse(widget.promotion!['endDate']) : null;
    _endTime = _endDate != null ? TimeOfDay.fromDateTime(_endDate!) : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, DateTime? initialDate, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  Future<void> _selectTime(BuildContext context, TimeOfDay? initialTime, Function(TimeOfDay) onTimeSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      onTimeSelected(picked);
    }
  }

  Widget _buildDateTimePicker(BuildContext context, String label, DateTime? selectedDate, TimeOfDay? selectedTime, Function(DateTime) onDateSelected, Function(TimeOfDay) onTimeSelected) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context, selectedDate, onDateSelected),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(),
              ),
              child: Text(selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate) : 'Chọn ngày'),
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: InkWell(
            onTap: () => _selectTime(context, selectedTime, onTimeSelected),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Chọn giờ',
                border: OutlineInputBorder(),
              ),
              child: Text(selectedTime != null ? selectedTime.format(context) : 'Chọn giờ'),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.promotion == null ? 'Thêm khuyến mãi' : 'Chỉnh sửa khuyến mãi',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tiêu đề là bắt buộc';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              _buildDateTimePicker(context, 'Ngày bắt đầu', _startDate, _startTime, (date) => setState(() => _startDate = date), (time) => setState(() => _startTime = time)),
              SizedBox(height: 16),
              _buildDateTimePicker(context, 'Ngày kết thúc', _endDate, _endTime, (date) => setState(() => _endDate = date), (time) => setState(() => _endTime = time)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final promotion = {
                'id': widget.promotion?['id'],
                'title': _titleController.text,
                'description': _descriptionController.text,
                'startDate': _startDate != null ? DateTime(_startDate!.year, _startDate!.month, _startDate!.day, _startTime?.hour ?? 0, _startTime?.minute ?? 0).toIso8601String() : null,
                'endDate': _endDate != null ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day, _endTime?.hour ?? 0, _endTime?.minute ?? 0).toIso8601String() : null,
              };
              Navigator.pop(context, promotion);
            }
          },
          child: Text(widget.promotion == null ? 'Thêm' : 'Lưu'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
          ),
        ),
      ],
      
    );
    
  }
}
