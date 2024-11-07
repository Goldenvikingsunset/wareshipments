tableextension 50700 "Warehouse Request Ext" extends "Warehouse Request"
{
    fields
    {
        field(50000; "Destination Sub. No."; Code[20])
        {
            Caption = 'Destination Sub. No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Destination Type" = CONST(Customer)) "Ship-to Address".Code WHERE("Customer No." = FIELD("Destination No."))
            ELSE IF ("Destination Type" = CONST(Vendor)) "Order Address".Code WHERE("Vendor No." = FIELD("Destination No."));
        }
    }
}