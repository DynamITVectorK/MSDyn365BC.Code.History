codeunit 134992 "ERM Financial Reports IV"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [ERM]
        IsInitialized := false;
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryReportValidation: Codeunit "Library - Report Validation";
        Assert: Codeunit Assert;
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        PostingDateError: Label 'Enter the posting date.';
        DocumentNoError: Label 'Enter the document no.';
        SettlementAccountError: Label 'Enter the settlement account';
        IsInitialized: Boolean;
        SameAmountError: Label 'Amount must be same.';
        NoDataRowErr: Label 'There is no dataset row corresponding to Element Name %1 with value %2';
        TooManyWorksheetsErr: Label 'Expected single worksheet';

    [Test]
    [HandlerFunctions('RHVATStatement')]
    [Scope('OnPrem')]
    procedure VATStatementWithOpenEntriesPurchase()
    var
        GenJournalLine: Record "Gen. Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Vendor: Record Vendor;
        Selection: Option Open,Closed,"Open and Closed";
    begin
        // Test VAT Statement Report for Purchase with Open VAT Entries.

        // Setup: Create and Post General Journal Line for Vendor, Taking -1 for negative sign factor.
        Initialize;
        LibraryPurchase.CreateVendor(Vendor);
        CreateAndPostGeneralJournalLine(
          VATPostingSetup, GenJournalLine."Account Type"::Vendor, Vendor."No.", GenJournalLine."Gen. Posting Type"::Purchase, -1);

        // Save VAT Statement Report for Purchase with Open Selection and Verify the Amount. Passing FALSE to find Open Entries for Purchase.
        // Exercise And Verification done in VATStatementForDifferentEntries function.
        VATStatementForDifferentEntries(VATPostingSetup, GenJournalLine."Gen. Posting Type"::Purchase, Selection::Open, false);
    end;

    [Test]
    [HandlerFunctions('RHVATStatement')]
    [Scope('OnPrem')]
    procedure VATStatementWithOpenEntriesSales()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Selection: Option Open,Closed,"Open and Closed";
    begin
        // Test VAT Statement Report for Sales with Open VAT Entries.

        // Setup: Create and Post General Journal Line for Customer, Taking 1 for positive sign factor.
        Initialize;
        LibrarySales.CreateCustomer(Customer);
        CreateAndPostGeneralJournalLine(
          VATPostingSetup, GenJournalLine."Account Type"::Customer, Customer."No.", GenJournalLine."Gen. Posting Type"::Sale, 1);

        // Save VAT Statement Report for Sale with Open Selection and Verify the Amount. Passing FALSE to find Open Entries for Sale.
        // Exercise And Verification done in VATStatementForDifferentEntries function.
        VATStatementForDifferentEntries(VATPostingSetup, GenJournalLine."Gen. Posting Type"::Sale, Selection::Open, false);
    end;

    [Test]
    [HandlerFunctions('RHVATStatement')]
    [Scope('OnPrem')]
    procedure VATStatementWithClosedEntriesPurchase()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        VATEntry: Record "VAT Entry";
        Selection: Option Open,Closed,"Open and Closed";
    begin
        // Test VAT Statement Report for Purchase with Closed VAT Entries.

        // Setup: Save VAT Statement Report with Closed Selection and Verify the Amount. Passing TRUE to find Close Entries.
        Initialize;
        FindVATPostingSetupFromVATEntries(VATPostingSetup, VATEntry.Type::Purchase);

        // Exercise And Verification done in VATStatementForDifferentEntries function.
        VATStatementForDifferentEntries(VATPostingSetup, VATEntry.Type::Purchase, Selection::Closed, true);
    end;

    [Test]
    [HandlerFunctions('RHVATStatement')]
    [Scope('OnPrem')]
    procedure VATStatementWithClosedEntriesSales()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        VATEntry: Record "VAT Entry";
        Selection: Option Open,Closed,"Open and Closed";
    begin
        // Test VAT Statement Report for Sales with Closed VAT Entries.

        // Setup: Save VAT Statement Report with Closed Selection and Verify the Amount. Passing TRUE to find Close Entries for Sale.
        Initialize;
        FindVATPostingSetupFromVATEntries(VATPostingSetup, VATEntry.Type::Sale);

        // Exercise And Verification done in VATStatementForDifferentEntries function.
        VATStatementForDifferentEntries(VATPostingSetup, VATEntry.Type::Sale, Selection::Closed, true);
    end;

    [Test]
    [HandlerFunctions('RHCalcAndPostVATSettlement')]
    [Scope('OnPrem')]
    procedure CalcAndPostVATSettlementPostingDateError()
    var
        CalcAndPostVATSettlement: Report "Calc. and Post VAT Settlement";
    begin
        // Test Error Message when Posting Date is not filled while running Calc. and Post VAT Settlement Report.

        // Setup: Set Parameters for Report having Starting Date, Ending Date, Posting Date, Document No. and Settlement Account No as Blank.
        Initialize;
        Clear(CalcAndPostVATSettlement);
        CalcAndPostVATSettlement.InitializeRequest(0D, 0D, 0D, '', '', false, false);

        // Exercise: Try to save Report with TEST Name.
        asserterror CalcAndPostVATSettlement.Run;

        // Verify: Verify that Posting Date not filled error appears.
        Assert.ExpectedError(StrSubstNo(PostingDateError));
    end;

    [Test]
    [HandlerFunctions('RHCalcAndPostVATSettlement')]
    [Scope('OnPrem')]
    procedure CalcAndPostVATSettlementDocNoError()
    var
        CalcAndPostVATSettlement: Report "Calc. and Post VAT Settlement";
    begin
        // Test Error Message when Document No. is not filled while running Calc. and Post VAT Settlement Report.

        // Setup: Set Parameters for Report having Starting Date, Ending Date, Document No. and Settlement Account No. as Blank, take Posting Date as WORKDATE.
        Initialize;
        Clear(CalcAndPostVATSettlement);
        CalcAndPostVATSettlement.InitializeRequest(0D, 0D, WorkDate, '', '', false, false);

        // Exercise: Try to save Report with TEST Name.
        asserterror CalcAndPostVATSettlement.Run;

        // Verify: Verify that Document No. not filled error appears.
        Assert.ExpectedError(StrSubstNo(DocumentNoError));
    end;

    [Test]
    [HandlerFunctions('RHCalcAndPostVATSettlement')]
    [Scope('OnPrem')]
    procedure CalcAndPostVATSettlementAccountError()
    var
        CalcAndPostVATSettlement: Report "Calc. and Post VAT Settlement";
    begin
        // Test Error Message when Settlement Account is not filled while running Calc. and Post VAT Settlement Report.

        // Setup: Set Parameters for Report having Starting Date, Ending Date and Settlement Account No. as Blank, take Posting Date as WORKDATE and a Random Document No. value is not important.
        Initialize;
        Clear(CalcAndPostVATSettlement);
        CalcAndPostVATSettlement.InitializeRequest(0D, 0D, WorkDate, Format(LibraryRandom.RandInt(100)), '', false, false);

        // Exercise: Try to save Report with TEST Name.
        asserterror CalcAndPostVATSettlement.Run;

        // Verify: Verify that Settement Account No. not filled error appears.
        Assert.ExpectedError(StrSubstNo(SettlementAccountError));
    end;

    [Test]
    [HandlerFunctions('RHCalcAndPostVATSettlement')]
    [Scope('OnPrem')]
    procedure CalcAndPostVATSettlementSalesPostTrue()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // Test Calc. and Post VAT Settlement Report for Sales and when posting is TRUE.

        // Calculate and Post VAT Settlement for Customer with Post TRUE, taking 1 for positive sign factor.
        Initialize;
        LibrarySales.CreateCustomer(Customer);
        CalcAndPostVATSettlementWithPostingOption(
          GenJournalLine."Account Type"::Customer, Customer."No.", GenJournalLine."Gen. Posting Type"::Sale, 1, true);
    end;

    [Test]
    [HandlerFunctions('RHCalcAndPostVATSettlement')]
    [Scope('OnPrem')]
    procedure CalcAndPostVATSettlementSalesPostFalse()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // Test Calc. and Post VAT Settlement Report for Sales and when posting is FALSE.

        // Calculate and Post VAT Settlement for Customer with Post FALSE, taking 1 for positive sign factor.
        Initialize;
        LibrarySales.CreateCustomer(Customer);
        CalcAndPostVATSettlementWithPostingOption(
          GenJournalLine."Account Type"::Customer, Customer."No.", GenJournalLine."Gen. Posting Type"::Sale, 1, false);
    end;

    [Test]
    [HandlerFunctions('RHCalcAndPostVATSettlement')]
    [Scope('OnPrem')]
    procedure CalcAndPostVATSettlementPurchasePostTrue()
    var
        GenJournalLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
    begin
        // Test Calc. and Post VAT Settlement Report for Purchase and when posting is TRUE.

        // Calculate and Post VAT Settlement for Vendor with Post TRUE, taking -1 for negative sign factor.
        Initialize;
        LibraryPurchase.CreateVendor(Vendor);
        CalcAndPostVATSettlementWithPostingOption(
          GenJournalLine."Account Type"::Vendor, Vendor."No.", GenJournalLine."Gen. Posting Type"::Purchase, -1, true);
    end;

    [Test]
    [HandlerFunctions('RHCalcAndPostVATSettlement')]
    [Scope('OnPrem')]
    procedure CalcAndPostVATSettlementPurchasePostFalse()
    var
        GenJournalLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
    begin
        // Test Calc. and Post VAT Settlement Report for Purchase and when posting is FALSE.

        // Calculate and Post VAT Settlement for Vendor with Post FALSE, taking -1 for negative sign factor.
        Initialize;
        LibraryPurchase.CreateVendor(Vendor);
        CalcAndPostVATSettlementWithPostingOption(
          GenJournalLine."Account Type"::Vendor, Vendor."No.", GenJournalLine."Gen. Posting Type"::Purchase, -1, false);
    end;

    [Test]
    [HandlerFunctions('RHVATVIESDeclaration')]
    [Scope('OnPrem')]
    procedure VATVIESDeclarationReport()
    var
        Customer: Record Customer;
        SalesLine: Record "Sales Line";
        GLAccount: Record "G/L Account";
        Item: Record Item;
    begin
        // Verify VAT VIES Declaration Tax Auth. Report.

        // Setup: Find Customer with VAT Registration Number, create and post four Sales Orders.
        Initialize;
        CreateCustomerWithCountryRegionVATRegNo(Customer);
        LibraryInventory.CreateItem(Item);
        PostSalesOrderWithVATSetup(Customer."No.", false, SalesLine.Type::Item, Item."No.");
        PostSalesOrderWithVATSetup(Customer."No.", true, SalesLine.Type::Item, Item."No.");

        LibraryERM.FindGLAccount(GLAccount);
        PostSalesOrderWithVATSetup(Customer."No.", false, SalesLine.Type::"G/L Account", GLAccount."No.");
        PostSalesOrderWithVATSetup(Customer."No.", true, SalesLine.Type::"G/L Account", GLAccount."No.");

        // Exercise: Save VAT VIES Declaration Tax Auth. Report.
        VATVIESDeclarationTaxReport(Customer."VAT Registration No.");

        // Verify: Verify Values on VAT VIES Declaration Tax Auth. Report.
        LibraryReportDataset.LoadDataSetFile;
        LibraryReportDataset.SetRange('VATRegNo', Customer."VAT Registration No.");
        Assert.AreEqual(
          -CalculateBase(Customer."No.", 'Yes|No'), LibraryReportDataset.Sum('TotalValueofItemSupplies'),
          SameAmountError);
        Assert.AreEqual(
          -CalculateBase(Customer."No.", 'Yes'), LibraryReportDataset.Sum('EU3PartyItemTradeAmt'),
          SameAmountError);
    end;

    [Test]
    [HandlerFunctions('RHCalcAndPostVATSettlement')]
    [Scope('OnPrem')]
    procedure CalculateVATSettlementAfterPostSalesOrder()
    var
        SalesHeader: Record "Sales Header";
        VATPostingSetup: Record "VAT Posting Setup";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // Test Calc. and Post VAT Settlement Report for Sales with blank VAT Bus. Posting Group.

        // Setup: Create and Post Sales Order.
        Initialize;
        CreateVATPostingSetupWithBlankVATBusPostingGroup(VATPostingSetup);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, CreateCustomer(VATPostingSetup));
        CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, CreateItem(VATPostingSetup));
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // Exercise: Calculate and Post VAT Settlement for Customer.
        SaveCalcAndPostVATSettlementReport(VATPostingSetup, LibraryUtility.GenerateGUID, false); // Set False for Post.

        // Verify: Verify Values on Cal.And Post VAT Settlement Report.
        VerifyValuesOnCalcAndPostVATSettlementReport(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('RHCalcAndPostVATSettlement')]
    [Scope('OnPrem')]
    procedure CalculateVATSettlementAfterPostPurchaseOrder()
    var
        PurchaseHeader: Record "Purchase Header";
        VATPostingSetup: Record "VAT Posting Setup";
        DocumentNo: Code[20];
    begin
        // Test Calc. and Post VAT Settlement Report for Purchase with blank VAT Bus. Posting Group.

        // Setup: Create and Post Purchase Order.
        Initialize;
        CreateVATPostingSetupWithBlankVATBusPostingGroup(VATPostingSetup);
        CreatePurchaseOrder(PurchaseHeader, VATPostingSetup);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // Exercise: Calculate and Post VAT Settlement for Vendor.
        SaveCalcAndPostVATSettlementReport(VATPostingSetup, LibraryUtility.GenerateGUID, false); // Set False for Post.

        // Verify: Verify Values on Cal.And Post VAT Settlement Report.
        VerifyValuesOnCalcAndPostVATSettlementReport(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('PurchaseReceiptRequestPageHandler')]
    [Scope('OnPrem')]
    procedure CheckCompanyNameInPurchaseReceiptReport()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        CompanyInformation: Record "Company Information";
        DocumentNo: Code[20];
    begin
        // Verify that Purchase Receipt Report displaying Company Name.

        // Setup: Create purchase order
        Initialize;
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CreatePurchaseOrder(PurchaseHeader, VATPostingSetup);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);
        PurchRcptHeader.SetRange("No.", DocumentNo);
        CompanyInformation.Get;

        // Exercise: Run Purchase - Receipt report.
        REPORT.Run(REPORT::"Purchase - Receipt", true, false, PurchRcptHeader);

        // Verify: Verifying company name is not blank on record and report.
        CompanyInformation.TestField(Name);
        LibraryReportDataset.LoadDataSetFile;
        LibraryReportDataset.AssertElementWithValueExists('CompanyAddr1', CompanyInformation.Name);
    end;

    [Test]
    [HandlerFunctions('VATStatementTemplateListModalPageHandler,VATStatementExcelRPH')]
    [Scope('OnPrem')]
    procedure TestReportPrint_PrintVATStmtName()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        VATStatementLine: array[2] of Record "VAT Statement Line";
        VATStatementTemplate: Record "VAT Statement Template";
        FileManagement: Codeunit "File Management";
        VATStatementNames: TestPage "VAT Statement Names";
        FileName: Text;
    begin
        // [FEATURE] [Report] [VAT Statement] [UI]
        // [SCENARIO 338378] "VAT Statement" report prints single page when the single vat statement line is reported from VAT Statement Names page
        Initialize;
        LibrarySales.CreateCustomer(Customer);
        CreateAndPostGeneralJournalLine(
          VATPostingSetup, GenJournalLine."Account Type"::Customer, Customer."No.", GenJournalLine."Gen. Posting Type"::Sale, 1);

        CreateVATStatementTemplateAndLine(VATStatementLine[1], VATPostingSetup, GenJournalLine."Gen. Posting Type"::Sale);
        CreateVATStatementTemplateAndLine(VATStatementLine[2], VATPostingSetup, GenJournalLine."Gen. Posting Type"::Sale);

        FileName := FileManagement.ServerTempFileName('xlsx');
        LibraryVariableStorage.Enqueue(VATStatementLine[1]."Statement Template Name");
        LibraryVariableStorage.Enqueue(FileName);

        Commit;

        VATStatementNames.OpenView;
        VATStatementNames."&Print".Invoke; // Print
        VATStatementNames.Close;

        Assert.AreEqual(1, LibraryReportValidation.CountWorksheets, TooManyWorksheetsErr);

        VATStatementTemplate.Get(VATStatementLine[1]."Statement Template Name");
        VATStatementTemplate.Delete(true);

        VATStatementTemplate.Get(VATStatementLine[2]."Statement Template Name");
        VATStatementTemplate.Delete(true);

        LibraryVariableStorage.AssertEmpty;
    end;

    [Test]
    [HandlerFunctions('VATStatementTemplateListModalPageHandler,VATStatementExcelRPH')]
    [Scope('OnPrem')]
    procedure TestReportPrint_PrintVATStmtLine()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        VATStatementLine: array[2] of Record "VAT Statement Line";
        VATStatementTemplate: Record "VAT Statement Template";
        FileManagement: Codeunit "File Management";
        VATStatement: TestPage "VAT Statement";
        FileName: Text;
    begin
        // [FEATURE] [Report] [VAT Statement] [UI]
        // [SCENARIO 338378] "VAT Statement" report prints single page when the single vat statement line is reported from VAT Statement card page
        Initialize;
        LibrarySales.CreateCustomer(Customer);
        CreateAndPostGeneralJournalLine(
          VATPostingSetup, GenJournalLine."Account Type"::Customer, Customer."No.", GenJournalLine."Gen. Posting Type"::Sale, 1);

        CreateVATStatementTemplateAndLine(VATStatementLine[1], VATPostingSetup, GenJournalLine."Gen. Posting Type"::Sale);
        CreateVATStatementTemplateAndLine(VATStatementLine[2], VATPostingSetup, GenJournalLine."Gen. Posting Type"::Sale);

        FileName := FileManagement.ServerTempFileName('xlsx');
        LibraryVariableStorage.Enqueue(VATStatementLine[1]."Statement Template Name");
        LibraryVariableStorage.Enqueue(FileName);

        Commit;

        VATStatement.OpenView;
        VATStatement.Print.Invoke;
        VATStatement.Close;

        Assert.AreEqual(1, LibraryReportValidation.CountWorksheets, TooManyWorksheetsErr);

        VATStatementTemplate.Get(VATStatementLine[1]."Statement Template Name");
        VATStatementTemplate.Delete(true);

        VATStatementTemplate.Get(VATStatementLine[2]."Statement Template Name");
        VATStatementTemplate.Delete(true);

        LibraryVariableStorage.AssertEmpty;
    end;

    local procedure Initialize()
    var
        ObjectOptions: Record "Object Options";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"ERM Financial Reports IV");
        LibraryVariableStorage.Clear;
        Clear(LibraryReportValidation);

        ObjectOptions.SetRange("Object Type", ObjectOptions."Object Type"::Report);
        ObjectOptions.SetRange("Object ID", REPORT::"VAT Statement");
        ObjectOptions.DeleteAll;
        Commit;

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"ERM Financial Reports IV");
        LibraryERMCountryData.CreateVATData;
        LibraryERMCountryData.UpdateGeneralPostingSetup;
        IsInitialized := true;
        Commit;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"ERM Financial Reports IV");
    end;

    local procedure FindVATPostingSetupFromVATEntries(var VATPostingSetup: Record "VAT Posting Setup"; EntryType: Option)
    var
        VATEntry: Record "VAT Entry";
    begin
        with VATEntry do begin
            SetRange("VAT Calculation Type", "VAT Calculation Type"::"Normal VAT");
            SetRange(Type, EntryType);
            SetRange(Closed, Closed);
            FindFirst;
            VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group");
        end;
    end;

    local procedure CalcAndPostVATSettlementWithPostingOption(AccountType: Option; AccountNo: Code[20]; GenPostingType: Option; SignFactor: Integer; Post: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        VATEntry: Record "VAT Entry";
        Amount: Decimal;
    begin
        // Setup: Create and Post General Journal Line with different Account Types, Find VAT Entries Amount.
        CreateAndPostGeneralJournalLine(VATPostingSetup, AccountType, AccountNo, GenPostingType, SignFactor);
        VATEntry.SetRange("Posting Date", WorkDate);
        Amount := -CalculateVATEntryAmount(VATEntry, VATPostingSetup, GenPostingType, false);

        // Exercise: Taking Random No. for Document No., value is not important.
        SaveCalcAndPostVATSettlementReport(VATPostingSetup, Format(LibraryRandom.RandInt(100)), Post);

        // Verify: Verify Amount on Report.
        LibraryReportDataset.LoadDataSetFile;
        LibraryReportDataset.AssertElementWithValueExists('GenJnlLineVATAmount', Amount);
    end;

    local procedure CalculateVATEntryAmount(var VATEntry: Record "VAT Entry"; VATPostingSetup: Record "VAT Posting Setup"; Type: Option; Closed: Boolean) TotalAmount: Decimal
    begin
        VATEntry.SetRange(Type, Type);
        VATEntry.SetRange(Closed, Closed);
        VATEntry.SetRange("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        VATEntry.SetRange("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        VATEntry.CalcSums(Amount);
        TotalAmount := VATEntry.Amount;
    end;

    local procedure CreateAndPostGeneralJournalLine(var VATPostingSetup: Record "VAT Posting Setup"; AccountType: Option; AccountNo: Code[20]; GenPostingType: Option; SignFactor: Integer)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        VATPostingSetup.SetRange("Unrealized VAT Type", VATPostingSetup."Unrealized VAT Type"::" ");
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);
        LibraryERM.ClearGenJournalLines(GenJournalBatch);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Invoice,
          AccountType, AccountNo, SignFactor * LibraryRandom.RandDec(100, 2));
        GenJournalLine.Validate("Bal. Account No.", CreateGLAccountWithVAT(VATPostingSetup, GenPostingType));
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateCustomerWithCountryRegionVATRegNo(var Customer: Record Customer)
    var
        CountryRegion: Record "Country/Region";
    begin
        LibraryERM.CreateCountryRegion(CountryRegion);
        CountryRegion.Validate("EU Country/Region Code", CountryRegion.Code);
        CountryRegion.Modify(true);
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Country/Region Code", CountryRegion.Code);
        Customer."VAT Registration No." := LibraryERM.GenerateVATRegistrationNo(CountryRegion.Code);
        Customer.Modify(true);
    end;

    local procedure CreateGLAccountWithVAT(VATPostingSetup: Record "VAT Posting Setup"; GenPostingType: Option): Code[20]
    var
        GeneralPostingSetup: Record "General Posting Setup";
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.FindGeneralPostingSetup(GeneralPostingSetup);
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Gen. Posting Type", GenPostingType);
        GLAccount.Validate("Gen. Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group");
        GLAccount.Validate("Gen. Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group");
        GLAccount.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        GLAccount.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        GLAccount.Modify(true);
        exit(GLAccount."No.");
    end;

    local procedure CreateVATStatementTemplateAndLine(var VATStatementLine: Record "VAT Statement Line"; VATPostingSetup: Record "VAT Posting Setup"; GenPostingType: Option)
    var
        VATStatementTemplate: Record "VAT Statement Template";
        VATStatementName: Record "VAT Statement Name";
    begin
        LibraryERM.CreateVATStatementTemplate(VATStatementTemplate);
        VATStatementTemplate.Validate("VAT Statement Report ID", REPORT::"VAT Statement");
        VATStatementTemplate.Modify(true);
        LibraryERM.CreateVATStatementName(VATStatementName, VATStatementTemplate.Name);
        LibraryERM.CreateVATStatementLine(VATStatementLine, VATStatementTemplate.Name, VATStatementName.Name);
        VATStatementLine.Validate("Row No.", Format(LibraryRandom.RandInt(100)));
        VATStatementLine.Validate(Type, VATStatementLine.Type::"VAT Entry Totaling");
        VATStatementLine.Validate("Gen. Posting Type", GenPostingType);
        VATStatementLine.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        VATStatementLine.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        VATStatementLine.Validate("Amount Type", VATStatementLine."Amount Type"::Amount);
        VATStatementLine.Modify(true);
    end;

    local procedure CreatePurchaseOrder(var PurchaseHeader: Record "Purchase Header"; VATPostingSetup: Record "VAT Posting Setup")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, CreateVendor(VATPostingSetup));
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, CreateItem(VATPostingSetup), LibraryRandom.RandDec(100, 2));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(100, 2));
        PurchaseLine.Modify(true);
    end;

    local procedure CalculateBase(CustomerNo: Code[20]; EU3PartyTrade: Text[10]) TotalBase: Decimal
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.SetFilter("EU 3-Party Trade", EU3PartyTrade);
        FindVATEntry(VATEntry, CustomerNo);
        repeat
            TotalBase += VATEntry.Base;
        until VATEntry.Next = 0;
    end;

    local procedure CreateCustomer(var VATPostingSetup: Record "VAT Posting Setup"): Code[20]
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Customer.Modify(true);
        exit(Customer."No.");
    end;

    local procedure CreateItem(var VATPostingSetup: Record "VAT Posting Setup"): Code[20]
    var
        Item: Record Item;
    begin
        LibraryInventory.CreateItem(Item);
        Item.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        Item.Modify(true);
        exit(Item."No.");
    end;

    local procedure CreateSalesLine(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; Type: Option; No: Code[20])
    begin
        // Create Sales Document with Random Quantity and Unit Price.
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Type, No, LibraryRandom.RandDec(100, 2) * 100);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(100, 2));
        SalesLine.Modify(true);
    end;

    local procedure CreateVendor(var VATPostingSetup: Record "VAT Posting Setup"): Code[20]
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;

    local procedure CreateVATPostingSetupWithBlankVATBusPostingGroup(var VATPostingSetup: Record "VAT Posting Setup")
    var
        VATProductPostingGroup: Record "VAT Product Posting Group";
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);
        LibraryERM.CreateVATPostingSetup(VATPostingSetup, '', VATProductPostingGroup.Code); // Set VAT Bus. Posting Group to blank.
        VATPostingSetup.Validate("VAT Identifier", VATPostingSetup."VAT Prod. Posting Group");
        VATPostingSetup.Validate("VAT %", LibraryRandom.RandInt(10));
        VATPostingSetup.Validate("Purchase VAT Account", GLAccount."No.");
        VATPostingSetup.Validate("Sales VAT Account", GLAccount."No.");
        VATPostingSetup.Modify(true);
    end;

    local procedure FindVATEntry(var VATEntry: Record "VAT Entry"; BilltoPaytoNo: Code[20])
    begin
        VATEntry.SetRange("Bill-to/Pay-to No.", BilltoPaytoNo);
        VATEntry.SetRange(Type, VATEntry.Type::Sale);
        VATEntry.SetRange("Posting Date", WorkDate);
        VATEntry.FindSet;
    end;

    local procedure PostSalesOrderWithVATSetup(CustomerNo: Code[20]; EU3PartyTrade: Boolean; Type: Option; No: Code[20])
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, CustomerNo);
        SalesHeader.Validate("EU 3-Party Trade", EU3PartyTrade);
        SalesHeader.Modify(true);
        CreateSalesLine(SalesLine, SalesHeader, Type, No);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;

    local procedure SaveCalcAndPostVATSettlementReport(VATPostingSetup: Record "VAT Posting Setup"; DocumentNo: Code[20]; Post: Boolean)
    var
        GLAccount: Record "G/L Account";
        CalcAndPostVATSettlement: Report "Calc. and Post VAT Settlement";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        Clear(CalcAndPostVATSettlement);
        VATPostingSetup.SetRange("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        VATPostingSetup.SetRange("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        CalcAndPostVATSettlement.SetTableView(VATPostingSetup);
        CalcAndPostVATSettlement.InitializeRequest(WorkDate, WorkDate, WorkDate, DocumentNo, GLAccount."No.", false, Post);
        Commit;
        CalcAndPostVATSettlement.Run;
    end;

    local procedure SaveVATStatementReport(Name: Code[10]; Selection: Option; PeriodSelection: Option)
    var
        VATStatementLine: Record "VAT Statement Line";
        VATStatementName: Record "VAT Statement Name";
        VATStatement: Report "VAT Statement";
    begin
        Clear(VATStatement);
        VATStatementName.SetRange(Name, Name);
        VATStatement.SetTableView(VATStatementName);
        VATStatement.InitializeRequest(VATStatementName, VATStatementLine, Selection, PeriodSelection, false, false, '', ''); // NAVCZ
        Commit;
        VATStatement.Run;
    end;

    local procedure VATStatementForDifferentEntries(VATPostingSetup: Record "VAT Posting Setup"; EntryType: Option; Selection: Option; Closed: Boolean)
    var
        VATStatementLine: Record "VAT Statement Line";
        VATStatementTemplate: Record "VAT Statement Template";
        VATEntry: Record "VAT Entry";
        PeriodSelection: Option "Before and Within Period","Within Period";
        Amount: Decimal;
    begin
        // Calculate VAT Entry Amount according to entry type, Create VAT Statement Template and VAT Statement Line.
        Amount := CalculateVATEntryAmount(VATEntry, VATPostingSetup, EntryType, Closed);
        CreateVATStatementTemplateAndLine(VATStatementLine, VATPostingSetup, EntryType);

        // Exercise.
        SaveVATStatementReport(VATStatementLine."Statement Name", Selection, PeriodSelection::"Within Period");

        // Verify: Verify Amount on VAT Statement Report.
        LibraryReportDataset.LoadDataSetFile;
        LibraryReportDataset.SetRange('VatStmtLineRowNo', VATStatementLine."Row No.");
        if not LibraryReportDataset.GetNextRow then
            Error(StrSubstNo(NoDataRowErr, 'VatStmtLineRowNo', VATStatementLine."Row No."));
        LibraryReportDataset.AssertCurrentRowValueEquals('TotalAmount', Amount);

        // Tear Down: Delete VAT Statement Template created earlier.
        VATStatementTemplate.Get(VATStatementLine."Statement Template Name");
        VATStatementTemplate.Delete(true);
    end;

    local procedure VATVIESDeclarationTaxReport(CustomerVATRegistrationNo: Text[20])
    var
        VATVIESDeclarationTaxAuth: Report "VAT- VIES Declaration Tax Auth";
    begin
        Clear(VATVIESDeclarationTaxAuth);
        VATVIESDeclarationTaxAuth.InitializeRequest(false, WorkDate, WorkDate, CustomerVATRegistrationNo);
        VATVIESDeclarationTaxAuth.Run;
    end;

    local procedure VerifyValuesOnCalcAndPostVATSettlementReport(DocumentNo: Code[20])
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.SetRange("Document No.", DocumentNo);
        VATEntry.FindFirst;
        LibraryReportDataset.LoadDataSetFile;
        Assert.AreEqual(
          LibraryReportDataset.Sum('GenJnlLineVATBaseAmount'), -VATEntry.Base,
          SameAmountError);

        Assert.AreEqual(
          LibraryReportDataset.Sum('GenJnlLineVATAmount'), -VATEntry.Amount,
          SameAmountError);
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure RHVATStatement(var VATStatement: TestRequestPage "VAT Statement")
    begin
        VATStatement.SaveAsXml(LibraryReportDataset.GetParametersFileName, LibraryReportDataset.GetFileName)
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure RHCalcAndPostVATSettlement(var CalcAndPostVATSettlement: TestRequestPage "Calc. and Post VAT Settlement")
    begin
        CalcAndPostVATSettlement.SaveAsXml(LibraryReportDataset.GetParametersFileName, LibraryReportDataset.GetFileName)
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure RHVATVIESDeclaration(var VATVIESDeclaration: TestRequestPage "VAT- VIES Declaration Tax Auth")
    begin
        VATVIESDeclaration.SaveAsXml(LibraryReportDataset.GetParametersFileName, LibraryReportDataset.GetFileName)
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure PurchaseReceiptRequestPageHandler(var PurchaseReceipt: TestRequestPage "Purchase - Receipt")
    begin
        PurchaseReceipt.SaveAsXml(LibraryReportDataset.GetParametersFileName, LibraryReportDataset.GetFileName);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure VATStatementTemplateListModalPageHandler(var VATStatementTemplateList: TestPage "VAT Statement Template List")
    begin
        VATStatementTemplateList.FILTER.SetFilter(Name, LibraryVariableStorage.DequeueText);
        VATStatementTemplateList.OK.Invoke;
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure VATStatementExcelRPH(var VATStatement: TestRequestPage "VAT Statement")
    var
        FileName: Text;
    begin
        FileName := LibraryVariableStorage.DequeueText;
        LibraryReportValidation.SetFileName(FileName);
        LibraryReportValidation.SetFullFileName(FileName);
        VATStatement.SaveAsExcel(LibraryReportValidation.GetFileName);
    end;
}
