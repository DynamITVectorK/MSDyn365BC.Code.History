page 18811 "TCS Nature Of Collections"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "TCS Nature of Collection";
    Caption = 'TCS Nature of Collections';
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Nature of Collection on which TCS is applied.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the TCS Nature of Collection.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("TCS Rates")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'TCS Rates';
                Promoted = false;
                Image = EditList;
                RunObject = page "Tax Rates";
                RunPageLink = "Tax Type" = const('TCS');
                RunPageMode = Edit;
                ToolTip = 'Specifies the TCS rates for each NOC and assessee type in the TCS rates window.';
            }
            action(EditInExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Edit in Excel';
                Image = Excel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Send the data in the page to an Excel file for analysis or editing';
                trigger OnAction()
                var
                    ODataUtility: Codeunit ODataUtility;
                    TCSNatureofCollectionLbl: Label 'Code eq %1', Comment = '%1 = TCS Nature of Collection';
                begin
                    ODataUtility.EditWorksheetInExcel('TCS Nature of Collection', CurrPage.ObjectId(false), StrSubstNo(TCSNatureofCollectionLbl, Rec.Code));
                end;
            }
            action(ClearFilter)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Clear Filter';
                Image = ClearFilter;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Clear the filer applied on the Page';

                trigger OnAction()
                begin
                    reset();
                end;
            }
        }
    }
}