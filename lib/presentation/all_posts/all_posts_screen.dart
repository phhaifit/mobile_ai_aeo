import 'package:flutter/material.dart';

class AllPostsScreen extends StatefulWidget {
  @override
  _AllPostsScreenState createState() => _AllPostsScreenState();
}

class _AllPostsScreenState extends State<AllPostsScreen> {
  final Set<PostItem> _selectedItems = {};

  // Mock Data
  final List<PostItem> _posts = [
    PostItem(
      title: 'Beyond the Logo: How YourBrand.com Builds Authority',
      description:
          'Have you ever felt the buzz of a brilliant idea, a product, or a service, only to find it struggles to connect with the right...',
      date: 'Mar 20, 15:54',
      publishedDate: 'Mar 20, 15:56',
      imageUrl: 'assets/images/img_login.jpg', // Placeholder image
      tags: ['Direct Brand Queries', 'Navigational'],
      type: 'BLOG',
    ),
    PostItem(
      title: '10 Tips for Effective Remote Work',
      description:
          'Remote work is here to stay. Learn how to maximize your productivity and maintain a healthy work-life balance...',
      date: 'Mar 21, 10:00',
      publishedDate: 'Mar 21, 10:30',
      imageUrl: 'assets/images/img_login.jpg', // Placeholder image
      tags: ['Productivity', 'Work'],
      type: 'SOCIAL',
    ),
  ];

  String _selectedFilter = 'All Content';
  List<int> _itemsPerPageOptions = [10, 25, 50, 100];
  int _itemsPerPage = 10;
  bool _isListView = false; // Add this line

