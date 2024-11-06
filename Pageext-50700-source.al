pageextension 50700 "Source Documents Ext" extends "Source Documents"
{
    layout
    {
        addafter("Destination No.")
        {
            field("Destination Sub. No."; Rec."Destination Sub. No.")
            {
                ApplicationArea = Warehouse;
                ToolTip = 'Specifies the sub destination number for the warehouse request.';
            }
        }
    }
}