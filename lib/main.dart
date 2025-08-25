import 'package:flutter/material.dart';
import 'dart:js' as js;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String? _deviceId;
  String? _shareResult;
  String? _loginResult;
  String? _locationResult;
  String? _albumResult;
  String? _hapticResult;
  String? _iapResult;
  String? _tossPayResult;
  List<Map<String, dynamic>> _albumPhotos = [];
  List<Map<String, dynamic>> _iapProducts = [];
  dynamic _locationWatcher;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _getDeviceId() {
    try {
      final deviceId = js.context.callMethod('flutterGetDeviceId');
      setState(() {
        _deviceId = deviceId.toString();
      });
    } catch (e) {
      setState(() {
        _deviceId = 'Error: $e';
      });
    }
  }

  void _shareMessage() {
    try {
      js.context.callMethod('flutterShare', ['토스 앱에서 Flutter 웹앱 테스트 중입니다!']);
      setState(() {
        _shareResult = '공유 성공!';
      });
    } catch (e) {
      setState(() {
        _shareResult = 'Error: $e';
      });
    }
  }

  void _appLogin() {
    try {
      // Promise를 처리하기 위해 호출
      js.context.callMethod('flutterAppLogin');
      setState(() {
        _loginResult = '로그인 요청 중...';
      });
      // 실제로는 Promise 결과를 받기 어려우므로 상태만 표시
    } catch (e) {
      setState(() {
        _loginResult = 'Error: $e';
      });
    }
  }

  void _startLocationTracking() {
    try {
      // JavaScript 콜백 함수들을 정의
      final onLocationUpdate = js.allowInterop((location) {
        setState(() {
          final coords = location['coords'];
          _locationResult =
              '위도: ${coords['latitude']}\n'
              '경도: ${coords['longitude']}\n'
              '정확도: ${coords['accuracy']}m';
        });
      });

      final onError = js.allowInterop((error) {
        setState(() {
          _locationResult = 'Location Error: $error';
        });
      });

      _locationWatcher = js.context.callMethod('flutterStartUpdateLocation', [
        'Balanced', // accuracy
        3000, // timeInterval
        10, // distanceInterval
        onLocationUpdate,
        onError,
      ]);

      setState(() {
        _locationResult = '위치 추적 시작...';
      });
    } catch (e) {
      setState(() {
        _locationResult = 'Error: $e';
      });
    }
  }

  void _stopLocationTracking() {
    if (_locationWatcher != null) {
      try {
        // 위치 추적 중지 함수 호출 (startUpdateLocation에서 반환된 함수)
        js.context.callMethod('Function.prototype.call.call', [
          _locationWatcher,
        ]);
        setState(() {
          _locationResult = '위치 추적 중지됨';
          _locationWatcher = null;
        });
      } catch (e) {
        setState(() {
          _locationResult = 'Stop Error: $e';
        });
      }
    }
  }

  void _fetchAlbumPhotos() {
    try {
      // JavaScript 콜백 함수들을 정의
      final onSuccess = js.allowInterop((photos) {
        setState(() {
          _albumResult = '앨범 사진 ${photos.length}개 가져오기 성공!';
          // JavaScript 배열을 Dart List로 변환
          _albumPhotos = [];
          for (int i = 0; i < photos.length; i++) {
            final photo = photos[i];
            _albumPhotos.add({'id': photo['id'], 'dataUri': photo['dataUri']});
          }
        });
      });

      final onError = js.allowInterop((error) {
        setState(() {
          _albumResult = 'Album Error: $error';
        });
      });

      js.context.callMethod('flutterFetchAlbumPhotos', [
        true, // base64
        360, // maxWidth
        onSuccess,
        onError,
      ]);

      setState(() {
        _albumResult = '앨범 사진 가져오는 중...';
      });
    } catch (e) {
      setState(() {
        _albumResult = 'Error: $e';
      });
    }
  }

  void _generateHapticFeedback(String type) {
    try {
      final onSuccess = js.allowInterop(() {
        setState(() {
          _hapticResult = '햅틱 피드백 성공! ($type)';
        });
      });

      final onError = js.allowInterop((error) {
        setState(() {
          _hapticResult = 'Haptic Error: $error';
        });
      });

      js.context.callMethod('flutterGenerateHapticFeedback', [
        type,
        onSuccess,
        onError,
      ]);

      setState(() {
        _hapticResult = '햅틱 피드백 실행 중... ($type)';
      });
    } catch (e) {
      setState(() {
        _hapticResult = 'Error: $e';
      });
    }
  }

  void _getProductItemList() {
    try {
      final onSuccess = js.allowInterop((products) {
        setState(() {
          _iapResult = '상품 목록 ${products.length}개 가져오기 성공!';
          // JavaScript 배열을 Dart List로 변환
          _iapProducts = [];
          for (int i = 0; i < products.length; i++) {
            final product = products[i];
            _iapProducts.add({
              'sku': product['sku'],
              'displayName': product['displayName'],
              'displayAmount': product['displayAmount'],
              'iconUrl': product['iconUrl'],
              'description': product['description'],
            });
          }
        });
      });

      final onError = js.allowInterop((error) {
        setState(() {
          _iapResult = 'IAP Products Error: $error';
        });
      });

      js.context.callMethod('flutterGetProductItemList', [onSuccess, onError]);

      setState(() {
        _iapResult = '상품 목록 가져오는 중...';
      });
    } catch (e) {
      setState(() {
        _iapResult = 'Error: $e';
      });
    }
  }

  void _purchaseProduct(String productId, String productName) {
    try {
      final onSuccess = js.allowInterop((result) {
        setState(() {
          _iapResult =
              '결제 성공!\n'
              '주문 ID: ${result['orderId']}\n'
              '상품명: ${result['displayName']}\n'
              '가격: ${result['displayAmount']}';
        });
      });

      final onError = js.allowInterop((error) {
        setState(() {
          _iapResult = 'Purchase Error: $error';
        });
      });

      js.context.callMethod('flutterCreateOneTimePurchaseOrder', [
        productId,
        onSuccess,
        onError,
      ]);

      setState(() {
        _iapResult = '$productName 결제 진행 중...';
      });
    } catch (e) {
      setState(() {
        _iapResult = 'Error: $e';
      });
    }
  }

  void _checkoutPayment(String payToken) {
    try {
      final onSuccess = js.allowInterop((result) {
        setState(() {
          final success = result['success'];
          final reason = result['reason'];

          if (success) {
            _tossPayResult = '토스페이 인증 성공!\n결제를 진행하세요.';
          } else {
            _tossPayResult = '토스페이 인증 실패\n이유: ${reason ?? "알 수 없는 오류"}';
          }
        });
      });

      final onError = js.allowInterop((error) {
        setState(() {
          _tossPayResult = 'TossPay Error: $error';
        });
      });

      js.context.callMethod('flutterCheckoutPayment', [
        payToken,
        onSuccess,
        onError,
      ]);

      setState(() {
        _tossPayResult = '토스페이 결제창 실행 중...';
      });
    } catch (e) {
      setState(() {
        _tossPayResult = 'Error: $e';
      });
    }
  }

  Widget _buildHapticButton(String type, String label) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: () => _generateHapticFeedback(type),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          textStyle: const TextStyle(fontSize: 11),
        ),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '토스 네이티브 기능 테스트',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            // 1. Device ID
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _getDeviceId,
                      child: const Text('1. 기기 ID 가져오기'),
                    ),
                    if (_deviceId != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '결과: $_deviceId',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 2. Share
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _shareMessage,
                      child: const Text('2. 메시지 공유하기'),
                    ),
                    if (_shareResult != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '결과: $_shareResult',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 3. Login
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _appLogin,
                      child: const Text('3. 토스 인증 로그인'),
                    ),
                    if (_loginResult != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '결과: $_loginResult',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 4. Location
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _startLocationTracking,
                          child: const Text('4. 위치 추적 시작'),
                        ),
                        ElevatedButton(
                          onPressed: _stopLocationTracking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('위치 추적 중지'),
                        ),
                      ],
                    ),
                    if (_locationResult != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '결과:\n$_locationResult',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 5. Album Photos
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _fetchAlbumPhotos,
                      child: const Text('5. 앨범 사진 가져오기'),
                    ),
                    if (_albumResult != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '결과: $_albumResult',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                    if (_albumPhotos.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        '가져온 사진들:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _albumPhotos.length,
                          itemBuilder: (context, index) {
                            final photo = _albumPhotos[index];
                            final imageUri =
                                'data:image/jpeg;base64,${photo['dataUri']}';
                            return Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 8),
                              child: Image.memory(
                                Uri.parse(imageUri).data!.contentAsBytes(),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 6. Haptic Feedback
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '6. 햅틱 피드백',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildHapticButton('tickWeak', '약한 틱'),
                        _buildHapticButton('tap', '탭'),
                        _buildHapticButton('tickMedium', '중간 틱'),
                        _buildHapticButton('softMedium', '부드러운 중간'),
                        _buildHapticButton('basicWeak', '약한 기본'),
                        _buildHapticButton('basicMedium', '중간 기본'),
                        _buildHapticButton('success', '성공'),
                        _buildHapticButton('error', '에러'),
                        _buildHapticButton('wiggle', '흔들림'),
                        _buildHapticButton('confetti', '축하'),
                      ],
                    ),
                    if (_hapticResult != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        '결과: $_hapticResult',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 7. In-App Purchase (IAP)
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '7. 인앱 결제 (IAP)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _getProductItemList,
                      child: const Text('상품 목록 가져오기'),
                    ),
                    if (_iapResult != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        '결과: $_iapResult',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                    if (_iapProducts.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        '구매 가능한 상품들:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _iapProducts.length,
                        itemBuilder: (context, index) {
                          final product = _iapProducts[index];
                          return Card(
                            color: Colors.grey[50],
                            child: ListTile(
                              leading: product['iconUrl'] != null
                                  ? Image.network(
                                      product['iconUrl'],
                                      width: 40,
                                      height: 40,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.shopping_cart,
                                              size: 40,
                                            );
                                          },
                                    )
                                  : const Icon(Icons.shopping_cart, size: 40),
                              title: Text(
                                product['displayName'] ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['description'] ?? '',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    product['displayAmount'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _purchaseProduct(
                                  product['sku'],
                                  product['displayName'],
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text(
                                  '구매',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 8. TossPay
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '8. 토스페이 결제',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '결제 토큰이 필요합니다. 실제 환경에서는 서버에서 payToken을 받아옵니다.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _checkoutPayment('demo-pay-token-12345'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('토스페이로 결제하기'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _checkoutPayment('invalid-token'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('실패 테스트 (잘못된 토큰)'),
                    ),
                    if (_tossPayResult != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _tossPayResult!.contains('성공')
                              ? Colors.green[50]
                              : _tossPayResult!.contains('실패')
                              ? Colors.red[50]
                              : Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _tossPayResult!.contains('성공')
                                ? Colors.green
                                : _tossPayResult!.contains('실패')
                                ? Colors.red
                                : Colors.blue,
                          ),
                        ),
                        child: Text(
                          '결과: $_tossPayResult',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Counter (기존 기능)
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('기존 카운터:'),
                    Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
