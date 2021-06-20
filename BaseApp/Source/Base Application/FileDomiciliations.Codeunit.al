codeunit 2000021 "File Domiciliations"
{
    TableNo = "Direct Debit Collection Entry";

    trigger OnRun()
    var
        DomJnlLine: Record "Domiciliation Journal Line";
        DirectDebitCollection: Record "Direct Debit Collection";
        DomJnlManagement: Codeunit DomiciliationJnlManagement;
    begin
        DirectDebitCollection.Get(GetRangeMin("Direct Debit Collection No."));
        DomJnlLine.SetRange("Journal Template Name", DirectDebitCollection.Identifier);
        DomJnlLine.SetRange("Journal Batch Name", DirectDebitCollection."Domiciliation Batch Name");
        DomJnlLine.SetRange("ISO Currency Code", ISOCurrencyCode);
        DomJnlLine.FindSet();
        DirectDebitCollection.Delete();
        Commit();
        DomJnlManagement.CreateDomiciliations(DomJnlLine);
        DomJnlManagement.OpenJournal(DirectDebitCollection."Domiciliation Batch Name", DomJnlLine);
        // Entry No. has been used to mark which wrapper is used.
        "Entry No." := CODEUNIT::"File Domiciliations";
    end;

    var
        ISOCurrencyCode: Label 'EUR';
}

