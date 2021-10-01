page 31006 "Sales Advance Letters History"
{
    Caption = 'Sales Advance Letters History';
    Editable = true;
    PageType = Document;
    SaveValues = true;
    SourceTable = Customer;

    layout
    {
        area(content)
        {
            field(CurrentMenuTypeValue; CurrentMenuType)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies current menu type';
                Visible = false;
            }
            group(Control1220006)
            {
                ShowCaption = false;
                field(OpenBtn; CurrentMenuTypeOpt)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Status';
                    OptionCaption = 'Open,Pending Advance Payment,Pending Advance Invoice,Pending Final Invoice,Closed';
                    ToolTip = 'Specifies the status of the sales advance letters.';

                    trigger OnValidate()
                    begin
                        if CurrentMenuTypeOpt = CurrentMenuTypeOpt::x5 then
                            x5CurrentMenuTypeOptOnValidate;
                        if CurrentMenuTypeOpt = CurrentMenuTypeOpt::x4 then
                            x4CurrentMenuTypeOptOnValidate;
                        if CurrentMenuTypeOpt = CurrentMenuTypeOpt::x3 then
                            x3CurrentMenuTypeOptOnValidate;
                        if CurrentMenuTypeOpt = CurrentMenuTypeOpt::x2 then
                            x2CurrentMenuTypeOptOnValidate;
                        if CurrentMenuTypeOpt = CurrentMenuTypeOpt::x1 then
                            x1CurrentMenuTypeOptOnValidate;
                    end;
                }
                field("STRSUBSTNO(Text001Lbl,QtyOfDocs[1])"; StrSubstNo(Text001Lbl, QtyOfDocs[1]))
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Open';
                    Editable = false;
                    ToolTip = 'Specifies the number of opened sales advance letters of the customer.';
                }
                field("STRSUBSTNO(Text001Lbl,QtyOfDocs[2])"; StrSubstNo(Text001Lbl, QtyOfDocs[2]))
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending Advance';
                    Editable = false;
                    ToolTip = 'Specifies the number of pending advance letters of the customer.';
                }
                field("STRSUBSTNO(Text001Lbl,QtyOfDocs[3])"; StrSubstNo(Text001Lbl, QtyOfDocs[3]))
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending Adv. Invoice';
                    Editable = false;
                    ToolTip = 'Specifies the number of pending advance invoice of the customer.';
                }
                field("STRSUBSTNO(Text001Lbl,QtyOfDocs[4])"; StrSubstNo(Text001Lbl, QtyOfDocs[4]))
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending Final Invoice';
                    Editable = false;
                    ToolTip = 'Specifies the number of pending final invoice of the customer.';
                }
                field("STRSUBSTNO(Text001Lbl,QtyOfDocs[5])"; StrSubstNo(Text001Lbl, QtyOfDocs[5]))
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Closed';
                    Editable = false;
                    ToolTip = 'Specifies the number of closed sales advance letters of the customer.';
                }
            }
            part(SubForm; "S.Adv. Letters History Subform")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Bill-to Customer No." = FIELD("No.");
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        CurrentMenuTypeOpt := CurrentMenuType;
    end;

    trigger OnOpenPage()
    begin
        CurrentMenuType := 0;
        ChangeSubMenu(1);
    end;

    var
        SalesAdvanceLetterLine: Record "Sales Advance Letter Line";
        SalesPostAdvances: Codeunit "Sales-Post Advances";
        QtyOfDocs: array[5] of Integer;
        CurrentMenuType: Integer;
        CurrentMenuTypeOpt: Option x1,x2,x3,x4,x5;
        Text001Lbl: Label '(%1)', Locked = true;

    [Scope('OnPrem')]
    procedure ChangeSubMenu(NewMenuType: Integer)
    begin
        if CurrentMenuType <> NewMenuType then begin
            CurrentMenuType := NewMenuType;
            SalesPostAdvances.CalcNoOfDocs("No.", QtyOfDocs);

            SalesAdvanceLetterLine.SetRange("Bill-to Customer No.", "No.");
            SalesAdvanceLetterLine.SetRange(Status, CurrentMenuType - 1);
            CurrPage.SubForm.PAGE.SetTableView(SalesAdvanceLetterLine);
            CurrPage.SubForm.PAGE.SetCurrSubPageUpdate;
        end;
    end;

    local procedure x1CurrentMenuTypeOptOnPush()
    begin
        ChangeSubMenu(1);
    end;

    local procedure x1CurrentMenuTypeOptOnValidate()
    begin
        x1CurrentMenuTypeOptOnPush;
    end;

    local procedure x2CurrentMenuTypeOptOnPush()
    begin
        ChangeSubMenu(2);
    end;

    local procedure x2CurrentMenuTypeOptOnValidate()
    begin
        x2CurrentMenuTypeOptOnPush;
    end;

    local procedure x3CurrentMenuTypeOptOnPush()
    begin
        ChangeSubMenu(3);
    end;

    local procedure x3CurrentMenuTypeOptOnValidate()
    begin
        x3CurrentMenuTypeOptOnPush;
    end;

    local procedure x4CurrentMenuTypeOptOnPush()
    begin
        ChangeSubMenu(4);
    end;

    local procedure x4CurrentMenuTypeOptOnValidate()
    begin
        x4CurrentMenuTypeOptOnPush;
    end;

    local procedure x5CurrentMenuTypeOptOnPush()
    begin
        ChangeSubMenu(5);
    end;

    local procedure x5CurrentMenuTypeOptOnValidate()
    begin
        x5CurrentMenuTypeOptOnPush;
    end;
}
