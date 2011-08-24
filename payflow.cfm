<!--- -------------------------------------------------- --->
<!--- PAYFLOW PRO CUSTOM TAG, WRITTEN BY BRIJESH CHAUHAN --->
<!--- DATE ADDED : - 24 August 2011 --->
<!--- payFlowStr is the structure that we need to PASS to this TAG --->
<!--- It returns back the Transaction Message --->
<!--- ---------------------------------------------------------------- --->

<cfscript>
	// Javaloader configurations 
	libpaths = [];
	ArrayAppend(libpaths, expandPath("./lib/payflow.jar"));
	loader = createObject("component", "javaloader.JavaLoader").init(loadPaths=libpaths, loadColdFusionClassPath=true);
</cfscript>

<cfset PayflowUtility = loader.create("paypal.payflow.PayflowUtility") />
<cfset strRequestID = PayflowUtility.getRequestId() />


<!--- PROPERTIES --->
<cfscript>
	 SDKProperties = loader.create("paypal.payflow.SDKProperties");
	 // For testing: 	pilot-payflowpro.paypal.com
     // For production:  payflowpro.paypal.com
	 SDKProperties.setHostAddress("pilot-payflowpro.paypal.com");
     SDKProperties.setHostPort(443);
     SDKProperties.setTimeOut(45);
	 //SDKProperties.setLogFileName("payflow_java.log");
	 //SDKProperties.setProxyAddress("");
	 //SDKProperties.setProxyPort();
     //SDKProperties.setProxyLogin("");
     //SDKProperties.setProxyPassword("");
     //SDKProperties.setLoggingLevel(PayflowConstants.SEVERITY_DEBUG);
     //SDKProperties.setMaxLogFileSize(10000000);
	 // JRUN HANDLER
	 SDKProperties.setURLStreamHandlerClass("sun.net.www.protocol.https.Handler");
	 SDKProperties.setStackTraceOn(true);
</cfscript>
<!--- --->


<!---- USER INFO --->

<cfscript>
	user = loader.create("paypal.payflow.UserInfo");
	// Remember: <vendor> = your merchant (login id), <user> = <vendor> unless you created a separate
    // <user> for Payflow Pro.
	vendor = javaCast("String","#ATTRIBUTES.payFlowStr.vendor#");
	user = javaCast("String","#ATTRIBUTES.payFlowStr.user#");
	partner = javaCast("String","#ATTRIBUTES.payFlowStr.partner#");
	password = javaCast("String","#ATTRIBUTES.payFlowStr.password#");
	user.init(user,vendor,partner,password); // TO DO , add the information in here 
	connection = loader.create("paypal.payflow.PayflowConnectionData");
	inv = loader.create("paypal.payflow.Invoice");
	amt = loader.create("paypal.payflow.Currency");
	totalAmt = decimalformat(ATTRIBUTES.payFlowStr.totalAmt);
	total = javaCast("Double",totalAmt);
	amt.init(total, "USD");
	inv.setAmt(amt);
	// Only Customer related information
	//inv.setPoNum("PO12345");
   	inv.setInvNum("#ATTRIBUTES.payFlowStr.invnum#");
	//custRef = '#ATTRIBUTES.payFlowStr.CFID#' & '#ATTRIBUTES.payFlowStr.CFToken#';
	//inv.setCustRef("#custRef#");
    //inv.setMerchDescr("Merchant Descr");
    //inv.setMerchSvc("Merchant Svc");
	//inv.setComment1("Comment1");
    //inv.setComment2("Comment2");
</cfscript>


<!--- Billing Information --->

<cfscript>
	bill = loader.create("paypal.payflow.BillTo");
	bill.setFirstName("#ATTRIBUTES.payFlowStr.bill_firstname#");
	bill.setLastName("#ATTRIBUTES.payFlowStr.bill_lastname#");
    bill.setCompanyName("#ATTRIBUTES.payFlowStr.bill_company#");
	bill.setStreet("#ATTRIBUTES.payFlowStr.bill_address#");
    // Secondary street address.
    // bill.setBillToStreet2("Suite A");
	bill.setCity("#ATTRIBUTES.payFlowStr.bill_city#");
    bill.setState("#ATTRIBUTES.payFlowStr.bill_state#");
    bill.setZip("#ATTRIBUTES.payFlowStr.bill_zip#");
	bill.setBillToCountry("840");
    bill.setPhoneNum("#ATTRIBUTES.payFlowStr.bill_phone#");
	bill.setEmail("#ATTRIBUTES.payFlowStr.bill_email#");
	inv.setBillTo(bill);
</cfscript>

<!--- Shipping Informatioin --->

