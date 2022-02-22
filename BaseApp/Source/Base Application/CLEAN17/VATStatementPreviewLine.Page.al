#if CLEAN17
page 475 "VAT Statement Preview Line"
{
    Caption = 'Lines';
    Editable = false;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "VAT Statement Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Row No."; "Row No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a number that identifies the line.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the VAT statement line.';
                }
                field(Type; Type)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies what the VAT statement line will include.';
                }
                field("Amount Type"; "Amount Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the VAT statement line shows the VAT amounts, or the base amounts on which the VAT is calculated.';
                }
                field("VAT Bus. Posting Group"; "VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT specification of the involved customer or vendor to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field("VAT Prod. Posting Group"; "VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT specification of the involved item or resource to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field("Tax Jurisdiction Code"; "Tax Jurisdiction Code")
                {
                    ApplicationArea = SalesTax;
                    ToolTip = 'Specifies a tax jurisdiction code for the statement.';
                    Visible = false;
                }
                field("Use Tax"; "Use Tax")
                {
                    ApplicationArea = SalesTax;
                    ToolTip = 'Specifies whether to use only entries from the VAT Entry table that are marked as Use Tax to be totaled on this line.';
                    Visible = false;
                }
                field(ColumnValue; ColumnValue)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 1;
                    BlankZero = true;
                    Caption = 'Column Amount';
                    DrillDown = true;
                    ToolTip = 'Specifies the type of entries that will be included in the amounts in columns.';

                    trigger OnDrillDown()
                    begin
                        case Type of
                            Type::"Account Totaling":
                                begin
                                    GLEntry.SetFilter("G/L Account No.", "Account Totaling");
                                    CopyFilter("Date Filter", GLEntry."Posting Date");
                                    OnColumnValueDrillDownOnBeforeRunGeneralLedgerEntries(VATEntry, GLEntry, Rec);
                                    PAGE.Run(PAGE::"General Ledger Entries", GLEntry);
                                end;
                            Type::"VAT Entry Totaling":
                                begin
                                    VATEntry.Reset();
                                    if not
                                       VATEntry.SetCurrentKey(
                                         Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group", "Posting Date")
                                    then
                                        VATEntry.SetCurrentKey(
                                          Type, Closed, "Tax Jurisdiction Code", "Use Tax", "Posting Date");
                                    VATEntry.SetRange(Type, "Gen. Posting Type");
                                    VATEntry.SetRange("VAT Bus. Posting Group", "VAT Bus. Posting Group");
                                    VATEntry.SetRange("VAT Prod. Posting Group", "VAT Prod. Posting Group");
                                    VATEntry.SetRange("Tax Jurisdiction Code", "Tax Jurisdiction Code");
                                    VATEntry.SetRange("Use Tax", "Use Tax");
                                    if GetFilter("Date Filter") <> '' then
                                        if PeriodSelection = PeriodSelection::"Before and Within Period" then
                                            VATEntry.SetRange("Posting Date", 0D, GetRangeMax("Date Filter"))
                                        else
                                            CopyFilter("Date Filter", VATEntry."Posting Date");
                                    case Selection of
                                        Selection::Open:
                                            VATEntry.SetRange(Closed, false);
                                        Selection::Closed:
                                            VATEntry.SetRange(Closed, true);
                                        Selection::"Open and Closed":
                                            VATEntry.SetRange(Closed);
                                    end;
                                    OnBeforeOpenPageVATEntryTotaling(VATEntry, Rec, GLEntry);
                                    PAGE.Run(PAGE::"VAT Entries", VATEntry);
                                end;
                            Type::"Row Totaling",
                            Type::Description:
                                Error(Text000, FieldCaption(Type), Type);
                        end;
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        CalcColumnValue(Rec, ColumnValue, 0);
        if "Print with" = "Print with"::"Opposite Sign" then
            ColumnValue := -ColumnValue;
    end;

    var
        Text000: Label 'Drilldown is not possible when %1 is %2.';

    protected var
        GLEntry: Record "G/L Entry";
        VATEntry: Record "VAT Entry";
        VATStatement: Report "VAT Statement";
        ColumnValue: Decimal;
        Selection: Enum "VAT Statement Report Selection";
        PeriodSelection: Enum "VAT Statement Report Period Selection";
        UseAmtsInAddCurr: Boolean;

    local procedure CalcColumnValue(VATStatementLine: Record "VAT Statement Line"; var ColumnValue: Decimal; Level: Integer)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcColumnValue(VATStatementLine, ColumnValue, Level, IsHandled, Selection, PeriodSelection, false, UseAmtsInAddCurr);
        if IsHandled then
            exit;

        VATStatement.CalcLineTotal(VATStatementLine, ColumnValue, Level);
    end;

    procedure UpdateForm(var VATStmtName: Record "VAT Statement Name"; NewSelection: Enum "VAT Statement Report Selection"; NewPeriodSelection: Enum "VAT Statement Report Period Selection"; NewUseAmtsInAddCurr: Boolean)
    begin
        SetRange("Statement Template Name", VATStmtName."Statement Template Name");
        SetRange("Statement Name", VATStmtName.Name);
        VATStmtName.CopyFilter("Date Filter", "Date Filter");
        Selection := NewSelection;
        PeriodSelection := NewPeriodSelection;
        UseAmtsInAddCurr := NewUseAmtsInAddCurr;
        VATStatement.InitializeRequest(VATStmtName, Rec, Selection, PeriodSelection, false, UseAmtsInAddCurr);
        OnUpdateFormOnBeforePageUpdate(VATStmtName, Rec, Selection, PeriodSelection, false, UseAmtsInAddCurr);
        CurrPage.Update();

        OnAfterUpdateForm();
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCalcColumnValue(VATStatementLine: Record "VAT Statement Line"; var TotalAmount: Decimal; Level: Integer; var IsHandled: Boolean; Selection: Enum "VAT Statement Report Selection"; PeriodSelection: Enum "VAT Statement Report Period Selection"; PrintInIntegers: Boolean; UseAmtsInAddCurr: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOpenPageVATEntryTotaling(var VATEntry: Record "VAT Entry"; var VATStatementLine: Record "VAT Statement Line"; var GLEntry: Record "G/L Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnColumnValueDrillDownOnBeforeRunGeneralLedgerEntries(var VATEntry: Record "VAT Entry"; var GLEntry: Record "G/L Entry"; var VATStatementLine: Record "VAT Statement Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateFormOnBeforePageUpdate(var NewVATStmtName: Record "VAT Statement Name"; var NewVATStatementLine: Record "VAT Statement Line"; NewSelection: Enum "VAT Statement Report Selection"; NewPeriodSelection: Enum "VAT Statement Report Period Selection"; NewPrintInIntegers: Boolean; NewUseAmtsInAddCurr: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterUpdateForm()
    begin
    end;
}
#endif