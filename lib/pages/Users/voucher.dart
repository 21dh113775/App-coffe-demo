import 'package:flutter/material.dart';
import 'package:test_login_sqlite/data/databasehelper.dart';
import 'package:intl/intl.dart';

class VoucherPage extends StatefulWidget {
  @override
  _VoucherPageState createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _vouchers = [];
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchVouchers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchVouchers() async {
    final vouchers = await dbHelper.getPromotions();
    setState(() {
      _vouchers = vouchers;
      _filterVouchers();
    });
  }

  void _filterVouchers() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _vouchers = List.from(_vouchers);
      } else {
        _vouchers = _vouchers.where((voucher) {
          return voucher['title']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              voucher['description']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
        }).toList();
      }
    });
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
          hintText: 'Nhập mã ưu đãi',
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
                      _filterVouchers();
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _filterVouchers();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       backgroundColor: Colors.white,
        title: Center(
          child: Image.asset(
            'assets/logo2.png',
            height: 40,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _vouchers.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'Không có ưu đãi nào.'
                          : 'Không tìm thấy ưu đãi phù hợp.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: _vouchers.length,
                    itemBuilder: (context, index) {
                      final voucher = _vouchers[index];
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                voucher['title'],
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(voucher['description'] ?? ''),
                              SizedBox(height: 8),
                              Text(
                                'HSD: ${_formatDateTime(voucher['endDate'])}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // Implement voucher use functionality
                                  },
                                  child: Text('Chọn'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white, backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}