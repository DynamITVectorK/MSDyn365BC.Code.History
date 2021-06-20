codeunit 143060 "Test Initialize Handler"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Test Initialize", 'OnBeforeTestSuiteInitialize', '', false, false)]
    local procedure UpdateRecordsOnBeforeTestSuiteInitialize(CallerCodeunitID: Integer)
    begin
        UpdatePurchasesPayablesSetup();
        UpdateSalesReceivablesSetup();
        UpdateAssemblySetup();
        UpdateInventorySetup();
        UpdateIntrastat();
        UpdateGeneralPostingSetup();
        UpdateReportSelections();
    end;

    local procedure UpdatePurchasesPayablesSetup()
    var
        PurchSetup: Record "Purchases & Payables Setup";
    begin
        PurchSetup.Get();
        PurchSetup."Invoice Rounding" := true;
        PurchSetup.Modify();
    end;

    local procedure UpdateSalesReceivablesSetup()
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.Get();
        SalesSetup."Credit Memo Confirmation" := false;
        SalesSetup."Invoice Rounding" := true;
        SalesSetup.Modify();
    end;

    local procedure UpdateAssemblySetup()
    var
        AssemblySetup: Record "Assembly Setup";
    begin
        AssemblySetup.Get();
        AssemblySetup."Gen. Bus. Posting Group" := '';
        AssemblySetup.Modify();
    end;

    local procedure UpdateInventorySetup()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        InventorySetup."Automatic Cost Posting" := false;
        InventorySetup."Def.Template for Phys.Neg.Adj" := '';
        InventorySetup."Def.Template for Phys.Pos.Adj" := '';
        InventorySetup.Modify();
    end;

    local procedure UpdateIntrastat()
    var
        IntrastatJnlBatch: Record "Intrastat Jnl. Batch";
    begin
        IntrastatJnlBatch.DeleteAll();
    end;

    local procedure UpdateGeneralPostingSetup()
    var
        GeneralPostingSetup: Record "General Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
    begin
        if GeneralPostingSetup.FindSet() then
            repeat
                if GeneralPostingSetup."Purch. Account" = GeneralPostingSetup."Purch. Line Disc. Account" then
                    GeneralPostingSetup."Purch. Line Disc. Account" := LibraryERM.CreateGLAccountNo();
                if GeneralPostingSetup."Purch. Account" = GeneralPostingSetup."Purch. Inv. Disc. Account" then
                    GeneralPostingSetup."Purch. Inv. Disc. Account" := LibraryERM.CreateGLAccountNo();
                GeneralPostingSetup.Modify();
            until GeneralPostingSetup.Next() = 0;
    end;

    local procedure UpdateReportSelections()
    var
        ReportSelections: Record "Report Selections";
    begin
        if ReportSelections.Get(ReportSelections.Usage::Reminder, 1) then begin
            ReportSelections.Validate("Report ID", Report::Reminder);
            ReportSelections.Modify();
        end;
        if ReportSelections.Get(ReportSelections.Usage::"Fin.Charge", 1) then begin
            ReportSelections.Validate("Report ID", Report::"Finance Charge Memo");
            ReportSelections.Modify();
        end;
    end;
}