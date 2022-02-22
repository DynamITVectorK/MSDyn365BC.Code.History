table 11784 "Non Deductible VAT Setup"
{
    Caption = 'Non Deductible VAT Setup';
    ObsoleteState = Pending;
    ObsoleteReason = 'The functionality of Non-deductible VAT will be removed and this table should not be used. (Obsolete::Removed in release 01.2021)';
    ObsoleteTag = '15.3';

    fields
    {
        field(1; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(2; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(3; "From Date"; Date)
        {
            Caption = 'From Date';
        }
        field(4; "Non Deductible VAT %"; Decimal)
        {
            Caption = 'Non Deductible VAT %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
    }

    keys
    {
        key(Key1; "VAT Bus. Posting Group", "VAT Prod. Posting Group", "From Date")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}
