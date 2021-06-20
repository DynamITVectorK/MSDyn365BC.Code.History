codeunit 144015 "CODA Import Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryCODADataProvider: Codeunit "Library CODA Data Provider";
        LibraryERM: Codeunit "Library - ERM";
        BBLEURTxt: Label 'BBL-EUR', Locked = true;
        WWBEURTxt: Label 'WWB-EUR', Locked = true;
        NBLTxt: Label 'NBL', Locked = true;

    [Test]
    [HandlerFunctions('RequestPageHandlerPostCODAStatementLines')]
    [Scope('OnPrem')]
    procedure PostCODAStatement()
    var
        CODAStatement: Record "CODA Statement";
        BankAccount: Record "Bank Account";
        BankAccountPage: TestPage "Bank Account List";
        CODAStatementListPage: TestPage "CODA Statement List";
        CODAStatementPage: TestPage "CODA Statement";
    begin
        // CODA - Print one of multiple coda statement
        // http://vstfnav:8080/tfs/web/wi.aspx?pcguid=9a2ffec1-5411-458b-b788-8c4a5507644c&id=60073

        UpdateCompanyInformation('0058315707');
        UpdateBankAccountProtocol(BankAccount, 'NBL', '290', '1');
        UpdateElectronicBanking(true);

        Commit();

        BankAccountPage.OpenView;
        BankAccountPage.FILTER.SetFilter("No.", 'NBL');
        BankAccountPage."No.".Activate;
        DeleteAllCODALines;

        LibraryCODADataProvider.InsertSampleCODAStatement(CODAStatement, 'NBL');

        CODAStatement.FindFirst;

        LibraryVariableStorage.Clear;
        LibraryVariableStorage.Enqueue(false);
        LibraryVariableStorage.Enqueue(false);

        Commit();

        // Process CODA Statement Lines
        CODAStatementListPage.OpenView;
        CODAStatementListPage.First;
        CODAStatementPage.Trap;

        CODAStatementListPage.View.Invoke;

        CODAStatementPage."Process CODA Statement Lines".Invoke;

        CODAStatementPage.Close;

        // Validation
        LibraryCODADataProvider.ValidateSampleCODAStatement(CODAStatement);
    end;

    [Test]
    [HandlerFunctions('RequestPageHandlerPostCODAStatementLines,MessageHandler,ConfirmHandler,GeneralJournalTemplateListModalPageHandler')]
    [Scope('OnPrem')]
    procedure TransferCODAStatementsToGeneralLedger()
    var
        BankAccount: Record "Bank Account";
        CODAStatement: Record "CODA Statement";
        ImportCODAStatement: Report "Import CODA Statement";
        CODAStatementListPage: TestPage "CODA Statement List";
        CODAStatementPage: TestPage "CODA Statement";
        FinancialJournalPage: TestPage "Financial Journal";
    begin
        // Implementation of manual test case: CODA - Transfer of CODA Statements to General Ledger (Import CODA file)
        // http://vstfnav:8080/tfs/web/wi.aspx?pcguid=9a2ffec1-5411-458b-b788-8c4a5507644c&id=60126

        // Initialize Company
        UpdateCompanyInformation('0430018420');

        // Create a bank account for KBC
        CreateBankAccount(BankAccount, 'KBC', '725', '737010689443');

        // Create a new Journal Template
        CreateGeneralJournalTemplate(BankAccount."No.", 'Financial', 'Bank Account');

        // Update Vendor
        UpdateVendorBankAccount('50000', 'Test', '467538877123', true);

        // Electronic Banking Setup
        UpdateElectronicBanking(true);

        // Import CODA file
        DeleteAllCODALines;
        ImportCODAStatement.SetBankAcc(BankAccount);
        ImportCODAStatement.InitializeRequest(LibraryCODADataProvider.ImportMultipleStatementsToCODAstatementDataFiles(1));
        ImportCODAStatement.Run;

        Commit();

        Assert.AreEqual(1, CODAStatement.Count, 'Line count failed');

        CODAStatementListPage.OpenView;
        CODAStatementListPage.First;

        LibraryVariableStorage.Clear;
        LibraryVariableStorage.Enqueue(false); // Default application
        LibraryVariableStorage.Enqueue(false); // Dont print
        CODAStatementPage.Trap;
        CODAStatementListPage.View.Invoke;

        // validate the processed CODA Statement content
        CODAStatementPage."Process CODA Statement Lines".Invoke; // Process CODA Statement lines
        CODAStatementPage."Transfer to General Ledger".Invoke; // Transfer to general ledger
        CODAStatementPage.Close;

        // the Journal is selected in the modal page handler for page id 250.
        FinancialJournalPage.OpenEdit;
        Assert.AreEqual('KBC', FinancialJournalPage."Bal. Account No.".Value, 'Balance Account No');
        Assert.AreEqual('Vendor', FinancialJournalPage."Account Type".Value, 'Account Type');
        Assert.AreEqual(Format(1352.48), FinancialJournalPage.Amount.Value, 'Amount');
        FinancialJournalPage.Close;
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConfirmHandler')]
    [Scope('OnPrem')]
    procedure ImportMultipleStatementsToCODAstatement()
    var
        BankAccount: Record "Bank Account";
        CODAStatement: Record "CODA Statement";
        CODAStatementLine: Record "CODA Statement Line";
        ImportCODAStatement: Report "Import CODA Statement";
        StatementNo: Text;
    begin
        // Implementation of manual test case: CODA - Import multiple statements to CODA statement
        // http://vstfnav:8080/tfs/web/wi.aspx?pcguid=9a2ffec1-5411-458b-b788-8c4a5507644c&id=60072

        // Create a bank account for KBC
        UpdateCompanyInformation('0430018420');
        UpdateElectronicBanking(true);
        CreateBankAccount(BankAccount, 'KBC', '725', '737010689443');
        CreateGeneralJournalTemplate(BankAccount."No.", 'Financial', 'Bank Account');

        UpdateVendorBankAccount('50000', 'Test', '467538877123', false);

        DeleteAllCODALines;
        // Run the processing only report with the two data files.
        ImportCODAStatement.SetBankAcc(BankAccount);
        ImportCODAStatement.InitializeRequest(LibraryCODADataProvider.ImportMultipleStatementsToCODAstatementDataFiles(1));
        ImportCODAStatement.Run;

        ImportCODAStatement.SetBankAcc(BankAccount);
        ImportCODAStatement.InitializeRequest(LibraryCODADataProvider.ImportMultipleStatementsToCODAstatementDataFiles(2));
        ImportCODAStatement.Run;

        Commit();

        Assert.AreEqual(33, CODAStatement.Count, 'Line count failed');

        // Pick CODA statement 025 from the list and check selected values
        StatementNo := '025';
        CODAStatement.Get(BankAccount."No.", StatementNo);
        Assert.AreNearlyEqual(CODAStatement."Balance Last Statement", 291730.22, 1, 'Balance Last Statement');

        CODAStatementLine.SetFilter("Bank Account No.", BankAccount."No.");
        CODAStatementLine.SetFilter("Statement No.", StatementNo);
        Assert.AreEqual(4, CODAStatementLine.Count, 'CODA statement Lines count failed');
        CODAStatementLine.FindFirst;
        Assert.AreEqual(10000, CODAStatementLine."Statement Line No.", 'CODAStatementLine."Statement Line No.');
        Assert.AreEqual(CODAStatementLine.ID::Movement, CODAStatementLine.ID, 'CODAStatementLine.ID');
        Assert.AreEqual(CODAStatementLine.Type::Global, CODAStatementLine.Type, 'CODAStatementLine.Type');
        Assert.AreEqual('OL9407316JBBO', CODAStatementLine."Bank Reference No.", 'CODAStatementLine."Bank Reference No."');
        Assert.AreEqual('EUBCRECL', CODAStatementLine."Ext. Reference No.", 'CODAStatementLine."Ext. Reference No."');
        Assert.AreEqual(7408, CODAStatementLine."Statement Amount", 'CODAStatementLine."Statement Amount"');
        Assert.AreEqual(CODAStatementLine."Statement Amount", CODAStatementLine."Unapplied Amount",
          'CODAStatementLine."Unapplied Amount"');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure ImportAccountTypeIsBankAccountInTransactionCodingLine()
    var
        BankAccount: Record "Bank Account";
        CODAStatement: Record "CODA Statement";
    begin
        // CODA -Verify CODA statement line when Account Type is Bank Account in a transaction coding line
        // http://vstfnav:8080/tfs/web/wi.aspx?pcguid=9a2ffec1-5411-458b-b788-8c4a5507644c&id=60257
        FindBankAccount(BankAccount, BBLEURTxt);
        Commit();
        ImportCODAWithSpecificAccountType(BankAccount, 'Bank Account', BBLEURTxt);

        CODAStatement.FindFirst;
        Assert.AreEqual(1, CODAStatement.Count, 'Line count failed');
        Assert.AreEqual(BankAccount."No.", CODAStatement."Bank Account No.", 'BankAccount."No."');
        Assert.AreEqual('084', CODAStatement."Statement No.", '"Statement No."');
        Assert.AreEqual(748802.07, CODAStatement."Statement Ending Balance", '"Statement Ending Balance"');
        Assert.AreEqual(20090420D, CODAStatement."Statement Date", '"Statement Date"');
        Assert.AreEqual(746171.93, CODAStatement."Balance Last Statement", '"Balance Last Statement"');
        Assert.AreEqual(1, CODAStatement."CODA Statement No.", '"CODA Statement No."');
        Assert.AreEqual(0, CODAStatement.Information, 'Information');
    end;

    [Test]
    [HandlerFunctions('RequestPageHandlerPostCODAStatementLines,MessageHandler')]
    [Scope('OnPrem')]
    procedure ImportAccountTypeIsBlankInTransactionCodingLine()
    var
        BankAccount: Record "Bank Account";
        CODAStatement: Record "CODA Statement";
        CODAStatementLine: Record "CODA Statement Line";
        BankAccountPage: TestPage "Bank Account List";
        CODAStatementListPage: TestPage "CODA Statement List";
        CODAStatementPage: TestPage "CODA Statement";
        PostingDate: Date;
    begin
        // CODA -Verify CODA statement line when Account Type is Blank in a transaction coding line
        // http://vstfnav:8080/tfs/web/wi.aspx?pcguid=9a2ffec1-5411-458b-b788-8c4a5507644c&id=60261

        ImportCODAWithSpecificAccountType(BankAccount, '', '');

        CODAStatement.FindFirst;
        Assert.AreEqual(1, CODAStatement.Count, 'Line count failed');
        Assert.AreEqual(BankAccount."No.", CODAStatement."Bank Account No.", 'BankAccount."No."');
        Assert.AreEqual('084', CODAStatement."Statement No.", '"Statement No."');
        Assert.AreEqual(748802.07, CODAStatement."Statement Ending Balance", '"Statement Ending Balance"');
        Assert.AreEqual(20090420D, CODAStatement."Statement Date", '"Statement Date"');
        Assert.AreEqual(746171.93, CODAStatement."Balance Last Statement", '"Balance Last Statement"');
        Assert.AreEqual(1, CODAStatement."CODA Statement No.", '"CODA Statement No."');
        Assert.AreEqual(0, CODAStatement.Information, 'Information');

        // Pick CODA statement 084 from the list and check selected values

        CODAStatementLine.SetFilter("Bank Account No.", BankAccount."No.");
        CODAStatementLine.SetFilter("Statement No.", CODAStatement."Statement No.");
        Assert.AreEqual(4, CODAStatementLine.Count, 'CODA statement Lines count failed');
        CODAStatementLine.FindFirst;
        Assert.AreEqual(10000, CODAStatementLine."Statement Line No.", 'CODAStatementLine."Statement Line No.');
        Assert.AreEqual(CODAStatementLine.ID::Movement, CODAStatementLine.ID, 'CODAStatementLine.ID');
        Assert.AreEqual(CODAStatementLine.Type::Global, CODAStatementLine.Type, 'CODAStatementLine.Type');
        Assert.AreEqual(CODAStatementLine."Account Type"::"G/L Account", CODAStatementLine."Account Type",
          'CODAStatementLine."Account Type"');
        Assert.AreEqual('0000900000404        ', CODAStatementLine."Bank Reference No.", 'CODAStatementLine."Bank Reference No."');
        Assert.AreEqual('', CODAStatementLine."Ext. Reference No.", 'CODAStatementLine."Ext. Reference No."');
        Assert.AreEqual(2689.84, CODAStatementLine."Statement Amount", 'CODAStatementLine."Statement Amount"');
        Assert.AreEqual(CODAStatementLine."Statement Amount", CODAStatementLine."Unapplied Amount",
          'CODAStatementLine."Unapplied Amount"');

        // Process the data.
        CODAStatementListPage.Trap;
        BankAccountPage.OpenView;
        BankAccountPage.FILTER.SetFilter("No.", BankAccount."No.");
        BankAccountPage."No.".Activate;
        BankAccountPage."CODA S&tatements".Invoke;
        CODAStatementListPage.First;

        LibraryVariableStorage.Clear;
        LibraryVariableStorage.Enqueue(false); // Default application
        LibraryVariableStorage.Enqueue(false); // Dont print
        CODAStatementPage.Trap;
        CODAStatementListPage.View.Invoke;

        // validate the processed CODA Statement content
        CODAStatementPage."Process CODA Statement Lines".Invoke;
        CODAStatementPage.StmtLines.First;
        CODAStatementPage.StmtLines.Next;
        Assert.AreEqual(' ', CODAStatementPage.StmtLines."Application Status".Value, 'Application Status');
        Evaluate(PostingDate, Format(CODAStatementPage.StmtLines."Posting Date"));
        Assert.AreEqual(20090421D, PostingDate, 'Posting Date');
        Assert.AreEqual(' ', CODAStatementPage.StmtLines."Document Type".Value, 'Document Type');
        Assert.AreEqual('G/L Account', CODAStatementPage.StmtLines."Account Type".Value, 'Account Type');
        Assert.AreEqual(Format(0.0, 0, '<Precision,2:3><Standard Format,0>'),
          CODAStatementPage.StmtLines.Amount.Value, 'Amount');
        Assert.AreEqual(Format(-59.7, 0, '<Precision,2:3><Standard Format,0>'),
          CODAStatementPage.StmtLines."Statement Amount".Value, 'Statement Amount');
    end;

    [Test]
    [HandlerFunctions('RequestPageHandlerPostCODAStatementLines,MessageHandler')]
    [Scope('OnPrem')]
    procedure ImportAccountTypeIsCustomerInTransactionCodingLine()
    var
        BankAccount: Record "Bank Account";
        CODAStatement: Record "CODA Statement";
        BankAccountPage: TestPage "Bank Account List";
        CODAStatementListPage: TestPage "CODA Statement List";
        CODAStatementPage: TestPage "CODA Statement";
        PostingDate: Date;
    begin
        // CODA -Verify CODA statement line when Account Type is Customer in a transaction coding line
        // http://vstfnav:8080/tfs/web/wi.aspx?pcguid=9a2ffec1-5411-458b-b788-8c4a5507644c&id=60259

        ImportCODAWithSpecificAccountType(BankAccount, 'Customer', '60000');

        CODAStatement.FindFirst;
        Assert.AreEqual(1, CODAStatement.Count, 'Line count failed');
        Assert.AreEqual(BankAccount."No.", CODAStatement."Bank Account No.", 'BankAccount."No."');
        Assert.AreEqual('084', CODAStatement."Statement No.", '"Statement No."');
        Assert.AreEqual(748802.07, CODAStatement."Statement Ending Balance", '"Statement Ending Balance"');
        Assert.AreEqual(20090420D, CODAStatement."Statement Date", '"Statement Date"');
        Assert.AreEqual(746171.93, CODAStatement."Balance Last Statement", '"Balance Last Statement"');
        Assert.AreEqual(1, CODAStatement."CODA Statement No.", '"CODA Statement No."');
        Assert.AreEqual(0, CODAStatement.Information, 'Information');

        // Process the data.
        CODAStatementListPage.Trap;
        BankAccountPage.OpenView;
        BankAccountPage.FILTER.SetFilter("No.", BankAccount."No.");
        BankAccountPage."No.".Activate;
        BankAccountPage."CODA S&tatements".Invoke;
        CODAStatementListPage.First;

        LibraryVariableStorage.Clear;
        LibraryVariableStorage.Enqueue(false); // Default application
        LibraryVariableStorage.Enqueue(false); // Dont print
        CODAStatementPage.Trap;
        CODAStatementListPage.View.Invoke;

        // validate the processed CODA Statement content
        CODAStatementPage."Process CODA Statement Lines".Invoke;
        CODAStatementPage.StmtLines.First;
        CODAStatementPage.StmtLines.Next;
        Assert.AreEqual('Partly applied', CODAStatementPage.StmtLines."Application Status".Value, 'Application Status');
        Evaluate(PostingDate, Format(CODAStatementPage.StmtLines."Posting Date"));
        Assert.AreEqual(20090421D, PostingDate, 'Posting Date');
        Assert.AreEqual('Payment', CODAStatementPage.StmtLines."Document Type".Value, 'Document Type');
        Assert.AreEqual('Customer', CODAStatementPage.StmtLines."Account Type".Value, 'Account Type');
        Assert.AreEqual('60000', CODAStatementPage.StmtLines."Account No.".Value, 'Account No.');
        // ala Assert.AreEqual('Blanemark Hifi Shop',CODAStatementPage.StmtLines.Description.VALUE,'Description');
        Assert.AreEqual(Format(-59.7, 0, '<Precision,2:3><Standard Format,0>'),
          CODAStatementPage.StmtLines.Amount.Value, 'Amount');
    end;

    [Test]
    [HandlerFunctions('RequestPageHandlerPostCODAStatementLines,MessageHandler')]
    [Scope('OnPrem')]
    procedure ImportAccountTypeIsVendorInTransactionCodingLine()
    var
        BankAccount: Record "Bank Account";
        CODAStatement: Record "CODA Statement";
        BankAccountPage: TestPage "Bank Account List";
        CODAStatementListPage: TestPage "CODA Statement List";
        CODAStatementPage: TestPage "CODA Statement";
        PostingDate: Date;
    begin
        // CODA -Verify CODA statement line when Account Type is Vendor in a transaction coding line
        // http://vstfnav:8080/tfs/web/wi.aspx?pcguid=9a2ffec1-5411-458b-b788-8c4a5507644c&id=60258

        ImportCODAWithSpecificAccountType(BankAccount, 'Vendor', '62000');

        CODAStatement.FindFirst;
        Assert.AreEqual(1, CODAStatement.Count, 'Line count failed');
        Assert.AreEqual(BankAccount."No.", CODAStatement."Bank Account No.", 'BankAccount."No."');
        Assert.AreEqual('084', CODAStatement."Statement No.", '"Statement No."');
        Assert.AreEqual(748802.07, CODAStatement."Statement Ending Balance", '"Statement Ending Balance"');
        Assert.AreEqual(20090420D, CODAStatement."Statement Date", '"Statement Date"');
        Assert.AreEqual(746171.93, CODAStatement."Balance Last Statement", '"Balance Last Statement"');
        Assert.AreEqual(1, CODAStatement."CODA Statement No.", '"CODA Statement No."');
        Assert.AreEqual(0, CODAStatement.Information, 'Information');

        // Process the data.
        CODAStatementListPage.Trap;
        BankAccountPage.OpenView;
        BankAccountPage.FILTER.SetFilter("No.", BankAccount."No.");
        BankAccountPage."No.".Activate;
        BankAccountPage."CODA S&tatements".Invoke;
        CODAStatementListPage.FILTER.SetFilter("Bank Account No.", BankAccount."No.");

        LibraryVariableStorage.Clear;
        LibraryVariableStorage.Enqueue(false); // Default application
        LibraryVariableStorage.Enqueue(false); // Dont print
        CODAStatementPage.Trap;
        CODAStatementListPage.View.Invoke;

        // validate the processed CODA Statement content
        CODAStatementPage."Process CODA Statement Lines".Invoke;
        CODAStatementPage.StmtLines.First;
        CODAStatementPage.StmtLines.Next;
        Assert.AreEqual('Partly applied', CODAStatementPage.StmtLines."Application Status".Value, 'Application Status');
        Evaluate(PostingDate, Format(CODAStatementPage.StmtLines."Posting Date"));
        Assert.AreEqual(20090421D, PostingDate, 'Posting Date');
        Assert.AreEqual('Payment', CODAStatementPage.StmtLines."Document Type".Value, 'Document Type');
        Assert.AreEqual('Vendor', CODAStatementPage.StmtLines."Account Type".Value, 'Account Type');
        Assert.AreEqual('62000', CODAStatementPage.StmtLines."Account No.".Value, 'Account No.');
        Assert.AreEqual(Format(-59.7, 0, '<Precision,2:3><Standard Format,0>'),
          CODAStatementPage.StmtLines.Amount.Value, 'Amount');
    end;

    [Test]
    [HandlerFunctions('RequestPageHandlerPostCODAStatementLines,MessageHandler')]
    [Scope('OnPrem')]
    procedure ImportAccountTypeIsGLAccountInTransactionCodingLine()
    var
        BankAccount: Record "Bank Account";
        CODAStatement: Record "CODA Statement";
        GLAccount: Record "G/L Account";
        BankAccountPage: TestPage "Bank Account List";
        CODAStatementListPage: TestPage "CODA Statement List";
        CODAStatementPage: TestPage "CODA Statement";
        PostingDate: Date;
    begin
        // CODA -Verify CODA statement line when Account Type is G/L Account in a transaction coding line
        // http://vstfnav:8080/tfs/web/wi.aspx?pcguid=9a2ffec1-5411-458b-b788-8c4a5507644c&id=60260

        ImportCODAWithSpecificAccountType(BankAccount, 'G/L Account', '499999');

        CODAStatement.FindFirst;
        Assert.AreEqual(1, CODAStatement.Count, 'Line count failed');
        Assert.AreEqual(BankAccount."No.", CODAStatement."Bank Account No.", 'BankAccount."No."');
        Assert.AreEqual('084', CODAStatement."Statement No.", '"Statement No."');
        Assert.AreEqual(748802.07, CODAStatement."Statement Ending Balance", '"Statement Ending Balance"');
        Assert.AreEqual(20090420D, CODAStatement."Statement Date", '"Statement Date"');
        Assert.AreEqual(746171.93, CODAStatement."Balance Last Statement", '"Balance Last Statement"');
        Assert.AreEqual(1, CODAStatement."CODA Statement No.", '"CODA Statement No."');
        Assert.AreEqual(0, CODAStatement.Information, 'Information');

        // Process the data.
        CODAStatementListPage.Trap;
        BankAccountPage.OpenView;
        BankAccountPage.FILTER.SetFilter("No.", BankAccount."No.");
        BankAccountPage."No.".Activate;
        BankAccountPage."CODA S&tatements".Invoke;
        CODAStatementListPage.FILTER.SetFilter("Bank Account No.", BankAccount."No.");

        LibraryVariableStorage.Clear;
        LibraryVariableStorage.Enqueue(false); // Default application
        LibraryVariableStorage.Enqueue(false); // Dont print
        CODAStatementPage.Trap;
        CODAStatementListPage.View.Invoke;

        // validate the processed CODA Statement content
        CODAStatementPage."Process CODA Statement Lines".Invoke;
        CODAStatementPage.StmtLines.First;
        CODAStatementPage.StmtLines.Next;
        Assert.AreEqual('Partly applied', CODAStatementPage.StmtLines."Application Status".Value, 'Application Status');
        Evaluate(PostingDate, Format(CODAStatementPage.StmtLines."Posting Date"));
        Assert.AreEqual(20090421D, PostingDate, 'Posting Date');
        Assert.AreEqual('G/L Account', CODAStatementPage.StmtLines."Account Type".Value, 'Account Type');
        Assert.AreEqual('499999', CODAStatementPage.StmtLines."Account No.".Value, 'Account No.');
        GLAccount.Get('499999');
        Assert.AreEqual(GLAccount.Name, CODAStatementPage.StmtLines.Description.Value, 'Description');
        Assert.AreEqual(Format(-59.7, 0, '<Precision,2:3><Standard Format,0>'),
          CODAStatementPage.StmtLines.Amount.Value, 'Amount');
    end;

    [Test]
    [HandlerFunctions('RequestPageHandlerPostCODAStatementLines,MessageHandler')]
    [Scope('OnPrem')]
    procedure PrintOneOfMultipleCODAStatements()
    var
        BankAccount: Record "Bank Account";
        CODAStatement: Record "CODA Statement";
        ImportCODAStatement: Report "Import CODA Statement";
        CODAStatementListPage: TestPage "CODA Statement List";
        CODAStatementPage: TestPage "CODA Statement";
    begin
        // CODA - Print one of multiple coda statement
        // http://vstfnav:8080/tfs/web/wi.aspx?pcguid=9a2ffec1-5411-458b-b788-8c4a5507644c&id=60073

        UpdateCompanyInformation('0058315707');
        FindBankAccount(BankAccount, NBLTxt);
        UpdateBankAccountProtocol(BankAccount, NBLTxt, '290', '1');
        BankAccount."Bank Account No." := '290004614187';
        BankAccount.Modify();
        Commit();
        UpdateElectronicBanking(true);

        Commit();

        // Run the processing only report with the data file.
        DeleteAllCODALines;
        ImportCODAStatement.SetBankAcc(BankAccount);
        ImportCODAStatement.InitializeRequest(LibraryCODADataProvider.PrintOneOfMultipleCODAStatementsDataFile);
        ImportCODAStatement.Run;

        Commit();

        CODAStatement.FindFirst;
        Assert.AreEqual(33, CODAStatement.Count, 'Line count failed');

        // Process CODA Statement Lines
        CODAStatementListPage.OpenView;
        CODAStatementListPage.First;
        CODAStatementPage.Trap;

        LibraryVariableStorage.Clear;
        LibraryVariableStorage.Enqueue(true);
        LibraryVariableStorage.Enqueue(true);
        CODAStatementListPage.View.Invoke;

        // TODO : This action exposes a productbug. This test should continue on to
        // validate the processed CODA Statement content
        asserterror CODAStatementPage."Process CODA Statement Lines".Invoke;
    end;

    [Test]
    [HandlerFunctions('RequestPageHandlerPostCODAStatementLines,MessageHandler')]
    [Scope('OnPrem')]
    procedure VerifyPostingOfCODAStatementLines()
    var
        BankAccount: Record "Bank Account";
        ImportCODAStatement: Report "Import CODA Statement";
        CODAStatementListPage: TestPage "CODA Statement List";
        CODAStatementPage: TestPage "CODA Statement";
    begin
        // Implementation of manual test case: CODA - Verify the process of posting CODA statement lines
        // http://vstfnav:8080/tfs/web/wi.aspx?pcguid=9a2ffec1-5411-458b-b788-8c4a5507644c&id=60154

        // Create a bankaccount for KBC
        UpdateCompanyInformation('0477997984');
        UpdateElectronicBanking(true);

        // Update bank account information
        FindBankAccount(BankAccount, WWBEURTxt);
        BankAccount."Bank Account No." := '734020020001';
        BankAccount."Protocol No." := '725';
        BankAccount."Version Code" := '2';
        BankAccount."Bank Branch No." := '734';
        BankAccount."SWIFT Code" := 'KREDBEBB';
        BankAccount.Modify();

        // Run the processing only report with the two data files.
        DeleteAllCODALines;
        ImportCODAStatement.SetBankAcc(BankAccount);
        ImportCODAStatement.InitializeRequest(LibraryCODADataProvider.OntVangenCODA20090416DataFile);
        ImportCODAStatement.Run;

        Commit();

        CODAStatementListPage.OpenView;
        CODAStatementListPage.First;

        LibraryVariableStorage.Clear;
        LibraryVariableStorage.Enqueue(false); // Default application
        LibraryVariableStorage.Enqueue(false); // Dont print
        CODAStatementPage.Trap;
        CODAStatementListPage.View.Invoke;

        // validate the processed CODA Statement content
        CODAStatementPage."Process CODA Statement Lines".Invoke; // Process CODA Statement lines
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure RequestPageHandlerPostCODAStatementLines(var PostCODAStatementLines: TestRequestPage "Post CODA Stmt. Lines")
    var
        Variant: Variant;
    begin
        LibraryVariableStorage.Dequeue(Variant);
        PostCODAStatementLines.DefaultApplication.SetValue(Variant); // DefaultApplication
        LibraryVariableStorage.Dequeue(Variant);
        PostCODAStatementLines.PrintReport.SetValue(Variant); // PrintReport

        PostCODAStatementLines.OK.Invoke;
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandler(Question: Text[1024]; var returnValue: Boolean)
    begin
        returnValue := true;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure GeneralJournalTemplateListModalPageHandler(var GeneralJournalTemplateListPage: TestPage "General Journal Template List")
    begin
        GeneralJournalTemplateListPage.FILTER.SetFilter(Name, 'KBC');
        GeneralJournalTemplateListPage.OK.Invoke;
    end;

    [Normal]
    local procedure CreateBankAccount(var BankAccount: Record "Bank Account"; AccountName: Code[10]; BranchId: Text[20]; BankAccountNo: Text[30])
    begin
        if not BankAccount.Get(AccountName) then begin
            BankAccount.Init();
            BankAccount."No." := AccountName;
            BankAccount.Name := AccountName;
            BankAccount."Bank Account No." := BankAccountNo;
            BankAccount."Bank Branch No." := BranchId;
            BankAccount."Protocol No." := CopyStr(BranchId, 1, MaxStrLen(BankAccount."Protocol No."));
            BankAccount."Version Code" := '1';
            BankAccount.Insert();
        end;
    end;

    [Normal]
    local procedure FindBankAccount(var BankAccount: Record "Bank Account"; BankAccountNo: Text)
    var
        NewBankAccount: Record "Bank Account";
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        if NewBankAccount.Get(Format(BankAccountNo)) then
            NewBankAccount.Delete();
        NewBankAccount := BankAccount;
        NewBankAccount."No." := Format(CopyStr(BankAccountNo, 1, MaxStrLen(BankAccount."No.")));
        NewBankAccount.Insert();
        BankAccount := NewBankAccount;
    end;

    [Normal]
    local procedure UpdateBankAccountProtocol(var BankAccount: Record "Bank Account"; AccountName: Text; Protocol: Text[3]; Version: Text[1])
    begin
        if BankAccount.Get(AccountName) then begin
            BankAccount."Protocol No." := Protocol;
            BankAccount."Version Code" := Version;
            BankAccount.Modify();
        end;
    end;

    [Normal]
    local procedure CreateGeneralJournalTemplate(Name: Text; Type: Text; BalanceAccountType: Text)
    var
        GeneralJournalTemplate: TestPage "General Journal Templates";
    begin
        GeneralJournalTemplate.OpenView;
        if GeneralJournalTemplate.GotoKey(Name) then
            GeneralJournalTemplate.Edit.Invoke
        else
            GeneralJournalTemplate.New;

        GeneralJournalTemplate.Name.SetValue := Name;
        GeneralJournalTemplate.Description.SetValue := Name;
        GeneralJournalTemplate.Type.SetValue := Type;
        GeneralJournalTemplate."Bal. Account Type".SetValue := BalanceAccountType;
        GeneralJournalTemplate."Bal. Account No.".SetValue := Name;
        GeneralJournalTemplate.OK.Invoke;
    end;

    [Normal]
    local procedure UpdateCompanyInformation(InterpriseNo: Text)
    var
        CompanyInformation: TestPage "Company Information";
    begin
        CompanyInformation.OpenEdit;
        CompanyInformation."Country/Region Code".SetValue := 'BE';
        CompanyInformation."VAT Registration No.".SetValue := '';
        CompanyInformation."Enterprise No.".SetValue := InterpriseNo;
        CompanyInformation.OK.Invoke;
    end;

    [Normal]
    local procedure UpdateElectronicBanking(SummarizeGeneralJournal: Boolean)
    var
        ElectronicBankingSetup: TestPage "Electronic Banking Setup";
    begin
        ElectronicBankingSetup.OpenEdit;
        ElectronicBankingSetup."Summarize Gen. Jnl. Lines".SetValue := SummarizeGeneralJournal;
        ElectronicBankingSetup.OK.Invoke;
    end;

    [Normal]
    local procedure UpdateVendorBankAccount(VendorNo: Code[20]; "Code": Code[10]; AccountNo: Text[30]; UpdatePreferredAccount: Boolean)
    var
        VendorBankAccount: Record "Vendor Bank Account";
        VendorListPage: TestPage "Vendor List";
        VendorCardPage: TestPage "Vendor Card";
    begin
        if VendorBankAccount.Get(VendorNo, Code) then begin
            VendorBankAccount.Validate("Bank Account No.", AccountNo);
            VendorBankAccount.Modify(true);
        end else begin
            VendorBankAccount.Init();
            VendorBankAccount.Validate("Vendor No.", VendorNo);
            VendorBankAccount.Validate(Code, Code);
            VendorBankAccount.Validate("Bank Account No.", AccountNo);
            VendorBankAccount.Insert(true);
        end;

        if UpdatePreferredAccount then begin
            Commit();

            VendorListPage.OpenView;
            VendorListPage.FILTER.SetFilter("No.", VendorNo);
            VendorListPage.First;

            VendorCardPage.Trap;
            VendorListPage.Edit.Invoke;
            VendorCardPage."Preferred Bank Account Code".SetValue(Code);
            VendorCardPage.OK.Invoke;
        end;
    end;

    [Normal]
    local procedure DeleteAllCODALines()
    var
        CODAStatement: Record "CODA Statement";
        CODAStatementLine: Record "CODA Statement Line";
        CODAStatementSourceLine: Record "CODA Statement Source Line";
    begin
        if not CODAStatement.IsEmpty then
            CODAStatement.DeleteAll(true);

        if not CODAStatementLine.IsEmpty then
            CODAStatementLine.DeleteAll(true);

        if not CODAStatementSourceLine.IsEmpty then
            CODAStatementSourceLine.DeleteAll(true);

        Commit();
    end;

    [Normal]
    local procedure ImportCODAWithSpecificAccountType(var BankAccount: Record "Bank Account"; AccountType: Text; TransactionAccountNo: Code[20])
    var
        TransactionCoding: Record "Transaction Coding";
        ImportCODAStatement: Report "Import CODA Statement";
    begin
        UpdateCompanyInformation('0448825928');

        BankAccount.Reset();
        Clear(BankAccount);
        // Update bank account for WWB-EUR
        if BankAccount.Get(BBLEURTxt) then begin
            BankAccount."Protocol No." := '200';
            BankAccount."Version Code" := '2';
            BankAccount."Bank Account No." := '230002155541';
            BankAccount."SWIFT Code" := 'GEBABEBB';
            BankAccount.Modify();
        end;

        TransactionCoding.DeleteAll();
        TransactionCoding.Init();
        TransactionCoding."Bank Account No." := '';
        TransactionCoding."Transaction Family" := 4;
        TransactionCoding.Transaction := 2;
        TransactionCoding."Transaction Category" := 0;
        TransactionCoding."Globalisation Code" := TransactionCoding."Globalisation Code"::Global;
        Evaluate(TransactionCoding."Account Type", AccountType);
        TransactionCoding."Account No." := TransactionAccountNo;

        TransactionCoding.Insert();

        UpdateElectronicBanking(false);

        Commit();

        // Run the processing only report with the data file.
        DeleteAllCODALines;
        ImportCODAStatement.SetBankAcc(BankAccount);
        ImportCODAStatement.InitializeRequest(LibraryCODADataProvider.ImportAccountTypeTestDataFile);
        ImportCODAStatement.Run;

        Commit();
    end;
}
