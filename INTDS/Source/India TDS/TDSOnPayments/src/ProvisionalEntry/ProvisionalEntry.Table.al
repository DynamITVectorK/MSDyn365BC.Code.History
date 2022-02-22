table 18766 "Provisional Entry"
{
    Caption = 'Provisional Entry';
    DrillDownPageID = "Provisional Entries";
    LookupPageID = "Provisional Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(7; "Party Type"; enum "GenJnl Party Type")
        {
            Caption = 'Party Type';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(8; "Party Code"; Code[20])
        {
            Caption = 'Party Code';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = IF ("Party Type" = CONST(Vendor)) Vendor."No."
            ELSE
            IF ("Party Type" = CONST(Customer)) Customer."No.";
        }
        field(9; "Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Account Type';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(10; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = IF ("Account Type" = CONST("G/L Account")) "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                                                      Blocked = CONST(false))
            ELSE
            IF ("Account Type" = CONST(Customer)) Customer
            ELSE
            IF ("Account Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Account Type" = CONST("Bank Account")) "Bank Account"
            ELSE
            IF ("Account Type" = CONST("Fixed Asset")) "Fixed Asset";
        }
        field(11; "TDS Section Code"; Code[10])
        {
            Caption = 'TDS Section Code';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "TDS Section";
        }
        field(12; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(13; "Debit Amount"; Decimal)
        {
            Caption = 'Debit Amount';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(14; "Credit Amount"; Decimal)
        {
            Caption = 'Credit Amount';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(15; "Bal. Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Bal. Account Type';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(16; "Bal. Account No."; Code[20])
        {
            Caption = 'Bal. Account No.';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = IF ("Bal. Account Type" = CONST("G/L Account")) "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                                                           Blocked = CONST(false))
            ELSE
            IF ("Bal. Account Type" = CONST(Customer)) Customer
            ELSE
            IF ("Bal. Account Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Bal. Account Type" = CONST("Bank Account")) "Bank Account"
            ELSE
            IF ("Bal. Account Type" = CONST("Fixed Asset")) "Fixed Asset";
        }
        field(17; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = Location;
        }
        field(18; "Externl Document No."; Code[35])
        {
            Caption = 'Externl Document No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(19; Reversed; Boolean)
        {
            Caption = 'Reversed';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(20; "Original Invoice Posted"; Boolean)
        {
            Caption = 'Original Invoice Posted';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(21; "Original Invoice Reversed"; Boolean)
        {
            Caption = 'Original Invoice Reversed';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(22; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(23; "Applied by Vendor Ledger Entry"; Integer)
        {
            Caption = 'Applied by Vendor Ledger Entry';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(24; "Reversed After TDS Paid"; Boolean)
        {
            Caption = 'Reversed After TDS Paid';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(25; Open; Boolean)
        {
            Caption = 'Open';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(26; "Applied Invoice No."; Code[20])
        {
            Caption = 'Applied Invoice No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(27; "Posted Document No."; Code[20])
        {
            Caption = 'Posted Document No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(28; "Purchase Invoice No."; Code[20])
        {
            Caption = 'Purchase Invoice No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(29; "Invoice Jnl Batch Name"; Code[10])
        {
            Caption = 'Invoice Jnl Batch Name';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(30; "Invoice Jnl Template Name"; Code[10])
        {
            Caption = 'Invoice Jnl Template Name';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(31; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(32; "Amount LCY"; Decimal)
        {
            Caption = 'Amount LCY';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(33; "Applied User ID"; Code[50])
        {
            Caption = 'Applied User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(34; "Actual Invoice Posting Date"; Date)
        {
            Caption = 'Actual Invoice Posting Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(35; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = Currency;
        }
        field(36; Update; Boolean)
        {
            Caption = 'Update';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    procedure Apply(GenJournalLine: Record "Gen. Journal Line")
    var
        GenJnlLine: Record "Gen. Journal Line";
        ProvisionalEntry: Record "Provisional Entry";
        PostingDateEarlierErr: Label 'Invoice Posting Date must not be earlier than Provisional Entry Posting Date.';
        AlreadyAppliedErr: Label 'Provisional Entry is already applied.';
        MultiEntryApplyErr: Label 'You canot apply more than one Provisional Entry.';
    begin
        GenJnlLine.GET(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", GenJournalLine."Line No.");
        IF "Purchase Invoice No." <> '' then
            ERROR(AlreadyAppliedErr);
        IF GenJnlLine."Applied Provisional Entry" <> 0 then
            ERROR(MultiEntryApplyErr);
        IF "Posting Date" > GenJnlLine."Posting Date" then
            ERROR(PostingDateEarlierErr);
        GenJnlLine.TestField("Bal. Account No.", "Bal. Account No.");
        GenJnlLine.TestField(Amount, Amount);
        GenJnlLine.TestField("Location Code", "Location Code");
        GenJnlLine.TestField("Account No.", "Party Code");
        GenJnlLine.TestField("Currency Code", "Currency Code");
        GenJnlLine."Applied Provisional Entry" := "Entry No.";
        GenJnlLine.Modify();

        ProvisionalEntry.GET("Entry No.");
        ProvisionalEntry."Purchase Invoice No." := GenJnlLine."Document No.";
        ProvisionalEntry."Invoice Jnl Batch Name" := GenJnlLine."Journal Batch Name";
        ProvisionalEntry."Invoice Jnl Template Name" := GenJnlLine."Journal Template Name";
        ProvisionalEntry."Applied User ID" := CopyStr(UserId, 1, 50);
        ProvisionalEntry.Modify();
    end;

    procedure Unapply(GenJournalLine: Record "Gen. Journal Line")
    var
        GenJnlLine: Record "Gen. Journal Line";
        ProvisionalEntry: Record "Provisional Entry";
        DiffUserErr: Label 'This entry is already applied by another user.';
    begin
        if "Purchase Invoice No." <> '' then
            if UserId <> "Applied User ID" then
                Error(DiffUserErr);

        GenJnlLine.GET(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", GenJournalLine."Line No.");
        ProvisionalEntry.GET("Entry No.");
        ProvisionalEntry."Purchase Invoice No." := '';
        ProvisionalEntry."Invoice Jnl Batch Name" := '';
        ProvisionalEntry."Invoice Jnl Template Name" := '';
        ProvisionalEntry."Applied User ID" := '';
        ProvisionalEntry.Modify();
        GenJnlLine."Applied Provisional Entry" := 0;
        GenJnlLine.Modify();
    end;
}
