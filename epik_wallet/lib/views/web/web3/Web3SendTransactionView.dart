import 'package:convert/convert.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/text/TextEllipsisMiddle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

class Web3SendTransactionView extends StatefulWidget {
  Transaction transaction;
  CurrencySymbol cs;
  String gasrate = null;
  String maxgasrate= null;

  Web3SendTransactionView(this.transaction, this.cs, this.gasrate,this.maxgasrate);

  @override
  State<StatefulWidget> createState() {
    return Web3SendTransactionViewState();
  }
}

class Web3SendTransactionViewState extends State<Web3SendTransactionView> {
  double key_w = 65;

  bool extend_data = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];

    if (widget.transaction.from != null) {
      Widget item = Row(
        children: [
          Container(
            width: key_w,
            child: Text(
              "From : ",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: TextEm(
              widget.transaction.from.hex,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
      items.add(item);
    }

    if (widget.transaction.to != null) {
      Widget item = Row(
        children: [
          Container(
            width: key_w,
            child: Text(
              "To : ",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: TextEm(
              widget.transaction.to.hex,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
      items.add(item);
    }

    EtherAmount ea_value = widget.transaction.value;
    if (ea_value == null) ea_value = EtherAmount.inWei(BigInt.from(0));
    // ea_value = EtherAmount.inWei(BigInt.parse("1230000000000000000"));
    if (ea_value != null) {
      String value = ea_value.getValueInUnit(EtherUnit.ether).toString();
      Widget item = Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: key_w,
            child: Text(
              "Value : ",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              color: ResColor.o_1, //Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            " ${widget?.cs?.symbol ?? ""}",
            style: TextStyle(
              fontSize: 20,
              color: ResColor.o_1, //Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
      items.add(item);
    }

    int gas = widget.transaction.maxGas;
    EtherAmount gp = widget.transaction.gasPrice;

    if (gas != null && gp != null) {
      String currencygas = null;
      double dcg = gp.getValueInUnit(EtherUnit.ether) * gas;
      currencygas = StringUtils.formatNumAmount(dcg, point: 18, supply0: false);
      Widget item = Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: key_w,
            child: Text(
              "Gas : ",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            "$currencygas ${widget?.cs?.symbol ?? ""}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              // fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
      items.add(item);
    }

    if (gas != null) {
      Widget item = Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: key_w,
            child: Text(
              "MaxGas : ",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            "$gas",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              // fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
      items.add(item);
    }
    {
      List<String> list_maxgas = ["1.5", "2.0", "2.5", "3.0"];

      Widget item = Container(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Row(children: [
          Container(
            width: key_w,
            child: Text(
              "",// "Gas加倍 : ",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...list_maxgas.map((e) {
            bool isSeleted = widget.maxgasrate == e;
            return Expanded(
                child: LoadingButton(
                  height: 20,
                  text: e+"x",
                  textstyle: TextStyle(
                    fontSize: 11,
                    color: isSeleted ? ResColor.black : ResColor.o_1,
                    fontWeight: FontWeight.bold,
                  ),
                  margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  bg_borderradius: BorderRadius.circular(4),
                  color_bg: isSeleted ? ResColor.o_1 : Colors.transparent,
                  disabledColor: Colors.transparent,
                  side: BorderSide(
                    color: ResColor.o_1,
                    width: 1,
                  ),
                  onclick: (lbtn) {
                    if (isSeleted) {
                      widget.maxgasrate = null;
                    } else {
                      widget.maxgasrate = e;
                    }
                    setState(() {});
                  },
                ));
          }).toList(),
        ]),
      );
      items.add(item);
    }

    if (gp != null) {
      num gpnm = gp.getValueInUnit(EtherUnit.gwei);
      String gpstr = StringUtils.formatNumAmount(gpnm, point: 18, supply0: false);
      Widget item = Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: key_w,
            child: Text(
              "GasPrice : ",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            gpstr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              // fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            " GWEI", //" ${widget?.cs?.symbol ?? ""}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              // fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
      items.add(item);
    }

    if (gp != null) {
      List<String> list_gasrate = ["1.1", "1.2", "1.3", "1.4", "1.5"];

      Widget item = Container(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Row(children: [
          Container(
            width: key_w,
            child: Text(
              "",// "Gas加倍 : ",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...list_gasrate.map((e) {
            bool isSeleted = widget.gasrate == e;
            return Expanded(
                child: LoadingButton(
              height: 20,
              text: e+"x",
              textstyle: TextStyle(
                fontSize: 11,
                color: isSeleted ? ResColor.black : ResColor.o_1,
                fontWeight: FontWeight.bold,
              ),
              margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
              bg_borderradius: BorderRadius.circular(4),
              color_bg: isSeleted ? ResColor.o_1 : Colors.transparent,
              disabledColor: Colors.transparent,
              side: BorderSide(
                color: ResColor.o_1,
                width: 1,
              ),
              onclick: (lbtn) {
                if (isSeleted) {
                  widget.gasrate = null;
                } else {
                  widget.gasrate = e;
                }
                setState(() {});
              },
            ));
          }).toList(),
        ]),
      );
      items.add(item);
    }

    if (widget.transaction.data != null) {
      Widget item = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: key_w,
            child: Text(
              "Data : ",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white60,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: extend_data
                ? SelectableText(
                    "0x" + hex.encode(widget.transaction.data)+hex.encode(widget.transaction.data)+hex.encode(widget.transaction.data),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
              onTap: (){
                extend_data= !extend_data;
                // print("extend_data=$extend_data");
                setState(() {
                });
              },
                  )
                : Text(
                    "0x" + hex.encode(widget.transaction.data),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
          ),
        ],
      );
      items.add(InkWell(
        child: item,
        onTap: () {
          extend_data= !extend_data;
          // print("extend_data=$extend_data");
          setState(() {
          });
        },
      ));
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.33,
        minHeight: 0,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items,
        ),
      ),
    );
  }
}
