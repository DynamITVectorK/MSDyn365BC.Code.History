codeunit 144004 "UT Address Format"
{
    // 1-2. Purpose of the test is to verify Post Code and City and Country Region Code with and without blank line on Customer Address of Report ID - 206 Sales - Invoice.
    // 3-4. Purpose of the test is to verify Post Code and City and Local Address Format on General Ledger Setup with and without blank line on Customer Address of Report ID - 206 Sales - Invoice.
    // 5-7. Purpose of this test to verify Country Region Code on Customer Card,Vendor Card and Contact Card.
    // 8. Purpose of this test to verify Country Region Code is deleted on Country/Region table.
    // 
    // Covers Test Cases for WI - 344970
    // ----------------------------------------------------------------------------------------------------------------------------
    // Test Function Name                                                                                                   TFS ID
    // ----------------------------------------------------------------------------------------------------------------------------
    // OnAfterGetRecAddrFormatPostCodeCity                                                                                  151133
    // OnAfterGetRecAddrFormatPostCodeCityGLSetup                                                                           151135
    // OnAfterGetRecAddrFormatBlankLinePostCodeCity                                                                         151132
    // OnAfterGetRecAddrFormatBlankLinePostCodeCityGLSetup                                                                  151134
    // OnAfterGetRecordCountryRegionCustomerCard,OnAfterGetRecordCountryRegionVendorCard
    // OnAfterGetRecordCountryRegionContactCard,OnDeleteCountryRegion

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryUTUtility: Codeunit "Library UT Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        PostCodeCityWithoutBlankLineTxt: Label 'CustAddr3';
        PostCodeCityWithBlankLineTxt: Label 'CustAddr4';
        CountryRegionCodeErr: Label 'Country Region should not exist';

    [Test]
    [HandlerFunctions('SalesInvoiceRequestPageHandler')]
    [Scope('OnPrem')]
    procedure OnAfterGetRecAddrFormatPostCodeCity()
    var
        CountryRegion: Record "Country/Region";
    begin
        // Purpose of the test is to verify Post Code and City and Country Region Code without blank line on Customer Address of Report ID - 206 Sales - Invoice.
        CustomerAddressFormatSalesInvoice(CreateCountryRegionCode(CountryRegion."Address Format"::"Post Code+City"));
    end;

    [Test]
    [HandlerFunctions('SalesInvoiceRequestPageHandler')]
    [Scope('OnPrem')]
    procedure OnAfterGetRecAddrFormatPostCodeCityGLSetup()
    begin
        // Purpose of the test is to verify Post Code and City and Local Address Format on General Ledger Setup without blank line on Customer Address of Report ID - 206 Sales - Invoice.
        CustomerAddressFormatSalesInvoice('');  // Using Blank for Country Region.
    end;

    local procedure CustomerAddressFormatSalesInvoice(CountryRegion: Code[10])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        // Setup & Excercise.
        PostedSalesInvoicePostCodeAndCity(SalesInvoiceHeader, CountryRegion);

        // Verify: Verify Bill To Post code and Bill To City on Customer Address.
        VerifyPostCodeAndCityOnCustomerAddress(SalesInvoiceHeader, PostCodeCityWithoutBlankLineTxt);
    end;

    [Test]
    [HandlerFunctions('SalesInvoiceRequestPageHandler')]
    [Scope('OnPrem')]
    procedure OnAfterGetRecAddrFormatBlankLinePostCodeCity()
    var
        CountryRegion: Record "Country/Region";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        // Purpose of the test is to verify Post Code and City and Country Region Code with blank line on Customer Address of Report ID - 206 Sales - Invoice.

        // Setup & Excercise.
        PostedSalesInvoicePostCodeAndCity(
          SalesInvoiceHeader, CreateCountryRegionCode(CountryRegion."Address Format"::"Blank Line+Post Code+City"));

        // Verify: Verify Blank Line, Bill To Post code and Bill To City in Customer Address.
        VerifyPostCodeAndCityOnCustomerAddress(SalesInvoiceHeader, PostCodeCityWithBlankLineTxt);
        LibraryReportDataset.AssertElementWithValueExists(PostCodeCityWithoutBlankLineTxt, '');
    end;

    [Test]
    [HandlerFunctions('SalesInvoiceRequestPageHandler')]
    [Scope('OnPrem')]
    procedure OnAfterGetRecAddrFormatBlankLinePostCodeCityGLSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        // Purpose of the test is to verify Post Code and City and Local Address Format on General Ledger Setup with blank line on Customer Address of Report ID - 206 Sales - Invoice.

        // Setup & Excercise.
        UpdateGeneralLedgerSetup(GeneralLedgerSetup."Local Address Format"::"Blank Line+Post Code+City");
        PostedSalesInvoicePostCodeAndCity(SalesInvoiceHeader, '');  // Using Blank for Country Region.

        // Verify: Verify Blank Line, Bill To Post code and Bill To City in Customer Address.
        VerifyPostCodeAndCityOnCustomerAddress(SalesInvoiceHeader, PostCodeCityWithBlankLineTxt);
        LibraryReportDataset.AssertElementWithValueExists(PostCodeCityWithoutBlankLineTxt, '');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnAfterGetRecordCountryRegionCustomerCard()
    var
        CountryRegion: Record "Country/Region";
        Customer: Record Customer;
        CustomerCard: TestPage "Customer Card";
    begin
        // Purpose of this test to verify Country Region Code on Page - 21 Customer Card.

        // Setup: Create Customer with Country Region.
        Initialize;
        CreateCustomerWithCountryRegion(Customer, CreateCountryRegionCode(CountryRegion."Address Format"::"Post Code+City"));
        CustomerCard.OpenEdit;

        // Exercise.
        CustomerCard.FILTER.SetFilter("No.", Customer."No.");

        // Verify: Verify Country Region Code on Customer Card Page.
        CustomerCard."Country/Region Code".AssertEquals(Customer."Country/Region Code");
        CustomerCard.Close;
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnAfterGetRecordCountryRegionVendorCard()
    var
        CountryRegion: Record "Country/Region";
        Vendor: Record Vendor;
        VendorCard: TestPage "Vendor Card";
    begin
        // Purpose of this test to verify Country Region Code on Page - 26 Vendor Card.

        // Setup: Create Vendor with Country Region.
        Initialize;
        CreateVendorWithCountryRegion(Vendor, CreateCountryRegionCode(CountryRegion."Address Format"::"Post Code+City"));
        VendorCard.OpenEdit;

        // Exercise.
        VendorCard.FILTER.SetFilter("No.", Vendor."No.");

        // Verify: Verify Country Region Code on Vendor Card Page.
        VendorCard."Country/Region Code".AssertEquals(Vendor."Country/Region Code");
        VendorCard.Close;
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnAfterGetRecordCountryRegionContactCard()
    var
        Contact: Record Contact;
        CountryRegion: Record "Country/Region";
        ContactCard: TestPage "Contact Card";
    begin
        // Purpose of this test to verify Country Region Code on Page - 5050 Contact Card.

        // Setup: Create Contact with Country Region.
        Initialize;
        CreateContactWithCountryRegion(Contact, CreateCountryRegionCode(CountryRegion."Address Format"::"Post Code+City"));
        ContactCard.OpenEdit;

        // Exercise.
        ContactCard.FILTER.SetFilter("No.", Contact."No.");

        // Verify: Verify Country Region Code on Contact Card Page.
        ContactCard."Country/Region Code".AssertEquals(Contact."Country/Region Code");
        ContactCard.Close;
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnDeleteCountryRegion()
    var
        CountryRegion: Record "Country/Region";
        VATRegistrationNoFormat: Record "VAT Registration No. Format";
    begin
        // Purpose of this test to verify Country Region Code is deleted on Table - 9 Country/Region.

        // Setup: Create Country Region.
        Initialize;
        CountryRegion.Code := LibraryUTUtility.GetNewCode10;
        CountryRegion.Insert();

        // Exercise: Delete Country Region.
        CountryRegion.Delete(true);

        // Verify: Verify Country Region deleted.
        Assert.IsFalse(CountryRegion.Get(CountryRegion.Code), CountryRegionCodeErr);
        Assert.IsFalse(VATRegistrationNoFormat.Get(CountryRegion.Code), CountryRegionCodeErr);
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear;
    end;

    local procedure CreatePostedSalesInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header"; CountryRegionCode: Code[10])
    var
        Customer: Record Customer;
    begin
        CreateCustomerWithCountryRegion(Customer, CountryRegionCode);
        SalesInvoiceHeader."No." := LibraryUTUtility.GetNewCode;
        SalesInvoiceHeader."Bill-to Customer No." := Customer."No.";
        SalesInvoiceHeader."Bill-to Address" := Customer.Address;
        SalesInvoiceHeader."Bill-to Address 2" := Customer."Address 2";
        SalesInvoiceHeader."Bill-to City" := Customer.City;
        SalesInvoiceHeader."Bill-to Post Code" := Customer."Post Code";
        SalesInvoiceHeader."Bill-to County" := Customer.County;
        SalesInvoiceHeader."Bill-to Country/Region Code" := Customer."Country/Region Code";
        SalesInvoiceHeader.Insert();
    end;

    local procedure CreateContactWithCountryRegion(var Contact: Record Contact; CountryRegionCode: Code[10])
    begin
        Contact."No." := LibraryUTUtility.GetNewCode;
        Contact.Address := LibraryUTUtility.GetNewCode;
        Contact."Address 2" := LibraryUTUtility.GetNewCode;
        Contact."Country/Region Code" := CountryRegionCode;
        Contact.County := LibraryUTUtility.GetNewCode;
        Contact."Post Code" := LibraryUTUtility.GetNewCode;
        Contact.City := LibraryUTUtility.GetNewCode;
        Contact.Insert();
    end;

    local procedure CreateCustomerWithCountryRegion(var Customer: Record Customer; CountryRegionCode: Code[10])
    begin
        Customer."No." := LibraryUTUtility.GetNewCode;
        Customer.Address := LibraryUTUtility.GetNewCode;
        Customer."Address 2" := LibraryUTUtility.GetNewCode;
        Customer."Country/Region Code" := CountryRegionCode;
        Customer.County := LibraryUTUtility.GetNewCode;
        Customer."Post Code" := LibraryUTUtility.GetNewCode;
        Customer.City := LibraryUTUtility.GetNewCode;
        Customer.Insert(true);
    end;

    local procedure CreateVendorWithCountryRegion(var Vendor: Record Vendor; CountryRegionCode: Code[10])
    begin
        Vendor."No." := LibraryUTUtility.GetNewCode;
        Vendor.Address := LibraryUTUtility.GetNewCode;
        Vendor."Address 2" := LibraryUTUtility.GetNewCode;
        Vendor."Country/Region Code" := CountryRegionCode;
        Vendor.County := LibraryUTUtility.GetNewCode;
        Vendor."Post Code" := LibraryUTUtility.GetNewCode;
        Vendor.City := LibraryUTUtility.GetNewCode;
        Vendor.Insert(true);
    end;

    local procedure CreateCountryRegionCode(AddressFormat: Option): Code[10]
    var
        CountryRegion: Record "Country/Region";
    begin
        CountryRegion.Code := LibraryUTUtility.GetNewCode10;
        CountryRegion."Address Format" := AddressFormat;
        CountryRegion.Insert();
        exit(CountryRegion.Code);
    end;

    local procedure PostedSalesInvoicePostCodeAndCity(var SalesInvoiceHeader: Record "Sales Invoice Header"; CountryRegionCode: Code[10])
    begin
        // Setup: Create Customer and Posted Sales Invoice and update General Ledger Setup.
        Initialize;
        CreatePostedSalesInvoice(SalesInvoiceHeader, CountryRegionCode);
        LibraryVariableStorage.Enqueue(SalesInvoiceHeader."No.");  // Enqueue value for SalesInvoiceRequestPageHandler.
        Commit();  // Commit required since explicit Commit used on OnRun Trigger of COD315: Sales Inv.-Printed.

        // Exercise.
        RunSalesInvoiceReport(SalesInvoiceHeader."No.");
    end;

    local procedure RunSalesInvoiceReport(No: Code[20])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoice: Report "Sales - Invoice";
    begin
        Clear(SalesInvoice);
        SalesInvoiceHeader.SetRange("No.", No);
        SalesInvoice.SetTableView(SalesInvoiceHeader);
        SalesInvoice.Run;  // Open SalesInvoiceRequestPageHandler.
    end;

    local procedure UpdateGeneralLedgerSetup(LocalAddressFormat: Option)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Local Address Format" := LocalAddressFormat;
        GeneralLedgerSetup.Modify();
    end;

    local procedure VerifyPostCodeAndCityOnCustomerAddress(SalesInvoiceHeader: Record "Sales Invoice Header"; CustomerAddressCityAndPostCode: Text)
    begin
        LibraryReportDataset.LoadDataSetFile;
        LibraryReportDataset.AssertElementWithValueExists(
          CustomerAddressCityAndPostCode, SalesInvoiceHeader."Bill-to Post Code" + ' ' + SalesInvoiceHeader."Bill-to City");
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure SalesInvoiceRequestPageHandler(var SalesInvoice: TestRequestPage "Sales - Invoice")
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        SalesInvoice."Sales Invoice Header".SetFilter("No.", No);
        SalesInvoice.SaveAsXml(LibraryReportDataset.GetParametersFileName, LibraryReportDataset.GetFileName);
    end;
}
