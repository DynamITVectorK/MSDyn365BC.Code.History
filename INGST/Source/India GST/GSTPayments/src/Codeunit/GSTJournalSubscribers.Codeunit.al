codeunit 18245 "GST Journal Subscribers"
{
    //Bank Charge Subscribers
    [EventSubscriber(ObjectType::Table, Database::"Bank Charge", 'OnAfterValidateEvent', 'GST Group Code', False, False)]
    local procedure ValidateGSTGroupCodeBankCharge(var Rec: Record "Bank Charge")
    begin
        GSTJournalValidations.GSTGroupCodeBankCharge(rec);
    end;

    //Bank Charge Deemed Value Setup - Subscribers
    [EventSubscriber(ObjectType::Table, Database::"Bank Charge Deemed Value Setup", 'OnAfterValidateEvent', 'Lower Limit', False, False)]
    local Procedure ValidateLowerLimit(var Rec: Record "Bank Charge Deemed Value Setup")
    begin

        GSTJournalValidations.LowerLimit(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Charge Deemed Value Setup", 'OnAfterValidateEvent', 'Upper Limit', False, False)]
    local Procedure ValidateUpperLimit(
        var Rec: Record "Bank Charge Deemed Value Setup";
        var xRec: Record "Bank Charge Deemed Value Setup")
    begin
        GSTJournalValidations.Upperlimit(rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Charge Deemed Value Setup", 'OnAfterDeleteEvent', '', False, False)]
    local procedure ValidateBankChargeDeemedDelete(var Rec: Record "Bank Charge Deemed Value Setup")
    begin
        GSTJournalValidations.BankChargeDeemedDelete(rec);
    end;

    //Journal Bank Charges Subscribers
    [EventSubscriber(ObjectType::Table, Database::"Journal Bank Charges", 'OnAfterValidateEvent', 'Bank Charge', false, false)]
    local procedure ValidateBankCharge(var Rec: Record "Journal Bank Charges")
    begin
        GSTJournalValidations.JnlBankCharge(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Journal Bank Charges", 'OnAfterValidateEvent', 'Amount', false, false)]
    local Procedure ValidatejnlAmount(var Rec: Record "Journal Bank Charges")
    begin
        GSTJournalValidations.JnlBankChargeAmount(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Journal Bank Charges", 'OnAfterValidateEvent', 'GST Group Code', false, false)]
    local procedure ValidateJnlBankChargeGSTGroupCode(var Rec: Record "Journal Bank Charges")
    begin
        GSTJournalValidations.JnlBankChargeGSTGroupCode(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Journal Bank Charges", 'OnAfterValidateEvent', 'LCY', false, false)]
    local procedure validateLcy(var Rec: Record "Journal Bank Charges")
    begin
        rec.Validate(amount, rec.amount);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Journal Bank Charges", 'OnAfterValidateEvent', 'GST Document Type', false, false)]
    local procedure ValidateGSTDocumentType(var Rec: Record "Journal Bank Charges")
    begin
        GSTJournalValidations.JnlBankChargeGSTDocumentType(rec);
    end;

    //GST TDSTCS Setup - Subscribers
    [EventSubscriber(ObjectType::Table, Database::"GST TDS/TCS Setup", 'OnAfterValidateEvent', 'Type', false, false)]
    local procedure ValidateGSTTDSTCSType(var Rec: Record "GST TDS/TCS Setup")
    begin
        GSTJournalValidations.GSTTDSTCSGSTType(rec);
    end;

    var
        GSTJournalValidations: Codeunit "GST Journal Validations";
}