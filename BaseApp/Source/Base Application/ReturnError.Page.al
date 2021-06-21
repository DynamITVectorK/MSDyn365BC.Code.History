page 15000013 "Return Error"
{
    Caption = 'Return Error';
    Editable = false;
    PageType = List;
    SourceTable = "Return Error";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Waiting Journal Reference"; "Waiting Journal Reference")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the waiting journal reference associated with the return error.';
                }
                field("Message Text"; "Message Text")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the message text of the return error.';
                }
                field("Payment Order ID"; "Payment Order ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID of the payment order associated with the return error.';
                    Visible = false;
                }
                field(Date; Date)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date of the return error.';
                    Visible = false;
                }
                field(Time; Time)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the time of the return error.';
                    Visible = false;
                }
                field("Transaction Name"; "Transaction Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transaction name of the return error.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}
