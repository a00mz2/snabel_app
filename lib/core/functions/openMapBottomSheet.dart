// ignore_for_file: deprecated_member_use, file_names

import 'package:customer/core/functions/snackbar.dart';
import 'package:customer/view/widget/widgetApp/ButtonAppWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:customer/controller/SignUpControler.dart';

Future<void> openMapBottomSheet(SignUpControler controller) async {
  try {
    Position position = await determinePosition();

    await Future.delayed(const Duration(milliseconds: 300)); // تأخير بسيط

    final MapController mapController = MapController();
    LatLng initialPosition = LatLng(position.latitude, position.longitude);
    controller.setTempLocation(initialPosition);

    Get.bottomSheet(
      Container(
        height: Get.height - 200,
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            Expanded(
              child: Obx(
                () => FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter:
                        controller.tempLocation.value ?? initialPosition,
                    initialZoom: 16,
                    onTap: (tapPos, point) {
                      controller.setTempLocation(point);
                    },
                    minZoom: 3,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.de/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.sanabel.tahouna',
                    ),
                    MarkerLayer(
                      markers: controller.tempLocation.value == null
                          ? []
                          : [
                              Marker(
                                point: controller.tempLocation.value!,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                Position position = await determinePosition();
                LatLng newPosition = LatLng(
                  position.latitude,
                  position.longitude,
                );
                controller.setTempLocation(newPosition);
                mapController.move(newPosition, 16);
              },
              icon: const Icon(Icons.my_location),
              label: const Text("موقعي الحالي"),
            ),
            SizedBox(height: 10),
            ButtonAppWidget(
              onPressed: () {
                controller.confirmLocation();
                Get.back();
              },
              lable: "تأكيد الموقع",
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
      isScrollControlled: true,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      mapController.move(initialPosition, 16);
    });
  } catch (e) {
    Get.snackbar("خطأ", e.toString());
  }
}

// دالة التحقق من صلاحيات الموقع والحصول عليه
Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    AppSnackBar.warning('خدمة الموقع مغلقة.');
    return Future.error('خدمة الموقع مغلقة.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('الصلاحيات مرفوضة.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('الصلاحيات مرفوضة نهائياً، لا يمكن الوصول للموقع.');
  }

  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}
