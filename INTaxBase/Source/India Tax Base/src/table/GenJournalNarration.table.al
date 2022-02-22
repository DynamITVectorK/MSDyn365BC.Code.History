table 18550 "Gen. Journal Narration"
{
    Caption = 'Gen. Journal Narration';

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            TableRelation = "Gen. Journal Template";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Journal Template Name"));
        }
        field(3; "Document No."; Code[20])
        {
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Gen. Journal Line No."; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; "Line No."; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; Narration; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;

            trigger OnLookup()
            begin
                if Page.RunModal(0, StdTxt) = Action::LookupOK then
                    Narration := StdTxt.Description;
            end;
        }
    }
    keys
    {
        key(Key1; "Journal Template Name", "Journal Batch Name", "Document No.", "Gen. Journal Line No.", "Line No.")
        {
            Clustered = true;
        }
    }
    var
        StdTxt: Record "Standard Text";
}