<cfscript>
	ship = loader.create("paypal.payflow.ShipTo");
        // Uncomment statements below to send to separate Ship To address.
        // Set the recipient's name.
        //ship.setShipToFirstName("Sam");
        //ship.setShipToMiddleName("J");
        //ship.setShipToLastName("Spade");
        //ship.setShipToStreet("456 Shipping St.");
        //ship.setShipToStreet2("Apt A");
        //ship.setShipToCity("Las Vegas");
        //ship.setShipToState("NV");
        //ship.setShipToZip("99999");
        // ShipToCountry code is based on numeric ISO country codes. (e.g. 840 = USA)
        // For more information, refer to the Payflow Pro Developer's Guide.
        //ship.setShipToCountry("840");
        //ship.setShipToPhone("555-123-1233");
        // Secondary phone numbers (could be mobile number etc).
        //ship.setShipToPhone2("555-333-1222");
        //ship.setShipToEmail("Sam.Spade@email.com");
        //ship.setShipFromZip(bill.getZip());

	ship = bill.copy();
	inv.setShipTo(ship);
</cfscript>

<!--- Customer Information --->

<!--- ONLY REQUIRED IF YOU ARE LOOKING FOR DISCOUNTS TO RETURNING CUSTOMERS 

<cfscript>
	CustInfo = loader.create("paypal.payflow.CustomerInfo");
	CustInfo.setCustCode("Cust123");
    CustInfo.setCustId("CustomerID");
    inv.setCustomerInfo(CustInfo);
</cfscript>

--->

<!--- CREDIT CARD INFORMAION --->

<cfscript>
	cc = loader.create("paypal.payflow.CreditCard");
	cc.init("#ATTRIBUTES.payFlowStr.ccnumber#", "#ATTRIBUTES.payFlowStr.expDate#");
	cc.setCvv2("#ATTRIBUTES.payFlowStr.cvv2#");
	cc.setName("#ATTRIBUTES.payFlowStr.cccardname#");
</cfscript>

<!--- Card Tender Object --->

<cfscript>
	card = loader.create("paypal.payflow.CardTender");
	card.init(cc);
</cfscript>

<!--- Transaction --->

<cfscript>
	trans = loader.create("paypal.payflow.SaleTransaction");
	trans.init(user, connection, inv, card, strRequestID);
	trans.setVerbosity("MEDIUM");
	clinfo = loader.create("paypal.payflow.ClientInfo");
	trans.setClientInfo(clinfo);
	// submit the transaction 
	Resp = trans.submitTransaction();
</cfscript>

<cfif Resp NEQ ''>
	<cfscript>
		TrxnResponse = Resp.getTransactionResponse();
	</cfscript>
    
    <cfscript>
			RespMsg = '';
			if (TrxnResponse.getResult() < 0) { // Transaction failed.
                RespMsg = "There was an error processing your transaction. Please contact Customer Service." + "\nError: " + TrxnResponse.getResult();
            } else if (TrxnResponse.getResult() == 1 || TrxnResponse.getResult() == 26) {
                // This is just checking for invalid login information.  You would not want to display this to your customers.
                RespMsg = "Account configuration issue.  Please verify your login credentials.";
            } else if (TrxnResponse.getResult() == 0) {
                RespMsg = "Your transaction was approved. Will ship in 24 hours.";
            } else if (TrxnResponse.getResult() == 12) { // Hard decline from bank.
                RespMsg = "Your transaction was declined.";
            } else if (TrxnResponse.getResult() == 13) {  // Voice authorization required.
                RespMsg = "Your Transaction is pending. Contact Customer Service to complete your order.";
            } else
            if (TrxnResponse.getResult() == 23 || TrxnResponse.getResult() == 24) { // Issue with credit card number or expiration date.
                RespMsg = "Invalid credit card information. Please re-enter.";
            } else if (TrxnResponse.getResult() == 125) { // 125, 126 and 127 are Fraud Responses.
                // Refer to the Payflow Pro Fraud Protection Services User's Guide or Website Payments Pro Payflow Edition - Fraud Protection Services User's Guide.
                RespMsg = "Your Transactions has been declined. Contact Customer Service.";
            } else if (TrxnResponse.getResult() == 126) { // Decline transaction if AVS fails.
                if ((!TrxnResponse.getAvsAddr() IS 'Y ') || (!TrxnResponse.getAvsZip() IS 'Y')) {
                    // Display message that transaction was not accepted.  At this time, you
                    // could display message that information is incorrect and redirect user
                    // to re-enter STREET and ZIP information.  However, there should be some sort of
                    // 3 strikes your out check.
                    RespMsg = "Your billing information does not match. Please re-enter.";
                } else {
                    RespMsg = "Your Transaction is Under Review. We will notify you via e-mail if accepted.";
                }
            } else if (TrxnResponse.getResult() == 127) {
                RespMsg = "Your Transaction is Under Review. We will notify you via e-mail if accepted.";
            } else { // Error occurred, display normalized message returned.
                RespMsg = TrxnResponse.getRespMsg();
            }
		</cfscript>
        
         <cfset "Caller.#Attributes.resultName#" = RespMsg /> 

</cfif>
     

</body>
</html>