# AGENTS.md

This file provides guidance to AI coding assistants when working with code in this repository.

## Overview

Example Phoenix application demonstrating the BB (Beam Bots) robotics framework with a WidowX 200 robot arm. This project integrates `bb_liveview` to provide a real-time web dashboard for robot control and 3D visualisation.

## Commands

```bash
mix setup              # Install deps and build assets
mix phx.server         # Start Phoenix server (localhost:4000)
iex -S mix phx.server  # Start with IEx shell
mix test               # Run all tests
mix test path:42       # Run single test at line
mix precommit          # Pre-commit checks (compile warnings, format, test)
```

## Architecture

### Robot Definition (`lib/bb/example/wx200/robot.ex`)

The robot is defined using BB's Spark DSL with four main sections:

- **parameters** - Configures bridges (servo communication adapters)
- **commands** - Defines available robot commands with state machine constraints
- **controllers** - Hardware communication (Robotis/Dynamixel via serial)
- **topology** - URDF-like kinematic chain with joints, links, visuals, and actuators

The robot starts as a supervised child in `application.ex` and exposes commands like `BB.Example.WX200.Robot.home()`.

### Web Dashboard

The router mounts `bb_dashboard("/", robot: BB.Example.WX200.Robot)` from `bb_liveview`, providing:
- Real-time joint state visualisation
- 3D robot model rendering
- Command execution interface

### Command Handlers (`lib/bb/example/wx200/command/`)

Commands implement `BB.Command` behaviour with `handle_command/2`. They receive a context containing the compiled robot struct and can send motion commands via `BB.Motion`.

## Physical Units

BB uses the `~u` sigil for physical quantities throughout the DSL:

```elixir
~u(0.1 meter)
~u(90 degree)
~u(180 degree_per_second)
~u(8 newton_meter)
```

## Dependencies

Local path dependencies to sibling BB repositories:
- `bb` - Core framework
- `bb_liveview` - Phoenix LiveView dashboard
- `bb_servo_robotis` - Dynamixel servo driver
- `bb_ik_fabrik` - Inverse kinematics
- `robotis` - Dynamixel protocol

See parent workspace `CLAUDE.md` for ecosystem documentation.
