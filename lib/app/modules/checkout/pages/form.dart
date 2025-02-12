import 'package:flutter/material.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';

class FormScreen extends StatelessWidget {
  const FormScreen({super.key});

  Widget buildTextField(String hintText, {int? maxlines}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (maxlines == null) Text(hintText),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          margin: EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xffEAEAEA)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            maxLines: maxlines ?? 1,
            decoration: InputDecoration(
                hintStyle: defaultTextStyle.copyWith(
                    color: Colors.grey.shade400, fontSize: 14),
                hintText: 'Enter $hintText',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none),
          ),
        ),
        SizedBox(height: 10)
      ],
    );
  }

  Widget buildDropdown(String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hintText),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          margin: EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xffEAEAEA)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              hint: Text('Select $hintText'),
              isExpanded: true,
              onChanged: (String? value) {},
              items: [],
            ),
          ),
        ),
        SizedBox(height: 10)
      ],
    );
  }

  Widget renderproducts() {
    return ListView.separated(
        separatorBuilder: (context, index) {
          return SizedBox(height: 15);
        },
        shrinkWrap: true,
        itemCount: 2,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [],
            ),
            child: Column(
              children: [
                _buildSellerSection(),
                Container(
                  height: 2,
                  color: Colors.grey.shade300,
                ),
                SizedBox(height: 10),
                _buildProductCard(),
              ],
            ),
          );
        });
  }

  Widget _buildSellerSection() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: Row(
        children: [
          Container(
            height: 37,
            width: 37,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset('assets/images/sktech.png'),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Stylish Collection Wholesellers',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("You've got free shipping with specific products!",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/shoes.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'hand bag for girls crossbody & shoulder handbag for women new design handbags',
                        style: defaultTextStyle.copyWith(
                            fontWeight: FontWeight.w400, fontSize: 15)),
                    SizedBox(height: 5),
                    Text('Color Family: Mustard  |  Size: S',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text('\$78',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red)),
                        SizedBox(width: 5),
                        Text('\$2222',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough)),
                        SizedBox(width: 15),
                        Container(
                          decoration: BoxDecoration(color: Colors.red.shade100),
                          height: 25,
                          width: 50,
                          child: Center(
                            child: Text('-65%',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.red)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 15),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      "Get Voucher",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("1 Item(S). Subtotal: ",
                            style: TextStyle(fontSize: 16)),
                        Text(" \$345",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text("Saved \$269",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child: Row(
              children: [
                Text("Home", style: defaultTextStyle.copyWith(fontSize: 16)),
                Text(" / Cart / ",
                    style: defaultTextStyle.copyWith(fontSize: 16)),
                Text("Checkout",
                    style: defaultTextStyle.copyWith(
                        fontSize: 16, color: Color(0xffD21642))),
              ],
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Add information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20),
          buildTextField("First Name"),
          buildTextField("Last Name"),
          buildTextField("Email"),
          buildTextField("Phone"),
          buildDropdown("Country"),
          buildDropdown("Region/State"),
          buildDropdown("City"),
          buildDropdown("Zip Code"),
          buildTextField("Address"),
          Row(
            children: [
              Checkbox(value: false, onChanged: (value) {}),
              Text("Ship into different address"),
            ],
          ),
          SizedBox(height: 18),
          Text("Add Payment Methods",
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                  child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          color: Color(0xffF9F9F9)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child:
                            Image.asset("assets/images/paypal.png", height: 44),
                      ))),
              SizedBox(width: 10),
              Expanded(
                  child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          color: Color(0xffF9F9F9)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child:
                            Image.asset("assets/images/visa.png", height: 44),
                      ))),
              SizedBox(width: 10),
              Expanded(
                  child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          color: Color(0xffF9F9F9)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child:
                            Image.asset("assets/images/paypal.png", height: 44),
                      ))),
            ],
          ),
          SizedBox(height: 16),
          Text("Additional Information",
              style: defaultTextStyle.copyWith(
                  fontSize: 18, fontWeight: FontWeight.w500)),
          SizedBox(height: 20),
          Text("Order Notes (Optional)",
              style: defaultTextStyle.copyWith(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.w500)),
          buildTextField(
              "Notes about your order, e.g. special notes for delivery",
              maxlines: 8),
          SizedBox(height: 15),
          renderproducts(),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Discount And Payment",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Daraz Voucher"),
                    Text("No Applicable Voucher"),
                  ],
                ),
                SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Items Total"),
                    Text(" \$1,029"),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Delivery Fee"),
                    Text(" \$1,029"),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Delivery Discount"),
                    Text(" -\$115", style: TextStyle(color: Colors.red)),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Payment",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(" \$1,144",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text("VAT Included, Where Applicable",
                      style: TextStyle(color: Colors.grey)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Material(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Center(
                          child: Text(
                            'Placed Order',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
