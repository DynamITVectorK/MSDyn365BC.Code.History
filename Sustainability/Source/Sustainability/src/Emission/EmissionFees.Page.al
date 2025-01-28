namespace Microsoft.Sustainability.Emission;

page 6245 "Emission Fees"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Emission Fee";
    Caption = 'Emission Fees';
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Emission Type"; Rec."Emission Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies gas emission type.';
                }
                field("Scope Type"; Rec."Scope Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Scope Type field.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Starting Date field.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Ending Date field.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Country/Region Code field.';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Responsibility Center field.';
                }
                field("Carbon Fee"; Rec."Carbon Fee")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies internal carbon fee that a company charges itself for each unit of CO2 equivalent that it emits. It can be configured only if the Emission Type is CO2, and it will be calculated not based on CO2 emission but based on CO2e.';
                }
                field("Carbon Equivalent Factor"; Rec."Carbon Equivalent Factor")
                {
                    Editable = not (Rec."Emission Type" = Rec."Emission Type"::CO2);
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the coefficient that converts the impact of various greenhouse gases into the equivalent amount of carbon dioxide based on their global warming potential. for CO2 it will be 1 by default and you cannot change this value. For other gases you need to add coefficients. If you use for example that 1 kilogram of CH4 is equivalent to 28 kilograms of CO2, to calculate this coefficient you need to use value 1/28.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Update Carbon Fees")
            {
                Caption = 'Update Carbon Fees';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Update Carbon Fees and CO2e on Posted transactions for already Posted values related to the new setup';
                Image = UpdateShipment;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = report "Batch Update Carbon Emission";
            }
        }
    }
}