# System Architecture

This document explains the end-to-end backend architecture for Swift Transit with the three primary actors: **Passenger/User**, **Bus (driver/device)**, and **Bus Owner/Operator**.

## High-level overview
- **Entry points**: REST HTTP API (`rest` package) and WebSocket streams for live location (`location` package).
- **Business services**: Domain services for users, routes, buses, tickets, and transactions orchestrated in `cmd/serve.go`.
- **Data & infrastructure**: PostgreSQL/PostGIS for persistence, Redis for ephemeral state and idempotency, RabbitMQ for ticket-processing pipelines, and SSLCommerz as the payment gateway.
- **Realtime layer**: A shared WebSocket hub distributes bus GPS updates to passengers and supports bus-side ticket validation checks.

## Architecture diagram (Mermaid)
```mermaid
graph LR
    %% Clients
    subgraph Clients
        U[Passenger App / Web]
        B[Bus Device / Driver App]
        O[Bus Owner Portal]
    end

    %% API Gateway (single Go HTTP server)
    subgraph API[REST & WS API (Go)]
        MW[Middleware Manager\n(logging, CORS, auth)]
        UH[User Handler]
        RH[Route Handler]
        BH[Bus Handler]
        TH[Ticket Handler]
        TrH[Transaction Handler]
        HUB[WebSocket Hub\n(location & ticket check)]
    end

    %% Domain Services
    subgraph Services
        USvc[User Service]
        RSvc[Route Service]
        BSvc[Bus Service\n(login, ticket check)]
        TSvc[Ticket Service\nasync purchase, QR generation]
        TrSvc[Transaction Service\nwallet recharge]
    end

    %% Data & Infra
    subgraph Infra
        DB[(PostgreSQL/PostGIS\nusers, routes, stops, bus_credentials, tickets, transactions)]
        Redis[(Redis\nticket status, recharge sessions)]
        MQ[(RabbitMQ\n"ticket_queue", ticket check jobs)]
        Pay[SSLCommerz Payment Gateway]
    end

    %% Workers
    subgraph Workers
        TW[Ticket Worker\ncreates tickets, QR, payment URLs]
        TCW[Ticket Check Worker\nvalidates payments, marks paid]
    end

    %% Client to API flows
    U -->|REST: signup/login, search routes, buy ticket, wallet| MW
    B -->|REST: bus login, register, ticket validation| MW
    O -->|REST: manage fleet, assign routes, view analytics| MW
    U -. WS: subscribe route locations .-> HUB
    B -. WS: publish bus GPS & ticket scans .-> HUB

    %% API routing to handlers
    MW --> UH
    MW --> RH
    MW --> BH
    MW --> TH
    MW --> TrH
    HUB --> TSvc

    %% Handlers to services
    UH --> USvc
    RH --> RSvc
    BH --> BSvc
    TH --> TSvc
    TrH --> TrSvc

    %% Services to data/infra
    USvc --> DB
    RSvc --> DB
    BSvc --> DB
    TSvc --> DB
    TSvc --> Redis
    TSvc --> MQ
    TSvc --> Pay
    TrSvc --> Redis
    TrSvc --> Pay
    TrSvc --> DB

    %% Workers consume from MQ and Redis
    MQ --> TW
    MQ --> TCW
    TW --> DB
    TW --> Redis
    TW --> Pay
    TCW --> DB
    TCW --> Redis

    %% Analytics for Bus Owner
    subgraph Analytics[Bus Owner Analytics]
        OA[Operational metrics\n(per route, per bus)]
        RA[Revenue & Ticket Sales\n(totals, history)]
        HA[Historical fleet utilization\n(route contributions, capacity)]
    end

    DB --> OA
    DB --> RA
    Redis --> OA
    MQ --> HA
    OA --> O
    RA --> O
    HA --> O
```

## How the system works for each actor
### Passenger/User
1. **Discovery**: Sends REST requests through the middleware to the Route Handler which calls `route.NewService` to search routes and stops.
2. **Ticket purchase**: Ticket Handler calls `ticket.NewService` to calculate fare, enforce per-route ticket limits, publish the request to RabbitMQ, and set an initial `ticket_status:<tracking_id>` entry in Redis.
3. **Payment & download**: Workers generate payment URLs (SSLCommerz) and PDFs/QR codes, persist tickets in PostgreSQL, update Redis with download links, and mark paid tickets via the Ticket Check Worker.
4. **Realtime updates**: Subscribes to the WebSocket hub for route-specific bus locations; the hub fans out GPS data received from buses.

### Bus (driver/device)
1. **Login & route binding**: Uses Bus Handler to authenticate with `bus.NewService`, selecting the up/down route variant from stored `bus_credentials`.
2. **Live location**: Publishes GPS over WebSocket to the hub, which relays to subscribed passengers on the same route.
3. **Ticket validation**: Scans passenger QR; Bus Service verifies route, payment, and over-travel logic using Ticket Repo, then marks the ticket as checked.

### Bus Owner/Operator
1. **Fleet contribution**: Registers buses (up to 10 per owner policy) by creating `bus_credentials` tied to up/down routes; routes come from `route.NewService` and persist in PostgreSQL.
2. **Operational view**: Queries aggregated data per bus and route (active tickets, check-in counts, over-travel events) fed from ticket records and Redis status caches.
3. **Revenue analytics**: Uses transaction history (wallet recharges) and ticket payments to compute total revenue, ticket counts, per-route earnings, and historical trends. These metrics are derived from `tickets`, `transactions`, and per-bus route assignments.
4. **Historical reporting**: Combines message traces from RabbitMQ (processing volumes) and DB timestamps to visualize utilization over time (e.g., buses per route per day, payment completion ratios, refund/cancellation rates).

## Key components and responsibilities
- **`cmd/serve.go`** wires configuration, database migrations, repositories, services, background workers, the WebSocket hub, and HTTP handlers.
- **Repositories** encapsulate persistence for users, routes, buses, tickets, and transactions (PostgreSQL/PostGIS via `sqlx`).
- **Services** enforce business rules: fare calculation, ticket limits, password hashing for buses, recharge validation, and ticket over-travel detection.
- **Middleware layer** provides logging, CORS, authentication, and context utilities reused across handlers.
- **Infra adapters** (Redis, RabbitMQ, SSLCommerz) decouple transport concerns from domain logic and enable resilient async processing.

## Analytics data sources for Bus Owners
- **Tickets**: QR codes, payment status, check-in flags, route IDs, batch IDs, and cancellation timestamps feed into per-bus and per-route sales reports.
- **Transactions**: Wallet credits/debits track monetary flows for revenue calculations and reconciliation with the payment gateway.
- **Routes & Bus Credentials**: Define which buses contributed to each route segment (up/down variants), enabling capacity planning and per-owner contribution summaries.
- **Realtime & Queue telemetry**: Redis ticket statuses plus RabbitMQ queue depth/throughput help monitor operational health and historical load patterns.
