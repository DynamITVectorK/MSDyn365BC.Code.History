table 11741 "Cash Desk Event"
{
    Caption = 'Cash Desk Event';
    LookupPageID = "Cash Desk Events";
    ObsoleteState = Pending;
    ObsoleteReason = 'Moved to Cash Desk Localization for Czech.';
    ObsoleteTag = '17.0';

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; "Cash Desk No."; Code[20])
        {
            Caption = 'Cash Desk No.';

            trigger OnLookup()
            begin
                BankAccount."No." := "Cash Desk No.";
                if PAGE.RunModal(PAGE::"Cash Desk List", BankAccount) = ACTION::LookupOK then
                    Validate("Cash Desk No.", BankAccount."No.");
            end;

            trigger OnValidate()
            begin
                if "Cash Desk No." <> '' then begin
                    BankAccount.Get("Cash Desk No.");
                    BankAccount.TestField("Account Type", BankAccount."Account Type"::"Cash Desk");
                    BankAccount.TestField(Blocked, false);
                end;
            end;
        }
        field(5; "Cash Document Type"; Option)
        {
            Caption = 'Cash Document Type';
            OptionCaption = ' ,Receipt,Withdrawal';
            OptionMembers = " ",Receipt,Withdrawal;

            trigger OnValidate()
            begin
                "Document Type" := "Document Type"::" ";

                if (("Account Type" = "Account Type"::Vendor) and ("Cash Document Type" = "Cash Document Type"::Withdrawal)) or
                   (("Account Type" = "Account Type"::Customer) and ("Cash Document Type" = "Cash Document Type"::Receipt))
                then
                    "Document Type" := "Document Type"::Payment;
                if (("Account Type" = "Account Type"::Customer) and ("Cash Document Type" = "Cash Document Type"::Withdrawal)) or
                   (("Account Type" = "Account Type"::Vendor) and ("Cash Document Type" = "Cash Document Type"::Receipt))
                then
                    "Document Type" := "Document Type"::Refund;
            end;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(11; "Account Type"; Option)
        {
            Caption = 'Account Type';
            OptionCaption = ' ,G/L Account,Customer,Vendor,Bank Account,Fixed Asset,Employee';
            OptionMembers = " ","G/L Account",Customer,Vendor,"Bank Account","Fixed Asset",Employee;

            trigger OnValidate()
            begin
                if "Account Type" <> xRec."Account Type" then begin
                    Validate("Cash Document Type");
                    Validate("Account No.", '');
                    Validate("Gen. Posting Type", "Gen. Posting Type"::" ");
                    Validate("VAT Bus. Posting Group", '');
                    Validate("VAT Prod. Posting Group", '');
                    Validate("EET Transaction", false);
                end;
            end;
        }
        field(12; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = IF ("Account Type" = CONST(" ")) "Standard Text"
            ELSE
            IF ("Account Type" = CONST("G/L Account")) "G/L Account"
            ELSE
            IF ("Account Type" = CONST(Customer)) Customer
            ELSE
            IF ("Account Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Account Type" = CONST(Employee)) Employee
            ELSE
            IF ("Account Type" = CONST("Bank Account")) "Bank Account" WHERE("Account Type" = CONST("Bank Account"))
            ELSE
            IF ("Account Type" = CONST("Fixed Asset")) "Fixed Asset";

            trigger OnValidate()
            var
                StdTxt: Record "Standard Text";
                GLAcc: Record "G/L Account";
                Employee: Record Employee;
            begin
                if ("Account No." <> xRec."Account No.") and ("Account No." <> '') then
                    case "Account Type" of
                        "Account Type"::" ":
                            begin
                                StdTxt.Get("Account No.");
                                Description := StdTxt.Description;
                            end;
                        "Account Type"::"G/L Account":
                            begin
                                GLAcc.Get("Account No.");
                                Description := GLAcc.Name;
                                "Gen. Posting Type" := GLAcc."Gen. Posting Type";
                                "VAT Bus. Posting Group" := GLAcc."VAT Bus. Posting Group";
                                "VAT Prod. Posting Group" := GLAcc."VAT Prod. Posting Group";
                            end;
                        "Account Type"::Customer:
                            begin
                                Customer.Get("Account No.");
                                Description := Customer.Name;
                                "Gen. Posting Type" := "Gen. Posting Type"::" ";
                                "VAT Bus. Posting Group" := '';
                                "VAT Prod. Posting Group" := '';
                            end;
                        "Account Type"::Vendor:
                            begin
                                Vendor.Get("Account No.");
                                Vendor.CheckBlockedVendOnJnls(Vendor, "Document Type", false);
                                Description := Vendor.Name;
                                "Gen. Posting Type" := "Gen. Posting Type"::" ";
                                "VAT Bus. Posting Group" := '';
                                "VAT Prod. Posting Group" := '';
                            end;
                        "Account Type"::"Fixed Asset":
                            begin
                                FA.Get("Account No.");
                                Description := FA.Description;
                                "Gen. Posting Type" := "Gen. Posting Type"::" ";
                                "VAT Bus. Posting Group" := '';
                                "VAT Prod. Posting Group" := '';
                            end;
                        "Account Type"::"Bank Account":
                            begin
                                BankAccount.Get("Account No.");
                                Description := BankAccount.Name;
                                "Gen. Posting Type" := "Gen. Posting Type"::" ";
                                "VAT Bus. Posting Group" := '';
                                "VAT Prod. Posting Group" := '';
                            end;
                        "Account Type"::Employee:
                            begin
                                Employee.Get("Account No.");
                                Description := CopyStr(Employee.FullName, 1, MaxStrLen(Description));
                                "Gen. Posting Type" := "Gen. Posting Type"::" ";
                                "VAT Bus. Posting Group" := '';
                                "VAT Prod. Posting Group" := '';
                            end;
                    end;
            end;
        }
        field(14; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = ' ,Payment,,,,,Refund';
            OptionMembers = " ",Payment,,,,,Refund;
        }
        field(29; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
                Modify;
            end;
        }
        field(30; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
                Modify;
            end;
        }
        field(72; "Gen. Posting Type"; Option)
        {
            Caption = 'Gen. Posting Type';
            OptionCaption = ' ,Purchase,Sale';
            OptionMembers = " ",Purchase,Sale;
        }
        field(116; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(117; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(31125; "EET Transaction"; Boolean)
        {
            Caption = 'EET Transaction';
            ObsoleteState = Pending;
            ObsoleteReason = 'Moved to Cash Desk Localization for Czech.';
            ObsoleteTag = '18.0';

            trigger OnValidate()
            begin
                if "EET Transaction" then
                    if not ("Account Type" in ["Account Type"::"G/L Account", "Account Type"::Customer]) then
                        FieldError("Account Type");
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        DimMgt.DeleteDefaultDim(DATABASE::"Cash Desk Event", Code);
    end;

    trigger OnRename()
    begin
        DimMgt.RenameDefaultDim(DATABASE::"Cash Desk Event", xRec.Code, Code);
    end;

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        FA: Record "Fixed Asset";
        BankAccount: Record "Bank Account";
        DimMgt: Codeunit DimensionManagement;

    [Obsolete('Moved to Cash Desk Localization for Czech.', '17.4')]
    [Scope('OnPrem')]
    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        if not IsTemporary then
            DimMgt.SaveDefaultDim(DATABASE::"Cash Desk Event", Code, FieldNumber, ShortcutDimCode);
    end;
}
