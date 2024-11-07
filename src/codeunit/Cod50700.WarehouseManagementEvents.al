codeunit 50700 "Warehouse Management Events"
{
    // Sales Release Events
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Sales Release", 'OnAfterCreateWhseRequest', '', false, false)]
    local procedure OnAfterCreateWhseRequest(var WhseRqst: Record "Warehouse Request"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; WhseType: Option Inbound,Outbound)
    begin
        WhseRqst.Validate("Destination Sub. No.", SalesHeader."Ship-to Code");
        WhseRqst.Modify();
    end;

    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnAfterCreateShptHeader', '', false, false)]
    local procedure OnAfterCreateShptHeader(var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; WarehouseRequest: Record "Warehouse Request")
    begin
        WarehouseShipmentHeader."Destination Type" := WarehouseRequest."Destination Type";
        WarehouseShipmentHeader."Destination No." := WarehouseRequest."Destination No.";
        WarehouseShipmentHeader."Destination Sub. No." := WarehouseRequest."Destination Sub. No.";
        WarehouseShipmentHeader.Modify();
    end;

    // Purchase Release Events
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Purch. Release", 'OnAfterCreateWhseRqst', '', false, false)]
    local procedure OnAfterPurchCreateWhseRequest(var WhseRqst: Record "Warehouse Request"; var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; WhseType: Option Inbound,Outbound)
    var
        OrderAddr: Record "Order Address";
    begin
        WhseRqst."Destination Type" := WhseRqst."Destination Type"::Vendor;
        WhseRqst."Destination No." := PurchHeader."Buy-from Vendor No.";

        // Handle Order Address
        if PurchHeader."Order Address Code" <> '' then begin
            // Validate Order Address exists
            if OrderAddr.Get(PurchHeader."Buy-from Vendor No.", PurchHeader."Order Address Code") then
                WhseRqst."Destination Sub. No." := PurchHeader."Order Address Code";
        end;

        WhseRqst.Modify();
    end;

    // Transfer Release Events - Inbound
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Transfer Release", 'OnAfterCreateInboundWhseRequest', '', false, false)]
    local procedure OnAfterCreateInboundWhseRequest(var WarehouseRequest: Record "Warehouse Request"; var TransferHeader: Record "Transfer Header")
    begin
        WarehouseRequest."Destination Type" := WarehouseRequest."Destination Type"::Location;
        WarehouseRequest."Destination No." := TransferHeader."Transfer-to Code";
        // Transfer doesn't use Destination Sub. No.
        WarehouseRequest.Modify();
    end;

    // Transfer Release Events - Outbound
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Transfer Release", 'OnAfterCreateOutboundWhseRequest', '', false, false)]
    local procedure OnAfterCreateOutboundWhseRequest(var WarehouseRequest: Record "Warehouse Request"; var TransferHeader: Record "Transfer Header")
    begin
        WarehouseRequest."Destination Type" := WarehouseRequest."Destination Type"::Location;
        WarehouseRequest."Destination No." := TransferHeader."Transfer-to Code";
        // Transfer doesn't use Destination Sub. No.
        WarehouseRequest.Modify();
    end;

    // Get Source Documents Events
    // Add new event subscriber for Get Source Documents
    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnSalesLineOnAfterGetRecordOnBeforeCreateShptHeader', '', false, false)]
    local procedure OnSalesLineOnAfterGetRecordOnBeforeCreateShptHeader(SalesLine: Record "Sales Line"; var WarehouseRequest: Record "Warehouse Request"; var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; var WhseHeaderCreated: Boolean; var OneHeaderCreated: Boolean; var IsHandled: Boolean; var ErrorOccured: Boolean; var LinesCreated: Boolean)
    var
        SalesHeader: Record "Sales Header";
        ExistingShipment: Record "Warehouse Shipment Header";
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        if not IsHandled then begin
            // Set the Ship-to Code in Warehouse Request
            if SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
                WarehouseRequest."Destination Sub. No." := SalesHeader."Ship-to Code";

            // Look for existing shipment
            ExistingShipment.Reset();
            ExistingShipment.SetRange("Location Code", WarehouseRequest."Location Code");
            ExistingShipment.SetRange("Destination Type", WarehouseRequest."Destination Type");
            ExistingShipment.SetRange("Destination No.", WarehouseRequest."Destination No.");
            ExistingShipment.SetRange("Destination Sub. No.", WarehouseRequest."Destination Sub. No.");
            ExistingShipment.SetRange("Shipping Agent Code", WarehouseRequest."Shipping Agent Code");
            ExistingShipment.SetRange(Status, ExistingShipment.Status::Open);

            if ExistingShipment.FindFirst() then begin
                // Check for picks
                WhseActivityLine.Reset();
                WhseActivityLine.SetRange("Whse. Document Type", WhseActivityLine."Whse. Document Type"::Shipment);
                WhseActivityLine.SetRange("Whse. Document No.", ExistingShipment."No.");

                if not WhseActivityLine.FindFirst() then begin
                    WarehouseShipmentHeader := ExistingShipment;
                    WhseHeaderCreated := true;
                    OneHeaderCreated := true;
                    IsHandled := false; // Allow standard processing to continue
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnBeforeCreateShptHeader', '', false, false)]
    local procedure OnBeforeCreateShptHeader(var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; var WarehouseRequest: Record "Warehouse Request"; SalesLine: Record "Sales Line"; var IsHandled: Boolean; Location: Record Location; var WhseShptLine: Record "Warehouse Shipment Line"; var ActivitiesCreated: Integer; var WhseHeaderCreated: Boolean; var RequestType: Option Receive,Ship)
    begin
        if not IsHandled then begin
            if WarehouseShipmentHeader."No." = '' then begin
                // Only set these for new shipments
                WarehouseShipmentHeader."Destination Type" := WarehouseRequest."Destination Type";
                WarehouseShipmentHeader."Destination No." := WarehouseRequest."Destination No.";
                WarehouseShipmentHeader."Destination Sub. No." := WarehouseRequest."Destination Sub. No.";
                WarehouseShipmentHeader."Shipping Agent Code" := WarehouseRequest."Shipping Agent Code";
            end;
            IsHandled := false; // Let standard processing continue
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnAfterProcessDocumentLine', '', false, false)]
    local procedure OnAfterProcessDocumentLine(var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; var WarehouseRequest: Record "Warehouse Request"; var LineCreated: Boolean; WarehouseReceiptHeader: Record "Warehouse Receipt Header"; OneHeaderCreated: Boolean; WhseHeaderCreated: Boolean)
    begin
        if (WarehouseShipmentHeader."No." <> '') then begin
            if WarehouseShipmentHeader."Destination Sub. No." = WarehouseRequest."Destination Sub. No." then
                LineCreated := true;
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnBeforeWhseShptHeaderInsert', '', false, false)]
    local procedure OnBeforeWhseShptHeaderInsert(var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; var WarehouseRequest: Record "Warehouse Request"; SalesLine: Record "Sales Line"; TransferLine: Record "Transfer Line"; SalesHeader: Record "Sales Header")
    begin
        if WarehouseShipmentHeader."No." = '' then begin
            WarehouseShipmentHeader."Destination Type" := WarehouseRequest."Destination Type";
            WarehouseShipmentHeader."Destination No." := WarehouseRequest."Destination No.";
            WarehouseShipmentHeader."Destination Sub. No." := WarehouseRequest."Destination Sub. No.";
            WarehouseShipmentHeader."Shipping Agent Code" := WarehouseRequest."Shipping Agent Code";
        end;
    end;

}