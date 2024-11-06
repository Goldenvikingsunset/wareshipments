report 50700 "Create Whse. Shipments"
{
    Caption = 'Create Whse. Shipments';
    ProcessingOnly = true;
    ApplicationArea = Warehouse;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("Warehouse Request"; "Warehouse Request")
        {
            DataItemTableView = sorting(Type, "Location Code", "Source Type", "Source Subtype", "Source No.")
                               where("Document Status" = const(Released),
                                     "Completely Handled" = const(false),
                                     Type = const(Outbound));
            RequestFilterFields = "Location Code", "Source Document", "Source No.", "Destination Type", "Destination No.", "Shipping Agent Code";

            trigger OnPreDataItem()
            begin
                if ToDate = 0D then
                    Error(Text002);

                Window.Open(Text001);
            end;

            trigger OnAfterGetRecord()
            var
                GetSourceDoc: Report "Get Source Documents";
                WhseShptHeader: Record "Warehouse Shipment Header";
                WhseActLine: Record "Warehouse Activity Line";
                SalesHeader: Record "Sales Header";
                Customer: Record Customer;
                IsExistingShipment: Boolean;
            begin
                Window.Update(1, "Source No.");

                // Check for blocked customer (standard logic)
                if "Source Type" = Database::"Sales Line" then
                    if Customer.Get("Destination No.") then
                        if (Customer.Blocked = Customer.Blocked::Ship) or (Customer.Blocked = Customer.Blocked::All) then
                            CurrReport.Skip();  // Skip blocked customers

                // Check for an open shipment that matches location, destination, and shipping agent
                IsExistingShipment := false;
                if CombineShipments then begin
                    WhseShptHeader.Reset();
                    WhseShptHeader.SetRange("Location Code", "Location Code");
                    WhseShptHeader.SetRange("Destination Type", "Destination Type");
                    WhseShptHeader.SetRange("Destination No.", "Destination No.");
                    WhseShptHeader.SetRange("Destination Sub. No.", "Destination Sub. No.");
                    WhseShptHeader.SetRange("Shipping Agent Code", "Shipping Agent Code");
                    WhseShptHeader.SetRange(Status, WhseShptHeader.Status::Open);

                    // Check if open shipment with no picks exists (standard logic)
                    if AppendToExisting = AppendToExisting::"If No Picks Exists" then begin
                        WhseActLine.SetRange("Whse. Document Type", WhseActLine."Whse. Document Type"::Shipment);
                        WhseActLine.SetRange("Whse. Document No.", WhseShptHeader."No.");
                        if not WhseActLine.FindFirst() then
                            IsExistingShipment := true;
                    end else
                        IsExistingShipment := WhseShptHeader.FindFirst();
                end;

                // If an existing, open shipment was found, set it as the target for appending
                if IsExistingShipment then
                    GetSourceDoc.SetOneCreatedShptHeader(WhseShptHeader)
                else begin
                    // Create a new shipment if no suitable open shipment found
                    Clear(GetSourceDoc);
                    GetSourceDoc.SetHideDialog(true);
                    GetSourceDoc.UseRequestPage(false);
                    GetSourceDoc.SetTableView("Warehouse Request");
                    GetSourceDoc.Run();
                end;
            end;

            trigger OnPostDataItem()
            begin
                // Release all shipments created in this session
                ReleaseShipments();
                Window.Close();
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ToDate; ToDate)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Ending Date';
                    }
                    field(CombineShipments; CombineShipments)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Combine Shipments';
                    }
                    field(AppendToExisting; AppendToExisting)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Append to Existing Shipment';
                        Enabled = CombineShipments;
                        OptionCaption = 'Never,Always,If No Picks Exists';
                    }
                }
            }
        }
    }

    var
        Window: Dialog;
        ToDate: Date;
        CombineShipments: Boolean;
        AppendToExisting: Option Never,Always,"If No Picks Exists";
        Text001: Label 'Processing Document No. #1########';
        Text002: Label 'The Ending Date must be entered.';

    local procedure ReleaseShipments()
    var
        WhseShptHeader: Record "Warehouse Shipment Header";
        ReleaseWhseShipment: Codeunit "Whse.-Shipment Release";
    begin
        // Release all open shipments that were created or modified in this process
        WhseShptHeader.SetRange(Status, WhseShptHeader.Status::Open);
        if WhseShptHeader.FindSet() then
            repeat
                ReleaseWhseShipment.Release(WhseShptHeader);
            until WhseShptHeader.Next() = 0;
    end;
}