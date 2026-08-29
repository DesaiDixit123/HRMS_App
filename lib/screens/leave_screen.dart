import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_app/controllers/leave_controller.dart';
import 'package:intl/intl.dart';

class LeaveScreen extends StatelessWidget {
  const LeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LeaveController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6E3EB5), Color(0xFF52B447)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Leave',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Apply & manage your leaves',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    TabBar(
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                      tabs: const [
                        Tab(text: 'Apply Leave'),
                        Tab(text: 'My Balances'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Tab 1: Apply Leave (existing content)
                    RefreshIndicator(
                      onRefresh: () async {
                        await controller.fetchMyLeaves();
                        await controller.fetchLeaveTypes();
                        await controller.fetchLeaveBalances();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            const SizedBox(height: 25),
                            Obx(() => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _statCard(
                                      title: 'Remaining',
                                      value: _formatDays(controller.leaveRemaining.value),
                                      color: const Color(0xFF52B447),
                                      icon: Icons.check_circle_outline,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _statCard(
                                      title: 'Used',
                                      value: _formatDays(controller.leaveUsed.value),
                                      color: const Color(0xFF6E3EB5),
                                      icon: Icons.work_history_outlined,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _statCard(
                                      title: 'Pending',
                                      value: _formatDays(controller.leavePending.value),
                                      color: const Color(0xFFFFA500),
                                      icon: Icons.pending_actions_outlined,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                            const SizedBox(height: 25),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Apply Leave Form
                                  const Text(
                                    'Apply Leave',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2430),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Leave Type Dropdown
                                        const Text(
                                          'Leave Type',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF74808F),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Obx(
                                          () => Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: const Color(0xFFDCE6D8)),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                hint: const Text('Select Leave Type'),
                                                value:
                                                    controller
                                                                .selectedLeaveTypeId
                                                                .value
                                                                .isEmpty
                                                            ? null
                                                            : controller.selectedLeaveTypeId.value,
                                                items: controller.leaveTypes
                                                    .map(
                                                      (type) => DropdownMenuItem(
                                                        value: type['_id'].toString(),
                                                        child: Text(
                                                          type['name'] ?? 'Unknown',
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    controller.selectedLeaveTypeId.value =
                                                        value;
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        // Day Type
                                        const Text(
                                          'Day Type',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF74808F),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Obx(
                                          () => Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children:
                                                [
                                                      'full day',
                                                      'first half',
                                                      'second half',
                                                      'late',
                                                    ]
                                                    .map(
                                                      (type) => ChoiceChip(
                                                        label: Text(
                                                          type[0].toUpperCase() +
                                                              type.substring(1),
                                                          style: const TextStyle(fontSize: 13),
                                                        ),
                                                        selected:
                                                            controller
                                                                .selectedDayType
                                                                .value ==
                                                            type,
                                                        selectedColor: const Color(0xFF6E3EB5),
                                                        labelStyle: TextStyle(
                                                          color:
                                                              controller
                                                                      .selectedDayType
                                                                      .value ==
                                                                  type
                                                              ? Colors.white
                                                              : const Color(0xFF1F2430),
                                                        ),
                                                        onSelected: (selected) {
                                                          if (selected) {
                                                            controller
                                                                    .selectedDayType
                                                                    .value =
                                                                type;
                                                          }
                                                        },
                                                      ),
                                                    )
                                                    .toList(),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        // Leave Duration
                                        const Text(
                                          'Duration',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF74808F),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Obx(
                                          () => Row(
                                            children: [
                                              Expanded(
                                                child: ChoiceChip(
                                                  label: const Text('Single Day'),
                                                  selected:
                                                      controller.selectedLeaveDay.value ==
                                                      'single',
                                                  selectedColor: const Color(0xFF6E3EB5),
                                                  labelStyle: TextStyle(
                                                    color:
                                                        controller.selectedLeaveDay.value ==
                                                            'single'
                                                        ? Colors.white
                                                        : const Color(0xFF1F2430),
                                                  ),
                                                  onSelected: (selected) {
                                                    if (selected) {
                                                      controller.selectedLeaveDay.value =
                                                          'single';
                                                      controller.toDate.value = null;
                                                    }
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: ChoiceChip(
                                                  label: const Text('Multiple Days'),
                                                  selected:
                                                      controller.selectedLeaveDay.value ==
                                                      'multiple',
                                                  selectedColor: const Color(0xFF6E3EB5),
                                                  labelStyle: TextStyle(
                                                    color:
                                                        controller.selectedLeaveDay.value ==
                                                            'multiple'
                                                        ? Colors.white
                                                        : const Color(0xFF1F2430),
                                                  ),
                                                  onSelected: (selected) {
                                                    if (selected) {
                                                      controller.selectedLeaveDay.value =
                                                          'multiple';
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        // From Date
                                        const Text(
                                          'From Date',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF74808F),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Obx(
                                          () => GestureDetector(
                                            onTap: () async {
                                              final picked = await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime.now().add(
                                                  const Duration(days: 365),
                                                ),
                                              );
                                              if (picked != null) {
                                                controller.fromDate.value = picked;
                                              }
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 14,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: const Color(0xFFDCE6D8),
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    controller.formatDate(
                                                      controller.fromDate.value,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color:
                                                          controller.fromDate.value == null
                                                          ? const Color(0xFF74808F)
                                                          : const Color(0xFF1F2430),
                                                    ),
                                                  ),
                                                  const Icon(
                                                    Icons.calendar_today,
                                                    size: 20,
                                                    color: Color(0xFF74808F),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        // To Date (only for multiple days)
                                        Obx(() {
                                          if (controller.selectedLeaveDay.value !=
                                              'multiple') {
                                            return const SizedBox.shrink();
                                          }
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'To Date',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF74808F),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              GestureDetector(
                                                onTap: () async {
                                                  final picked = await showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                        controller.fromDate.value ??
                                                        DateTime.now(),
                                                    firstDate:
                                                        controller.fromDate.value ??
                                                        DateTime.now(),
                                                    lastDate: DateTime.now().add(
                                                      const Duration(days: 365),
                                                    ),
                                                  );
                                                  if (picked != null) {
                                                    controller.toDate.value = picked;
                                                  }
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 14,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: const Color(0xFFDCE6D8),
                                                    ),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        controller.formatDate(
                                                          controller.toDate.value,
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color:
                                                              controller.toDate.value ==
                                                                  null
                                                              ? const Color(0xFF74808F)
                                                              : const Color(0xFF1F2430),
                                                        ),
                                                      ),
                                                      const Icon(
                                                        Icons.calendar_today,
                                                        size: 20,
                                                        color: Color(0xFF74808F),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                            ],
                                          );
                                        }),
                                        // Reason
                                        const Text(
                                          'Reason',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF74808F),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          maxLines: 3,
                                          onChanged: (val) => controller.reason.value = val,
                                          decoration: InputDecoration(
                                            hintText: 'Enter reason for leave...',
                                            hintStyle: const TextStyle(color: Color(0xFF74808F)),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFDCE6D8),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFDCE6D8),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF6E3EB5),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        // Submit Button
                                        SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: Obx(
                                            () => ElevatedButton(
                                              onPressed: controller.isSubmitting.value
                                                  ? null
                                                  : () => controller.applyLeave(),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF6E3EB5),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: controller.isSubmitting.value
                                                  ? const SizedBox(
                                                      height: 24,
                                                      width: 24,
                                                      child: CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2.5,
                                                      ),
                                                    )
                                                  : const Text(
                                                      'Apply Leave',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  // Leave History
                                  const Text(
                                    'Leave History',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2430),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Obx(() {
                                    if (controller.isLoading.value) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    if (controller.appliedLeaves.isEmpty) {
                                      return Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(30),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'No leave records found',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF74808F),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return Column(
                                      children: controller.appliedLeaves
                                          .map((leave) => _leaveHistoryItem(leave))
                                          .toList(),
                                    );
                                  }),
                                  const SizedBox(height: 30),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Tab 2: My Balances (List of Leave Type Cards)
                    RefreshIndicator(
                      onRefresh: () async {
                        await controller.fetchLeaveBalances();
                      },
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (controller.leaveTypeBalances.isEmpty) {
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                              const Center(
                                child: Text(
                                  'No leave types configured.',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF74808F),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          itemCount: controller.leaveTypeBalances.length,
                          itemBuilder: (context, index) {
                            final balance = controller.leaveTypeBalances[index];
                            final name = balance['leave_type_name'] ?? 'Leave Type';
                            final allowed = balance['allowed'] ?? 0;
                            final used = balance['used'] ?? 0;
                            final pending = balance['pending'] ?? 0;
                            final remaining = balance['remaining'] ?? 0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6E3EB5).withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.credit_card_outlined,
                                          color: Color(0xFF6E3EB5),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          name.toString().toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F2430),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  const Divider(height: 1, color: Color(0xFFDCE6D8)),
                                  const SizedBox(height: 14),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _balanceItem('Allowed', allowed.toString(), const Color(0xFF74808F)),
                                      _balanceItem('Used', used.toString(), const Color(0xFF6E3EB5)),
                                      _balanceItem('Pending', pending.toString(), const Color(0xFFFFA500)),
                                      _balanceItem('Remaining', remaining.toString(), const Color(0xFF52B447), isBold: true),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leaveHistoryItem(Map<String, dynamic> leave) {
    final status = leave['leave_status'] ?? 'pending';
    final reason = leave['reason'] ?? '';
    final dayType = leave['leave_per_day_type'] ?? '';
    final leaveDay = leave['leave_day'] ?? '';

    // Leave type name
    String typeName = '';
    final leaveType = leave['leavetypeid'];
    if (leaveType is Map) {
      typeName = leaveType['name'] ?? '';
    }

    // Format dates
    String fromStr = '';
    String toStr = '';
    try {
      if (leave['from_date'] != null) {
        fromStr = DateFormat(
          'MMM dd, yyyy',
        ).format(DateTime.parse(leave['from_date']));
      }
      if (leave['to_date'] != null) {
        toStr = DateFormat(
          'MMM dd, yyyy',
        ).format(DateTime.parse(leave['to_date']));
      }
    } catch (_) {}

    // Status styling
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;
    switch (status) {
      case 'approved':
        statusColor = Color(0xFF52B447);
        statusBgColor = Color(0xFFE8F5E9);
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Color(0xFFFF3B30);
        statusBgColor = Color(0xFFFFEBEE);
        statusIcon = Icons.cancel;
        break;
      case 'cancelled':
        statusColor = Color(0xFF74808F);
        statusBgColor = Color(0xFFF5F5F5);
        statusIcon = Icons.block;
        break;
      default: // pending
        statusColor = Color(0xFFFFA500);
        statusBgColor = Color(0xFFFFF3E0);
        statusIcon = Icons.access_time;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        typeName.isNotEmpty
                            ? typeName
                            : '${dayType[0].toUpperCase()}${dayType.substring(1)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2430),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        leaveDay == 'multiple' ? '$fromStr - $toStr' : fromStr,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF74808F),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      SizedBox(width: 4),
                      Text(
                        status[0].toUpperCase() + status.substring(1),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (reason.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                reason,
                style: TextStyle(fontSize: 13, color: Color(0xFF74808F)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (status == 'pending' ||
                (status == 'approved' &&
                    leave['from_date'] != null &&
                    DateTime.now().isBefore(
                      DateTime.parse(leave['from_date']),
                    ))) ...[
              SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'Cancel Leave',
                      middleText: 'Are you sure you want to cancel this leave?',
                      textConfirm: 'Yes, Cancel',
                      textCancel: 'No',
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.red[400],
                      cancelTextColor: Colors.grey[700],
                      onConfirm: () {
                        Get.back();
                        Get.find<LeaveController>().cancelLeave(leave['_id']);
                      },
                    );
                  },
                  icon: Icon(
                    Icons.cancel_outlined,
                    size: 16,
                    color: Colors.red[400],
                  ),
                  label: Text(
                    'Cancel Leave',
                    style: TextStyle(fontSize: 13, color: Colors.red[400]),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: Colors.red[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2430),
            ),
          ),
          SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF74808F),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDays(double val) {
    return val % 1 == 0 ? val.toInt().toString() : val.toString();
  }

  Widget _balanceItem(String label, String value, Color color, {bool isBold = false}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF74808F),
          ),
        ),
      ],
    );
  }
}
