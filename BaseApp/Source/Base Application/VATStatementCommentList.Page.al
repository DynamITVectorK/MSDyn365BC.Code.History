page 11772 "VAT Statement Comment List"
{
    Caption = 'VAT Statement Comment List (Obsolete)';
    DataCaptionFields = "VAT Statement Template Name", "VAT Statement Name";
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "VAT Statement Comment Line";
    ObsoleteState = Pending;
    ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
    ObsoleteTag = '17.0';

    layout
    {
        area(content)
        {
            repeater(Control1220003)
            {
                ShowCaption = false;
                field("VAT Statement Name"; "VAT Statement Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of VAT statement.';
                }
                field(Date; Date)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date of VAT statement comment.';
                }
                field(Comment; Comment)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the comment for VAT statement.';
                }
            }
        }
    }

    actions
    {
    }
}
