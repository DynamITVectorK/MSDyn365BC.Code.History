pageextension 20259 "Sales Quote Ext" extends "Sales Quote"
{
    layout
    {
        addbefore(IncomingDocAttachFactBox)
        {
            part(TaxInformation; "Tax Information Factbox")
            {
                Provider = SalesLines;
                SubPageLink = "Table ID Filter" = const(37), "Document Type Filter" = field("Document Type"), "Document No. Filter" = field("Document No."), "Line No. Filter" = field("Line No.");
                ApplicationArea = Basic, Suite;
            }
        }
    }
}