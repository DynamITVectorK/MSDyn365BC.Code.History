tableextension 18395 "GST Trans. Receipt Header Ext" extends "Transfer Receipt Header"
{
    fields
    {
        field(18390; "Vendor No."; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        field(18391; "Time of Removal"; Time)
        {
            Caption = 'Time of Removal';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18392; "LR/RR No."; Date)
        {
            Caption = 'LR/RR No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18393; "LR/RR Date"; Date)
        {
            Caption = 'LR/RR Date';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18394; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18395; "Mode of Transport"; text[15])
        {
            Caption = 'Mode of Transport';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18396; "Bill Of Entry No."; Text[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Bill Of Entry No.';
        }
        field(18397; "Bill Of Entry Date"; Date)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Bill Of Entry Date';
        }
        field(18398; "Distance (Km)"; Decimal)
        {
            Caption = 'Distance (Km)';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18399; "Vehicle Type"; Enum "GST Vehicle Type")
        {
            Caption = 'Vehicle Type';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18400; "Vendor Invoice No."; code[20])
        {
            Caption = 'Vendor Invoice No.';
            DataClassification = EndUserIdentifiableInformation;
        }
    }
}