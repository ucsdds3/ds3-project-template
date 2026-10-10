# CoffeeVend

Cloud-connected coffee vending for DS3 members.

CoffeeVend is a hardware-focused vending system that dispenses one coffee cup and one coffee pod after a DS3 member redeems a coffee through the DS3 member portal.

The project combines:

- ESP32 embedded programming
- Servo/motor control
- Sensors
- CAD and 3D printing
- Supabase backend integration
- AWS Lambda and API Gateway
- Cloud monitoring with CloudWatch
- Operational data collection and reliability analysis

## Project Goal

Build a reliable end-to-end system where:

**Member redeems coffee → backend validates redemption → machine receives authorization → cup + pod dispense → sensors confirm success → inventory/redemption status updates**

The final system should connect DS3’s existing website and Supabase backend to a physical vending machine controlled by an ESP32.

---

## System Overview

CoffeeVend is split into several major subsystems:

### Hardware
- ESP32 microcontroller
- Servo or motor-driven cup dispenser
- Servo or motor-driven pod dispenser
- IR/optical sensors for dispense confirmation
- 3D-printed mechanical components
- Physical enclosure and storage magazines

### Backend / Cloud
- Supabase for existing DS3 users, points, redemptions, inventory, and event data
- AWS Lambda for vending logic
- Amazon API Gateway for backend API endpoints
- Amazon CloudWatch for logging and monitoring
- AWS IAM for permissions
- AWS IoT Core

### Data
The system will generate an operational dataset containing information such as:

- redemption ID
- timestamp
- redemption status
- cup dispense status
- pod dispense status
- number of attempts
- dispense latency
- error type
- inventory changes
- network status
- machine state

This data will be used for:

- reliability testing
- error analysis
- inventory tracking
- usage analysis
- system improvements

---

## High-Level Architecture

```text
DS3 Member
    ↓
DS3 Website / Member Portal
    ↓
Supabase
    ↓
Amazon API Gateway
    ↓
AWS Lambda
    ↓
ESP32
    ↓
Servo / Motor Mechanisms
    ↓
Cup + Coffee Pod Dispensed
    ↓
Sensors Confirm Dispense
    ↓
Backend / Supabase Updated
