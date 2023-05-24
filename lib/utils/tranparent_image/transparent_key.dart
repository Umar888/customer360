import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:io';


class TransparentKey{
  Future<Uint8List?> removeWhiteBackground(Uint8List bytes) async {
    img.Image? image = img.decodeImage(bytes);
    img.Image? transparentImage = await colorTransparent(image!, 255, 255, 255);
    var newPng = img.encodePng(transparentImage!);
    Uint8List unit8list = Uint8List.fromList(newPng);
    return unit8list;
  }


  Future<Uint8List> downloadImage(String url) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    //File file = File("http://photo.tuchong.com/4870004/f/298584322.jpg");

    final ByteData imageData = await NetworkAssetBundle(Uri.parse(url)).load("");
    final Uint8List finalImg = imageData.buffer.asUint8List();

    // display it with the Image.memory widget
    //var image = await file.readAsBytes();
    return finalImg;

  }


  Future<img.Image?> colorTransparent(img.Image src, int red, int green, int blue) async {
    var bytes = src.getBytes() ;
    for (int i = 0, len = bytes.length; i < len; i += 4) {
      if((bytes[i] == red&&bytes[i+1] == green&&bytes[i+2] == blue)
      ){
        bytes[i+3] = 0;
      }
    }

    return img.Image.fromBytes(src.width, src.height, bytes);
  }}