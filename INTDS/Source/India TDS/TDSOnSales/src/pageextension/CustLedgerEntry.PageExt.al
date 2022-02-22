pageextension 18668 "Cust. Ledger Entry" extends "Customer Ledger Entries"
{
    layout
    {
        addafter(Amount)
        {
            field("Certificate No."; "Certificate No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the certificate number as per the certificate received.';
            }
            field("TDS Certificate Rcpt Date"; "TDS Certificate Rcpt Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the date on which TDS certificate has been received.';
            }
            field("TDS Certificate Amount"; "TDS Certificate Amount")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specify the TDS certificate amount as per the TDS certificate.';
            }
            field("TDS Certificate Receivable"; "TDS Certificate Receivable")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specify customer ledger entries against which TDS certificate is receivable.';
            }
            field("TDS Certificate Received"; "TDS Certificate Received")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Mark in this field specify the same entry in the Rectify TDS Cert. Details window.';
            }
            field("TDS Section Code"; "TDS Section Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the section codes on which TDS against customer is calculated.';
            }
            field("Certificate Received"; "Certificate Received")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specify whether report to generate for certificate received or not.';
            }
        }
    }
}