  List<PostItem> get _filteredPosts {
    List<PostItem> filtered = [];
    if (_selectedFilter == 'All Content') {
      filtered = _posts;
    } else {
      filtered = _posts
          .where((post) =>
              post.type.toUpperCase() == _selectedFilter.toUpperCase())
          .toList();
    }

    // Simple pagination simulation: show only up to _itemsPerPage
    // In a real app, this would fetch from backend or slice the list properly for the current page
    return filtered.take(_itemsPerPage).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  void _toggleSelection(PostItem post) {
    setState(() {
      if (_selectedItems.contains(post)) {
        _selectedItems.remove(post);
      } else {
        _selectedItems.add(post);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedItems.length == _filteredPosts.length) {
        _selectedItems.clear();
      } else {
        _selectedItems.addAll(_filteredPosts);
      }
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.chevron_left, color: Colors.black),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        'All Posts',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.help_outline, color: Colors.grey),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildTabs(),
        if (_selectedItems.isNotEmpty) _buildSelectionBar(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: _buildSearchBar(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildActionRow(),
        ),
        Expanded(
          child: _isListView ? _buildListWithStickyHeader() : _buildGridView(),
        ),
        _buildPagination(),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[50],
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = 'All Content';
                });
              },
              child: _buildTabItem(
                  icon: Icons.layers,
                  label: 'All Content',
                  isSelected: _selectedFilter == 'All Content'),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = 'Blog';
                });
              },
              child: _buildTabItem(
                  icon: Icons.article,
                  label: 'Blog',
                  isSelected: _selectedFilter == 'Blog'),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = 'Social';
                });
              },
              child: _buildTabItem(
                  icon: Icons.share,
                  label: 'Social',
                  isSelected: _selectedFilter == 'Social'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(
      {required IconData icon,
      required String label,
      required bool isSelected}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search prompts...',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildActionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton.icon(
          onPressed: _showFilters,
          icon: Icon(Icons.filter_list, size: 18, color: Colors.grey[700]),
          label: Text('Filters', style: TextStyle(color: Colors.grey[700])),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey[300]!),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isListView = true;
                      });
                    },
                    icon: Icon(Icons.list,
                        color: _isListView ? Colors.black : Colors.grey[600]),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isListView = false;
                      });
                    },
                    icon: Icon(Icons.grid_view,
                        color: !_isListView ? Colors.black : Colors.grey[600]),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.add, size: 18, color: Colors.white),
              label: Text('Add Content', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6600), // Orange color
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
          ],
        )
      ],
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            _buildFilterHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Status'),
                    _buildCheckboxOption('Draft'),
                    _buildCheckboxOption('Ready'),
                    _buildCheckboxOption('Published'),
                    Divider(height: 32),
                    _buildSectionTitle('Content Type'),
                    _buildCheckboxOption('Blog Post'),
                    _buildCheckboxOption('Social Media'),
                    Divider(height: 32),
                    _buildSectionTitle('Topic'),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            _buildCheckboxOption('Direct Brand Queries'),
                            _buildCheckboxOption(
                                'Digital Branding Services Exploration'),
                            _buildCheckboxOption('Online Presence Challenges'),
                            _buildCheckboxOption(
                                'Strategic Digital Asset Development'),
                            _buildCheckboxOption('Digital Agency Evaluation'),
                            _buildCheckboxOption(
                                'Digital Branding Services Exploration'),
                          ],
                        ),
                      ),
                    ),
                    Divider(height: 32),
                    _buildDateFilterSection(),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: Offset(0, -2),
                  blurRadius: 4,
                )
              ]),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Apply Filters',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF6600),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Filters',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextButton(
            onPressed: () {},
            child: Text('Clear all', style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildCheckboxOption(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: false,
              onChanged: (v) {},
              shape: CircleBorder(), // Circular checkbox as per design
              side: BorderSide(color: Colors.grey[400]!),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Published Date',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Icon(Icons.keyboard_arrow_up, color: Colors.grey),
          ],
        ),
        SizedBox(height: 12),
        Text('Last', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Text('days'),
                  SizedBox(width: 8),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: Color(0xFFFF6600),
              ),
            ),
            child: CalendarDatePicker(
              initialDate: DateTime(2026, 3, 21),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              onDateChanged: (v) {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListWithStickyHeader() {
    return Column(
      children: [
        _buildListViewHeader(),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _filteredPosts.length,
            separatorBuilder: (context, index) => SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildPostListItem(_filteredPosts[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionBar() {
    return Container(
      width: double.infinity,
      color: Colors.orange[50], // Light orange background as requested
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        // Use Column for mobile responsiveness
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${_selectedItems.length} item${_selectedItems.length > 1 ? 's' : ''} selected',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(width: 16),
              GestureDetector(
                onTap: _toggleSelectAll, // Use the method here
                child: Row(
                  children: [
                    Icon(
                        _selectedItems.length == _filteredPosts.length
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 20,
                        color: Colors.black87),
                    SizedBox(width: 4),
                    Text('Select All',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            // Horizontal scroll for action buttons on mobile
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon:
                      Icon(Icons.delete_outline, size: 18, color: Colors.white),
                  label: Text('Delete', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.visibility_outlined,
                      size: 18, color: Colors.green),
                  label: Text('Publish', style: TextStyle(color: Colors.green)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.visibility_off_outlined,
                      size: 18, color: Colors.red),
                  label: Text('Unpublish', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.archive_outlined,
                      size: 18, color: Colors.black87),
                  label:
                      Text('Archive', style: TextStyle(color: Colors.black87)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListViewHeader() {
    bool allSelected = _filteredPosts.isNotEmpty &&
        _selectedItems.length == _filteredPosts.length;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              value: allSelected,
              onChanged: (v) => _toggleSelectAll(), // Use the method here
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'TITLE',
              style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Text(
              'STATUS',
              style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
          SizedBox(width: 16),
          SizedBox(
            width: 100,
            child: Text(
              'ACTIONS',
              style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostListItem(PostItem post) {
    bool isSelected = _selectedItems.contains(post);
    return Container(
      // Highlight selected item
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange[50] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: isSelected ? Colors.orange : Colors.grey[200]!),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              value: isSelected,
              onChanged: (v) => _toggleSelection(post),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          Expanded(
            flex: 3,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.only(bottom: 8),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minWidth: constraints.maxWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            softWrap: false,
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.description_outlined,
                                  size: 16, color: Colors.deepPurple),
                              SizedBox(width: 4),
                              Text(post.type.toUpperCase(),
                                  style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                post.description,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14),
                                softWrap: false,
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
          SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green[100]!),
                  borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4),
                  Flexible(
                    child: Text('Published',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16),
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.edit_outlined, size: 20, color: Colors.grey[600]),
                SizedBox(width: 12),
                Icon(Icons.visibility_off_outlined,
                    size: 20, color: Colors.grey[600]),
                SizedBox(width: 12),
                Icon(Icons.open_in_new, size: 20, color: Colors.grey[600]),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: _filteredPosts.length,
      separatorBuilder: (context, index) => SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildPostCard(_filteredPosts[index]);
      },
    );
  }

  Widget _buildPostCard(PostItem post) {
    bool isSelected = _selectedItems.contains(post);
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange[50] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: isSelected ? Colors.orange : Colors.grey[200]!),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Placeholder
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                    image: AssetImage(
                        'assets/images/img_login.jpg'), // Placeholder
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.1), BlendMode.darken))),
            child: Center(
              child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Color(0xFFFF6600),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.check, color: Colors.white, size: 32)),
            ),
          ),
          SizedBox(height: 16),

          Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (v) => _toggleSelection(post),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4)),
                child: Text('#1',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border.all(color: Colors.blue[100]!),
                    borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: [
                    Icon(Icons.description, size: 14, color: Colors.blue),
                    SizedBox(width: 4),
                    Text(post.type,
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Spacer(),
              Icon(Icons.edit, size: 18, color: Colors.grey[400]),
              SizedBox(width: 8),
              Icon(Icons.visibility_off, size: 18, color: Colors.grey[400]),
              SizedBox(width: 8),
              Icon(Icons.open_in_new, size: 18, color: Colors.grey[400]),
            ],
          ),
          SizedBox(height: 8),

          Text(
            post.title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            post.description,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: post.tags
                .map((tag) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.blue[50],
                          border: Border.all(color: Colors.blue[100]!),
                          borderRadius: BorderRadius.circular(16)),
                      child: Text(tag,
                          style: TextStyle(color: Colors.blue, fontSize: 12)),
                    ))
                .toList(),
          ),
          SizedBox(height: 16),
          Divider(height: 1),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('Created: ${post.date}',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: Colors.green),
                  SizedBox(width: 4),
                  Text('Published: ${post.publishedDate}',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
              '${_filteredPosts.length} result${_filteredPosts.length == 1 ? '' : 's'}',
              style: TextStyle(color: Colors.grey[600])),
          SizedBox(width: 16),
          Text('Show:', style: TextStyle(color: Colors.grey[600])),
          SizedBox(width: 8),
          PopupMenuButton<int>(
            initialValue: _itemsPerPage,
            onSelected: (int value) {
              setState(() {
                _itemsPerPage = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return _itemsPerPageOptions.map((int value) {
                return PopupMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList();
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: [
                    Text(_itemsPerPage.toString(),
                        style: TextStyle(color: Colors.grey[800])),
                    Icon(Icons.arrow_drop_down, color: Colors.grey[600])
                  ],
                )),
          ),
          SizedBox(width: 8),
          Text('per page', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class PostItem {
  final String title;
  final String description;
  final String date;
  final String publishedDate;
  final String imageUrl;
  final List<String> tags;
  final String type;

  PostItem({
    required this.title,
    required this.description,
    required this.date,
    required this.publishedDate,
    required this.imageUrl,
    required this.tags,
    required this.type,
  });
}
