codeunit 12184 "Fattura Doc. Helper"
{

    trigger OnRun()
    begin
    end;

    var
        CompanyInformation: Record "Company Information";
        ErrorMessage: Record "Error Message";
        IsInitialized: Boolean;
        CustomerNoFieldNo: Integer;
        PaymentMethodCodeFieldNo: Integer;
        PaymentTermsCodeFieldNo: Integer;
        CurrencyCodeFieldNo: Integer;
        CurrencyFactorFieldNo: Integer;
        InvoiceDiscountAmountFieldNo: Integer;
        QuantityFieldNo: Integer;
        DocNoFieldNo: Integer;
        VatPercFieldNo: Integer;
        LineNoFieldNo: Integer;
        LineTypeFieldNo: Integer;
        NoFieldNo: Integer;
        DescriptionFieldNo: Integer;
        UnitOfMeasureFieldNo: Integer;
        UnitPriceFieldNo: Integer;
        LineDiscountPercFieldNo: Integer;
        LineInvDiscAmountFieldNo: Integer;
        LineAmountFieldNo: Integer;
        LineAmountIncludingVATFieldNo: Integer;
        VATProdPostingGroupCodeFieldNo: Integer;
        VATBusPostingGroupCodeFieldNo: Integer;
        FatturaProjectCodeFieldNo: Integer;
        FatturaTenderCodeFieldNo: Integer;
        CustomerPurchaseOrderFieldNo: Integer;
        ShipmentNoFieldNo: Integer;
        AttachedToLineNoFieldNo: Integer;
        OrderNoFieldNo: Integer;
        PrepaymentInvoiceFieldNo: Integer;
        FatturaStampFieldNo: Integer;
        FatturaStampAmountFieldNo: Integer;
        MissingLinesErr: Label 'The document must contain lines in order to be sent through FatturaPA.';
        TxtTok: Label 'TXT%1', Locked = true;
        ExemptionDataMsg: Label '%1 del %2.', Locked = true;
        VATExemptionPrefixTok: Label 'Dich.Intento n.', Locked = true;
        NonPublicCompanyLbl: Label 'FPR12', Locked = true;
        BasicVATTypeLbl: Label 'I', Locked = true;
        ReverseChargeVATDescrLbl: Label 'Reverse Charge VAT %1', Comment = '%1 = VAT percent';

    [Scope('OnPrem')]
    procedure CollectDocumentInformation(var TempFatturaHeader: Record "Fattura Header" temporary; var TempFatturaLine: Record "Fattura Line" temporary; HeaderRecRef: RecordRef)
    var
        LineRecRef: RecordRef;
    begin
        CompanyInformation.Get;
        if not CollectDocHeaderInformation(TempFatturaHeader, LineRecRef, HeaderRecRef) then
            exit;

        CollectDocLinesInformation(TempFatturaLine, LineRecRef, TempFatturaHeader);
        CollectPaymentInformation(TempFatturaLine, TempFatturaHeader);
    end;

    local procedure CollectDocHeaderInformation(var TempFatturaHeader: Record "Fattura Header" temporary; var LineRecRef: RecordRef; HeaderRecRef: RecordRef): Boolean
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Customer: Record Customer;
    begin
        Initialize;
        Customer.Get(HeaderRecRef.Field(CustomerNoFieldNo).Value);

        TempFatturaHeader.Init;
        TempFatturaHeader."Customer No" := Customer."No.";
        TempFatturaHeader."Document No." := Format(HeaderRecRef.Field(DocNoFieldNo).Value);
        TempFatturaHeader."Payment Method Code" := HeaderRecRef.Field(PaymentMethodCodeFieldNo).Value;
        TempFatturaHeader."Payment Terms Code" := HeaderRecRef.Field(PaymentTermsCodeFieldNo).Value;
        if not InitFatturaHeaderWithCheck(TempFatturaHeader, LineRecRef, HeaderRecRef) then
            exit(false);

        if TempFatturaHeader."Entry Type" = TempFatturaHeader."Entry Type"::Sales then
            Evaluate(TempFatturaHeader.Prepayment, Format(HeaderRecRef.Field(PrepaymentInvoiceFieldNo).Value));
        TempFatturaHeader."Fattura Document Type" := GetTipoDocumento(TempFatturaHeader, Customer);
        if TempFatturaHeader."Document Type" = TempFatturaHeader."Document Type"::Invoice then begin
            TempFatturaHeader."Order No." := Format(HeaderRecRef.Field(OrderNoFieldNo).Value);
            TempFatturaHeader."Customer Purchase Order No." := HeaderRecRef.Field(CustomerPurchaseOrderFieldNo).Value;
        end;

        GeneralLedgerSetup.Get;
        TempFatturaHeader."Currency Code" := Format(HeaderRecRef.Field(CurrencyCodeFieldNo));
        TempFatturaHeader."Currency Factor" := HeaderRecRef.Field(CurrencyFactorFieldNo).Value;

        TempFatturaHeader."Fattura Stamp" := HeaderRecRef.Field(FatturaStampFieldNo).Value;
        TempFatturaHeader."Fattura Stamp Amount" := HeaderRecRef.Field(FatturaStampAmountFieldNo).Value;
        TempFatturaHeader."Fattura Project Code" := HeaderRecRef.Field(FatturaTenderCodeFieldNo).Value;
        TempFatturaHeader."Fattura Tender Code" := HeaderRecRef.Field(FatturaProjectCodeFieldNo).Value;
        TempFatturaHeader."Transmission Type" := GetTransmissionType(Customer);

        TempFatturaHeader."Progressive No." := GetNextProgressiveNo;
        UpdateFatturaHeaderWithDiscountInformation(TempFatturaHeader, LineRecRef, HeaderRecRef);
        UpdateFattureHeaderWithApplicationInformation(TempFatturaHeader);
        UpdateFatturaHeaderWithTaxRepresentativeInformation(TempFatturaHeader);
        TempFatturaHeader.Insert;
        exit(true);
    end;

    local procedure CollectDocLinesInformation(var TempFatturaLine: Record "Fattura Line" temporary; var LineRecRef: RecordRef; TempFatturaHeader: Record "Fattura Header" temporary)
    var
        TempSalesShipmentBuffer: Record "Sales Shipment Buffer" temporary;
        TempVATEntry: Record "VAT Entry" temporary;
        TempVATPostingSetup: Record "VAT Posting Setup" temporary;
        IsSplitPayment: Boolean;
        DocLineNo: Integer;
    begin
        CollectShipmentInfo(TempSalesShipmentBuffer, LineRecRef, TempFatturaHeader);
        BuildOrderDataBuffer(TempFatturaLine, TempSalesShipmentBuffer, TempFatturaHeader);
        BuildShipmentDataBuffer(TempFatturaLine, TempSalesShipmentBuffer);
        LineRecRef.FindSet;
        repeat
            if not IsSplitPaymentLine(LineRecRef) then
                InsertFatturaLine(TempFatturaLine, DocLineNo, TempFatturaHeader, LineRecRef);
        until LineRecRef.Next = 0;

        CollectVATOnLines(TempVATEntry, TempVATPostingSetup, TempFatturaHeader);
        TempVATEntry.Reset;
        if TempVATEntry.FindSet then begin
            IsSplitPayment := HasSplitPayment(LineRecRef);
            Clear(TempFatturaLine);
            TempFatturaLine."Line Type" := TempFatturaLine."Line Type"::VAT;
            repeat
                if not IsSplitVATEntry(TempVATEntry) then
                    InsertVATFatturaLine(
                      TempFatturaLine, TempFatturaHeader."Document Type" = TempFatturaHeader."Document Type"::Invoice,
                      TempVATEntry, TempFatturaHeader."Customer No", IsSplitPayment);
            until TempVATEntry.Next = 0;
        end;
    end;

    local procedure CollectPaymentInformation(var TempFatturaLine: Record "Fattura Line" temporary; TempFatturaHeader: Record "Fattura Header" temporary)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if (TempFatturaHeader."Payment Method Code" = '') or
           (TempFatturaHeader."Payment Terms Code" = '')
        then
            exit;

        FindCustLedgEntry(CustLedgerEntry, TempFatturaHeader);
        Clear(TempFatturaLine);
        TempFatturaLine."Line Type" := TempFatturaLine."Line Type"::Payment;
        repeat
            TempFatturaLine."Line No." += 1;
            TempFatturaLine."Due Date" := CustLedgerEntry."Due Date";
            CustLedgerEntry.CalcFields("Amount (LCY)");
            TempFatturaLine.Amount := CustLedgerEntry."Amount (LCY)";
            TempFatturaLine.Insert;
        until CustLedgerEntry.Next = 0;
    end;

    [Scope('OnPrem')]
    procedure CollectSelfBillingDocInformation(var TempFatturaHeader: Record "Fattura Header" temporary; var TempFatturaLine: Record "Fattura Line" temporary; var TempVATEntry: Record "VAT Entry" temporary)
    begin
        CompanyInformation.Get;
        CheckCompanyInformationFields(ErrorMessage);
        CheckFatturaPANos(ErrorMessage);
        if HasErrors then
            exit;

        Initialize;

        TempFatturaHeader.Init;
        TempFatturaHeader."Entry Type" := TempFatturaHeader."Entry Type"::Sales;
        TempFatturaHeader."Document Type" := TempVATEntry."Document Type"::Invoice;
        TempFatturaHeader."Posting Date" := TempVATEntry."Posting Date";
        TempFatturaHeader."Document No." := TempVATEntry."Document No.";
        TempFatturaHeader."Progressive No." := GetNextProgressiveNo;
        TempFatturaHeader."Transmission Type" := NonPublicCompanyLbl;
        TempFatturaHeader."Fattura Document Type" := GetDefaultFatturaDocType;
        TempVATEntry.CalcSums(Amount);
        TempFatturaHeader."Total Amount" := TempVATEntry.Amount;
        TempFatturaHeader.Insert;
        CollectSelfBillingDocLinesInformation(TempFatturaLine, TempVATEntry);
    end;

    local procedure CollectSelfBillingDocLinesInformation(var TempFatturaLine: Record "Fattura Line" temporary; var TempVATEntry: Record "VAT Entry" temporary)
    begin
        with TempVATEntry do begin
            SetCurrentKey(
              "Document No.", Type, "VAT Bus. Posting Group", "VAT Prod. Posting Group",
              "VAT %", "Deductible %", "VAT Identifier", "Transaction No.", "Unrealized VAT Entry No.");
            FindSet;
            TempFatturaLine.Init;
            TempFatturaLine.Quantity := 1;
            repeat
                SetRange("VAT Bus. Posting Group", "VAT Bus. Posting Group");
                SetRange("VAT Prod. Posting Group", "VAT Prod. Posting Group");
                CalcSums(Base, Amount);

                TempFatturaLine."Line Type" := TempFatturaLine."Line Type"::Document;
                TempFatturaLine.Description := StrSubstNo(ReverseChargeVATDescrLbl, "VAT %");
                TempFatturaLine."Line No." += 1;
                TempFatturaLine."Unit Price" := -Base;
                TempFatturaLine.Amount := TempFatturaLine."Unit Price";
                TempFatturaLine."VAT %" := "VAT %";
                TempFatturaLine.Insert;

                TempFatturaLine."Line Type" := TempFatturaLine."Line Type"::VAT;
                TempFatturaLine."VAT Base" := TempFatturaLine.Amount;
                TempFatturaLine."VAT Amount" := -Amount;
                TempFatturaLine.Description := BasicVATTypeLbl;
                TempFatturaLine.Insert;

                FindLast;
                SetRange("VAT Bus. Posting Group");
                SetRange("VAT Prod. Posting Group");
            until Next = 0;
        end;
    end;

    local procedure Initialize()
    begin
        CompanyInformation.Get;
        if IsInitialized then
            exit;

        // field id of the Header tables
        CustomerNoFieldNo := 4;
        PaymentTermsCodeFieldNo := 23;
        PaymentMethodCodeFieldNo := 104;
        CurrencyCodeFieldNo := 32;
        CurrencyFactorFieldNo := 33;
        InvoiceDiscountAmountFieldNo := 1305;
        DocNoFieldNo := 3;
        FatturaProjectCodeFieldNo := 12182;
        FatturaTenderCodeFieldNo := 12183;
        CustomerPurchaseOrderFieldNo := 12184;

        // field id of Line tables
        QuantityFieldNo := 15;
        LineAmountIncludingVATFieldNo := 30;
        VatPercFieldNo := 25;
        LineNoFieldNo := 4;
        LineTypeFieldNo := 5;
        NoFieldNo := 6;
        DescriptionFieldNo := 11;
        UnitOfMeasureFieldNo := 13;
        UnitPriceFieldNo := 22;
        LineAmountFieldNo := 103;
        LineDiscountPercFieldNo := 27;
        LineInvDiscAmountFieldNo := 69;
        VATBusPostingGroupCodeFieldNo := 89;
        VATProdPostingGroupCodeFieldNo := 90;
        ShipmentNoFieldNo := 63;
        AttachedToLineNoFieldNo := 80;
        OrderNoFieldNo := 44;
        PrepaymentInvoiceFieldNo := 136;
        FatturaStampFieldNo := 12185;
        FatturaStampAmountFieldNo := 12186;

        IsInitialized := true;
    end;

    [Scope('OnPrem')]
    procedure InitializeErrorLog(ContextRecordVariant: Variant)
    begin
        ErrorMessage.SetContext(ContextRecordVariant);
        ErrorMessage.ClearLog;
    end;

    [Scope('OnPrem')]
    procedure HasErrors(): Boolean
    begin
        exit(ErrorMessage.HasErrors(false));
    end;

    local procedure InitFatturaHeaderWithCheck(var TempFatturaHeader: Record "Fattura Header" temporary; var LineRecRef: RecordRef; HeaderRecRef: RecordRef): Boolean
    var
        PaymentTerms: Record "Payment Terms";
        PaymentMethod: Record "Payment Method";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        FieldRef: FieldRef;
    begin
        CheckMandatoryFields(HeaderRecRef, ErrorMessage);
        if PaymentMethod.Get(TempFatturaHeader."Payment Method Code") and
           PaymentTerms.Get(TempFatturaHeader."Payment Terms Code")
        then begin
            TempFatturaHeader."Fattura PA Payment Method" := PaymentMethod."Fattura PA Payment Method";
            TempFatturaHeader."Fattura Payment Terms Code" := PaymentTerms."Fattura Payment Terms Code";
        end;
        case HeaderRecRef.Number of
            DATABASE::"Sales Invoice Header":
                begin
                    HeaderRecRef.SetTable(SalesInvoiceHeader);
                    SalesInvoiceHeader.CalcFields("Amount Including VAT", "Invoice Discount Amount");
                    CheckSalesInvHeaderFields(SalesInvoiceHeader, PaymentMethod);
                    TempFatturaHeader."Entry Type" := TempFatturaHeader."Entry Type"::Sales;
                    TempFatturaHeader."Document Type" := CustLedgerEntry."Document Type"::Invoice;
                    TempFatturaHeader."Posting Date" := SalesInvoiceHeader."Posting Date";
                    TempFatturaHeader."Document No." := SalesInvoiceHeader."No.";
                    LineRecRef.Open(DATABASE::"Sales Invoice Line");
                end;
            DATABASE::"Service Invoice Header":
                begin
                    HeaderRecRef.SetTable(ServiceInvoiceHeader);
                    ServiceInvoiceHeader.CalcFields("Amount Including VAT");
                    CheckServiceInvHeaderFields(ServiceInvoiceHeader, PaymentMethod);
                    TempFatturaHeader."Entry Type" := TempFatturaHeader."Entry Type"::Service;
                    TempFatturaHeader."Document Type" := CustLedgerEntry."Document Type"::Invoice;
                    TempFatturaHeader."Posting Date" := ServiceInvoiceHeader."Posting Date";
                    TempFatturaHeader."Document No." := ServiceInvoiceHeader."No.";
                    LineRecRef.Open(DATABASE::"Service Invoice Line");
                end;
            DATABASE::"Sales Cr.Memo Header":
                begin
                    HeaderRecRef.SetTable(SalesCrMemoHeader);
                    SalesCrMemoHeader.CalcFields("Amount Including VAT", "Invoice Discount Amount");
                    CheckSalesCrMemoHeaderFields(SalesCrMemoHeader, PaymentMethod);
                    TempFatturaHeader."Entry Type" := TempFatturaHeader."Entry Type"::Sales;
                    TempFatturaHeader."Document Type" := CustLedgerEntry."Document Type"::"Credit Memo";
                    TempFatturaHeader."Posting Date" := SalesCrMemoHeader."Posting Date";
                    TempFatturaHeader."Document No." := SalesCrMemoHeader."No.";
                    LineRecRef.Open(DATABASE::"Sales Cr.Memo Line");
                end;
            DATABASE::"Service Cr.Memo Header":
                begin
                    HeaderRecRef.SetTable(ServiceCrMemoHeader);
                    ServiceCrMemoHeader.CalcFields("Amount Including VAT");
                    CheckServiceCrMemoHeaderFields(ServiceCrMemoHeader, PaymentMethod);
                    TempFatturaHeader."Entry Type" := TempFatturaHeader."Entry Type"::Service;
                    TempFatturaHeader."Document Type" := CustLedgerEntry."Document Type"::"Credit Memo";
                    TempFatturaHeader."Posting Date" := ServiceCrMemoHeader."Posting Date";
                    TempFatturaHeader."Document No." := ServiceCrMemoHeader."No.";
                    LineRecRef.Open(DATABASE::"Service Cr.Memo Line");
                end;
        end;

        FieldRef := LineRecRef.Field(DocNoFieldNo);
        FieldRef.SetRange(TempFatturaHeader."Document No.");

        if not LineRecRef.FindSet then
            ErrorMessage.LogSimpleMessage(ErrorMessage."Message Type"::Error, MissingLinesErr);

        exit(not ErrorMessage.HasErrors(false));
    end;

    [Scope('OnPrem')]
    procedure CheckMandatoryFields(HeaderRecRef: RecordRef; var ErrorMessage: Record "Error Message")
    var
        PaymentTerms: Record "Payment Terms";
        PaymentMethod: Record "Payment Method";
        Customer: Record Customer;
        TaxRepresentativeVendor: Record Vendor;
        TransmissionIntermediaryVendor: Record Vendor;
        PaymentTermsAndPaymentMethodExists: Boolean;
    begin
        Initialize;
        Customer.Get(HeaderRecRef.Field(CustomerNoFieldNo).Value);
        PaymentTermsAndPaymentMethodExists :=
          PaymentMethod.Get(HeaderRecRef.Field(PaymentMethodCodeFieldNo)) and
          PaymentTerms.Get(HeaderRecRef.Field(PaymentTermsCodeFieldNo));

        CheckCompanyInformationFields(ErrorMessage);
        ErrorMessage.LogIfEmpty(Customer, Customer.FieldNo("PA Code"), ErrorMessage."Message Type"::Error);
        ErrorMessage.LogIfEmpty(Customer, Customer.FieldNo("Country/Region Code"), ErrorMessage."Message Type"::Error);
        ErrorMessage.LogIfEmpty(Customer, Customer.FieldNo(Address), ErrorMessage."Message Type"::Error);
        ErrorMessage.LogIfEmpty(Customer, Customer.FieldNo("Post Code"), ErrorMessage."Message Type"::Error);
        ErrorMessage.LogIfEmpty(Customer, Customer.FieldNo(City), ErrorMessage."Message Type"::Error);
        if Customer."Individual Person" then begin
            ErrorMessage.LogIfEmpty(
              Customer, Customer.FieldNo("Last Name"), ErrorMessage."Message Type"::Error);
            ErrorMessage.LogIfEmpty(
              Customer, Customer.FieldNo("First Name"), ErrorMessage."Message Type"::Error);
            ErrorMessage.LogIfEmpty(Customer, Customer.FieldNo("Fiscal Code"), ErrorMessage."Message Type"::Error);
        end else begin
            ErrorMessage.LogIfEmpty(Customer, Customer.FieldNo("VAT Registration No."), ErrorMessage."Message Type"::Error);
            ErrorMessage.LogIfEmpty(
              Customer, Customer.FieldNo(Name), ErrorMessage."Message Type"::Error);
        end;

        if TaxRepresentativeVendor.Get(CompanyInformation."Tax Representative No.") then begin
            ErrorMessage.LogIfEmpty(
              TaxRepresentativeVendor, TaxRepresentativeVendor.FieldNo("Country/Region Code"), ErrorMessage."Message Type"::Error);
            ErrorMessage.LogIfEmpty(
              TaxRepresentativeVendor, TaxRepresentativeVendor.FieldNo("Fiscal Code"), ErrorMessage."Message Type"::Error);
        end;

        if TransmissionIntermediaryVendor.Get(CompanyInformation."Transmission Intermediary No.") then begin
            ErrorMessage.LogIfEmpty(TransmissionIntermediaryVendor,
              TransmissionIntermediaryVendor.FieldNo("Country/Region Code"), ErrorMessage."Message Type"::Error);
            ErrorMessage.LogIfEmpty(TransmissionIntermediaryVendor,
              TransmissionIntermediaryVendor.FieldNo("Fiscal Code"), ErrorMessage."Message Type"::Error);
        end;

        if PaymentTermsAndPaymentMethodExists then begin
            ErrorMessage.LogIfEmpty(PaymentTerms,
              PaymentTerms.FieldNo("Fattura Payment Terms Code"), ErrorMessage."Message Type"::Error);
            ErrorMessage.LogIfEmpty(PaymentMethod,
              PaymentMethod.FieldNo("Fattura PA Payment Method"), ErrorMessage."Message Type"::Error);
        end;

        CheckFatturaPANos(ErrorMessage);
    end;

    local procedure CheckCompanyInformationFields(var ErrorMessage: Record "Error Message")
    begin
        ErrorMessage.LogIfLengthExceeded(
          CompanyInformation, CompanyInformation.FieldNo("Fiscal Code"), ErrorMessage."Message Type"::Error, 11);
        ErrorMessage.LogIfEmpty(
          CompanyInformation, CompanyInformation.FieldNo("Country/Region Code"), ErrorMessage."Message Type"::Error);
        ErrorMessage.LogIfEmpty(
          CompanyInformation, CompanyInformation.FieldNo("VAT Registration No."), ErrorMessage."Message Type"::Error);
        ErrorMessage.LogIfEmpty(
          CompanyInformation, CompanyInformation.FieldNo("Company Type"), ErrorMessage."Message Type"::Error);
        ErrorMessage.LogIfEmpty(CompanyInformation, CompanyInformation.FieldNo(Address), ErrorMessage."Message Type"::Error);
        ErrorMessage.LogIfEmpty(CompanyInformation, CompanyInformation.FieldNo("Post Code"), ErrorMessage."Message Type"::Error);
        ErrorMessage.LogIfEmpty(CompanyInformation, CompanyInformation.FieldNo(City), ErrorMessage."Message Type"::Error);
        ErrorMessage.LogIfEmpty(CompanyInformation, CompanyInformation.FieldNo("REA No."), ErrorMessage."Message Type"::Error);
        ErrorMessage.LogIfEmpty(
          CompanyInformation, CompanyInformation.FieldNo("Registry Office Province"), ErrorMessage."Message Type"::Error);
    end;

    local procedure CheckFatturaPANos(var ErrorMessage: Record "Error Message")
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        FatturaPANoSeries: Record "No. Series";
        FatturaNoSeriesLine: Record "No. Series Line";
    begin
        SalesReceivablesSetup.Get;
        ErrorMessage.LogIfEmpty(
          SalesReceivablesSetup, SalesReceivablesSetup.FieldNo("Fattura PA Nos."), ErrorMessage."Message Type"::Error);
        if FatturaPANoSeries.Get(SalesReceivablesSetup."Fattura PA Nos.") then;
        FatturaNoSeriesLine.SetRange("Series Code", FatturaPANoSeries.Code);
        FatturaNoSeriesLine.SetRange(Open, true);
        if FatturaNoSeriesLine.FindFirst then begin
            ErrorMessage.LogIfLengthExceeded(FatturaNoSeriesLine, FatturaNoSeriesLine.FieldNo("Starting No."),
              ErrorMessage."Message Type"::Error, 5);
            ErrorMessage.LogIfLengthExceeded(FatturaNoSeriesLine, FatturaNoSeriesLine.FieldNo("Ending No."),
              ErrorMessage."Message Type"::Error, 5);
        end;
    end;

    local procedure CheckSalesInvHeaderFields(SalesInvoiceHeader: Record "Sales Invoice Header"; PaymentMethod: Record "Payment Method")
    begin
        if ErrorMessage.LogIfEmpty(
             SalesInvoiceHeader, SalesInvoiceHeader.FieldNo("Payment Method Code"), ErrorMessage."Message Type"::Warning) = 0
        then
            ErrorMessage.LogIfEmpty(
              PaymentMethod, PaymentMethod.FieldNo("Fattura PA Payment Method"), ErrorMessage."Message Type"::Error);

        ErrorMessage.LogIfEmpty(
          SalesInvoiceHeader, SalesInvoiceHeader.FieldNo("Payment Terms Code"), ErrorMessage."Message Type"::Warning);
    end;

    local procedure CheckSalesCrMemoHeaderFields(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; PaymentMethod: Record "Payment Method")
    begin
        if ErrorMessage.LogIfEmpty(
             SalesCrMemoHeader, SalesCrMemoHeader.FieldNo("Payment Method Code"), ErrorMessage."Message Type"::Warning) = 0
        then
            ErrorMessage.LogIfEmpty(
              PaymentMethod, PaymentMethod.FieldNo("Fattura PA Payment Method"), ErrorMessage."Message Type"::Error);

        ErrorMessage.LogIfEmpty(
          SalesCrMemoHeader, SalesCrMemoHeader.FieldNo("Payment Terms Code"), ErrorMessage."Message Type"::Warning);
    end;

    local procedure CheckServiceInvHeaderFields(ServiceInvoiceHeader: Record "Service Invoice Header"; PaymentMethod: Record "Payment Method")
    begin
        if ErrorMessage.LogIfEmpty(
             ServiceInvoiceHeader, ServiceInvoiceHeader.FieldNo("Payment Method Code"), ErrorMessage."Message Type"::Warning) = 0
        then
            ErrorMessage.LogIfEmpty(
              PaymentMethod, PaymentMethod.FieldNo("Fattura PA Payment Method"), ErrorMessage."Message Type"::Error);

        ErrorMessage.LogIfEmpty(
          ServiceInvoiceHeader, ServiceInvoiceHeader.FieldNo("Payment Terms Code"), ErrorMessage."Message Type"::Warning);
    end;

    local procedure CheckServiceCrMemoHeaderFields(ServiceCrMemoHeader: Record "Service Cr.Memo Header"; PaymentMethod: Record "Payment Method")
    begin
        if ErrorMessage.LogIfEmpty(
             ServiceCrMemoHeader, ServiceCrMemoHeader.FieldNo("Payment Method Code"), ErrorMessage."Message Type"::Warning) = 0
        then
            ErrorMessage.LogIfEmpty(
              PaymentMethod, PaymentMethod.FieldNo("Fattura PA Payment Method"), ErrorMessage."Message Type"::Error);

        ErrorMessage.LogIfEmpty(
          ServiceCrMemoHeader, ServiceCrMemoHeader.FieldNo("Payment Terms Code"), ErrorMessage."Message Type"::Warning);
    end;

    local procedure UpdateFatturaHeaderWithDiscountInformation(var TempFatturaHeader: Record "Fattura Header" temporary; var LineRecRef: RecordRef; HeaderRecRef: RecordRef)
    var
        FieldRef: FieldRef;
    begin
        TempFatturaHeader."Total Amount" := ExchangeToLCYAmount(TempFatturaHeader, GetTotalDocAmount(LineRecRef));
        if TempFatturaHeader."Entry Type" = TempFatturaHeader."Entry Type"::Sales then begin
            FieldRef := HeaderRecRef.Field(InvoiceDiscountAmountFieldNo);
            if Format(FieldRef.Class) = 'FlowField' then
                FieldRef.CalcField;
            TempFatturaHeader."Total Inv. Discount" := FieldRef.Value;
        end else
            TempFatturaHeader."Total Inv. Discount" := CalcServInvDiscAmount(LineRecRef, TempFatturaHeader);
        TempFatturaHeader."Total Inv. Discount" := ExchangeToLCYAmount(TempFatturaHeader, TempFatturaHeader."Total Inv. Discount");
    end;

    local procedure UpdateFattureHeaderWithApplicationInformation(var TempFatturaHeader: Record "Fattura Header" temporary)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        AppliedCustLedgerEntry: Record "Cust. Ledger Entry";
        DocRecRef: RecordRef;
    begin
        FindCustLedgEntry(CustLedgerEntry, TempFatturaHeader);
        if not FindAppliedEntry(AppliedCustLedgerEntry, CustLedgerEntry) then
            exit;

        TempFatturaHeader."Applied Doc. No." := AppliedCustLedgerEntry."Document No.";
        TempFatturaHeader."Applied Posting Date" := AppliedCustLedgerEntry."Posting Date";

        if not FindSourceDocument(DocRecRef, AppliedCustLedgerEntry) then
            exit;

        TempFatturaHeader."Appl. Fattura Project Code" := DocRecRef.Field(FatturaProjectCodeFieldNo).Value;
        TempFatturaHeader."Appl. Fattura Tender Code" := DocRecRef.Field(FatturaTenderCodeFieldNo).Value;
    end;

    local procedure UpdateFatturaHeaderWithTaxRepresentativeInformation(var TempFatturaHeader: Record "Fattura Header" temporary)
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.SetRange("Document Type", TempFatturaHeader."Document Type");
        VATEntry.SetRange("Document No.", TempFatturaHeader."Document No.");
        VATEntry.SetRange("Posting Date", TempFatturaHeader."Posting Date");
        if VATEntry.FindFirst then
            if VATEntry."Tax Representative Type" <> 0 then begin
                TempFatturaHeader."Tax Representative Type" := VATEntry."Tax Representative Type";
                TempFatturaHeader."Tax Representative No." := VATEntry."Tax Representative No.";
            end;

        if (TempFatturaHeader."Tax Representative Type" = 0) and (CompanyInformation."Tax Representative No." <> '') then begin
            TempFatturaHeader."Tax Representative Type" := VATEntry."Tax Representative Type"::Vendor;
            TempFatturaHeader."Tax Representative No." := CompanyInformation."Tax Representative No.";
        end;
    end;

    [Scope('OnPrem')]
    procedure BuildSelfBillingDocPageSource(var TempVATEntry: Record "VAT Entry" temporary; DateFilter: Text[30])
    var
        FatturaSetup: Record "Fattura Setup";
        VATEntry: Record "VAT Entry";
    begin
        FatturaSetup.VerifyAndSetData;
        with TempVATEntry do begin
            Reset;
            DeleteAll;

            VATEntry.SetCurrentKey("Document No.", "Posting Date", "Unrealized VAT Entry No.");
            VATEntry.SetRange("VAT Bus. Posting Group", FatturaSetup."Self-Billing VAT Bus. Group");
            VATEntry.SetRange(Type, VATEntry.Type::Sale);
            VATEntry.SetRange("VAT Calculation Type", VATEntry."VAT Calculation Type"::"Reverse Charge VAT");
            VATEntry.SetFilter("Document Type", '%1|%2', VATEntry."Document Type"::Invoice, VATEntry."Document Type"::"Credit Memo");
            VATEntry.SetFilter("Posting Date", DateFilter);
            BuildVATEntryBufferWithLinks(TempVATEntry, VATEntry);
        end;
    end;

    [Scope('OnPrem')]
    procedure BuildVATEntryBufferWithLinks(var TempVATEntry: Record "VAT Entry" temporary; var VATEntry: Record "VAT Entry")
    var
        FirstVATEntry: Record "VAT Entry";
        LastDocNo: Code[20];
        LastPostingDate: Date;
        LastEntryNo: Integer;
    begin
        with TempVATEntry do begin
            if not VATEntry.FindSet then
                exit;

            FirstVATEntry := VATEntry;
            repeat
                TempVATEntry := VATEntry;
                if (LastDocNo = VATEntry."Document No.") and (LastPostingDate = VATEntry."Posting Date") then
                    "Related Entry No." := LastEntryNo
                else begin
                    "Related Entry No." := 0;
                    LastEntryNo := VATEntry."Entry No.";
                end;
                LastDocNo := VATEntry."Document No.";
                LastPostingDate := VATEntry."Posting Date";
                Insert;
            until VATEntry.Next = 0;
            TempVATEntry := FirstVATEntry;
            Find;
        end;
    end;

    [Scope('OnPrem')]
    procedure GetFileName(ProgressiveNo: Code[20]): Text[40]
    var
        CompanyInformation: Record "Company Information";
        ZeroNo: Code[10];
        BaseString: Text;
    begin
        // - country code + the transmitter's unique identity code + unique progressive number of the file
        CompanyInformation.Get;
        BaseString := CopyStr(DelChr(ProgressiveNo, '=', ',?;.:/-_ '), 1, 10);
        ZeroNo := PadStr('', 10 - StrLen(BaseString), '0');
        exit(CompanyInformation."Country/Region Code" +
          CompanyInformation."Fiscal Code" + '_' + ZeroNo + BaseString);
    end;

    local procedure GetTransmissionType(Customer: Record Customer): Text[5]
    begin
        if Customer.IsPublicCompany then
            exit('FPA12');
        exit(NonPublicCompanyLbl);
    end;

    local procedure GetTipoDocumento(TempFatturaHeader: Record "Fattura Header" temporary; Customer: Record Customer): Text[4]
    begin
        if Customer."VAT Registration No." = CompanyInformation."VAT Registration No." then
            exit('TD20');

        if TempFatturaHeader.Prepayment then
            exit('TD02');

        case TempFatturaHeader."Document Type" of
            TempFatturaHeader."Document Type"::Invoice:
                exit(GetDefaultFatturaDocType);
            TempFatturaHeader."Document Type"::"Credit Memo":
                exit('TD04');
            else
                exit('TD02');
        end;
    end;

    local procedure GetTotalDocAmount(var LineRecRef: RecordRef) TotalAmount: Decimal
    var
        AmountInclVAT: Decimal;
    begin
        repeat
            if not IsSplitPaymentLine(LineRecRef) then
                if Evaluate(AmountInclVAT, Format(LineRecRef.Field(LineAmountIncludingVATFieldNo).Value)) then
                    TotalAmount += AmountInclVAT;
        until LineRecRef.Next = 0;
        exit(TotalAmount);
    end;

    local procedure GetVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; LineRecRef: RecordRef): Boolean
    begin
        exit(VATPostingSetup.Get(Format(LineRecRef.Field(VATBusPostingGroupCodeFieldNo).Value),
            Format(LineRecRef.Field(VATProdPostingGroupCodeFieldNo).Value)));
    end;

    local procedure GetVATType(VATEntry: Record "VAT Entry"; IsSplitPaymentDoc: Boolean): Code[1]
    begin
        if IsSplitPaymentDoc then
            exit('S');
        if VATEntry."Unrealized Amount" <> 0 then
            exit('D');
        exit(BasicVATTypeLbl);
    end;

    local procedure GetVATExemptionDescription(CustomerNo: Code[20]; DocumentDate: Date): Text[50]
    var
        VATExemption: Record "VAT Exemption";
    begin
        if VATExemption.FindCustVATExemptionOnDate(CustomerNo, DocumentDate, DocumentDate) then
            exit(
              StrSubstNo(ExemptionDataMsg, VATExemption."VAT Exempt. No.",
                Format(VATExemption."VAT Exempt. Date", 0, '<Day,2>/<Month,2>/<Year4>')));
    end;

    local procedure GetNextProgressiveNo(): Code[20]
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        FatturaPANoSeries: Record "No. Series";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        SalesReceivablesSetup.Get;
        if FatturaPANoSeries.Get(SalesReceivablesSetup."Fattura PA Nos.") then
            exit(NoSeriesManagement.GetNextNo(FatturaPANoSeries.Code, Today, true));
    end;

    local procedure GetDefaultFatturaDocType(): Text[4]
    begin
        exit('TD01');
    end;

    local procedure FindCustLedgEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; TempFatturaHeader: Record "Fattura Header" temporary)
    begin
        CustLedgerEntry.SetRange("Document Type", TempFatturaHeader."Document Type");
        CustLedgerEntry.SetRange("Document No.", TempFatturaHeader."Document No.");
        CustLedgerEntry.SetRange("Posting Date", TempFatturaHeader."Posting Date");
        CustLedgerEntry.FindSet;
    end;

    local procedure FindAppliedEntry(var AppliedCustLedgerEntry: Record "Cust. Ledger Entry"; OriginalCustLedgerEntry: Record "Cust. Ledger Entry"): Boolean
    var
        InvDtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        AppliedDtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        AppliedDocType: Option;
    begin
        case OriginalCustLedgerEntry."Document Type" of
            OriginalCustLedgerEntry."Document Type"::Invoice:
                AppliedDocType := OriginalCustLedgerEntry."Document Type"::"Credit Memo";
            OriginalCustLedgerEntry."Document Type"::"Credit Memo":
                AppliedDocType := OriginalCustLedgerEntry."Document Type"::Invoice;
            else
                exit(false);
        end;

        InvDtldCustLedgEntry.SetRange("Cust. Ledger Entry No.", OriginalCustLedgerEntry."Entry No.");
        InvDtldCustLedgEntry.SetRange(Unapplied, false);
        if InvDtldCustLedgEntry.FindSet then
            repeat
                if InvDtldCustLedgEntry."Cust. Ledger Entry No." =
                   InvDtldCustLedgEntry."Applied Cust. Ledger Entry No."
                then begin
                    AppliedDtldCustLedgEntry.SetRange(
                      "Applied Cust. Ledger Entry No.", InvDtldCustLedgEntry."Applied Cust. Ledger Entry No.");
                    AppliedDtldCustLedgEntry.SetRange("Entry Type", AppliedDtldCustLedgEntry."Entry Type"::Application);
                    AppliedDtldCustLedgEntry.SetRange(Unapplied, false);
                    if AppliedDtldCustLedgEntry.FindSet then
                        repeat
                            if AppliedDtldCustLedgEntry."Cust. Ledger Entry No." <>
                               AppliedDtldCustLedgEntry."Applied Cust. Ledger Entry No."
                            then
                                if AppliedCustLedgerEntry.Get(AppliedDtldCustLedgEntry."Cust. Ledger Entry No.") and
                                   (AppliedCustLedgerEntry."Document Type" = AppliedDocType)
                                then
                                    exit(true);
                        until AppliedDtldCustLedgEntry.Next = 0;
                end else
                    if AppliedCustLedgerEntry.Get(InvDtldCustLedgEntry."Applied Cust. Ledger Entry No.") and
                       (AppliedCustLedgerEntry."Document Type" = AppliedDocType)
                    then
                        exit(true);
            until InvDtldCustLedgEntry.Next = 0;
        exit(false);
    end;

    local procedure FindSourceDocument(var DocRecRef: RecordRef; AppliedCustLedgerEntry: Record "Cust. Ledger Entry"): Boolean
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
    begin
        case AppliedCustLedgerEntry."Document Type" of
            AppliedCustLedgerEntry."Document Type"::Invoice:
                begin
                    if SalesInvoiceHeader.Get(AppliedCustLedgerEntry."Document No.") then
                        DocRecRef.GetTable(SalesInvoiceHeader)
                    else
                        if ServiceInvoiceHeader.Get(AppliedCustLedgerEntry."Document No.") then
                            DocRecRef.GetTable(ServiceInvoiceHeader)
                        else
                            exit(false);
                end;
            AppliedCustLedgerEntry."Document Type"::"Credit Memo":
                begin
                    if SalesCrMemoHeader.Get(AppliedCustLedgerEntry."Document No.") then
                        DocRecRef.GetTable(SalesCrMemoHeader)
                    else
                        if ServiceCrMemoHeader.Get(AppliedCustLedgerEntry."Document No.") then
                            DocRecRef.GetTable(ServiceCrMemoHeader)
                        else
                            exit(false);
                end;
            else
                exit(false);
        end;
        exit(true);
    end;

    local procedure CalcServInvDiscAmount(var LineRecRef: RecordRef; TempFatturaHeader: Record "Fattura Header" temporary) ServInvDiscount: Decimal
    var
        InvDiscountAmount: Decimal;
    begin
        if TempFatturaHeader."Entry Type" <> TempFatturaHeader."Entry Type"::Service then
            exit;

        if not LineRecRef.FindSet then
            exit;

        repeat
            if Evaluate(InvDiscountAmount, Format(LineRecRef.Field(LineInvDiscAmountFieldNo).Value)) then;
            ServInvDiscount += InvDiscountAmount;
        until LineRecRef.Next = 0;
        exit(ServInvDiscount);
    end;

    [Scope('OnPrem')]
    procedure CalcInvDiscAmountDividedByQty(RecRef: RecordRef; QuantityFieldNo: Integer; LineInvoiceDiscoutAmountFieldNo: Integer): Decimal
    var
        FieldRef: FieldRef;
        InvDiscAmount: Decimal;
        QtyValue: Decimal;
    begin
        FieldRef := RecRef.Field(LineInvoiceDiscoutAmountFieldNo);
        InvDiscAmount := FieldRef.Value;
        FieldRef := RecRef.Field(QuantityFieldNo);
        QtyValue := FieldRef.Value;
        exit(Round(InvDiscAmount / QtyValue));
    end;

    local procedure ExchangeToLCYAmount(TempFatturaHeader: Record "Fattura Header" temporary; Amount: Decimal): Decimal
    var
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        if TempFatturaHeader."Currency Code" = '' then
            exit(Amount);

        Currency.Get(TempFatturaHeader."Currency Code");
        Currency.InitRoundingPrecision;
        exit(
          Round(
            CurrExchRate.ExchangeAmtFCYToLCY(
              TempFatturaHeader."Posting Date", TempFatturaHeader."Currency Code",
              Amount, TempFatturaHeader."Currency Factor"),
            Currency."Amount Rounding Precision"));
    end;

    local procedure CollectShipmentInfo(var TempSalesShipmentBuffer: Record "Sales Shipment Buffer" temporary; var LineRecRef: RecordRef; TempFatturaHeader: Record "Fattura Header" temporary)
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        ServiceShipmentHeader: Record "Service Shipment Header";
        ServiceShipmentLine: Record "Service Shipment Line";
        TempLineNumberBuffer: Record "Line Number Buffer" temporary;
        ShptNo: Code[20];
        ShipmentDate: Date;
        i: Integer;
    begin
        if TempFatturaHeader."Document Type" <> TempFatturaHeader."Document Type"::Invoice then
            exit;

        if LineRecRef.FindSet then
            repeat
                i += 1;
                ShptNo := Format(LineRecRef.Field(ShipmentNoFieldNo).Value);
                if (Format(LineRecRef.Field(LineTypeFieldNo).Value) = 'Item') and (ShptNo <> '') then begin
                    if TempFatturaHeader."Entry Type" = TempFatturaHeader."Entry Type"::Sales then begin
                        SalesShipmentHeader.Get(ShptNo);
                        ShipmentDate := SalesShipmentHeader."Shipment Date";
                    end else begin
                        ServiceShipmentHeader.Get(ShptNo);
                        ShipmentDate := ServiceShipmentHeader."Posting Date";
                    end;
                    InsertShipmentBuffer(TempSalesShipmentBuffer, i, ShptNo, ShipmentDate, IsSplitPaymentLine(LineRecRef));
                end;
                if TempFatturaHeader."Order No." <> '' then begin
                    TempLineNumberBuffer.Init;
                    Evaluate(TempLineNumberBuffer."Old Line Number", Format(LineRecRef.Field(LineNoFieldNo).Value));
                    TempLineNumberBuffer."New Line Number" := i;
                    TempLineNumberBuffer.Insert;
                end;
            until LineRecRef.Next = 0;
        if TempFatturaHeader."Order No." <> '' then
            if TempFatturaHeader."Entry Type" = TempFatturaHeader."Entry Type"::Sales then begin
                SalesShipmentLine.SetRange(Type, SalesShipmentLine.Type::Item);
                SalesShipmentLine.SetRange("Order No.", TempFatturaHeader."Order No.");
                if SalesShipmentLine.FindSet then
                    repeat
                        i += 1;
                        TempLineNumberBuffer.Get(SalesShipmentLine."Order Line No.");
                        InsertShipmentBuffer(
                          TempSalesShipmentBuffer, TempLineNumberBuffer."New Line Number", SalesShipmentLine."Document No.",
                          SalesShipmentLine."Shipment Date", false);
                    until SalesShipmentLine.Next = 0;
            end else begin
                ServiceShipmentLine.SetRange(Type, ServiceShipmentLine.Type::Item);
                ServiceShipmentLine.SetRange("Order No.", TempFatturaHeader."Order No.");
                if ServiceShipmentLine.FindSet then
                    repeat
                        i += 1;
                        TempLineNumberBuffer.Get(ServiceShipmentLine."Order Line No.");
                        InsertShipmentBuffer(
                          TempSalesShipmentBuffer, TempLineNumberBuffer."New Line Number", ServiceShipmentLine."Document No.",
                          ServiceShipmentLine."Posting Date", false);
                    until ServiceShipmentLine.Next = 0;
            end;
    end;

    local procedure CollectVATOnLines(var TempVATEntry: Record "VAT Entry" temporary; var TempVATPostingSetup: Record "VAT Posting Setup" temporary; TempFatturaHeader: Record "Fattura Header" temporary)
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.SetRange("Document Type", TempFatturaHeader."Document Type");
        VATEntry.SetRange("Document No.", TempFatturaHeader."Document No.");
        VATEntry.SetRange("Posting Date", TempFatturaHeader."Posting Date");
        if VATEntry.FindSet then
            repeat
                CollectVATPostingSetup(TempVATPostingSetup, VATEntry);
                if not IsSplitVATSetup(TempVATPostingSetup) then begin
                    TempVATEntry.SetRange("VAT %", VATEntry."VAT %");
                    TempVATEntry.SetRange("VAT Transaction Nature", TempVATPostingSetup."VAT Transaction Nature");
                    if TempVATEntry.FindFirst then begin
                        TempVATEntry.Base += VATEntry.Base + VATEntry."Unrealized Base";
                        TempVATEntry.Amount += VATEntry.Amount + VATEntry."Unrealized Amount";
                        TempVATEntry.Modify;
                    end else begin
                        TempVATEntry.Init;
                        TempVATEntry := VATEntry;
                        TempVATEntry.Base += TempVATEntry."Unrealized Base";
                        TempVATEntry.Amount += TempVATEntry."Unrealized Amount";
                        TempVATEntry.Insert;
                    end;
                end;
            until VATEntry.Next = 0;
    end;

    local procedure CollectVATPostingSetup(var TempVATPostingSetup: Record "VAT Posting Setup" temporary; VATEntry: Record "VAT Entry")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if TempVATPostingSetup.Get(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group") then
            exit;

        VATPostingSetup.Get(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group");
        TempVATPostingSetup := VATPostingSetup;
        TempVATPostingSetup.Insert;
    end;

    local procedure BuildOrderDataBuffer(var TempFatturaLine: Record "Fattura Line" temporary; var TempSalesShipmentBuffer: Record "Sales Shipment Buffer" temporary; TempFatturaHeader: Record "Fattura Header" temporary)
    var
        MultipleOrders: Boolean;
        Finished: Boolean;
    begin
        TempSalesShipmentBuffer.Reset;
        TempSalesShipmentBuffer.SetRange("Entry No.", 0); // only non-split lines affected
        if not TempSalesShipmentBuffer.FindSet then
            exit;

        MultipleOrders := HasMultipleOrders(TempSalesShipmentBuffer);
        if (not MultipleOrders) and
           (TempFatturaHeader."Customer Purchase Order No." = '') and
           (TempFatturaHeader."Fattura Project Code" = '') and
           (TempFatturaHeader."Fattura Tender Code" = '')
        then
            exit;

        Clear(TempFatturaLine);
        TempFatturaLine."Line Type" := TempFatturaLine."Line Type"::Order;
        repeat
            TempFatturaLine."Document No." := TempSalesShipmentBuffer."Document No.";
            repeat
                if MultipleOrders then
                    TempFatturaLine."Related Line No." := TempSalesShipmentBuffer."Line No.";
                Finished := TempSalesShipmentBuffer.Next = 0;
                TempFatturaLine."Line No." += 1;
                TempFatturaLine.Insert;
            until Finished or (TempFatturaLine."Document No." <> TempSalesShipmentBuffer."Document No.");
        until Finished;
    end;

    local procedure BuildShipmentDataBuffer(var TempFatturaLine: Record "Fattura Line" temporary; var TempSalesShipmentBuffer: Record "Sales Shipment Buffer" temporary)
    var
        MultipleOrders: Boolean;
    begin
        TempSalesShipmentBuffer.Reset;
        if TempSalesShipmentBuffer.FindSet then begin
            MultipleOrders := TempSalesShipmentBuffer.Count > 1;
            Clear(TempFatturaLine);
            TempFatturaLine."Line Type" := TempFatturaLine."Line Type"::Shipment;
            repeat
                TempFatturaLine."Line No." += 1;
                TempFatturaLine."Document No." := TempSalesShipmentBuffer."Document No.";
                TempFatturaLine."Posting Date" := TempSalesShipmentBuffer."Posting Date";
                if MultipleOrders then
                    TempFatturaLine."Related Line No." := TempSalesShipmentBuffer."Line No.";
                TempFatturaLine.Insert;
            until TempSalesShipmentBuffer.Next = 0;
        end;
    end;

    local procedure BuildAttachedToLinesExtTextBuffer(var TempFatturaLine: Record "Fattura Line" temporary; CurrRecRef: RecordRef)
    var
        OriginalFatturaLine: Record "Fattura Line";
        LineRecRef: RecordRef;
        TypeFieldRef: FieldRef;
        AttachedToLineNoFieldRef: FieldRef;
        LineNoFieldRef: FieldRef;
        SourceTypeFound: Boolean;
        SourceNoNoValue: Text;
    begin
        OriginalFatturaLine := TempFatturaLine;
        TempFatturaLine.Init;
        TempFatturaLine.SetRange("Line Type", TempFatturaLine."Line Type"::"Extended Text");
        if TempFatturaLine.FindLast then
            TempFatturaLine."Line No." := TempFatturaLine."Line No.";
        TempFatturaLine."Related Line No." := TempFatturaLine."Line No.";
        TempFatturaLine."Line Type" := TempFatturaLine."Line Type"::"Extended Text";

        LineRecRef := CurrRecRef.Duplicate;

        TypeFieldRef := LineRecRef.Field(LineTypeFieldNo);
        TypeFieldRef.SetRange(0);

        AttachedToLineNoFieldRef := LineRecRef.Field(AttachedToLineNoFieldNo);
        AttachedToLineNoFieldRef.SetFilter(Format(LineRecRef.Field(LineNoFieldNo).Value));

        if LineRecRef.FindSet then begin
            SourceNoNoValue := CurrRecRef.Field(NoFieldNo).Value;
            repeat
                InsertExtTextFatturaLine(TempFatturaLine, LineRecRef, StrSubstNo(TxtTok, SourceNoNoValue));
            until LineRecRef.Next = 0;
        end;
        TypeFieldRef.SetRange;
        AttachedToLineNoFieldRef.SetRange(0);
        LineNoFieldRef := LineRecRef.Field(LineNoFieldNo);
        LineNoFieldRef.SetFilter('>%1', Format(CurrRecRef.Field(LineNoFieldNo).Value));
        if LineRecRef.FindSet then
            repeat
                SourceTypeFound := Format(TypeFieldRef.Value) <> ' ';
                if not SourceTypeFound then begin
                    SourceNoNoValue := LineRecRef.Field(NoFieldNo).Value;
                    if SourceNoNoValue <> '' then
                        InsertExtTextFatturaLine(TempFatturaLine, LineRecRef, SourceNoNoValue);
                end;
            until (LineRecRef.Next = 0) or SourceTypeFound;

        TypeFieldRef.SetRange;
        AttachedToLineNoFieldRef.SetRange;
        LineNoFieldRef.SetRange;

        TempFatturaLine := OriginalFatturaLine;
    end;

    local procedure InsertShipmentBuffer(var TempSalesShipmentBuffer: Record "Sales Shipment Buffer" temporary; LineNo: Integer; ShipmentNo: Code[20]; ShipmentDate: Date; IsSplitLine: Boolean)
    begin
        TempSalesShipmentBuffer.Init;
        TempSalesShipmentBuffer."Document No." := ShipmentNo;
        TempSalesShipmentBuffer."Line No." := LineNo;
        TempSalesShipmentBuffer."Posting Date" := ShipmentDate;
        if IsSplitLine then
            TempSalesShipmentBuffer."Entry No." := LineNo; // Mark split line with non-empty "Line No."
        TempSalesShipmentBuffer.Insert;
    end;

    local procedure InsertFatturaLine(var TempFatturaLine: Record "Fattura Line" temporary; var DocLineNo: Integer; TempFatturaHeader: Record "Fattura Header" temporary; LineRecRef: RecordRef)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Quantity: Decimal;
        UnitPrice: Decimal;
        InvDiscAmountByQty: Decimal;
        LineDiscountPct: Decimal;
        LineAmount: Decimal;
    begin
        if Format(LineRecRef.Field(LineTypeFieldNo).Value) = ' ' then
            exit;

        DocLineNo += 1;
        Clear(TempFatturaLine);
        TempFatturaLine."Line Type" := TempFatturaLine."Line Type"::Document;
        TempFatturaLine."Line No." := DocLineNo;
        TempFatturaLine.Type := Format(LineRecRef.Field(LineTypeFieldNo).Value);
        TempFatturaLine."No." := LineRecRef.Field(NoFieldNo).Value;
        TempFatturaLine.Description := LineRecRef.Field(DescriptionFieldNo).Value;

        Quantity := LineRecRef.Field(QuantityFieldNo).Value;
        UnitPrice := LineRecRef.Field(UnitPriceFieldNo).Value;
        if Quantity < 0 then
            TempFatturaLine."Unit Price" := -UnitPrice
        else begin
            TempFatturaLine.Quantity := Quantity;
            TempFatturaLine."Unit of Measure" := LineRecRef.Field(UnitOfMeasureFieldNo).Value;
            TempFatturaLine."Unit Price" := UnitPrice;
        end;
        TempFatturaLine."Unit Price" := ExchangeToLCYAmount(TempFatturaHeader, TempFatturaLine."Unit Price");

        InvDiscAmountByQty :=
          ExchangeToLCYAmount(
            TempFatturaHeader, CalcInvDiscAmountDividedByQty(LineRecRef, QuantityFieldNo, LineInvDiscAmountFieldNo));
        LineDiscountPct := LineRecRef.Field(LineDiscountPercFieldNo).Value;
        if (InvDiscAmountByQty <> 0) or (LineDiscountPct <> 0) then begin
            TempFatturaLine."Discount Percent" := LineDiscountPct;
            if TempFatturaLine."Discount Percent" = 0 then
                TempFatturaLine."Discount Amount" := InvDiscAmountByQty;
        end;

        LineAmount := LineRecRef.Field(LineAmountFieldNo).Value;
        TempFatturaLine.Amount := ExchangeToLCYAmount(TempFatturaHeader, LineAmount);

        TempFatturaLine."VAT %" := LineRecRef.Field(VatPercFieldNo).Value;
        if TempFatturaLine."VAT %" = 0 then begin
            GetVATPostingSetup(VATPostingSetup, LineRecRef);
            TempFatturaLine."VAT Transaction Nature" := VATPostingSetup."VAT Transaction Nature";
        end;
        TempFatturaLine.Insert;

        if TempFatturaLine.Type <> '' then
            BuildAttachedToLinesExtTextBuffer(TempFatturaLine, LineRecRef);
    end;

    local procedure InsertExtTextFatturaLine(var TempFatturaLine: Record "Fattura Line" temporary; LineRecRef: RecordRef; NoValue: Text)
    var
        ExtendedTextValue: Text;
    begin
        ExtendedTextValue := LineRecRef.Field(DescriptionFieldNo).Value;
        if ExtendedTextValue <> '' then begin
            TempFatturaLine."Line No." += 1;
            TempFatturaLine."Ext. Text Source No" := CopyStr(NoValue, 1, 10);
            TempFatturaLine.Description := CopyStr(ExtendedTextValue, 1, MaxStrLen(TempFatturaLine.Description));
            TempFatturaLine.Insert;
        end;
    end;

    local procedure InsertVATFatturaLine(var TempFatturaLine: Record "Fattura Line" temporary; IsInvoice: Boolean; VATEntry: Record "VAT Entry"; CustNo: Code[20]; IsSplitPayment: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        VATIdentifier: Record "VAT Identifier";
        VATNatureDescription: Text[100];
        VATExemptionDescription: Text[50];
    begin
        TempFatturaLine."Line No." += 1;
        TempFatturaLine."VAT %" := VATEntry."VAT %";
        if TempFatturaLine."VAT %" = 0 then begin
            VATPostingSetup.Get(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group");
            TempFatturaLine."VAT Transaction Nature" := VATPostingSetup."VAT Transaction Nature";
            if VATIdentifier.Get(VATEntry."VAT Identifier") then
                VATNatureDescription := VATIdentifier.Description;
            VATExemptionDescription := GetVATExemptionDescription(CustNo, VATEntry."Document Date");
            if VATExemptionDescription <> '' then
                VATNatureDescription += StrSubstNo(' %1 %2', VATExemptionPrefixTok, VATExemptionDescription);
            TempFatturaLine."VAT Nature Description" := VATNatureDescription;
        end;
        TempFatturaLine."VAT Base" := VATEntry.Base;
        TempFatturaLine."VAT Amount" := VATEntry.Amount;
        if IsInvoice then begin
            TempFatturaLine."VAT Base" := -TempFatturaLine."VAT Base";
            TempFatturaLine."VAT Amount" := -TempFatturaLine."VAT Amount";
        end;
        TempFatturaLine.Description := GetVATType(VATEntry, IsSplitPayment);
        TempFatturaLine.Insert;
    end;

    local procedure HasMultipleOrders(var TempSalesShipmentBuffer: Record "Sales Shipment Buffer" temporary) HasMultipleOrders: Boolean
    begin
        TempSalesShipmentBuffer.SetFilter("Document No.", '<>%1', TempSalesShipmentBuffer."Document No.");
        HasMultipleOrders := not TempSalesShipmentBuffer.IsEmpty;
        TempSalesShipmentBuffer.SetRange("Document No.");
        exit(HasMultipleOrders);
    end;

    local procedure HasSplitPayment(var LineRecRef: RecordRef): Boolean
    begin
        repeat
            if IsSplitPaymentLine(LineRecRef) then begin
                LineRecRef.FindFirst;
                exit(true);
            end;
        until LineRecRef.Next = 0;
        LineRecRef.FindFirst;
        exit(false)
    end;

    local procedure IsSplitPaymentLine(LineRecRef: RecordRef): Boolean
    var
        VATPostingSetup: Record "VAT Posting Setup";
        ReversedVATPostingSetup: Record "VAT Posting Setup";
    begin
        if GetVATPostingSetup(VATPostingSetup, LineRecRef) then
            exit((VATPostingSetup."VAT Calculation Type" = VATPostingSetup."VAT Calculation Type"::"Full VAT") and
              ReversedVATPostingSetup.Get(
                VATPostingSetup."Reversed VAT Bus. Post. Group",
                VATPostingSetup."Reversed VAT Prod. Post. Group"));
        exit(false);
    end;

    local procedure IsSplitVATEntry(VATEntry: Record "VAT Entry"): Boolean
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if VATPostingSetup.Get(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group") then
            exit(IsSplitVATSetup(VATPostingSetup));
        exit(false);
    end;

    local procedure IsSplitVATSetup(VATPostingSetup: Record "VAT Posting Setup"): Boolean
    var
        ReversedVATPostingSetup: Record "VAT Posting Setup";
    begin
        if VATPostingSetup."VAT Calculation Type" <> VATPostingSetup."VAT Calculation Type"::"Full VAT" then
            exit(false);

        exit(
          ReversedVATPostingSetup.Get(
            VATPostingSetup."Reversed VAT Bus. Post. Group",
            VATPostingSetup."Reversed VAT Prod. Post. Group"));
    end;
}
