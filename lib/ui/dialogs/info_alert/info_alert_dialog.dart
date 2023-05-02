import 'package:flutter/material.dart';
import 'package:flutter_app_test_stacked/ui/common/ui_helpers.dart';
import 'package:stacked_services/stacked_services.dart';

const double _graphicSize = 60;

class InfoAlertDialog extends StatelessWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const InfoAlertDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool? success = request.data;

    String? titleText = request.title;
    String graphic = '❕';

    if (success == true) {
      titleText = 'Hooray!';
      graphic = '🎉';
    } else if (success == false) {
      titleText = 'Oops!';
      graphic = '💥';
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleText!,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        request.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF474A54),
                        ),
                        maxLines: 3,
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: _graphicSize,
                  height: _graphicSize,
                  decoration: const BoxDecoration(
                    color: Color(0xffF6E7B0),
                    borderRadius: BorderRadius.all(
                      Radius.circular(_graphicSize / 2),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    graphic,
                    style: const TextStyle(fontSize: 30),
                  ),
                )
              ],
            ),
            const SizedBox(height: 25),
            GestureDetector(
              onTap: () => completer(DialogResponse(
                confirmed: true,
              )),
              child: Container(
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  request.mainButtonTitle ?? 'Got it',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: circularBorderRadius,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
