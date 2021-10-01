codeunit 31096 "Release Reverse Charge"
{
    TableNo = "Reverse Charge Header";
    ObsoleteState = Pending;
    ObsoleteReason = 'The functionality of Reverse Charge Statement will be removed and this codeunit should not be used. (Obsolete::Removed in release 01.2021)';
    ObsoleteTag = '15.3';

    trigger OnRun()
    var
        ReverseChargeLn: Record "Reverse Charge Line";
    begin
        if Status = Status::Released then
            exit;

        TestField("VAT Registration No.");
        TestField("Document Date");

        ReverseChargeLn.SetRange("Reverse Charge No.", "No.");
        if ReverseChargeLn.IsEmpty then
            Error(NothingToReleaseErr, "No.");

        if ReverseChargeLn.FindSet then
            repeat
                ReverseChargeLn.TestField("VAT Registration No.");
                ReverseChargeLn.TestField("VAT Base Amount (LCY)");
            until ReverseChargeLn.Next = 0;

        Status := Status::Released;

        Modify(true);
    end;

    var
        NothingToReleaseErr: Label 'There is nothing to release for declaration No. %1.', Comment = '%1 = Reverse Charge No.';

    [Scope('OnPrem')]
    [Obsolete('The functionality of Reverse Charge Statement will be removed and this function should not be used. (Obsolete::Removed in release 01.2021)','15.3')]
    procedure Reopen(var ReverseChargeHdr: Record "Reverse Charge Header")
    begin
        with ReverseChargeHdr do begin
            if Status = Status::Open then
                exit;

            Status := Status::Open;

            Modify(true);
        end;
    end;
}
