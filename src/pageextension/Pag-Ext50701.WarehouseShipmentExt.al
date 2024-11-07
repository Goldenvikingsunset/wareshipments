pageextension 50701 "Warehouse Shipment Ext" extends "Warehouse Shipment"
{
    layout
    {
        addafter("Sorting Method")
        {
            field("Destination Type"; Rec."Destination Type")
            {
                ApplicationArea = Warehouse;
                ToolTip = 'Specifies the type of destination for the warehouse shipment.';
                Editable = false;
            }
            field("Destination No."; Rec."Destination No.")
            {
                ApplicationArea = Warehouse;
                ToolTip = 'Specifies the destination number for the warehouse shipment.';
                Editable = false;
            }
            field("Destination Sub. No."; Rec."Destination Sub. No.")
            {
                ApplicationArea = Warehouse;
                ToolTip = 'Specifies the sub destination number for the warehouse shipment.';
                Editable = false;
            }
        }
    }
}