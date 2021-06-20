table 11757 "Reg. No. Srv Config"
{
    Caption = 'Reg. No. Srv Config';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; Enabled; Boolean)
        {
            Caption = 'Enabled';
        }
        field(3; "Service Endpoint"; Text[250])
        {
            Caption = 'Service Endpoint';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if not IsEmpty then
            Error(CannotInsertMultipleSettingsErr);
    end;

    var
        RegNoSettingIsNotEnabledErr: Label 'Registration Service Setting is not enabled.';
        CannotInsertMultipleSettingsErr: Label 'You cannot insert multiple settings.';

    procedure RegNoSrvIsEnabled(): Boolean
    var
        RegNoSrvConfig: Record "Reg. No. Srv Config";
    begin
        RegNoSrvConfig.SetRange(Enabled, true);
        exit(RegNoSrvConfig.FindFirst and RegNoSrvConfig.Enabled);
    end;

    procedure GetRegNoURL(): Text
    var
        RegNoSrvConfig: Record "Reg. No. Srv Config";
    begin
        RegNoSrvConfig.SetRange(Enabled, true);
        if not RegNoSrvConfig.FindFirst then
            Error(RegNoSettingIsNotEnabledErr);

        RegNoSrvConfig.TestField("Service Endpoint");

        exit(RegNoSrvConfig."Service Endpoint");
    end;
}
