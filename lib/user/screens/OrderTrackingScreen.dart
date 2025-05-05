import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';

import '../../main.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/models/LoginResponse.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';

class OrderTrackingScreen extends StatefulWidget {
  static String tag = '/OrderTrackingScreen';

  final OrderData orderData;

  OrderTrackingScreen({required this.orderData});

  @override
  OrderTrackingScreenState createState() => OrderTrackingScreenState();
}

class OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Timer? timer;

  List<Marker> markers = [];
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];

  late PolylinePoints polylinePoints;

  LatLng? sourceLocation;

  double cameraZoom = 13;

  double cameraTilt = 0;
  double cameraBearing = 30;

  UserData? deliveryBoyData;

  late Marker deliveryBoyMarker;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    polylinePoints = PolylinePoints();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => getDeliveryBoyDetails());
  }

  getDeliveryBoyDetails() {
    getUserDetail(widget.orderData.deliveryManId.validate()).then((value) {
      deliveryBoyData = value;
      sourceLocation = LatLng(deliveryBoyData!.latitude.toDouble(), deliveryBoyData!.longitude.toDouble());
      MarkerId id = MarkerId("DeliveryBoy");
      markers.remove(id);
      deliveryBoyMarker = Marker(
        markerId: id,
        position: LatLng(deliveryBoyData!.latitude.toDouble(), deliveryBoyData!.longitude.toDouble()),
        infoWindow: InfoWindow(
            title: '${deliveryBoyData!.name.validate()}',
            snippet: '${language.lastUpdatedAt} ${dateParse(deliveryBoyData!.updatedAt!)}'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );
      markers.add(deliveryBoyMarker);
      markers.add(
        Marker(
          markerId: MarkerId(widget.orderData.cityName.validate()),
          position: widget.orderData.status == ORDER_ACCEPTED
              ? LatLng(
                  widget.orderData.pickupPoint!.latitude.toDouble(), widget.orderData.pickupPoint!.longitude.toDouble())
              : LatLng(widget.orderData.deliveryPoint!.latitude.toDouble(),
                  widget.orderData.deliveryPoint!.longitude.toDouble()),
          infoWindow: InfoWindow(
              title: widget.orderData.status == ORDER_ACCEPTED
                  ? widget.orderData.pickupPoint!.address.validate()
                  : widget.orderData.deliveryPoint!.address.validate()),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
      setPolyLines(deliveryLatLng: LatLng(deliveryBoyData!.latitude.toDouble(), deliveryBoyData!.longitude.toDouble()));
      setState(() {});
    }).catchError((error) {
      print(error);
    });
  }

  Future<void> setPolyLines({required LatLng deliveryLatLng}) async {
    _polylines.clear();
    polylineCoordinates.clear();
    var result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: googleMapAPIKey,
        request: PolylineRequest(
          origin: PointLatLng(deliveryLatLng.latitude, deliveryLatLng.longitude),
          destination: widget.orderData.status == ORDER_ACCEPTED
              ? PointLatLng(
                  widget.orderData.pickupPoint!.latitude.toDouble(), widget.orderData.pickupPoint!.longitude.toDouble())
              : PointLatLng(widget.orderData.deliveryPoint!.latitude.toDouble(),
                  widget.orderData.deliveryPoint!.longitude.toDouble()),
          mode: TravelMode.driving,
        ));
    if (result.points.isNotEmpty) {
      result.points.forEach((element) {
        polylineCoordinates.add(LatLng(element.latitude, element.longitude));
      });
      _polylines.add(Polyline(
        visible: true,
        width: 5,
        polylineId: PolylineId('poly'),
        color: Color.fromARGB(255, 40, 122, 198),
        points: polylineCoordinates,
      ));
      setState(() {});
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: language.trackOrder,
      body: sourceLocation != null
          ? GoogleMap(
              markers: markers.map((e) => e).toSet(),
              polylines: _polylines,
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: sourceLocation!,
                zoom: cameraZoom,
                tilt: cameraTilt,
                bearing: cameraBearing,
              ),
            )
          : loaderWidget(),
    );
  }
}
