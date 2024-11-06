tableextension 50701 "Warehouse Shipment Header Ext" extends "Warehouse Shipment Header"
{
    fields
    {
        field(50000; "Destination Type"; Enum "Warehouse Destination Type")
        {
            Caption = 'Destination Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50001; "Destination No."; Code[20])
        {
            Caption = 'Destination No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Destination Type" = CONST(Vendor)) Vendor
            ELSE IF ("Destination Type" = CONST(Customer)) Customer
            ELSE IF ("Destination Type" = CONST(Location)) Location;
            Editable = false;
        }
        field(50002; "Destination Sub. No."; Code[20])
        {
            Caption = 'Destination Sub. No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Destination Type" = CONST(Customer)) "Ship-to Address".Code WHERE("Customer No." = FIELD("Destination No."))
            ELSE IF ("Destination Type" = CONST(Vendor)) "Order Address".Code WHERE("Vendor No." = FIELD("Destination No."));
            Editable = false;
        }
    }
}