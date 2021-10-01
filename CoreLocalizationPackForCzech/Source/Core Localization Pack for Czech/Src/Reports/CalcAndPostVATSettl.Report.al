report 11971 "Calc. and Post VAT Settl. CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/CalcAndPostVATSett.rdl';
    AdditionalSearchTerms = 'settle vat value added tax,report vat value added tax';
    ApplicationArea = Basic, Suite;
    Caption = 'Calculate and Post VAT Settlement';
    Permissions = TableData "VAT Entry" = imd;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("VAT Posting Setup"; "VAT Posting Setup")
        {
            DataItemTableView = sorting("VAT Bus. Posting Group", "VAT Prod. Posting Group");
            RequestFilterFields = "VAT Bus. Posting Group", "VAT Prod. Posting Group";
            column(TodayFormatted; Format(Today, 0, 4))
            {
            }
            column(PeriodVATDateFilter; StrSubstNo(PeriodTxt, VATDateFilter))
            {
            }
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(PostSettlement; PostSettlement)
            {
            }
            column(PostingDate; Format(PostingDate))
            {
            }
            column(DocNo; DocNo)
            {
            }
            column(GLAccSettleNo; GLAccSettle."No.")
            {
            }
            column(UseAmtsInAddCurr; UseAmtsInAddCurr)
            {
            }
            column(PrintVATEntries; PrintVATEntries)
            {
            }
            column(VATPostingSetupCaption; TableCaption + ': ' + VATPostingSetupFilter)
            {
            }
            column(VATPostingSetupFilter; VATPostingSetupFilter)
            {
            }
            column(HeaderText; HeaderText)
            {
            }
            column(VATAmount; VATAmount)
            {
                AutoFormatExpression = GetCurrency();
                AutoFormatType = 1;
            }
            column(VATAmountAddCurr; VATAmountAddCurr)
            {
                AutoFormatExpression = GetCurrency();
                AutoFormatType = 1;
            }
            column(CalcandPostVATSettlementCaption; CalcandPostVATSettlementCaptionLbl)
            {
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            column(TestReportnotpostedCaption; TestReportnotpostedCaptionLbl)
            {
            }
            column(DocNoCaption; DocNoCaptionLbl)
            {
            }
            column(SettlementAccCaption; SettlementAccCaptionLbl)
            {
            }
            column(DocumentTypeCaption; DocumentTypeCaptionLbl)
            {
            }
            column(UserIDCaption; UserIDCaptionLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
            column(DocumentNoCaption; "VAT Entry".FieldCaption("Document No."))
            {
            }
            column(TypeCaption; "VAT Entry".FieldCaption(Type))
            {
            }
            column(BaseCaption; "VAT Entry".FieldCaption(Base))
            {
            }
            column(AmountCaption; "VAT Entry".FieldCaption(Amount))
            {
            }
            column(UnrealizedBaseCaption; "VAT Entry".FieldCaption("Unrealized Base"))
            {
            }
            column(UnrealizedAmountCaption; "VAT Entry".FieldCaption("Unrealized Amount"))
            {
            }
            column(VATCalculationCaption; "VAT Entry".FieldCaption("VAT Calculation Type"))
            {
            }
            column(BilltoPaytoNoCaption; "VAT Entry".FieldCaption("Bill-to/Pay-to No."))
            {
            }
            column(EntryNoCaption; "VAT Entry".FieldCaption("Entry No."))
            {
            }
            column(PostingDateCaption; "VAT Entry".FieldCaption("VAT Date CZL"))
            {
            }
            dataitem(Advance; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = filter(1 .. 2));
                dataitem("Closing G/L and VAT Entry"; "Integer")
                {
                    DataItemTableView = sorting(Number);
                    column(VATBusPstGr_VATPostSetup; "VAT Posting Setup"."VAT Bus. Posting Group")
                    {
                    }
                    column(VATPrdPstGr_VATPostSetup; "VAT Posting Setup"."VAT Prod. Posting Group")
                    {
                    }
                    column(VATEntryGetFilterType; VATEntry.GetFilter(Type))
                    {
                    }
                    column(VATEntryGetFiltTaxJurisCd; VATEntry.GetFilter("Tax Jurisdiction Code"))
                    {
                    }
                    column(VATEntryGetFilterUseTax; VATEntry.GetFilter("Use Tax"))
                    {
                    }
                    dataitem("VAT Entry"; "VAT Entry")
                    {
                        DataItemTableView = sorting(Type, Closed) where(Closed = const(false), Type = filter(Purchase | Sale));
                        column(PostingDate_VATEntry; Format("VAT Date CZL"))
                        {
                        }
                        column(DocumentNo_VATEntry; VATEntryDocumentNo)
                        {
                        }
                        column(DocumentType_VATEntry; VATEntryDocumentType)
                        {
                        }
                        column(Type_VATEntry; Type)
                        {
                            IncludeCaption = false;
                        }
                        column(Base_VATEntry; Base)
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(Amount_VATEntry; Amount)
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(VATCalcType_VATEntry; "VAT Calculation Type")
                        {
                        }
                        column(BilltoPaytoNo_VATEntry; "Bill-to/Pay-to No.")
                        {
                        }
                        column(EntryNo_VATEntry; "Entry No.")
                        {
                        }
                        column(UserID_VATEntry; "User ID")
                        {
                        }
                        column(UnrealizedAmount_VATEntry; "Unrealized Amount")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(UnrealizedBase_VATEntry; "Unrealized Base")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(AddCurrUnrlzdAmt_VATEntry; "Add.-Currency Unrealized Amt.")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(AddCurrUnrlzdBas_VATEntry; "Add.-Currency Unrealized Base")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(AdditionlCurrAmt_VATEntry; "Additional-Currency Amount")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(AdditinlCurrBase_VATEntry; "Additional-Currency Base")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(VATRegistrationNo_VATEntry; "VAT Registration No.")
                        {
                            IncludeCaption = true;
                        }
                        column(CountryRegionCode_VATEntry; "Country/Region Code")
                        {
                            IncludeCaption = true;
                        }
                        dataitem(CountrySubTotal; "Integer")
                        {
                            DataItemTableView = sorting(Number);
                            column(CountrySubtotalCaption; StrSubstNo(CountrySubtotalCaptionLbl, "VAT Entry"."Country/Region Code"))
                            {
                            }
                            column(CountrySubBase; CountrySubTotalAmt[1])
                            {
                            }
                            column(CountrySubAmount; CountrySubTotalAmt[2])
                            {
                            }
                            column(CountrySubUnrealBase; CountrySubTotalAmt[3])
                            {
                            }
                            column(CountrySubUnrealAmount; CountrySubTotalAmt[4])
                            {
                            }
                            column(CountrySubTotalPrint; PrintCountrySubTotal)
                            {
                            }
                            trigger OnPreDataItem()
                            var
                                VATEntryLocal: Record "VAT Entry";
                            begin
                                if not PrintVATEntries then
                                    CurrReport.Break();

                                if PrintCountrySubTotal = 1 then
                                    Clear(CountrySubTotalAmt);
                                Clear(PrintCountrySubTotal);
                                if not UseAmtsInAddCurr then begin
                                    CountrySubTotalAmt[1] += "VAT Entry".Base;
                                    CountrySubTotalAmt[2] += "VAT Entry".Amount;
                                    CountrySubTotalAmt[3] += "VAT Entry"."Unrealized Base";
                                    CountrySubTotalAmt[4] += "VAT Entry"."Unrealized Amount";
                                end else begin
                                    CountrySubTotalAmt[1] += "VAT Entry"."Additional-Currency Base";
                                    CountrySubTotalAmt[2] += "VAT Entry"."Additional-Currency Amount";
                                    CountrySubTotalAmt[3] += "VAT Entry"."Add.-Currency Unrealized Base";
                                    CountrySubTotalAmt[4] += "VAT Entry"."Add.-Currency Unrealized Amt.";
                                end;

                                SetRange(Number, 0);
                                VATEntryLocal := "VAT Entry";
                                if "VAT Entry".Next() <> 0 then begin
                                    if VATEntryLocal."Country/Region Code" <> "VAT Entry"."Country/Region Code" then
                                        PrintCountrySubTotal := 1;
                                    "VAT Entry".Next(-1);
                                    if ("VAT Entry".Base = 0) and ("VAT Entry"."Advance Base" <> 0) then
                                        "VAT Entry".Base := "VAT Entry"."Advance Base";
                                end else
                                    PrintCountrySubTotal := 1;
                                SetRange(Number, PrintCountrySubTotal);
                            end;
                        }
                        trigger OnAfterGetRecord()
                        begin
                            if not PrintVATEntries then
                                CurrReport.Skip();
                            if (Base = 0) and ("Advance Base" <> 0) then
                                Base := "Advance Base";
                            VATEntryDocumentNo := "Document No.";
                            VATEntryDocumentType := Format("Document Type");
                        end;

                        trigger OnPreDataItem()
                        begin
                            CopyFilters(VATEntry);
                            Clear(CountrySubTotalAmt);
                        end;
                    }
                    dataitem("Close VAT Entries"; "Integer")
                    {
                        DataItemTableView = sorting(Number);
                        MaxIteration = 1;
                        column(PostingDate1; Format(PostingDate))
                        {
                        }
                        column(GenJnlLineDocumentNo; GenJnlLine."Document No.")
                        {
                        }
                        column(GenJnlLineVATBaseAmount; GenJnlLine."VAT Base Amount")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(GenJnlLineVATAmount; GenJnlLine."VAT Amount")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(GenJnlLnVATCalcType; Format(GenJnlLine."VAT Calculation Type"))
                        {
                        }
                        column(NextVATEntryNo; NextVATEntryNo)
                        {
                        }
                        column(GenJnlLnSrcCurrVATAmount; GenJnlLine."Source Curr. VAT Amount")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(GenJnlLnSrcCurrVATBaseAmt; GenJnlLine."Source Curr. VAT Base Amount")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(GenJnlLine2Amount; GenJnlLine2.Amount)
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(GenJnlLine2DocumentNo; GenJnlLine2."Document No.")
                        {
                        }
                        column(ReversingEntry; ReversingEntry)
                        {
                        }
                        column(GenJnlLn2SrcCurrencyAmt; GenJnlLine2."Source Currency Amount")
                        {
                            AutoFormatExpression = GetCurrency();
                            AutoFormatType = 1;
                        }
                        column(SettlementCaption; SettlementCaptionLbl)
                        {
                        }
                        column(GenJnlLineVATRegistrationNo; GenJnlLine."VAT Registration No.")
                        {
                        }
                        column(GenJnlLineCountryRegionCode; GenJnlLine."Country/Region Code")
                        {
                        }
                        column(GenJnlLine2VATRegistrationNo; GenJnlLine2."VAT Registration No.")
                        {
                        }
                        column(GenJnlLine2CountryRegionCode; GenJnlLine2."Country/Region Code")
                        {
                        }
                        trigger OnAfterGetRecord()
                        var
                            VATEntry2: Record "VAT Entry";
                        begin
                            // Calculate amount and base
                            VATEntry.CalcSums(Base, Amount, "Additional-Currency Base", "Additional-Currency Amount", "Advance Base",
#pragma warning disable AL0432
                                "VAT Amount (Non Deductible)");
#pragma warning restore AL0432
                            ReversingEntry := false;

                            // Balancing entries to VAT accounts
                            Clear(GenJnlLine);
                            GenJnlLine."System-Created Entry" := true;
                            GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                            case VATType of
                                VATEntry.Type::Purchase:
                                    GenJnlLine.Description := CopyStr(
                                      DelChr(
                                        StrSubstNo(
                                          PurchaseVatSettlementTxt,
                                          "VAT Posting Setup"."VAT Bus. Posting Group",
                                          "VAT Posting Setup"."VAT Prod. Posting Group"),
                                        '>'), 1, MaxStrLen(GenJnlLine.Description));
                                VATEntry.Type::Sale:
                                    GenJnlLine.Description := CopyStr(
                                      DelChr(
                                        StrSubstNo(
                                          SalesVatSettlementTxt,
                                          "VAT Posting Setup"."VAT Bus. Posting Group",
                                          "VAT Posting Setup"."VAT Prod. Posting Group"),
                                        '>'), 1, MaxStrLen(GenJnlLine.Description));
                            end;
                            SetVatPostingSetupToGenJnlLine(GenJnlLine, "VAT Posting Setup");
                            GenJnlLine."Posting Date" := PostingDate;
                            GenJnlLine.Validate("VAT Date CZL", PostingDate);
                            GenJnlLine."Document Type" := GenJnlLine."Document Type"::" ";
                            GenJnlLine."Document No." := DocNo;
                            GenJnlLine."Source Code" := SourceCodeSetup."VAT Settlement";
                            GenJnlLine."VAT Posting" := GenJnlLine."VAT Posting"::"Manual VAT Entry";
                            case "VAT Posting Setup"."VAT Calculation Type" of
                                "VAT Posting Setup"."VAT Calculation Type"::"Normal VAT",
                                "VAT Posting Setup"."VAT Calculation Type"::"Full VAT":
                                    begin
                                        GenJnlLine."Account No." :=
                                          "VAT Posting Setup".GetVATAccountNoCZL(VATEntry.Type, VATEntry."Advance Letter No." <> '');
                                        CopyAmounts(GenJnlLine, VATEntry);
                                        if PostSettlement then
                                            PostGenJnlLine(GenJnlLine);
                                        VATAmount := VATAmount + VATEntry.Amount;
                                        VATAmountAddCurr := VATAmountAddCurr + VATEntry."Additional-Currency Amount";
                                    end;
                                "VAT Posting Setup"."VAT Calculation Type"::"Reverse Charge VAT":
                                    case VATType of
                                        VATEntry.Type::Purchase:
                                            begin
                                                GenJnlLine."Account No." :=
                                                  "VAT Posting Setup".GetVATAccountNoCZL(VATEntry.Type, VATEntry."Advance Letter No." <> '');
                                                CopyAmounts(GenJnlLine, VATEntry);
                                                if PostSettlement then
                                                    PostGenJnlLine(GenJnlLine);

                                                CreateGenJnlLine(GenJnlLine2, "VAT Posting Setup".GetRevChargeAccount(false));
#pragma warning disable AL0432
                                                GenJnlLine2.Amount += VATEntry."VAT Amount (Non Deductible)";
#pragma warning restore AL0432
                                                SetVatPostingSetupToGenJnlLine(GenJnlLine2, "VAT Posting Setup");
                                                if PostSettlement then
                                                    PostGenJnlLine(GenJnlLine2);
                                                ReversingEntry := true;
#pragma warning disable AL0432
                                                VATAmount := VATAmount - VATEntry."VAT Amount (Non Deductible)";
#pragma warning restore AL0432
                                            end;
                                        VATEntry.Type::Sale:
                                            begin
                                                GenJnlLine."Account No." :=
                                                  "VAT Posting Setup".GetVATAccountNoCZL(VATEntry.Type, VATEntry."Advance Letter No." <> '');
                                                CopyAmounts(GenJnlLine, VATEntry);
                                                if PostSettlement then
                                                    PostGenJnlLine(GenJnlLine);
                                            end;
                                    end;
                                "VAT Posting Setup"."VAT Calculation Type"::"Sales Tax":
                                    begin
                                        TaxJurisdiction.Get(VATEntry."Tax Jurisdiction Code");
                                        GenJnlLine."Tax Area Code" := TaxJurisdiction.Code;
                                        GenJnlLine."Use Tax" := VATEntry."Use Tax";
                                        case VATType of
                                            VATEntry.Type::Purchase:
                                                if VATEntry."Use Tax" then begin
                                                    TaxJurisdiction.TestField("Tax Account (Purchases)");
                                                    GenJnlLine."Account No." := TaxJurisdiction."Tax Account (Purchases)";
                                                    CopyAmounts(GenJnlLine, VATEntry);
                                                    if PostSettlement then
                                                        PostGenJnlLine(GenJnlLine);

                                                    TaxJurisdiction.TestField("Reverse Charge (Purchases)");
                                                    CreateGenJnlLine(GenJnlLine2, TaxJurisdiction."Reverse Charge (Purchases)");
                                                    GenJnlLine2."Tax Area Code" := TaxJurisdiction.Code;
                                                    GenJnlLine2."Use Tax" := VATEntry."Use Tax";
                                                    if PostSettlement then
                                                        PostGenJnlLine(GenJnlLine2);
                                                    ReversingEntry := true;
                                                end else begin
                                                    TaxJurisdiction.TestField("Tax Account (Purchases)");
                                                    GenJnlLine."Account No." := TaxJurisdiction."Tax Account (Purchases)";
                                                    CopyAmounts(GenJnlLine, VATEntry);
                                                    if PostSettlement then
                                                        PostGenJnlLine(GenJnlLine);
                                                    VATAmount := VATAmount + VATEntry.Amount;
                                                    VATAmountAddCurr := VATAmountAddCurr + VATEntry."Additional-Currency Amount";
                                                end;
                                            VATEntry.Type::Sale:
                                                begin
                                                    TaxJurisdiction.TestField("Tax Account (Sales)");
                                                    GenJnlLine."Account No." := TaxJurisdiction."Tax Account (Sales)";
                                                    CopyAmounts(GenJnlLine, VATEntry);
                                                    if PostSettlement then
                                                        PostGenJnlLine(GenJnlLine);
                                                    VATAmount := VATAmount + VATEntry.Amount;
                                                    VATAmountAddCurr := VATAmountAddCurr + VATEntry."Additional-Currency Amount";
                                                end;
                                        end;
                                    end;
                            end;
                            NextVATEntryNo := NextVATEntryNo + 1;

                            // Close current VAT entries
                            if PostSettlement then begin
                                VATEntry.ModifyAll("Closed by Entry No.", NextVATEntryNo);
                                VATEntry.ModifyAll("VAT Settlement No. CZL", DocNo);
                                VATEntry.ModifyAll(Closed, true);

                                VATEntry2.Get(NextVATEntryNo);
                                VATEntry2."VAT Settlement No. CZL" := DocNo;
                                VATEntry2.Modify();
                            end;
                        end;
                    }
                    trigger OnAfterGetRecord()
                    begin
                        VATEntry.Reset();
                        VATEntry.SetRange(Type, VATType);
                        VATEntry.SetRange(Closed, false);
                        VATEntry.SetFilter("VAT Date CZL", VATDateFilter);
                        VATEntry.SetRange("VAT Bus. Posting Group", "VAT Posting Setup"."VAT Bus. Posting Group");
                        VATEntry.SetRange("VAT Prod. Posting Group", "VAT Posting Setup"."VAT Prod. Posting Group");
                        if Advance.Number = 1 then
                            VATEntry.SetRange("Advance Letter No.", '')
                        else
                            VATEntry.SetFilter("Advance Letter No.", '<>%1', '');

                        case "VAT Posting Setup"."VAT Calculation Type" of
                            "VAT Posting Setup"."VAT Calculation Type"::"Normal VAT",
                            "VAT Posting Setup"."VAT Calculation Type"::"Reverse Charge VAT",
                            "VAT Posting Setup"."VAT Calculation Type"::"Full VAT":
                                begin
                                    VATEntry.SetCurrentKey(
                                      Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group",
                                      "Gen. Bus. Posting Group", "Gen. Prod. Posting Group",
                                      "EU 3-Party Trade");
                                    if FindFirstEntry then begin
                                        if VATEntry.IsEmpty() then
                                            repeat
                                                VATType := IncrementGenPostingType(VATType);
                                                VATEntry.SetRange(Type, VATType);
                                            until (VATType = VATEntry.Type::Settlement) or not VATEntry.IsEmpty();
                                        FindFirstEntry := false;
                                    end else
                                        if VATEntry.Next() = 0 then
                                            repeat
                                                VATType := IncrementGenPostingType(VATType);
                                                VATEntry.SetRange(Type, VATType);
                                            until (VATType = VATEntry.Type::Settlement) or not VATEntry.IsEmpty();
                                    if IsNotSettlement(VATType) then
                                        VATEntry.FindLast();
                                end;
                            "VAT Posting Setup"."VAT Calculation Type"::"Sales Tax":
                                begin
                                    VATEntry.SetCurrentKey(Type, Closed, "Tax Jurisdiction Code", "Use Tax", "VAT Date CZL");
                                    if FindFirstEntry then begin
                                        if VATEntry.IsEmpty() then
                                            repeat
                                                VATType := IncrementGenPostingType(VATType);
                                                VATEntry.SetRange(Type, VATType);
                                            until (VATType = VATEntry.Type::Settlement) or not VATEntry.IsEmpty();
                                        FindFirstEntry := false;
                                    end else begin
                                        VATEntry.SetRange("Tax Jurisdiction Code");
                                        VATEntry.SetRange("Use Tax");
                                        if VATEntry.Next() = 0 then
                                            repeat
                                                VATType := IncrementGenPostingType(VATType);
                                                VATEntry.SetRange(Type, VATType);
                                            until (VATType = VATEntry.Type::Settlement) or not VATEntry.IsEmpty();
                                    end;
                                    if IsNotSettlement(VATType) then begin
                                        VATEntry.SetRange("Tax Jurisdiction Code", VATEntry."Tax Jurisdiction Code");
                                        VATEntry.SetRange("Use Tax", VATEntry."Use Tax");
                                        VATEntry.FindLast();
                                    end;
                                end;
                        end;

                        if VATType = VATEntry.Type::Settlement then
                            CurrReport.Break();
                    end;

                    trigger OnPreDataItem()
                    begin
                        VATType := VATEntry.Type::Purchase;
                        FindFirstEntry := true;
                    end;
                }
            }
            trigger OnPostDataItem()
            begin
                // Post to settlement account
                if VATAmount <> 0 then begin
                    GenJnlLine.Init();
                    GenJnlLine."System-Created Entry" := true;
                    GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";

                    GLAccSettle.TestField("Gen. Posting Type", GenJnlLine."Gen. Posting Type"::" ".AsInteger());
                    GLAccSettle.TestField("VAT Bus. Posting Group", '');
                    GLAccSettle.TestField("VAT Prod. Posting Group", '');
                    if VATPostingSetup.Get(GLAccSettle."VAT Bus. Posting Group", GLAccSettle."VAT Prod. Posting Group") then
                        VATPostingSetup.TestField("VAT %", 0);
                    GLAccSettle.TestField("Gen. Bus. Posting Group", '');
                    GLAccSettle.TestField("Gen. Prod. Posting Group", '');

                    GenJnlLine.Validate("Account No.", GLAccSettle."No.");
                    GenJnlLine."Posting Date" := PostingDate;
                    GenJnlLine.Validate("VAT Date CZL", PostingDate);
                    GenJnlLine."Document Type" := GenJnlLine."Document Type"::" ";
                    GenJnlLine."Document No." := DocNo;
                    GenJnlLine.Description := VatSettlementTxt;
                    GenJnlLine.Amount := VATAmount;
                    GenJnlLine."Source Currency Code" := GLSetup."Additional Reporting Currency";
                    GenJnlLine."Source Currency Amount" := VATAmountAddCurr;
                    GenJnlLine."Source Code" := SourceCodeSetup."VAT Settlement";
                    GenJnlLine."VAT Posting" := GenJnlLine."VAT Posting"::"Manual VAT Entry";
                    if PostSettlement then
                        PostGenJnlLine(GenJnlLine);
                end;
            end;

            trigger OnPreDataItem()
            begin
                GLEntry.LockTable(); // Avoid deadlock with function 12
                if GLEntry.FindLast() then;
                VATEntry.LockTable();
                VATEntry.Reset();
                NextVATEntryNo := VATEntry.GetLastEntryNo();

                SourceCodeSetup.Get();
                GLSetup.Get();
                VATAmount := 0;
                VATAmountAddCurr := 0;

                if UseAmtsInAddCurr then
                    HeaderText := StrSubstNo(AllAmountsAreInTxt, GLSetup."Additional Reporting Currency")
                else begin
                    GLSetup.TestField("LCY Code");
                    HeaderText := StrSubstNo(AllAmountsAreInTxt, GLSetup."LCY Code");
                end;
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        ShowFilter = false;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(StartingDate; EntrdStartDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Starting Date';
                        TableRelation = "VAT Period CZL";
                        ToolTip = 'Specifies the first date in the period from which VAT entries are processed in the batch job.';

                        trigger OnValidate()
                        begin
                            VATPeriodCZL.Get(EntrdStartDate);
                            if VATPeriodCZL.Next() > 0 then
                                EndDateReq := CalcDate('<-1D>', VATPeriodCZL."Starting Date");
                        end;
                    }
                    field(EndingDate; EndDateReq)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Ending Date';
                        ToolTip = 'Specifies the last date in the period from which VAT entries are processed in the batch job.';
                    }
                    field(PostingDt; PostingDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the date on which the transfer to the VAT account is posted. This field must be filled in.';
                    }
                    field(DocumentNo; DocNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies a document number. This field must be filled in.';
                    }
                    field(SettlementAcc; GLAccSettle."No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Settlement Account';
                        TableRelation = "G/L Account";
                        ToolTip = 'Specifies the number of the VAT settlement account. Select the field to see the chart of account. This field must be filled in.';

                        trigger OnValidate()
                        begin
                            if GLAccSettle."No." <> '' then begin
                                GLAccSettle.Find();
                                GLAccSettle.CheckGLAcc();
                            end;
                        end;
                    }
                    field(ShowVATEntries; PrintVATEntries)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show VAT Entries';
                        ToolTip = 'Specifies if you want the report that is printed during the batch job to contain the individual VAT entries. If you do not choose to print the VAT entries, the settlement amount is shown only for each VAT posting group.';
                    }
                    field(Post; PostSettlement)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Post';
                        ToolTip = 'Specifies if you want the program to post the transfer to the VAT settlement account automatically. If you do not choose to post the transfer, the batch job only prints a test report, and Test Report (not Posted) appears on the report.';
                    }
                    field(AmtsinAddReportingCurr; UseAmtsInAddCurr)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Amounts in Add. Reporting Currency';
                        MultiLine = true;
                        ToolTip = 'Specifies if the reported amounts are shown in the additional reporting currency.';
                    }
                }
            }
        }
    }
    trigger OnPostReport()
    begin
        if PostSettlement and VATPeriodCZL.Get(EntrdStartDate) then begin
            VATPeriodCZL.Closed := true;
            VATPeriodCZL.Modify();
        end;
        OnAfterPostReport();
    end;

    trigger OnPreReport()
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        OnBeforePreReport("VAT Posting Setup");

        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Testfield("Use VAT Date CZL");
        if PostingDate = 0D then
            Error(PostingDateErr);
        if DocNo = '' then
            Error(DocumentNoErr);
        if GLAccSettle."No." = '' then
            Error(SettlementAccErr);
        GLAccSettle.Find();

        if PostSettlement and not Initialized then
            if not ConfirmManagement.GetResponseOrDefault(ConfirmCalcPostQst, true) then
                CurrReport.Quit();

        VATPostingSetupFilter := "VAT Posting Setup".GetFilters();
        if EndDateReq = 0D then
            VATEntry.SetFilter("VAT Date CZL", '%1..', EntrdStartDate)
        else
            VATEntry.SetRange("VAT Date CZL", EntrdStartDate, EndDateReq);
        VATDateFilter := VATEntry.GetFilter("VAT Date CZL");
        Clear(GenJnlPostLine);
        OnAfterPreReport();
    end;

    var
        GLAccSettle: Record "G/L Account";
        SourceCodeSetup: Record "Source Code Setup";
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlLine2: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        VATEntry: Record "VAT Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        GLSetup: Record "General Ledger Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        VATPeriodCZL: Record "VAT Period CZL";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        EntrdStartDate: Date;
        EndDateReq: Date;
        PrintVATEntries: Boolean;
        NextVATEntryNo: Integer;
        PostingDate: Date;
        DocNo: Code[20];
        VATType: Enum "General Posting Type";
        VATAmount: Decimal;
        VATAmountAddCurr: Decimal;
        PostSettlement: Boolean;
        FindFirstEntry: Boolean;
        ReversingEntry: Boolean;
        Initialized: Boolean;
        VATPostingSetupFilter: Text;
        VATDateFilter: Text;
        UseAmtsInAddCurr: Boolean;
        HeaderText: Text[30];
        CalcandPostVATSettlementCaptionLbl: Label 'Calculate and Post VAT Settlement';
        PageCaptionLbl: Label 'Page';
        TestReportnotpostedCaptionLbl: Label 'Test Report (Not Posted)';
        DocNoCaptionLbl: Label 'Document No.';
        SettlementAccCaptionLbl: Label 'Settlement Account';
        DocumentTypeCaptionLbl: Label 'Document Type';
        UserIDCaptionLbl: Label 'User ID';
        TotalCaptionLbl: Label 'Total';
        PostingDateErr: Label 'Enter the posting date.';

        SettlementCaptionLbl: Label 'Settlement';
        PrintCountrySubTotal: Integer;
        CountrySubTotalAmt: array[4] of Decimal;
        CountrySubtotalCaptionLbl: Label 'Total for Country/Region %1', Comment = '%1="Country/Region Code"';
        DocumentNoErr: Label 'Enter the document no.';
        SettlementAccErr: Label 'Enter the settlement account.';
        ConfirmCalcPostQst: Label 'Do you want to calculate and post the VAT Settlement?';
        VatSettlementTxt: Label 'VAT Settlement';
        PeriodTxt: Label 'Period: %1', Comment = '%1 = Period';
        AllAmountsAreInTxt: Label 'All amounts are in %1.', Comment = '%1 = Currency Code';
        PurchaseVatSettlementTxt: Label 'Purchase VAT settlement: #1######## #2########', Comment = '%1 = "VAT Bus. Posting Group", %2 = "VAT Prod. Posting Group"';
        SalesVatSettlementTxt: Label 'Sales VAT settlement  : #1######## #2########', Comment = '%1 = "VAT Bus. Posting Group", %2 = "VAT Prod. Posting Group"';
        VATEntryDocumentNo: Code[20];
        VATEntryDocumentType: Text;

    procedure InitializeRequest(NewStartDate: Date; NewEndDate: Date; NewPostingDate: Date; NewDocNo: Code[20]; NewSettlementAcc: Code[20]; ShowVATEntries: Boolean; Post: Boolean)
    begin
        EntrdStartDate := NewStartDate;
        EndDateReq := NewEndDate;
        PostingDate := NewPostingDate;
        DocNo := NewDocNo;
        GLAccSettle."No." := NewSettlementAcc;
        PrintVATEntries := ShowVATEntries;
        PostSettlement := Post;
        Initialized := true;
        if VATPeriodCZL.Get(EntrdStartDate) then;
    end;

    procedure InitializeRequest2(NewUseAmtsInAddCurr: Boolean)
    begin
        UseAmtsInAddCurr := NewUseAmtsInAddCurr;
    end;

    local procedure GetCurrency(): Code[10]
    begin
        if UseAmtsInAddCurr then
            exit(GLSetup."Additional Reporting Currency");

        exit('');
    end;

    local procedure PostGenJnlLine(var GenJnlLine: Record "Gen. Journal Line")
    var
        DimMgt: Codeunit DimensionManagement;
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        TableID[1] := Database::"G/L Account";
        TableID[2] := Database::"G/L Account";
        No[1] := GenJnlLine."Account No.";
        No[2] := GenJnlLine."Bal. Account No.";
        GenJnlLine."Dimension Set ID" :=
          DimMgt.GetRecDefaultDimID(
            GenJnlLine, 0, TableID, No, GenJnlLine."Source Code",
            GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code", 0, 0);
        GenJnlPostLine.Run(GenJnlLine);
    end;

    procedure SetInitialized(Initialize: Boolean)
    begin
        Initialized := Initialize;
    end;

    local procedure CopyAmounts(var GenJournalLine: Record "Gen. Journal Line"; VATEntry: Record "VAT Entry")
    begin
        GenJournalLine.Amount := -VATEntry.Amount;
        GenJournalLine."VAT Amount" := -VATEntry.Amount;
        GenJournalLine."VAT Base Amount" := -VATEntry.Base - VATEntry."Advance Base";
        GenJournalLine."Source Currency Code" := GLSetup."Additional Reporting Currency";
        GenJournalLine."Source Currency Amount" := -VATEntry."Additional-Currency Amount";
        GenJournalLine."Source Curr. VAT Amount" := -VATEntry."Additional-Currency Amount";
        GenJournalLine."Source Curr. VAT Base Amount" := -VATEntry."Additional-Currency Base";
    end;

    local procedure CreateGenJnlLine(var GenJnlLine2: Record "Gen. Journal Line"; AccountNo: Code[20])
    begin
        Clear(GenJnlLine2);
        GenJnlLine2."System-Created Entry" := true;
        GenJnlLine2."Account Type" := GenJnlLine2."Account Type"::"G/L Account";
        GenJnlLine2.Description := GenJnlLine.Description;
        GenJnlLine2."Posting Date" := PostingDate;
        GenJnlLine2.Validate("VAT Date CZL", PostingDate);
        GenJnlLine2."Document Type" := GenJnlLine2."Document Type"::" ";
        GenJnlLine2."Document No." := DocNo;
        GenJnlLine2."Source Code" := SourceCodeSetup."VAT Settlement";
        GenJnlLine2."VAT Posting" := GenJnlLine2."VAT Posting"::"Manual VAT Entry";
        GenJnlLine2."Account No." := AccountNo;
        GenJnlLine2.Amount := VATEntry.Amount;
        GenJnlLine2."Source Currency Code" := GLSetup."Additional Reporting Currency";
        GenJnlLine2."Source Currency Amount" := VATEntry."Additional-Currency Amount";
    end;

    local procedure SetVatPostingSetupToGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; VATPostingSetup: Record "VAT Posting Setup")
    begin
        GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::Settlement;
        GenJnlLine."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        GenJnlLine."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
        GenJnlLine."VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
    end;

    local procedure IncrementGenPostingType(var OldGenPostingType: Enum "General Posting Type") NewGenPostingType: Enum "General Posting Type"
    begin
        case OldGenPostingType of
            OldGenPostingType::" ":
                exit(NewGenPostingType::Purchase);
            OldGenPostingType::Purchase:
                exit(NewGenPostingType::Sale);
            OldGenPostingType::Sale:
                exit(NewGenPostingType::Settlement);
        end;

        OnAfterIncrementGenPostingType(OldGenPostingType, NewGenPostingType);
    end;

    local procedure IsNotSettlement(GeneralPostingType: Enum "General Posting Type"): Boolean
    begin
        exit(
            (GeneralPostingType = GeneralPostingType::" ") or
            (GeneralPostingType = GeneralPostingType::Purchase) or
            (GeneralPostingType = GeneralPostingType::Sale));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPreReport()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostReport()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePreReport(var VATPostingSetup: Record "VAT Posting Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIncrementGenPostingType(OldGenPostingType: Enum "General Posting Type"; var NewGenPostingType: Enum "General Posting Type")
    begin
    end;
}