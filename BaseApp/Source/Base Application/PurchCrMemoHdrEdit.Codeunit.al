codeunit 10767 "Purch. Cr. Memo Hdr. - Edit"
{
    Permissions = TableData "Purch. Cr. Memo Hdr." = rm;
    TableNo = "Purch. Cr. Memo Hdr.";

    trigger OnRun()
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        PurchCrMemoHdr := Rec;
        PurchCrMemoHdr.LockTable();
        PurchCrMemoHdr.Find();
        PurchCrMemoHdr."Operation Description" := "Operation Description";
        PurchCrMemoHdr."Operation Description 2" := "Operation Description 2";
        PurchCrMemoHdr."Special Scheme Code" := "Special Scheme Code";
        PurchCrMemoHdr."Cr. Memo Type" := "Cr. Memo Type";
        PurchCrMemoHdr."Correction Type" := "Correction Type";
        OnRunOnBeforeTestFieldNo(PurchCrMemoHdr, Rec);
        PurchCrMemoHdr.TestField("No.", "No.");
        PurchCrMemoHdr.Modify();
        Rec := PurchCrMemoHdr;
        UpdateSIIDocUploadState(Rec);
    end;

    local procedure UpdateSIIDocUploadState(PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    var
        SIIDocUploadState: Record "SII Doc. Upload State";
        SIIManagement: Codeunit "SII Management";
    begin
        if not SIIManagement.IsSIISetupEnabled then
            exit;

        if not SIIDocUploadState.GetSIIDocUploadStateByDocument(
             SIIDocUploadState."Document Source"::"Vendor Ledger".AsInteger(),
             SIIDocUploadState."Document Type"::"Credit Memo".AsInteger(),
             PurchCrMemoHdr."Posting Date",
             PurchCrMemoHdr."No.")
        then
            exit;

        SIIDocUploadState."Purch. Cr. Memo Type" := PurchCrMemoHdr."Cr. Memo Type" + 1;
        SIIDocUploadState."Purch. Special Scheme Code" := PurchCrMemoHdr."Special Scheme Code" + 1;
        SIIDocUploadState.IDType := PurchCrMemoHdr."ID Type";
        SIIDocUploadState."Succeeded Company Name" := PurchCrMemoHdr."Succeeded Company Name";
        SIIDocUploadState."Succeeded VAT Registration No." := PurchCrMemoHdr."Succeeded VAT Registration No.";
        SIIDocUploadState.Modify();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforeTestFieldNo(var PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; PurchCrMemoHeaderRec: Record "Purch. Cr. Memo Hdr.")
    begin
    end;
}
