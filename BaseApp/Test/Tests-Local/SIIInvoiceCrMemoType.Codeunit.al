codeunit 147551 "SII Invoice/Cr. Memo Type"
{
    // // [FEATURE] [SII]

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        LibrarySII: Codeunit "Library - SII";
        IsInitialized: Boolean;
        IncorrectXMLDocErr: Label 'The XML document was not generated properly.';
        XPathSalesFacturaExpedidaTok: Label '//soapenv:Body/siiRL:SuministroLRFacturasEmitidas/siiRL:RegistroLRFacturasEmitidas/siiRL:FacturaExpedida/';
        XPathPurchFacturaRecibidaTok: Label '//soapenv:Body/siiRL:SuministroLRFacturasRecibidas/siiRL:RegistroLRFacturasRecibidas/siiRL:FacturaRecibida/';
        UploadType: Option Regular,Intracommunity,RetryAccepted;

    [Test]
    [Scope('OnPrem')]
    procedure SalesInvoiceWithInvTypeF2HasNoContraparteBlock()
    var
        SalesHeader: Record "Sales Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SIIXMLCreator: Codeunit "SII XML Creator";
        XMLDoc: DotNet XmlDocument;
    begin
        // [FEATURE] [Sales] [Invoice]
        // [SCENARIO 223508] XML has no node "Contraparte" when post Sales Invoice with "Invoice Type" = "F2 Simplified Invoice"
        // [SCENARIO 234067] XML has node "ImporteTotal" when post Sales Invoice with "Invoice Type" = "F2 Simplified Invoice"
        // [SCENARIO 252872] XML has node "ImporteTotal" with positive value

        Initialize;

        // [GIVEN] Posted Sales Invoice with "Invoice Type" = "F2 Simplified Invoice"
        // [GIVEN] Customer Ledger Entry Created with Amount = 120
        PostSalesDocWithInvOrCrMemoType(
          CustLedgerEntry, SalesHeader."Document Type"::Invoice, 0, SalesHeader."Invoice Type"::"F2 Simplified Invoice", 0);

        // [WHEN] Create xml for Posted Sales Invoice
        Assert.IsTrue(SIIXMLCreator.GenerateXml(CustLedgerEntry, XMLDoc, UploadType::Regular, false), IncorrectXMLDocErr);

        // [THEN] XML file has no node "Contraparte"
        LibrarySII.ValidateNoElementsByName(XMLDoc, 'sii:Contraparte');

        // [THEN] XML file has node "ImporteTotal" with value 120
        CustLedgerEntry.CalcFields("Amount (LCY)");
        LibrarySII.ValidateElementByName(XMLDoc, 'sii:ImporteTotal', SIIXMLCreator.FormatNumber(CustLedgerEntry."Amount (LCY)"));

        // [THEN] TipoFactura is "F2" in exported SII File
        LibrarySII.VerifyOneNodeWithValueByXPath(XMLDoc, XPathSalesFacturaExpedidaTok, 'sii:TipoFactura', 'F2');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SalesInvoiceWithInvTypeF3HasContraparteBlock()
    var
        SalesHeader: Record "Sales Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SIIXMLCreator: Codeunit "SII XML Creator";
        XMLDoc: DotNet XmlDocument;
    begin
        // [FEATURE] [Sales] [Invoice]
        // [SCENARIO 223508] XML has node "Contraparte" when post Sales Invoice with "Invoice Type" = "F3 Invoice issued to replace simplified invoices"
        // [SCENARIO 234067] XML has no node "ImporteTotal" when post Sales Invoice with "Invoice Type" = "F3 Invoice issued to replace simplified invoices"
        Initialize;

        // [GIVEN] Posted Sales Invoice with "Invoice Type" = "F3 Invoice issued to replace simplified invoices"
        PostSalesDocWithInvOrCrMemoType(
          CustLedgerEntry, SalesHeader."Document Type"::Invoice, 0,
          SalesHeader."Invoice Type"::"F3 Invoice issued to replace simplified invoices", 0);

        // [WHEN] Create xml for Posted Sales Invoice
        Assert.IsTrue(SIIXMLCreator.GenerateXml(CustLedgerEntry, XMLDoc, UploadType::Regular, false), IncorrectXMLDocErr);

        // [THEN] XML file has node "Contraparte"
        LibrarySII.ValidateElementWithNameExists(XMLDoc, 'sii:Contraparte');

        // [THEN] XML file has no node "ImporteTotal"
        LibrarySII.ValidateNoElementsByName(XMLDoc, 'sii:ImporteTotal');

        // [THEN] TipoFactura is "F3" in exported SII File
        LibrarySII.VerifyOneNodeWithValueByXPath(XMLDoc, XPathSalesFacturaExpedidaTok, 'sii:TipoFactura', 'F3');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SalesInvoiceWithInvTypeF4HasContraparteBlock()
    var
        SalesHeader: Record "Sales Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SIIXMLCreator: Codeunit "SII XML Creator";
        XMLDoc: DotNet XmlDocument;
    begin
        // [FEATURE] [Sales] [Invoice]
        // [SCENARIO 223508] XML has node "Contraparte" when post Sales Invoice with "Invoice Type" = "F4 Invoice summary entry"
        // [SCENARIO 234067] XML has node "ImporteTotal" when post Sales Invoice with "Invoice Type" = "F4 Invoice summary entry"
        Initialize;

        // [GIVEN] Posted Sales Invoice with "Invoice Type" = "F4 Invoice summary entry"
        PostSalesDocWithInvOrCrMemoType(
          CustLedgerEntry, SalesHeader."Document Type"::Invoice, 0, SalesHeader."Invoice Type"::"F4 Invoice summary entry", 0);

        // [WHEN] Create xml for Posted Sales Invoice
        Assert.IsTrue(SIIXMLCreator.GenerateXml(CustLedgerEntry, XMLDoc, UploadType::Regular, false), IncorrectXMLDocErr);

        // [THEN] XML file has node "Contraparte"
        LibrarySII.ValidateElementWithNameExists(XMLDoc, 'sii:Contraparte');

        // [THEN] XML file has node "ImporteTotal"
        LibrarySII.ValidateElementWithNameExists(XMLDoc, 'sii:ImporteTotal');

        // [THEN] TipoFactura is "F4" in exported SII File
        LibrarySII.VerifyOneNodeWithValueByXPath(XMLDoc, XPathSalesFacturaExpedidaTok, 'sii:TipoFactura', 'F4');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SalesDiffCrMemoWithCrMemoTypeR2HasContraparteBlock()
    var
        SalesHeader: Record "Sales Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SIIXMLCreator: Codeunit "SII XML Creator";
        XMLDoc: DotNet XmlDocument;
    begin
        // [FEATURE] [Sales] [Credit Memo]
        // [SCENARIO 223508] XML has node "Contraparte" when post Sales Credit Memo with Type "Difference" and "Cr. Memo Type" = "R2 Corrected Invoice (Art. 80.3)"
        // [SCENARIO 252872] XML has node "ImporteTotal" with negative value

        Initialize;

        // [GIVEN] Posted Sales Credit Memo type "Difference" and "Cr. Memo Type" = "R2 Corrected Invoice (Art. 80.3)"
        // [GIVEN] Customer Ledger Entry Created with Amount = -120

        PostSalesDocWithInvOrCrMemoType(
          CustLedgerEntry, SalesHeader."Document Type"::"Credit Memo", SalesHeader."Correction Type"::Difference,
          0, SalesHeader."Cr. Memo Type"::"R2 Corrected Invoice (Art. 80.3)");

        // [WHEN] Create xml for Posted Sales Credit Memo
        Assert.IsTrue(SIIXMLCreator.GenerateXml(CustLedgerEntry, XMLDoc, UploadType::Regular, false), IncorrectXMLDocErr);

        // [THEN] XML file has node "ImporteTotal" with value -120
        CustLedgerEntry.CalcFields("Amount (LCY)");
        LibrarySII.ValidateElementByName(XMLDoc, 'sii:ImporteTotal', SIIXMLCreator.FormatNumber(CustLedgerEntry."Amount (LCY)"));

        // [THEN] TipoFactura is "R2" in exported SII File
        LibrarySII.VerifyOneNodeWithValueByXPath(XMLDoc, XPathSalesFacturaExpedidaTok, 'sii:TipoFactura', 'R2');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SalesDiffCrMemoWithCrMemoTypeR3HasContraparteBlock()
    var
        SalesHeader: Record "Sales Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SIIXMLCreator: Codeunit "SII XML Creator";
        XMLDoc: DotNet XmlDocument;
    begin
        // [FEATURE] [Sales] [Credit Memo]
        // [SCENARIO 223508] XML has node "Contraparte" when post Sales Credit Memo with Type "Difference" and "Cr. Memo Type" = "R3 Corrected Invoice (Art. 80.4)"

        Initialize;

        // [GIVEN] Posted Sales Credit Memo type "Difference" and "Cr. Memo Type" = "R3 Corrected Invoice (Art. 80.4)"
        PostSalesDocWithInvOrCrMemoType(
          CustLedgerEntry, SalesHeader."Document Type"::"Credit Memo", SalesHeader."Correction Type"::Difference,
          0, SalesHeader."Cr. Memo Type"::"R3 Corrected Invoice (Art. 80.4)");

        // [WHEN] Create xml for Posted Sales Credit Memo
        Assert.IsTrue(SIIXMLCreator.GenerateXml(CustLedgerEntry, XMLDoc, UploadType::Regular, false), IncorrectXMLDocErr);

        // [THEN] XML file has node "Contraparte"
        LibrarySII.ValidateElementWithNameExists(XMLDoc, 'sii:Contraparte');

        // [THEN] TipoFactura is "R3" in exported SII File
        LibrarySII.VerifyOneNodeWithValueByXPath(XMLDoc, XPathSalesFacturaExpedidaTok, 'sii:TipoFactura', 'R3');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SalesDiffCrMemoWithCrMemoTypeR4HasContraparteBlock()
    var
        SalesHeader: Record "Sales Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SIIXMLCreator: Codeunit "SII XML Creator";
        XMLDoc: DotNet XmlDocument;
    begin
        // [FEATURE] [Sales] [Credit Memo]
        // [SCENARIO 223508] XML has node "Contraparte" when post Sales Credit Memo with Type "Difference" and "Cr. Memo Type" = "R4 Corrected Invoice (Other)"

        Initialize;

        // [GIVEN] Posted Sales Credit Memo type "Difference" and "Cr. Memo Type" = "R4 Corrected Invoice (Other)"
        PostSalesDocWithInvOrCrMemoType(
          CustLedgerEntry, SalesHeader."Document Type"::"Credit Memo", SalesHeader."Correction Type"::Difference,
          0, SalesHeader."Cr. Memo Type"::"R4 Corrected Invoice (Other)");

        // [WHEN] Create xml for Posted Sales Credit Memo
        Assert.IsTrue(SIIXMLCreator.GenerateXml(CustLedgerEntry, XMLDoc, UploadType::Regular, false), IncorrectXMLDocErr);

        // [THEN] XML file has node "Contraparte"
        LibrarySII.ValidateElementWithNameExists(XMLDoc, 'sii:Contraparte');

        // [THEN] TipoFactura is "R4" in exported SII File
        LibrarySII.VerifyOneNodeWithValueByXPath(XMLDoc, XPathSalesFacturaExpedidaTok, 'sii:TipoFactura', 'R4');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SalesReplacementWithCrMemoTypeR2HasContraparteBlock()
    var
        SalesHeader: Record "Sales Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SIIXMLCreator: Codeunit "SII XML Creator";
        XMLDoc: DotNet XmlDocument;
    begin
        // [FEATURE] [Sales] [Credit Memo]
        // [SCENARIO 223508] XML has node "Contraparte" when post Sales Credit Memo with Type "Replacement" and "Cr. Memo Type" = "R2 Corrected Invoice (Art. 80.3)"
        // [SCENARIO 252872] XML has node "ImporteTotal" with negative value

        Initialize;

        // [GIVEN] Posted Sales Credit Memo type "Replacement" and "Cr. Memo Type" = "R2 Corrected Invoice (Art. 80.3)"
        // [GIVEN] Customer Ledger Entry Created with Amount = -120
        PostSalesDocWithInvOrCrMemoType(
          CustLedgerEntry, SalesHeader."Document Type"::"Credit Memo", SalesHeader."Correction Type"::Replacement,
          0, SalesHeader."Cr. Memo Type"::"R2 Corrected Invoice (Art. 80.3)");

        // [WHEN] Create xml for Posted Sales Credit Memo
        Assert.IsTrue(SIIXMLCreator.GenerateXml(CustLedgerEntry, XMLDoc, UploadType::Regular, false), IncorrectXMLDocErr);

        // [THEN] XML file has node "Contraparte"
        LibrarySII.ValidateElementWithNameExists(XMLDoc, 'sii:Contraparte');

        // [THEN] XML file has node "ImporteTotal" with value -120
        CustLedgerEntry.CalcFields("Amount (LCY)");
        LibrarySII.ValidateElementByName(XMLDoc, 'sii:ImporteTotal', SIIXMLCreator.FormatNumber(CustLedgerEntry."Amount (LCY)"));

        // [THEN] TipoFactura is "R2" in exported SII File
        LibrarySII.VerifyOneNodeWithValueByXPath(XMLDoc, XPathSalesFacturaExpedidaTok, 'sii:TipoFactura', 'R2');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SalesReplacementWithCrMemoTypeR3HasContraparteBlock()
    var
        SalesHeader: Record "Sales Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SIIXMLCreator: Codeunit "SII XML Creator";
        XMLDoc: DotNet XmlDocument;
    begin
        // [FEATURE] [Sales] [Credit Memo]
        // [SCENARIO 223508] XML has node "Contraparte" when post Sales Credit Memo with Type "Replacement" and "Cr. Memo Type" = "R3 Corrected Invoice (Art. 80.4)"

        Initialize;

        // [GIVEN] Posted Sales Credit Memo type "Replacement" and "Cr. Memo Type" = "R3 Corrected Invoice (Art. 80.4)"
        PostSalesDocWithInvOrCrMemoType(
          CustLedgerEntry, SalesHeader."Document Type"::"Credit Memo", SalesHeader."Correction Type"::Replacement,
          0, SalesHeader."Cr. Memo Type"::"R3 Corrected Invoice (Art. 80.4)");

        // [WHEN] Create xml for Posted Sales Credit Memo
        Assert.IsTrue(SIIXMLCreator.GenerateXml(CustLedgerEntry, XMLDoc, UploadType::Regular, false), IncorrectXMLDocErr);

        // [THEN] XML file has node "Contraparte"
        LibrarySII.ValidateElementWithNameExists(XMLDoc, 'sii:Contraparte');

        // [THEN] TipoFactura is "R3" in exported SII File
        LibrarySII.VerifyOneNodeWithValueByXPath(XMLDoc, XPathSalesFacturaExpedidaTok, 'sii:TipoFactura', 'R3');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SalesReplacementWithCrMemoTypeR4HasContraparteBlock()
    var
        SalesHeader: Record "Sales Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SIIXMLCreator: Codeunit "SII XML Creator";
        XMLDoc: DotNet XmlDocument;
    begin
        // [FEATURE] [Sales] [Credit Memo]
        // [SCENARIO 223508] XML has node "Contraparte" when post Sales Credit Memo with Type "Replacement" and "Cr. Memo Type" = "R4 Corrected Invoice (Other)"

        Initialize;

        // [GIVEN] Posted Sales Credit Memo type "Replacement" and "Cr. Memo Type" = "R4 Corrected Invoice (Other)"
        PostSalesDocWithInvOrCrMemoType(
          CustLedgerEntry, SalesHeader."Document Type"::"Credit Memo", SalesHeader."Correction Type"::Replacement,
          0, SalesHeader."Cr. Memo Type"::"R4 Corrected Invoice (Other)");

        // [WHEN] Create xml for Posted Sales Credit Memo
        Assert.IsTrue(SIIXMLCreator.GenerateXml(CustLedgerEntry, XMLDoc, UploadType::Regular, false), IncorrectXMLDocErr);

        // [THEN] XML file has node "Contraparte"
        LibrarySII.ValidateElementWithNameExists(XMLDoc, 'sii:Contraparte');

        // [THEN] TipoFactura is "R4" in exported SII File
        LibrarySII.VerifyOneNodeWithValueByXPath(XMLDoc, XPathSalesFacturaExpedidaTok, 'sii:TipoFactura', 'R4');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PurchInvoiceWithInvTypeF2HasContraparteBlock()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        SIIXMLCreator: Codeunit "SII XML Creator";
        XMLDoc: DotNet XmlDocument;
    begin
        // [FEATURE] [Purchase] [Invoice]
        // [SCENARIO 223508] XML has node "Contraparte" when post Purchase Invoice with "Invoice Type" = "F2 Simplified Invoice"
        // [SCENARIO 234067] XML has node "ImporteTotal" when post Purchase Invoice with "Invoice Type" = "F2 Simplified Invoice"
        // [SCENARIO 252872] XML has node "ImporteTotal" with positive value

        Initialize;

        // [GIVEN] Posted Purchase Invoice with "Invoice Type" = "F2 Simplified Invoice"
        // [GIVEN] Vendor Ledger Entry Created with Amount = 120
        PostPurchDocWithInvOrCrMemoType(
          VendorLedgerEntry, PurchaseHeader."Document Type"::Invoice, 0, PurchaseHeader."Invoice Type"::"F2 Simplified Invoice", 0);

        // [WHEN] Create xml for Posted Purchase Invoice
        Assert.IsTrue(SIIXMLCreator.GenerateXml(VendorLedgerEntry, XMLDoc, UploadType::Regular, false), IncorrectXMLDocErr);

        // [THEN] XML file has node "Contraparte"
        LibrarySII.ValidateElementWithNameExists(XMLDoc, 'sii:Contraparte');

        // [THEN] XML file has node "ImporteTotal" with value 120
        VendorLedgerEntry.CalcFields("Amount (LCY)");
        LibrarySII.ValidateElementByName(XMLDoc, 'sii:ImporteTotal', SIIXMLCreator.FormatNumber(-VendorLedgerEntry."Amount (LCY)"));

        // [THEN] TipoFactura is "F2" in exported SII File
        LibrarySII.VerifyOneNodeWithValueByXPath(XMLDoc, XPathPurchFacturaRecibidaTok, 'sii:TipoFactura', 'F2');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PurchInvoiceWithInvTypeF3HasContraparteBlock()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        SIIXMLCreator: Codeunit "SII XML Creator";
        XMLDoc: DotNet XmlDocument;
    begin
        // [FEATURE] [Purchase] [Invoice]
        // [SCENARIO 223508] XML has node "Contraparte" when post Purchase Invoice with "Invoice Type" = "F3 Invoice issued to replace simplified invoices"
        // [SCENARIO 234067] XML has no node "ImporteTotal" when post Purchase Invoice with "Invoice Type" = "F3 Invoice issued to replace simplified invoices"
        Initialize;

        // [GIVEN] Posted Purchase Invoice with "Invoice Type" = "F3 Invoice issued to replace simplified invoices"
        PostPurchDocWithInvOrCrMemoType(
          VendorLedgerEntry, PurchaseHeader."Document Type"::Invoice, 0,
          PurchaseHeader."Invoice Type"::"F3 Invoice issued to replace simplified invoices", 0);

        // [WHEN] Create xml for Posted Purchase Invoice
        Assert.IsTrue(SIIXMLCreator.GenerateXml(VendorLedgerEntry, XMLDoc, UploadType::Regular, false), IncorrectXMLDocErr);

        // [THEN] XML file has node "Contraparte"
        LibrarySII.ValidateElementWithNameExists(XMLDoc, 'sii:Contraparte');

        // [THEN] XML file has no node "ImporteTotal"
        LibrarySII.ValidateNoElementsByName(XMLDoc, 'sii:ImporteTotal');

        // [THEN] TipoFactura is "F3" in exported SII File
        LibrarySII.VerifyOneNodeWithValueByXPath(XMLDoc, XPathPurchFacturaRecibidaTok, 'sii:TipoFactura', 'F3');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PurchInvoiceWithInvTypeF4HasContraparteBlock()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        SIIXMLCreator: Codeunit "SII XML Creator";
        XMLDoc: DotNet XmlDocument;
    begin
        // [FEATURE] [Purchase] [Invoice]
        // [SCENARIO 223508] XML has node "Contraparte" when post Purchase Invoice with "Invoice Type" = "F4 Invoice summary entry"
        // [SCENARIO 234067] XML has node "ImporteTotal" when post Purchase Invoice with "Invoice Type" = "F4 Invoice summary entry"
        Initialize;

        // [GIVEN] Posted Purchase Invoice with "Invoice Type" = "F4 Invoice summary entry"
        PostPurchDocWithInvOrCrMemoType(
          VendorLedgerEntry, PurchaseHeader."Document Type"::Invoice, 0, PurchaseHeader."Invoice Type"::"F4 Invoice summary entry", 0);

        // [WHEN] Create xml for Posted Purchase Invoice
        Assert.IsTrue(SIIXMLCreator.GenerateXml(VendorLedgerEntry, XMLDoc, UploadType::Regular, false), IncorrectXMLDocErr);

        // [THEN] XML file has node "Contraparte"
        LibrarySII.ValidateElementWithNameExists(XMLDoc, 'sii:Contraparte');

        // [THEN] XML file has node "ImporteTotal"
        LibrarySII.ValidateElementWithNameExists(XMLDoc, 'sii:ImporteTotal');

        // [THEN] TipoFactura is "F4" in exported SII File
        LibrarySII.VerifyOneNodeWithValueByXPath(XMLDoc, XPathPurchFacturaRecibidaTok, 'sii:TipoFactura', 'F4');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PurchInvoiceWithInvTypeF5HasContraparteBlock()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        SIIXMLCreator: Codeunit "SII XML Creator";
        XMLDoc: DotNet XmlDocument;
    begin
        // [FEATURE] [Purchase] [Invoice]
        // [SCENARIO 223508] XML has node "Contraparte" when post Purchase Invoice with "Invoice Type" = "F5 Imports (DUA)"
        Initialize;

        // [GIVEN] Posted Purchase Invoice with "Invoice Type" = "F5 Imports (DUA)"
        PostPurchDocWithInvOrCrMemoType(
          VendorLedgerEntry, PurchaseHeader."Document Type"::Invoice, 0, PurchaseHeader."Invoice Type"::"F5 Imports (DUA)", 0);

        // [WHEN] Create xml for Posted Purchase Invoice
        Assert.IsTrue(SIIXMLCreator.GenerateXml(VendorLedgerEntry, XMLDoc, UploadType::Regular, false), IncorrectXMLDocErr);

        // [THEN] XML file has node "Contraparte"
        LibrarySII.ValidateElementWithNameExists(XMLDoc, 'sii:Contraparte');

        // [THEN] TipoFactura is "F4" in exported SII File
        LibrarySII.VerifyOneNodeWithValueByXPath(XMLDoc, XPathPurchFacturaRecibidaTok, 'sii:TipoFactura', 'F5');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PurchInvoiceWithInvTypeF6HasContraparteBlock()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        SIIXMLCreator: Codeunit "SII XML Creator";
        XMLDoc: DotNet XmlDocument;
    begin
        // [FEATURE] [Purchase] [Invoice]
        // [SCENARIO 269099] XML has node "Contraparte" when post Purchase Invoice with "Invoice Type" = "F6 Accounting support material"
        Initialize;

        // [GIVEN] Posted Purchase Invoice with "Invoice Type" = "F5 Imports (DUA)"
        PostPurchDocWithInvOrCrMemoType(
          VendorLedgerEntry, PurchaseHeader."Document Type"::Invoice, 0, PurchaseHeader."Invoice Type"::"F6 Accounting support material", 0);

        // [WHEN] Create xml for Posted Purchase Invoice
        Assert.IsTrue(SIIXMLCreator.GenerateXml(VendorLedgerEntry, XMLDoc, UploadType::Regular, false), IncorrectXMLDocErr);

        // [THEN] XML file has node "Contraparte"
        LibrarySII.ValidateElementWithNameExists(XMLDoc, 'sii:Contraparte');

        // [THEN] TipoFactura is "F4" in exported SII File
        LibrarySII.VerifyOneNodeWithValueByXPath(XMLDoc, XPathPurchFacturaRecibidaTok, 'sii:TipoFactura', 'F6');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PurchDiffCrMemoWithCrMemoTypeR2HasContraparteBlock()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        SIIXMLCreator: Codeunit "SII XML Creator";
        XMLDoc: DotNet XmlDocument;
    begin
        // [FEATURE] [Purchase] [Credit Memo]
        // [SCENARIO 223508] XML has node "Contraparte" when post Purchase Credit Memo with Type "Difference" and "Cr. Memo Type" = "R2 Corrected Invoice (Art. 80.3)"
        // [SCENARIO 252872] XML has node "ImporteTotal" with negative value

        Initialize;

        // [GIVEN] Posted Purchase Credit Memo type "Difference" and "Cr. Memo Type" = "R2 Corrected Invoice (Art. 80.3)"
        // [GIVEN] Vendor Ledger Entry Created with Amount = -120
        PostPurchDocWithInvOrCrMemoType(
          VendorLedgerEntry, PurchaseHeader."Document Type"::"Credit Memo", PurchaseHeader."Correction Type"::Difference,
          0, PurchaseHeader."Cr. Memo Type"::"R2 Corrected Invoice (Art. 80.3)");

        // [WHEN] Create xml for Posted Purchase Credit Memo
        Assert.IsTrue(SIIXMLCreator.GenerateXml(VendorLedgerEntry, XMLDoc, UploadType::Regular, false), IncorrectXMLDocErr);

        // [THEN] XML file has node "Contraparte"
        LibrarySII.ValidateElementWithNameExists(XMLDoc, 'sii:Contraparte');

        // [THEN] TipoFactura is "R2" in exported SII File
        LibrarySII.VerifyOneNodeWithValueByXPath(XMLDoc, XPathPurchFacturaRecibidaTok, 'sii:TipoFactura', 'R2');

        // [THEN] XML file has node "ImporteTotal" with value -120
        VendorLedgerEntry.CalcFields("Amount (LCY)");
        LibrarySII.ValidateElementByName(XMLDoc, 'sii:ImporteTotal', SIIXMLCreator.FormatNumber(-VendorLedgerEntry."Amount (LCY)"));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PurchDiffCrMemoWithCrMemoTypeR3HasContraparteBlock()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        SIIXMLCreator: Codeunit "SII XML Creator";
        XMLDoc: DotNet XmlDocument;
    begin
        // [FEATURE] [Purchase] [Credit Memo]
        // [SCENARIO 223508] XML has node "Contraparte" when post Purchase Credit Memo with Type "Difference" and "Cr. Memo Type" = "R3 Corrected Invoice (Art. 80.4)"

        Initialize;

        // [GIVEN] Posted Purchase Credit Memo type "Difference" and "Cr. Memo Type" = "R3 Corrected Invoice (Art. 80.4)"
        PostPurchDocWithInvOrCrMemoType(
          VendorLedgerEntry, PurchaseHeader."Document Type"::"Credit Memo", PurchaseHeader."Correction Type"::Difference,
          0, PurchaseHeader."Cr. Memo Type"::"R3 Corrected Invoice (Art. 80.4)");

        // [WHEN] Create xml for Posted Purchase Credit Memo
        Assert.IsTrue(SIIXMLCreator.GenerateXml(VendorLedgerEntry, XMLDoc, UploadType::Regular, false), IncorrectXMLDocErr);

        // [THEN] XML file has node "Contraparte"
        LibrarySII.ValidateElementWithNameExists(XMLDoc, 'sii:Contraparte');

        // [THEN] TipoFactura is "R3" in exported SII File
        LibrarySII.VerifyOneNodeWithValueByXPath(XMLDoc, XPathPurchFacturaRecibidaTok, 'sii:TipoFactura', 'R3');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PurchDiffCrMemoWithCrMemoTypeR4HasContraparteBlock()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        SIIXMLCreator: Codeunit "SII XML Creator";
        XMLDoc: DotNet XmlDocument;
    begin
        // [FEATURE] [Purchase] [Credit Memo]
        // [SCENARIO 223508] XML has node "Contraparte" when post Purchase Credit Memo with Type "Difference" and "Cr. Memo Type" = "R4 Corrected Invoice (Other)"

        Initialize;

        // [GIVEN] Posted Purchase Credit Memo type "Difference" and "Cr. Memo Type" = "R4 Corrected Invoice (Other)"
        PostPurchDocWithInvOrCrMemoType(
          VendorLedgerEntry, PurchaseHeader."Document Type"::"Credit Memo", PurchaseHeader."Correction Type"::Difference,
          0, PurchaseHeader."Cr. Memo Type"::"R4 Corrected Invoice (Other)");

        // [WHEN] Create xml for Posted Purchase Credit Memo
        Assert.IsTrue(SIIXMLCreator.GenerateXml(VendorLedgerEntry, XMLDoc, UploadType::Regular, false), IncorrectXMLDocErr);

        // [THEN] XML file has node "Contraparte"
        LibrarySII.ValidateElementWithNameExists(XMLDoc, 'sii:Contraparte');

        // [THEN] TipoFactura is "R4" in exported SII File
        LibrarySII.VerifyOneNodeWithValueByXPath(XMLDoc, XPathPurchFacturaRecibidaTok, 'sii:TipoFactura', 'R4');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PurchReplacementWithCrMemoTypeR2HasContraparteBlock()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        SIIXMLCreator: Codeunit "SII XML Creator";
        XMLDoc: DotNet XmlDocument;
    begin
        // [FEATURE] [Purchase] [Credit Memo]
        // [SCENARIO 223508] XML has node "Contraparte" when post Purchase Credit Memo with Type "Replacement" and "Cr. Memo Type" = "R2 Corrected Invoice (Art. 80.3)"
        // [SCENARIO 252872] XML has node "ImporteTotal" with negative value
        // [SCENARIO 256251] Sales Credit Memo with type "Replacement" has positive values for VAT

        Initialize;

        // [GIVEN] Posted Purchase Credit Memo type "Replacement" and "Cr. Memo Type" = "R2 Corrected Invoice (Art. 80.3)"
        // [GIVEN] Vendor Ledger Entry Created with Amount = -120
        PostPurchDocWithInvOrCrMemoType(
          VendorLedgerEntry, PurchaseHeader."Document Type"::"Credit Memo", PurchaseHeader."Correction Type"::Replacement,
          0, PurchaseHeader."Cr. Memo Type"::"R2 Corrected Invoice (Art. 80.3)");

        // [WHEN] Create xml for Posted Purchase Credit Memo
        Assert.IsTrue(SIIXMLCreator.GenerateXml(VendorLedgerEntry, XMLDoc, UploadType::Regular, false), IncorrectXMLDocErr);

        // [THEN] XML file has node "Contraparte"
        LibrarySII.ValidateElementWithNameExists(XMLDoc, 'sii:Contraparte');

        // [THEN] TipoFactura is "R2" in exported SII File
        LibrarySII.VerifyOneNodeWithValueByXPath(XMLDoc, XPathPurchFacturaRecibidaTok, 'sii:TipoFactura', 'R2');

        // [THEN] XML file has node "ImporteTotal" with value 120
        VendorLedgerEntry.CalcFields("Amount (LCY)");
        LibrarySII.ValidateElementByName(XMLDoc, 'sii:ImporteTotal', SIIXMLCreator.FormatNumber(-VendorLedgerEntry."Amount (LCY)"));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PurchReplacementWithCrMemoTypeR3HasContraparteBlock()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        SIIXMLCreator: Codeunit "SII XML Creator";
        XMLDoc: DotNet XmlDocument;
    begin
        // [FEATURE] [Purchase] [Credit Memo]
        // [SCENARIO 223508] XML has node "Contraparte" when post Purchase Credit Memo with Type "Replacement" and "Cr. Memo Type" = "R3 Corrected Invoice (Art. 80.4)"

        Initialize;

        // [GIVEN] Posted Purchase Credit Memo type "Replacement" and "Cr. Memo Type" = "R3 Corrected Invoice (Art. 80.4)"
        PostPurchDocWithInvOrCrMemoType(
          VendorLedgerEntry, PurchaseHeader."Document Type"::"Credit Memo", PurchaseHeader."Correction Type"::Replacement,
          0, PurchaseHeader."Cr. Memo Type"::"R3 Corrected Invoice (Art. 80.4)");

        // [WHEN] Create xml for Posted Purchase Credit Memo
        Assert.IsTrue(SIIXMLCreator.GenerateXml(VendorLedgerEntry, XMLDoc, UploadType::Regular, false), IncorrectXMLDocErr);

        // [THEN] XML file has node "Contraparte"
        LibrarySII.ValidateElementWithNameExists(XMLDoc, 'sii:Contraparte');

        // [THEN] TipoFactura is "R3" in exported SII File
        LibrarySII.VerifyOneNodeWithValueByXPath(XMLDoc, XPathPurchFacturaRecibidaTok, 'sii:TipoFactura', 'R3');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PurchReplacementWithCrMemoTypeR4HasContraparteBlock()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        SIIXMLCreator: Codeunit "SII XML Creator";
        XMLDoc: DotNet XmlDocument;
    begin
        // [FEATURE] [Purchase] [Credit Memo]
        // [SCENARIO 223508] XML has node "Contraparte" when post Purchase Credit Memo with Type "Replacement" and "Cr. Memo Type" = "R4 Corrected Invoice (Other)"

        Initialize;

        // [GIVEN] Posted Purchase Credit Memo type "Replacement" and "Cr. Memo Type" = "R4 Corrected Invoice (Other)"
        PostPurchDocWithInvOrCrMemoType(
          VendorLedgerEntry, PurchaseHeader."Document Type"::"Credit Memo", PurchaseHeader."Correction Type"::Replacement,
          0, PurchaseHeader."Cr. Memo Type"::"R4 Corrected Invoice (Other)");

        // [WHEN] Create xml for Posted Purchase Credit Memo
        Assert.IsTrue(SIIXMLCreator.GenerateXml(VendorLedgerEntry, XMLDoc, UploadType::Regular, false), IncorrectXMLDocErr);

        // [THEN] XML file has node "Contraparte"
        LibrarySII.ValidateElementWithNameExists(XMLDoc, 'sii:Contraparte');

        // [THEN] TipoFactura is "R4" in exported SII File
        LibrarySII.VerifyOneNodeWithValueByXPath(XMLDoc, XPathPurchFacturaRecibidaTok, 'sii:TipoFactura', 'R4');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TipoFacturaLCsForPurchInvoiceWithCustomsComplementaryLiquidationInvType()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        SIIXMLCreator: Codeunit "SII XML Creator";
        XMLDoc: DotNet XmlDocument;
    begin
        // [FEATURE] [Purchase] [Invoice]
        // [SCENARIO 263060] TipoFactura is 'LC' for Purchase invoice with invoice type "Customs - Complementary Liquidation"

        Initialize;

        // [GIVEN] Posted Purchase Invoice with "Invoice Type" = "Customs - Complementary Liquidation"
        PostPurchDocWithInvOrCrMemoType(
          VendorLedgerEntry, PurchaseHeader."Document Type"::Invoice, 0,
          PurchaseHeader."Invoice Type"::"Customs - Complementary Liquidation", 0);

        // [WHEN] Create xml for Posted Purchase Invoice
        Assert.IsTrue(SIIXMLCreator.GenerateXml(VendorLedgerEntry, XMLDoc, UploadType::Regular, false), IncorrectXMLDocErr);

        // [THEN] TipoFactura is "F2" in exported SII File
        LibrarySII.VerifyOneNodeWithValueByXPath(XMLDoc, XPathPurchFacturaRecibidaTok, 'sii:TipoFactura', 'LC');
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        LibrarySII.InitSetup(true, false);
        LibrarySII.BindSubscriptionJobQueue;

        IsInitialized := true;
    end;

    local procedure PostSalesDocWithInvOrCrMemoType(var CustLedgerEntry: Record "Cust. Ledger Entry"; DocType: Enum "Sales Document Type"; CorrType: Option; InvoiceType: Option; CrMemoType: Integer)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocType, LibrarySales.CreateCustomerNo);
        SalesHeader.Validate("Correction Type", CorrType);
        SalesHeader.Validate("Invoice Type", InvoiceType);
        SalesHeader.Validate("Cr. Memo Type", CrMemoType);
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader, SalesLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithSalesSetup, LibraryRandom.RandInt(100));
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(100, 2));
        SalesLine.Modify(true);
        LibraryERM.FindCustomerLedgerEntry(CustLedgerEntry, DocType, LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure PostPurchDocWithInvOrCrMemoType(var VendorLedgerEntry: Record "Vendor Ledger Entry"; DocType: Enum "Purchase Document Type"; CorrType: Option; InvoiceType: Option; CrMemoType: Integer)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocType, LibraryPurchase.CreateVendorNo);
        PurchaseHeader.Validate("Correction Type", CorrType);
        PurchaseHeader.Validate("Invoice Type", InvoiceType);
        PurchaseHeader.Validate("Cr. Memo Type", CrMemoType);
        PurchaseHeader.Modify(true);
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account",
          LibraryERM.CreateGLAccountWithSalesSetup, LibraryRandom.RandInt(100));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(100, 2));
        PurchaseLine.Modify(true);
        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, DocType, LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;
}
