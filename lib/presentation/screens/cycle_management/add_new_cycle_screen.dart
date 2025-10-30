// lib/presentation/screens/cycle_management/add_new_cycle_screen.dart

import 'package:flutter/material.dart';
import 'package:laour_cycle_manager/config/dependency_injection.dart';
import 'package:laour_cycle_manager/presentation/view_models/add_new_cycle_viewmodel.dart';
import 'package:provider/provider.dart';

class AddNewCycleScreen extends StatelessWidget {
  const AddNewCycleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<AddNewCycleViewModel>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('새 사이클 추가'),
        ),
        body: const AddNewCycleForm(),
      ),
    );
  }
}

class AddNewCycleForm extends StatefulWidget {
  const AddNewCycleForm({super.key});

  @override
  State<AddNewCycleForm> createState() => _AddNewCycleFormState();
}

class _AddNewCycleFormState extends State<AddNewCycleForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tickerController = TextEditingController();
  final _amountController = TextEditingController();
  final _divisionsController = TextEditingController(text: '40'); // 기본값 40
  final _profitTargetController = TextEditingController(text: '10'); // 기본값 10

  @override
  void dispose() {
    _nameController.dispose();
    _tickerController.dispose();
    _amountController.dispose();
    _divisionsController.dispose();
    _profitTargetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AddNewCycleViewModel>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '사이클 이름 (예: TQQQ 첫번째)'),
              validator: (value) => (value == null || value.isEmpty) ? '이름을 입력해주세요.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tickerController,
              decoration: const InputDecoration(labelText: '종목 티커 (예: TQQQ)'),
              textCapitalization: TextCapitalization.characters, // 자동 대문자 변환
              validator: (value) => (value == null || value.isEmpty) ? '티커를 입력해주세요.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: '총 투자금'),
              keyboardType: TextInputType.number,
              validator: (value) => (value == null || double.tryParse(value) == null) ? '숫자만 입력해주세요.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _divisionsController,
              decoration: const InputDecoration(labelText: '분할 횟수'),
              keyboardType: TextInputType.number,
              validator: (value) => (value == null || int.tryParse(value) == null) ? '정수만 입력해주세요.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _profitTargetController,
              decoration: const InputDecoration(labelText: '목표 수익률 (%)'),
              keyboardType: TextInputType.number,
              validator: (value) => (value == null || double.tryParse(value) == null) ? '숫자만 입력해주세요.' : null,
            ),
            const SizedBox(height: 24),
            if (viewModel.getErrorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(viewModel.getErrorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final success = await viewModel.addNewCycle(
                          name: _nameController.text,
                          ticker: _tickerController.text,
                          totalInvestmentAmount: _amountController.text,
                          divisionCount: _divisionsController.text,
                          targetProfitPercentage: _profitTargetController.text,
                        );
                        if (success && mounted) {
                          // 성공 시 이전 화면(사이클 목록)으로 돌아갑니다.
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: const Text('사이클 생성하기'),
                  ),
          ],
        ),
      ),
    );
  }
}