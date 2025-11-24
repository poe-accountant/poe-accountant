# Infrastructure for POE-Accountant

At a high level, POE accountant can be boiled down to the following services:
1. Redis / Valkey (caching and queues)
2. Postgres (storage)
3. API Service
4. Ninja Service
5. Frontend Website

## Redis / Valkey
Redis (Valkey implementation) is used for:
1. Queue Management System
2. Caching

### Queues
The queue management system is used via microservice endpoints that listen to certain events published. This ensures the ability to scale.

### Caching
The caching system allows us to cache on a timer and share that with all other services to ensure our API access is unrestricted as much as possible. Hitting rate limits is something we don't want to do as best we can.

## Postgres
Postgres is used for long-term storage such as user account details and previous results for users.

## API Service
The API Service is a gateway into the backend system, essentially acting as an entrypoint for many actions. It connects to other microservices in the backend.

## Ninja Service
The pathofexile.com/trade gateway. It handles all incoming requests and translates them into data we need retrieved from pathofexile.com/trade and other sources.

## Frontend Website
A static React / vite website
