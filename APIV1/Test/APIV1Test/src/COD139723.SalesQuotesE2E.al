codeunit 139723 "APIV1 - Sales Quotes E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Sales] [Quote]
    end;

    var
        Assert: Codeunit "Assert";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryGraphDocumentTools: Codeunit "Library - Graph Document Tools";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        LibrarySmallBusiness: Codeunit "Library - Small Business";
        LibraryERM: Codeunit "Library - ERM";
        QuoteServiceNameTxt: Label 'salesQuotes';
        GraphContactIdFieldTxt: Label 'contactId';
        CustomerIdFieldTxt: Label 'customerId';
        CustomerNameFieldTxt: Label 'customerName';
        CustomerNumberFieldTxt: Label 'customerNumber';
        DiscountAmountFieldTxt: Label 'discountAmount';
        ActionSendTxt: Label 'Microsoft.NAV.send', Locked = true;
        ActionMakeInvoiceTxt: Label 'Microsoft.NAV.makeInvoice', Locked = true;
        ActionMakeOrderTxt: Label 'Microsoft.NAV.makeOrder', Locked = true;
        InvoiceStatusErr: Label 'The invoice status is incorrect.';
        QuoteStatusErr: Label 'The quote status is incorrect.', Locked = true;
        OrderStatusErr: Label 'The order status is incorrect.', Locked = true;
        CannotFindQuoteErr: Label 'Cannot find the quote.', Locked = true;
        CannotFindOrderErr: Label 'Cannot find the order.';
        CannotFindDraftInvoiceErr: Label 'Cannot find the draft invoice.';
        NotEmptyResponseErr: Label 'Response body should be empty.';
        QuoteStillExistsErr: Label 'The quote still exists.', Locked = true;
        EmptyParameterErr: Label 'Email parameter %1 is empty.', Locked = true;
        NotEmptyParameterErr: Label 'Email parameter %1 is not empty.', Locked = true;
        InvoiceIdErr: Label 'The invoice ID should differ from the quote ID.', Locked = true;
        MailingJobErr: Label 'The mailing job is not created.', Locked = true;

    local procedure Initialize()
    begin
        WorkDate := Today();
    end;

    local procedure InitializeForSending()
    begin
        CreateSMTPMailSetup();
        DeleteJobQueueEntry(CODEUNIT::"Document-Mailing");
        DeleteJobQueueEntry(CODEUNIT::"O365 Sales Cancel Invoice");
        Initialize();
    end;


    [Test]
    procedure TestGetQuotes()
    var
        SalesHeader: Record "Sales Header";
        QuoteID: array[2] of Text;
        QuoteJSON: array[2] of Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create Sales Quotes and use a GET method to retrieve them
        // [GIVEN] 2 quotes in the table
        Initialize();
        CreateSalesQuoteWithLines(SalesHeader);
        QuoteID[1] := SalesHeader."No.";

        CreateSalesQuoteWithLines(SalesHeader);
        QuoteID[2] := SalesHeader."No.";
        Commit();

        // [WHEN] we GET all the quotes from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Sales Quotes", QuoteServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the 2 quotes should exist in the response
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(
            ResponseText, 'number', QuoteID[1], QuoteID[2], QuoteJSON[1], QuoteJSON[2]),
          'Could not find the quotes in JSON');
        LibraryGraphMgt.VerifyIDInJson(QuoteJSON[1]);
        LibraryGraphMgt.VerifyIDInJson(QuoteJSON[2]);
    end;

    [Test]
    procedure TestPostQuotes()
    var
        SalesHeader: Record "Sales Header";
        SellToCustomer: Record "Customer";
        BillToCustomer: Record "Customer";
        ShipToCustomer: Record "Customer";
        LibrarySales: Codeunit "Library - Sales";
        CustomerNo: Text;
        QuoteDate: Date;
        ResponseText: Text;
        QuoteNumber: Text;
        TargetURL: Text;
        QuoteWithComplexJSON: Text;
        QuoteExists: Boolean;
    begin
        // [SCENARIO] Create sales quotes JSON and use HTTP POST to create them
        Initialize();

        // [GIVEN] a customer
        LibrarySales.CreateCustomerWithAddress(SellToCustomer);
        LibrarySales.CreateCustomerWithAddress(ShipToCustomer);
        Commit();
        CustomerNo := SellToCustomer."No.";
        QuoteDate := TODAY();

        // [GIVEN] a JSON text with a quote that contains the customer and an adress as complex type
        QuoteWithComplexJSON := CreateQuoteJSONWithAddress(SellToCustomer, BillToCustomer, ShipToCustomer, QuoteDate);
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Sales Quotes", QuoteServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, QuoteWithComplexJSON, ResponseText);

        // [THEN] the response text should have the correct Id, quote address and the quote should exist in the table with currency code set by default
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', QuoteNumber), 'Could not find sales quote number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        QuoteExists := FindSalesHeader(SalesHeader, CustomerNo, QuoteNumber);
        Assert.IsTrue(QuoteExists, 'The quote should exist');

        LibraryGraphDocumentTools.VerifySalesDocumentSellToAddress(SellToCustomer, SalesHeader, ResponseText, false, false);
        LibraryGraphDocumentTools.VerifySalesDocumentShipToAddress(ShipToCustomer, SalesHeader, ResponseText, false, false);

        Assert.AreEqual('', SalesHeader."Currency Code", 'The quote should have the LCY currency code set by default');
    end;

    [Test]
    procedure TestPostQuoteWithCurrency()
    var
        SalesHeader: Record "Sales Header";
        Currency: Record "Currency";
        Customer: Record "Customer";
        LibrarySales: Codeunit "Library - Sales";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        CustomerNo: Text;
        ResponseText: Text;
        QuoteNumber: Text;
        TargetURL: Text;
        QuoteJSON: Text;
        CurrencyCode: Code[10];
        QuoteExists: Boolean;
    begin
        // [SCENARIO] Create sales quote with specific currency set and use HTTP POST to create it
        Initialize();

        // [GIVEN] a quote with a non-LCY currencyCode set
        LibrarySales.CreateCustomer(Customer);
        CustomerNo := Customer."No.";
        Currency.SetFilter(Code, '<>%1', '');
        Currency.FindFirst();
        CurrencyCode := Currency.Code;
        QuoteJSON := LibraryGraphMgt.AddPropertytoJSON('', 'customerNumber', CustomerNo);
        QuoteJSON := LibraryGraphMgt.AddPropertytoJSON(QuoteJSON, 'currencyCode', CurrencyCode);
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Sales Quotes", QuoteServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, QuoteJSON, ResponseText);

        // [THEN] the response text should contain the correct Id and the quote should be created
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', QuoteNumber),
          'Could not find the sales quote number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        QuoteExists := FindSalesHeader(SalesHeader, CustomerNo, QuoteNumber);
        Assert.IsTrue(QuoteExists, 'The quote should exist');
        Assert.AreEqual(CurrencyCode, SalesHeader."Currency Code", 'The quote should have the correct currency code');
    end;

    [Test]
    procedure TestModifyQuotes()
    begin
        TestMultipleModifyQuotes(false, false);
    end;

    [Test]
    procedure TestEmptyModifyQuotes()
    begin
        TestMultipleModifyQuotes(true, false);
    end;

    [Test]
    procedure TestPartialModifyQuotes()
    begin
        TestMultipleModifyQuotes(false, true);
    end;

    local procedure TestMultipleModifyQuotes(EmptyData: Boolean; PartiallyEmptyData: Boolean)
    var
        SellToCustomer: Record "Customer";
        BillToCustomer: Record "Customer";
        ShipToCustomer: Record "Customer";
        SalesLine: Record "Sales Line";
        Item: Record "Item";
        SalesHeader: Record "Sales Header";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        QuoteIntegrationID: Text;
        QuoteNumber: Text;
        ResponseText: Text;
        TargetURL: Text;
        QuoteJSON: Text;
        QuoteWithComplexJSON: Text;
        SellToAddressComplexTypeJSON: Text;
        BillToAddressComplexTypeJSON: Text;
        ShipToAddressComplexTypeJSON: Text;
    begin
        // [SCENARIO] Create sales quote, use a PATCH method to change it and then verify the changes
        // [GIVEN] a customer with address
        Initialize();
        LibrarySales.CreateCustomerWithAddress(SellToCustomer);
        LibrarySales.CreateCustomerWithAddress(BillToCustomer);
        LibrarySales.CreateCustomerWithAddress(ShipToCustomer);

        // [GIVEN] a salesperson
        LibrarySales.CreateSalesperson(SalespersonPurchaser);

        // [GIVEN] a quote with the previously created customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, SellToCustomer."No.");

        // [GIVEN] an item with unit price and unit cost
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));

        // [GIVEN] an line in the previously created quote
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
        QuoteNumber := SalesHeader."No.";

        // [GIVEN] the quote's unique ID
        FindSalesHeader(SalesHeader, '', QuoteNumber);
        QuoteIntegrationID := SalesHeader.Id;
        Assert.AreNotEqual('', QuoteIntegrationID, 'ID should not be empty');

        IF EmptyData THEN
            QuoteJSON := '{}'
        ELSE BEGIN
            QuoteJSON := LibraryGraphMgt.AddPropertytoJSON(QuoteJSON, 'salesperson', SalespersonPurchaser.Code);
            QuoteJSON := LibraryGraphMgt.AddPropertytoJSON(QuoteJSON, 'customerNumber', SellToCustomer."No.");
            QuoteJSON := LibraryGraphMgt.AddPropertytoJSON(QuoteJSON, 'billToCustomerNumber', BillToCustomer."No.");
        END;

        // [GIVEN] a JSON text with an quote that has the sddresses complex types
        QuoteWithComplexJSON := QuoteJSON;
        LibraryGraphDocumentTools.GetCustomerAddressComplexType(SellToAddressComplexTypeJSON, SellToCustomer, EmptyData, PartiallyEmptyData);
        LibraryGraphDocumentTools.GetCustomerAddressComplexType(BillToAddressComplexTypeJSON, BillToCustomer, EmptyData, PartiallyEmptyData);
        LibraryGraphDocumentTools.GetCustomerAddressComplexType(ShipToAddressComplexTypeJSON, ShipToCustomer, EmptyData, PartiallyEmptyData);
        QuoteWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(QuoteWithComplexJSON, 'sellingPostalAddress', SellToAddressComplexTypeJSON);
        QuoteWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(QuoteWithComplexJSON, 'billingPostalAddress', BillToAddressComplexTypeJSON);
        QuoteWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(QuoteWithComplexJSON, 'shippingPostalAddress', ShipToAddressComplexTypeJSON);

        Commit();

        // [WHEN] we PATCH the JSON to the web service, with the unique quote ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(QuoteIntegrationID, PAGE::"APIV1 - Sales Quotes", QuoteServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, QuoteWithComplexJSON, ResponseText);

        // [THEN] the quote should have the Unit of Measure and address as a value in the table
        FindSalesHeader(SalesHeader, '', QuoteNumber);
        Assert.IsTrue(SalesHeader.FindFirst(), 'The sales quote should exist in the table');
        IF NOT EmptyData THEN
            Assert.AreEqual(SalesHeader."Salesperson Code", SalespersonPurchaser.Code, 'The patch of Sales Person code was unsuccessful');

        LibraryGraphDocumentTools.VerifySalesDocumentSellToAddress(SellToCustomer, SalesHeader, ResponseText, EmptyData, PartiallyEmptyData);
        LibraryGraphDocumentTools.VerifySalesDocumentBillToAddress(BillToCustomer, SalesHeader, ResponseText, EmptyData, PartiallyEmptyData);
        LibraryGraphDocumentTools.VerifySalesDocumentShipToAddress(ShipToCustomer, SalesHeader, ResponseText, EmptyData, PartiallyEmptyData);
    end;

    [Test]
    procedure TestDeleteQuotes()
    var
        SalesHeader: Record "Sales Header";
        QuoteID: array[2] of Text;
        ID: array[2] of Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create sales quotes and use HTTP DELETE to delete them
        // [GIVEN] 2 quotes in the table
        Initialize();
        CreateSalesQuoteWithLines(SalesHeader);
        QuoteID[1] := SalesHeader."No.";
        ID[1] := SalesHeader.Id;
        Assert.AreNotEqual('', ID[1], 'ID should not be empty');

        CreateSalesQuoteWithLines(SalesHeader);
        QuoteID[2] := SalesHeader."No.";
        ID[2] := SalesHeader.Id;
        Assert.AreNotEqual('', ID[2], 'ID should not be empty');
        Commit();

        // [WHEN] we DELETE the quotes from the web service, with the quotes' unique IDs
        TargetURL := LibraryGraphMgt.CreateTargetURL(ID[1], PAGE::"APIV1 - Sales Quotes", QuoteServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);
        TargetURL := LibraryGraphMgt.CreateTargetURL(ID[2], PAGE::"APIV1 - Sales Quotes", QuoteServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] the quotes shouldn't exist in the table
        IF SalesHeader.Get(SalesHeader."Document Type"::Quote, QuoteID[1]) THEN
            Assert.ExpectedError('The quote should not exist');

        IF SalesHeader.Get(SalesHeader."Document Type"::Quote, QuoteID[2]) THEN
            Assert.ExpectedError('The quote should not exist');
    end;

    [Test]
    procedure TestCreateQuoteThroughPageAndAPI()
    var
        PageSalesHeader: Record "Sales Header";
        ApiSalesHeader: Record "Sales Header";
        Customer: Record "Customer";
        TempIgnoredFieldsForComparison: Record 2000000041 temporary;
        TempRecordField: Record Field;
        LibrarySales: Codeunit "Library - Sales";
        ApiRecordRef: RecordRef;
        PageRecordRef: RecordRef;
        SalesQuote: TestPage 41;
        CustomerNo: Text;
        QuoteDate: Date;
        ResponseText: Text;
        TargetURL: Text;
        QuoteWithComplexJSON: Text;
        QuoteExists: Boolean;
    begin
        // [SCENARIO] Create a quote both through the client UI and through the API and compare them. They should be the same and have the same fields autocompleted wherever needed.
        Initialize();
        LibraryGraphDocumentTools.InitializeUIPage();

        // [GIVEN] a customer
        LibrarySales.CreateCustomer(Customer);
        CustomerNo := Customer."No.";
        QuoteDate := TODAY();

        // [GIVEN] a json describing our new quote
        QuoteWithComplexJSON := CreateQuoteJSONWithAddress(Customer, Customer, Customer, QuoteDate);
        Commit();

        // [WHEN] we POST the JSON to the web service and create another quote through the test page
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Sales Quotes", QuoteServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, QuoteWithComplexJSON, ResponseText);

        CreateQuoteThroughTestPage(SalesQuote, Customer, QuoteDate);

        // [THEN] the quote should exist in the table and match the quote created from the page
        QuoteExists := FindSalesHeader(ApiSalesHeader, CustomerNo, '');
        ApiSalesHeader.SetFilter("Document Date", '=%1', QuoteDate);
        Assert.IsTrue(QuoteExists, 'The quote should exist');

        // Ignore these fields when comparing Page and API Quotes
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesHeader.FIELDNO("No."), DATABASE::"Sales Header");
        LibraryUtility.AddTempField(
          TempIgnoredFieldsForComparison, ApiSalesHeader.FIELDNO("Posting Description"), DATABASE::"Sales Header");
        LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesHeader.FIELDNO(Id), DATABASE::"Sales Header");
        // Special ignore case for ES
        TempRecordField.SetRange(TableNo, DATABASE::"Sales Header");
        TempRecordField.SetRange(FieldName, 'Due Date Modified');
        if TempRecordField.FINDFIRST() then
            LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, TempRecordField."No.", DATABASE::"Sales Header");

        // Time zone will impact how the date from the page vs WebService is saved. If removed this will fail in snap between 12:00 - 1 AM
        IF TIME() < 020000T THEN BEGIN
            LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesHeader.FIELDNO("Order Date"), DATABASE::"Sales Header");
            LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesHeader.FIELDNO("Shipment Date"), DATABASE::"Sales Header");
            LibraryUtility.AddTempField(TempIgnoredFieldsForComparison, ApiSalesHeader.FIELDNO("Posting Date"), DATABASE::"Sales Header");
        END;

        PageSalesHeader.Get(PageSalesHeader."Document Type"::Quote, SalesQuote."No.".VALUE());
        ApiRecordRef.GETTABLE(ApiSalesHeader);
        PageRecordRef.GETTABLE(PageSalesHeader);
        Assert.RecordsAreEqualExceptCertainFields(ApiRecordRef, PageRecordRef, TempIgnoredFieldsForComparison,
          'Page and API quote do not match');
    end;

    [Test]
    procedure TestGetQuotesAppliesDiscountPct()
    var
        SalesHeader: Record "Sales Header";
        ResponseText: Text;
        TargetURL: Text;
        DiscountPct: Decimal;
    begin
        // [SCENARIO] When a quote is created, the GET Method should update the quote and assign a total
        // [GIVEN] a quote without totals assigned
        Initialize();
        LibraryGraphDocumentTools.CreateDocumentWithDiscountPctPending(SalesHeader, DiscountPct, SalesHeader."Document Type"::Quote);
        SalesHeader.CalcFields("Recalculate Invoice Disc.");
        Assert.IsTrue(SalesHeader."Recalculate Invoice Disc.", 'Setup error - recalculate Invoice disc. should be set');
        Commit();

        // [WHEN] we GET the quote from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(SalesHeader.Id, PAGE::"APIV1 - Sales Quotes", QuoteServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the quote should exist in the response and Discount Should be Applied
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
        LibraryGraphDocumentTools.VerifySalesTotals(
          SalesHeader, ResponseText, DiscountPct, SalesHeader."Invoice Discount Calculation"::"%");
    end;

    [Test]
    procedure TestGetQuotesRedistributesDiscountAmt()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
        ResponseText: Text;
        TargetURL: Text;
        DiscountPct: Decimal;
        DiscountAmt: Decimal;
    begin
        // [SCENARIO] When a quote is created, the GET Method should update the quote and redistribute the discount amount
        // [GIVEN] a quote with discount amount that should be redistributed
        Initialize();
        LibraryGraphDocumentTools.CreateDocumentWithDiscountPctPending(SalesHeader, DiscountPct, SalesHeader."Document Type"::Quote);
        SalesHeader.CalcFields(Amount);
        DiscountAmt := LibraryRandom.RandDecInRange(1, ROUND(SalesHeader.Amount / 2, 1), 1);
        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(DiscountAmt, SalesHeader);
        GetFirstSalesQuoteLine(SalesHeader, SalesLine);
        SalesLine.Validate(Quantity, SalesLine.Quantity + 1);
        SalesLine.Modify(true);
        SalesHeader.CalcFields("Recalculate Invoice Disc.");
        Commit();

        // [WHEN] we GET the quote from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(SalesHeader.Id, PAGE::"APIV1 - Sales Quotes", QuoteServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the quote should exist in the response and Discount Should be Applied
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
        LibraryGraphDocumentTools.VerifySalesTotals(
          SalesHeader, ResponseText, DiscountAmt, SalesHeader."Invoice Discount Calculation"::Amount);
    end;

    [Test]
    procedure TestGetQuotesWithContactId()
    var
        SalesHeader: Record "Sales Header";
        GraphIntegrationRecord: Record "Graph Integration Record";
        QuoteID: Code[40];
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [FEATURE] [Contact] [ID]
        // [SCENARIO] Create a quote with a contact with graph ID (GET method should return Graph Contact ID)
        // [GIVEN] One Quote with contact ID
        Initialize();

        CreateSalesQuoteWithGraphContactID(SalesHeader, GraphIntegrationRecord);
        QuoteID := SalesHeader.Id;

        // [WHEN] We get Quote from web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(QuoteID, PAGE::"APIV1 - Sales Quotes", QuoteServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The Quote should contain the Contact ID
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
        VerifyContactId(ResponseText, GraphIntegrationRecord."Graph ID");
    end;

    [Test]
    procedure TestPostQuotesWithGraphContactId()
    var
        Contact: Record "Contact";
        Customer: Record "Customer";
        SalesHeader: Record "Sales Header";
        GraphIntegrationRecord: Record "Graph Integration Record";
        QuoteWithComplexJSON: Text;
        TargetURL: Text;
        ResponseText: Text;
        QuoteNumber: Text;
    begin
        // [FEATURE] [Contact] [ID]
        // [SCENARIO] Posting a Quote with Graph Contact ID (POST method should find the customer based on Contact ID)
        // [GIVEN] One Quote with contact ID
        Initialize();
        LibraryGraphDocumentTools.CreateContactWithGraphId(Contact, GraphIntegrationRecord);
        LibraryGraphDocumentTools.CreateCustomerFromContact(Customer, Contact);
        QuoteWithComplexJSON := CreateQuoteJSONWithContactId(GraphIntegrationRecord);

        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Sales Quotes", QuoteServiceNameTxt);
        Commit();

        // [WHEN] We post a quote to web service
        LibraryGraphMgt.PostToWebService(TargetURL, QuoteWithComplexJSON, ResponseText);

        // [THEN] The Quote should have a customer found based on contact ID
        VerifyValidPostRequest(ResponseText, QuoteNumber);
        VerifyContactId(ResponseText, GraphIntegrationRecord."Graph ID");
        VerifyCustomerFields(Customer, ResponseText);
        VerifyContactFieldsUpdatedOnSalesHeader(QuoteNumber, SalesHeader."Document Type"::Quote, Contact);
    end;

    [Test]
    procedure TestModifyingContactIdUpdatesSellToCustomer()
    var
        SalesHeader: Record "Sales Header";
        GraphIntegrationRecord: Record "Graph Integration Record";
        SecondCustomer: Record "Customer";
        SecondContact: Record "Contact";
        SecondGraphIntegrationRecord: Record "Graph Integration Record";
        QuoteID: Code[40];
        CustomerNo: Code[20];
        TargetURL: Text;
        ResponseText: Text;
        QuoteWithComplexJSON: Text;
        QuoteNumber: Text;
    begin
        // [FEATURE] [Contact] [ID]
        // [SCENARIO] Create a quote with a contact with graph ID (Selecting a different contact will change sell-to customer)
        // [GIVEN] One quote with contact ID
        Initialize();

        CreateSalesQuoteWithGraphContactID(SalesHeader, GraphIntegrationRecord);
        QuoteID := SalesHeader.Id;
        CustomerNo := SalesHeader."Sell-to Customer No.";

        LibraryGraphDocumentTools.CreateContactWithGraphId(SecondContact, SecondGraphIntegrationRecord);
        LibraryGraphDocumentTools.CreateCustomerFromContact(SecondCustomer, SecondContact);

        // Creating the second contact will update the header due to the bug
        SalesHeader.Find();
        SalesHeader."Sell-to Customer No." := CustomerNo;
        SalesHeader.Modify();

        TargetURL := LibraryGraphMgt.CreateTargetURL(QuoteID, PAGE::"APIV1 - Sales Quotes", QuoteServiceNameTxt);
        QuoteWithComplexJSON := CreateQuoteJSONWithContactId(SecondGraphIntegrationRecord);

        Commit();

        // [WHEN] We Patch to web service
        LibraryGraphMgt.PatchToWebService(TargetURL, QuoteWithComplexJSON, ResponseText);

        // [THEN] The Quote should have a new customer
        VerifyValidPostRequest(ResponseText, QuoteNumber);
        VerifyContactId(ResponseText, SecondGraphIntegrationRecord."Graph ID");
        VerifyCustomerFields(SecondCustomer, ResponseText);
        VerifyContactFieldsUpdatedOnSalesHeader(QuoteNumber, SalesHeader."Document Type"::Quote, SecondContact);
    end;

    [Test]
    procedure TestModifyQuoteSetManualDiscount()
    var
        Customer: Record "Customer";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record "Item";
        InvoiceDiscountAmount: Decimal;
        TargetURL: Text;
        QuoteJSON: Text;
        ResponseText: Text;
        QuoteID: Text;
    begin
        // [SCENARIO 184721] Create Sales Quote, use a PATCH method to change it and then verify the changes
        Initialize();
        LibrarySales.CreateCustomerWithAddress(Customer);

        // [GIVEN] an item with unit price and unit cost
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));

        // [GIVEN] an order with the previously created customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");

        // [GIVEN] an line in the previously created quote
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
        SalesHeader.SetAutoCalcFields(Amount);
        SalesHeader.Find();
        QuoteID := SalesHeader."No.";
        InvoiceDiscountAmount := Round(SalesHeader.Amount / 2, LibraryERM.GetCurrencyAmountRoundingPrecision(SalesHeader."Currency Code"), '=');
        Commit();

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(SalesHeader.Id, PAGE::"APIV1 - Sales Quotes", QuoteServiceNameTxt);
        QuoteJSON := STRSUBSTNO('{"%1": %2}', DiscountAmountFieldTxt, FORMAT(InvoiceDiscountAmount, 0, 9));
        LibraryGraphMgt.PatchToWebService(TargetURL, QuoteJSON, ResponseText);

        // [THEN] Header value was updated
        SalesHeader.Find();
        SalesHeader.CalcFields("Invoice Discount Amount");
        Assert.AreEqual(InvoiceDiscountAmount, SalesHeader."Invoice Discount Amount", 'Invoice discount Amount was not set');

        // [THEN] Response contains the updated value
        VerifyValidPostRequest(ResponseText, QuoteID);
        LibraryGraphDocumentTools.VerifyValidDiscountAmount(ResponseText, InvoiceDiscountAmount);
    end;

    [Test]
    procedure TestClearingManualDiscounts()
    var
        Customer: Record "Customer";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record "Item";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
        TargetURL: Text;
        QuoteJSON: Text;
        ResponseText: Text;
        QuoteID: Text;
    begin
        // [SCENARIO 184721] Clearing manually set discount
        Initialize();

        // [GIVEN] an item with unit price and unit cost
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
          Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));

        // [Given] a customer
        LibrarySales.CreateCustomerWithAddress(Customer);

        // [GIVEN] an order with the previously created customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");

        // [GIVEN] an line in the previously created quote
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));
        QuoteID := SalesHeader."No.";

        SalesHeader.SetAutoCalcFields(Amount);
        SalesHeader.Find();

        SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(SalesHeader.Amount / 2, SalesHeader);

        Commit();

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(SalesHeader.Id, PAGE::"APIV1 - Sales Quotes", QuoteServiceNameTxt);
        QuoteJSON := STRSUBSTNO('{"%1": %2}', DiscountAmountFieldTxt, FORMAT(0, 0, 9));
        LibraryGraphMgt.PatchToWebService(TargetURL, QuoteJSON, ResponseText);

        // [THEN] Header value was updated
        SalesHeader.Find();
        SalesHeader.CalcFields("Invoice Discount Amount");
        Assert.AreEqual(0, SalesHeader."Invoice Discount Amount", 'Invoice discount Amount was not set');

        // [THEN] Discount should be removed
        VerifyValidPostRequest(ResponseText, QuoteID);
        LibraryGraphDocumentTools.VerifyValidDiscountAmount(ResponseText, 0);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionSendQuote()
    var
        SalesHeader: Record "Sales Header";
        TempSalesQuoteEntityBuffer: Record "Sales Quote Entity Buffer" temporary;
        DocumentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can send a sales quote through the API.
        InitializeForSending();

        // [GIVEN] Draft sales quote exists
        CreateSalesQuoteWithLines(SalesHeader);
        SetCustomerEmail(SalesHeader."Sell-to Customer No.");
        DocumentId := SalesHeader.Id;
        Commit();
        VerifySalesQuote(DocumentId, TempSalesQuoteEntityBuffer.Status::Draft);

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, PAGE::"APIV1 - Sales Quotes", QuoteServiceNameTxt, ActionSendTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Quote is sent
        VerifySalesQuote(DocumentId, TempSalesQuoteEntityBuffer.Status::Sent);

        // [THEN] Mailing job is created
        CheckJobQueueEntry(CODEUNIT::"Document-Mailing");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionMakeInvoiceFromQuote()
    var
        SalesHeader: Record "Sales Header";
        TempSalesQuoteEntityBuffer: Record "Sales Quote Entity Buffer" temporary;
        TempSalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate" temporary;
        QuoteRecordRef: RecordRef;
        InvoiceRecordRef: RecordRef;
        DocumentId: Guid;
        DocumentNo: Code[20];
        ResponseText: Text;
        TargetURL: Text;
        QuoteEmailAddress: Text;
        QuoteEmailSubject: Text;
        InvoiceEmailAddress: Text;
        InvoiceEmailSubject: Text;
    begin
        // [SCENARIO] User can convert a sales quote to a sales invoice through the API.
        Initialize();

        // [GIVEN] Sales quote exists
        CreateSalesQuoteWithLines(SalesHeader);
        CreateEmailParameters(SalesHeader);
        QuoteRecordRef.GetTable(SalesHeader);
        GetEmailParameters(QuoteRecordRef, QuoteEmailAddress, QuoteEmailSubject);
        DocumentId := SalesHeader.Id;
        DocumentNo := SalesHeader."No.";
        Commit();
        Assert.IsTrue(QuoteEmailAddress <> '', StrSubstNo(EmptyParameterErr, 'Address'));
        Assert.IsTrue(QuoteEmailSubject <> '', StrSubstNo(EmptyParameterErr, 'Subject'));
        VerifySalesQuote(DocumentId, TempSalesQuoteEntityBuffer.Status::Draft);

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, PAGE::"APIV1 - Sales Quotes", QuoteServiceNameTxt, ActionMakeInvoiceTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Quote is deleted
        SalesHeader.Reset();
        SalesHeader.SetRange(Id, DocumentId);
        Assert.IsFalse(SalesHeader.FindFirst(), QuoteStillExistsErr);

        // [THEN] Invoice is created
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.SetRange("Quote No.", DocumentNo);
        Assert.IsTrue(SalesHeader.FindFirst(), CannotFindDraftInvoiceErr);
        Assert.AreNotEqual(DocumentId, SalesHeader.Id, InvoiceIdErr);
        VerifyDraftSalesInvoice(SalesHeader.Id, TempSalesInvoiceEntityAggregate.Status::Draft);

        // [THEN] Email parameters are deleted
        InvoiceRecordRef.GetTable(SalesHeader);
        GetEmailParameters(InvoiceRecordRef, InvoiceEmailAddress, InvoiceEmailSubject);
        Assert.AreEqual('', InvoiceEmailAddress, StrSubstNo(NotEmptyParameterErr, 'Address'));
        Assert.AreEqual('', InvoiceEmailSubject, StrSubstNo(NotEmptyParameterErr, 'Subject'));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionMakeOrderFromQuote()
    var
        SalesHeader: Record "Sales Header";
        TempSalesQuoteEntityBuffer: Record "Sales Quote Entity Buffer" temporary;
        TempSalesOrderEntityBuffer: Record "Sales Order Entity Buffer" temporary;
        QuoteRecordRef: RecordRef;
        OrderRecordRef: RecordRef;
        DocumentId: Guid;
        DocumentNo: Code[20];
        ResponseText: Text;
        TargetURL: Text;
        QuoteEmailAddress: Text;
        QuoteEmailSubject: Text;
        OrderEmailAddress: Text;
        OrderEmailSubject: Text;
    begin
        // [SCENARIO] User can convert a sales quote to a sales order through the API.
        Initialize();

        // [GIVEN] Sales quote exists
        CreateSalesQuoteWithLines(SalesHeader);
        CreateEmailParameters(SalesHeader);
        QuoteRecordRef.GetTable(SalesHeader);
        GetEmailParameters(QuoteRecordRef, QuoteEmailAddress, QuoteEmailSubject);
        DocumentId := SalesHeader.Id;
        DocumentNo := SalesHeader."No.";
        Commit();
        Assert.IsTrue(QuoteEmailAddress <> '', StrSubstNo(EmptyParameterErr, 'Address'));
        Assert.IsTrue(QuoteEmailSubject <> '', StrSubstNo(EmptyParameterErr, 'Subject'));
        VerifySalesQuote(DocumentId, TempSalesQuoteEntityBuffer.Status::Draft);

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, PAGE::"APIV1 - Sales Quotes", QuoteServiceNameTxt, ActionMakeOrderTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] Quote is deleted
        SalesHeader.Reset();
        SalesHeader.SetRange(Id, DocumentId);
        Assert.IsFalse(SalesHeader.FindFirst(), QuoteStillExistsErr);

        // [THEN] Order is created
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("Quote No.", DocumentNo);
        Assert.IsTrue(SalesHeader.FindFirst(), CannotFindOrderErr);
        Assert.AreNotEqual(DocumentId, SalesHeader.Id, InvoiceIdErr);
        VerifySalesOrder(SalesHeader.Id, TempSalesOrderEntityBuffer.Status::Draft);

        // [THEN] Email parameters are deleted
        OrderRecordRef.GetTable(SalesHeader);
        GetEmailParameters(OrderRecordRef, OrderEmailAddress, OrderEmailSubject);
        Assert.AreEqual('', OrderEmailAddress, StrSubstNo(NotEmptyParameterErr, 'Address'));
        Assert.AreEqual('', OrderEmailSubject, StrSubstNo(NotEmptyParameterErr, 'Subject'));
    end;

    local procedure CreateQuoteJSONWithAddress(SellToCustomer: Record "Customer"; BillToCustomer: Record "Customer"; ShipToCustomer: Record "Customer"; DocumentDate: Date): Text
    var
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        QuoteJSON: Text;
        SellToAddressComplexTypeJSON: Text;
        BillToAddressComplexTypeJSON: Text;
        ShipToAddressComplexTypeJSON: Text;
        QuoteWithComplexJSON: Text;
    begin
        QuoteJSON := LibraryGraphMgt.AddPropertytoJSON('', 'customerNumber', SellToCustomer."No.");
        QuoteJSON := LibraryGraphMgt.AddPropertytoJSON(QuoteJSON, 'documentDate', DocumentDate);

        QuoteWithComplexJSON := QuoteJSON;
        LibraryGraphDocumentTools.GetCustomerAddressComplexType(SellToAddressComplexTypeJSON, SellToCustomer, false, false);
        LibraryGraphDocumentTools.GetCustomerAddressComplexType(BillToAddressComplexTypeJSON, BillToCustomer, false, false);
        LibraryGraphDocumentTools.GetCustomerAddressComplexType(ShipToAddressComplexTypeJSON, ShipToCustomer, false, false);
        QuoteWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(QuoteWithComplexJSON, 'sellingPostalAddress', SellToAddressComplexTypeJSON);
        QuoteWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(QuoteWithComplexJSON, 'billingPostalAddress', BillToAddressComplexTypeJSON);
        QuoteWithComplexJSON := LibraryGraphMgt.AddComplexTypetoJSON(QuoteWithComplexJSON, 'shippingPostalAddress', ShipToAddressComplexTypeJSON);
        EXIT(QuoteWithComplexJSON);
    end;

    local procedure CreateQuoteThroughTestPage(var SalesQuote: TestPage 41; Customer: Record "Customer"; DocumentDate: Date)
    begin
        SalesQuote.OpenNew();
        SalesQuote."Sell-to Customer No.".SETVALUE(Customer."No.");
        SalesQuote."Document Date".SETVALUE(DocumentDate);
    end;

    local procedure GetFirstSalesQuoteLine(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.FindFirst();
    end;

    local procedure CreateSalesQuoteWithGraphContactID(var SalesHeader: Record "Sales Header"; var GraphIntegrationRecord: Record "Graph Integration Record")
    var
        Contact: Record "Contact";
        Customer: Record "Customer";
    begin
        LibraryGraphDocumentTools.CreateContactWithGraphId(Contact, GraphIntegrationRecord);
        LibraryGraphDocumentTools.CreateCustomerFromContact(Customer, Contact);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, Customer."No.");
    end;

    local procedure CreateQuoteJSONWithContactId(GraphIntegrationRecord: Record "Graph Integration Record"): Text
    var
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        QuoteJSON: Text;
    begin
        QuoteJSON := LibraryGraphMgt.AddPropertytoJSON('', GraphContactIdFieldTxt, GraphIntegrationRecord."Graph ID");

        EXIT(QuoteJSON);
    end;

    local procedure VerifyValidPostRequest(ResponseText: Text; var QuoteNumber: Text)
    begin
        Assert.AreNotEqual('', ResponseText, 'response JSON should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', QuoteNumber),
          'Could not find sales quote number');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
    end;

    local procedure VerifyCustomerFields(ExpectedCustomer: Record "Customer"; ResponseText: Text)
    var
        IntegrationManagement: Codeunit "Integration Management";
        customerIdValue: Text;
        customerNameValue: Text;
        customerNumberValue: Text;
    begin
        LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, CustomerIdFieldTxt, customerIdValue);
        LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, CustomerNameFieldTxt, customerNameValue);
        LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, CustomerNumberFieldTxt, customerNumberValue);

        Assert.AreEqual(
          IntegrationManagement.GetIdWithoutBrackets(ExpectedCustomer.Id), UPPERCASE(customerIdValue), 'Wrong setting for Customer Id');
        Assert.AreEqual(ExpectedCustomer."No.", customerNumberValue, 'Wrong setting for Customer Number');
        Assert.AreEqual(ExpectedCustomer.Name, customerNameValue, 'Wrong setting for Customer Name');
    end;

    local procedure VerifyContactFieldsUpdatedOnSalesHeader(DocumentNumber: Text; DocumentType: Option; ExpectedContact: Record "Contact")
    var
        SalesHeader: Record "Sales Header";
    begin
        Assert.IsTrue(SalesHeader.Get(DocumentType, DocumentNumber), 'Could not find the sales header for ' + DocumentNumber);
        Assert.AreEqual(ExpectedContact."No.", SalesHeader."Sell-to Contact No.", 'Wrong sell to contact no');
    end;

    local procedure VerifyContactId(ResponseText: Text; ExpectedContactId: Text)
    var
        contactId: Text;
    begin
        LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, GraphContactIdFieldTxt, contactId);
        Assert.AreEqual(ExpectedContactId, contactId, 'Wrong contact id was returned');
    end;

    local procedure VerifySalesQuote(DocumentId: Guid; Status: Integer)
    var
        SalesHeader: Record "Sales Header";
        SalesQuoteEntityBuffer: Record "Sales Quote Entity Buffer";
    begin
        SalesHeader.SetRange(Id, DocumentId);
        Assert.IsFalse(SalesHeader.IsEmpty(), CannotFindQuoteErr);

        SalesQuoteEntityBuffer.SetRange(Id, DocumentId);
        Assert.IsTrue(SalesQuoteEntityBuffer.FindFirst(), CannotFindQuoteErr);
        Assert.AreEqual(Status, SalesQuoteEntityBuffer.Status, QuoteStatusErr);
    end;

    local procedure VerifyDraftSalesInvoice(DocumentId: Guid; Status: Integer)
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
    begin
        SalesHeader.SetRange(Id, DocumentId);
        Assert.IsFalse(SalesHeader.IsEmpty(), CannotFindDraftInvoiceErr);

        SalesInvoiceEntityAggregate.SetRange(Id, DocumentId);
        Assert.IsTrue(SalesInvoiceEntityAggregate.FindFirst(), CannotFindDraftInvoiceErr);
        Assert.AreEqual(Status, SalesInvoiceEntityAggregate.Status, InvoiceStatusErr);
    end;

    local procedure VerifySalesOrder(DocumentId: Guid; Status: Integer)
    var
        SalesHeader: Record "Sales Header";
        SalesOrderEntityBuffer: Record "Sales Order Entity Buffer";
    begin
        SalesHeader.SetRange(Id, DocumentId);
        Assert.IsFalse(SalesHeader.IsEmpty(), CannotFindOrderErr);

        SalesOrderEntityBuffer.SetRange(Id, DocumentId);
        Assert.IsTrue(SalesOrderEntityBuffer.FindFirst(), CannotFindOrderErr);
        Assert.AreEqual(Status, SalesOrderEntityBuffer.Status, OrderStatusErr);
    end;

    local procedure CreateSalesQuoteWithLines(var SalesHeader: Record "Sales Header")
    var
        Customer: Record "Customer";
        Item: Record "Item";
    begin
        LibrarySmallBusiness.CreateCustomer(Customer);
        LibrarySmallBusiness.CreateItem(Item);
        LibrarySmallBusiness.CreateSalesQuoteHeaderWithLines(SalesHeader, Customer, Item, 1, 1);
    end;

    local procedure FindSalesHeader(var SalesHeader: Record "Sales Header"; CustomerNo: Text; QuoteNumber: Text): Boolean
    begin
        SalesHeader.Reset();
        IF QuoteNumber <> '' THEN
            SalesHeader.SetRange("No.", QuoteNumber);
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        IF CustomerNo <> '' THEN
            SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        EXIT(SalesHeader.FindFirst());
    end;

    local procedure CreateSMTPMailSetup()
    var
        SMTPMailSetup: Record "SMTP Mail Setup";
        IsNew: Boolean;
    begin
        IsNew := not SMTPMailSetup.FindFirst();

        if IsNew then
            SMTPMailSetup.Init();
        SMTPMailSetup."SMTP Server" := 'SomeServer';
        SMTPMailSetup."SMTP Server Port" := 1000;
        SMTPMailSetup."Secure Connection" := true;
        SMTPMailSetup.Authentication := SMTPMailSetup.Authentication::Basic;
        SMTPMailSetup."User ID" := 'somebody@somewhere.com';
        SMTPMailSetup.SetPassword('Some Password');
        if IsNew then
            SMTPMailSetup.Insert(true)
        else
            SMTPMailSetup.Modify(true);
    end;

    local procedure CreateEmailParameters(var SalesHeader: Record "Sales Header")
    var
        EmailParameter: Record "Email Parameter";
    begin
        EmailParameter.SaveParameterValue(
          SalesHeader."No.", SalesHeader."Document Type",
          EmailParameter."Parameter Type"::Address,
          StrSubstNo('%1@home.local', CopyStr(CreateGuid(), 2, 8)));
        EmailParameter.SaveParameterValue(
          SalesHeader."No.", SalesHeader."Document Type",
          EmailParameter."Parameter Type"::Subject, Format(CreateGuid()));
    end;

    local procedure GetEmailParameters(var RecordRef: RecordRef; var Email: Text; var Subject: Text)
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        EmailParameter: Record "Email Parameter";
    begin
        Email := '';
        Subject := '';
        case RecordRef.Number() of
            DATABASE::"Sales Header":
                begin
                    RecordRef.SetTable(SalesHeader);
                    if EmailParameter.GetEntryWithReportUsage(
                         SalesHeader."No.", SalesHeader."Document Type", EmailParameter."Parameter Type"::Address)
                    then
                        Email := EmailParameter.GetParameterValue();
                    if EmailParameter.GetEntryWithReportUsage(
                         SalesHeader."No.", SalesHeader."Document Type", EmailParameter."Parameter Type"::Subject)
                    then
                        Subject := EmailParameter.GetParameterValue();
                end;
            DATABASE::"Sales Invoice Header":
                begin
                    RecordRef.SetTable(SalesInvoiceHeader);
                    if EmailParameter.GetEntryWithReportUsage(
                         SalesInvoiceHeader."No.", SalesHeader."Document Type"::Invoice, EmailParameter."Parameter Type"::Address)
                    then
                        Email := EmailParameter.GetParameterValue();
                    if EmailParameter.GetEntryWithReportUsage(
                         SalesInvoiceHeader."No.", SalesHeader."Document Type"::Invoice, EmailParameter."Parameter Type"::Subject)
                    then
                        Subject := EmailParameter.GetParameterValue();
                end;
        end;
    end;

    local procedure SetCustomerEmail(CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        Customer."E-Mail" := 'somebody@somewhere.com';
        Customer.Modify(true);
    end;

    local procedure GetJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry"; CodeunitID: Integer): Boolean
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CodeunitID);
        exit(JobQueueEntry.FindFirst());
    end;

    local procedure CheckJobQueueEntry(CodeunitID: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if not GetJobQueueEntry(JobQueueEntry, CodeunitID) then
            Error(MailingJobErr);
        JobQueueEntry.Cancel();
    end;

    local procedure DeleteJobQueueEntry(CodeunitID: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        while JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, CodeunitID) do
            JobQueueEntry.Cancel();
    end;


}