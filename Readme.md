# Enhanced Warehouse Shipment Combination

## Overview
A modern Business Central extension that intelligently combines warehouse shipments based on Ship-to Codes. Built on Olof Simren's original concept, enhanced with modern event architecture and improved reliability.

## Features
- Event-driven architecture
- Intelligent shipment combination
- Robust error handling
- No base modifications

## Process Flow

```mermaid
flowchart TD
    A[Release Sales Order] --> B[Create Warehouse Request]
    B --> C{Check Existing Shipments}
    C -->|Match Found| D[Validate Ship-to Code]
    C -->|No Match| E[Create New Shipment]
    D -->|Match| F[Add to Existing Shipment]
    D -->|No Match| E
    E --> G[Set Destination Fields]
    F --> H[Update Lines]
    G --> I[Process Shipment]
    H --> I
```

## Installation
1. Import AL files
2. Publish extension
3. No additional setup needed

## Usage
1. Release sales orders
2. Run "Create Warehouse Shipment" batch job
3. System automatically combines matching shipments

## Combination Logic

```mermaid
flowchart TD
    A[Get Source Document] --> B{Check Combination Settings}
    B -->|Combine=Yes| C[Check Existing Shipments]
    B -->|Combine=No| D[Create New Shipment]
    C --> E{Check Ship-to Code}
    E -->|Match| F{Check Shipping Agent}
    E -->|No Match| D
    F -->|Match| G{Check for Picks}
    F -->|No Match| D
    G -->|No Picks| H[Add to Existing]
    G -->|Has Picks| D
```

## Requirements
- Business Central 2024 Wave 1 (BC23)
- Standard warehouse setup

## Technical Details
- Event-based architecture
- Clean record handling
- Robust error prevention
- Transaction management

## Contributing
Issues and enhancements welcome via issue tracker

## Version History
- 2.0.0: Modern event architecture
- 1.0.0: Initial implementation

## License
[Your License]

## Credits
- Original concept: Olof Simren
- Modern implementation: Paul Rennison
