// lib/presentation/screens/cycle_management/manual_trade_screen.dart

import 'package:flutter/material.dart';
import 'package:laour_cycle_manager/config/dependency_injection.dart';
import 'package:laour_cycle_manager/domain/entities/cycle.dart';
import 'package:laour_cycle_manager/domain/entities/trade_record.dart';
import 'package:laour_cycle_manager/presentation/view_models/manual_trade_viewmodel.dart';
import 'package:provider/provider.dart';

class ManualTradeScreen extends StatelessWidget {
  final Cycle cycle;

  const ManualTradeScreen({super.key, required this.cycle});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<ManualTradeViewModel>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('수동 거래 추가'),
        ),
        body: ManualTradeForm(cycle: cycle),
      ),
    );
  }
}

class ManualTradeForm extends StatefulWidget {
  final Cycle cycle;
  const ManualTradeForm({super.key, required this.cycle});

  @override
  State<ManualTradeForm> createState() => _ManualTradeFormState();
}

class _ManualTradeFormState extends State<ManualTradeForm> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  
  // 거래 종류를 선택하기 위한 상태 변수 (기본값: 수동 매수)
  TradeType _selectedTradeType = TradeType.manualBuy;

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ManualTradeViewModel>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 거래 종류 선택 라디오 버튼
            const Text('거래 종류', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<TradeType>(
                    title: const Text('수동 매수'),
                    value: TradeType.manualBuy,
                    groupValue: _selectedTradeType,
                    onChanged: (value) => setState(() => _selectedTradeType = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<TradeType>(
                    title: const Text('수동 매도'),
                    value: TradeType.manualSell,
                    groupValue: _selectedTradeType,
                    onChanged: (value) => setState(() => _selectedTradeType = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: '체결 가격'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) => (value == null || double.tryParse(value) == null) ? '숫자만 입력해주세요.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: '수량'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                        final success = await viewModel.submitManualTrade(
                          cycleId: widget.cycle.id,
                          tradeType: _selectedTradeType,
                          price: _priceController.text,
                          quantity: _quantityController.text,
                        );
                        if (success && mounted) {
                          // 성공 시 이전 화면(사이클 상세)으로 돌아갑니다.
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: const Text('거래 기록 저장하기'),
                  ),
          ],
        ),
      ),
    );
  }
}