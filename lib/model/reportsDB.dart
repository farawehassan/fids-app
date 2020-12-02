/// A class to hold my [Reports] model
class Reports {

  /// Setting constructor for [Reports] class
  Reports({
    this.id,
    this.qty,
    this.yards,
    this.productName,
    this.printPrice,
    this.tailorPrice,
    this.costPrice,
    this.unitPrice,
    this.paymentMode,
    this.createdAt
  });

  /// A string variable to hold id
  String id;

  /// An integer variable to hold dress number
  double qty;

  /// A double variable to hold the number of yards used
  double yards;

  /// A string variable to hold product name
  String productName;

  /// A double variable to hold print price
  double printPrice;

  /// A double variable to hold tailor price
  double tailorPrice;

  /// A double variable to hold cost price
  double costPrice;

  /// A double variable to hold unit price
  double unitPrice;

  /// A string variable to hold payment mode
  String paymentMode;

  /// A string variable to hold time
  String createdAt;

  /// Creating a method to map my JSON values to the model details accordingly
  factory Reports.fromJson(Map<String, dynamic> json) {
    return Reports(
      id: json["_id"].toString(),
      qty: double.parse(json["dress"].toString()),
      yards: double.parse(json["quantity"].toString()),
      productName: json["productName"].toString(),
      printPrice: double.parse(json["printPrice"].toString()),
      tailorPrice: double.parse(json["tailorPrice"].toString()),
      costPrice: double.parse(json["costPrice"].toString()),
      unitPrice: double.parse(json["unitPrice"].toString()),
      paymentMode: json["paymentMode"].toString(),
      createdAt: json["createdAt"].toString(),
    );
  }

}