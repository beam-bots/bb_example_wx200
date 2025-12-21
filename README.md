<!--
SPDX-FileCopyrightText: 2025 James Harton

SPDX-License-Identifier: Apache-2.0
-->

<img src="https://github.com/beam-bots/bb/blob/main/logos/beam_bots_logo.png?raw=true" alt="Beam Bots Logo" width="250" />

# BB Example: WidowX 200

Example Phoenix application demonstrating the [Beam Bots](https://github.com/beam-bots/bb) robotics framework with a WidowX 200 robot arm.

## Features

- **Complete robot definition** - 6-DOF arm with gripper using the BB DSL
- **Web dashboard** - Real-time control and 3D visualisation via `bb_liveview`
- **Dynamixel integration** - Hardware control via `bb_servo_robotis`
- **Custom commands** - Home position, demo circle, and torque control

## Requirements

- Elixir ~> 1.15
- WidowX 200 robot arm (or run without hardware for simulation)
- U2D2 USB adapter at `/dev/ttyUSB0` (configurable in robot definition)

## Quick Start

```bash
# Install dependencies and build assets
mix setup

# Start the Phoenix server
mix phx.server
```

Visit [localhost:4000](http://localhost:4000) to access the robot dashboard.

## Robot Definition

The robot is defined in `lib/bb/example/wx200/robot.ex` using the BB DSL:

```elixir
defmodule BB.Example.WX200.Robot do
  use BB

  parameters do
    bridge(:robotis, {BB.Servo.Robotis.Bridge, controller: :dynamixel})
  end

  commands do
    command :home do
      handler(BB.Example.WX200.Command.Home)
      allowed_states([:idle])
    end
    # ... additional commands
  end

  controllers do
    controller(:dynamixel, {BB.Servo.Robotis.Controller,
      port: "/dev/ttyUSB0",
      baud_rate: 1_000_000,
      control_table: :xm430
    })
  end

  topology do
    link :base_link do
      joint :waist do
        # ... joint definition with actuator
        link :shoulder_link do
          # ... nested kinematic chain
        end
      end
    end
  end
end
```

## Commands

| Command | Description | Allowed States |
|---------|-------------|----------------|
| `arm` | Enable torque and prepare for motion | `[:disarmed]` |
| `disarm` | Disable torque safely | `[:idle]` |
| `home` | Move all joints to zero position | `[:idle]` |
| `demo_circle` | Execute circular motion demo | `[:idle]` |
| `disable_torque` | Disable servo torque without state change | `[:idle, :disarmed]` |

Execute commands via the web dashboard or programmatically:

```elixir
{:ok, task} = BB.Example.WX200.Robot.home()
{:ok, :homed} = Task.await(task)
```

## Project Structure

```
lib/
├── bb/example/wx200/
│   ├── robot.ex              # Robot DSL definition
│   └── command/              # Custom command handlers
│       ├── home.ex
│       ├── demo_circle.ex
│       └── disable_torque.ex
├── bb_example_wx200.ex       # Application context
├── bb_example_wx200/
│   └── application.ex        # Supervision tree
└── bb_example_wx200_web/     # Phoenix web layer
    ├── router.ex             # Mounts bb_dashboard
    └── ...
```

## Development

```bash
mix test                      # Run tests
mix test path/to/test.exs:42  # Run single test at line
mix precommit                 # Pre-commit checks (compile, format, test)
```

## Related Packages

- [bb](https://github.com/beam-bots/bb) - Core framework
- [bb_liveview](https://github.com/beam-bots/bb_liveview) - Phoenix LiveView dashboard
- [bb_servo_robotis](https://github.com/beam-bots/bb_servo_robotis) - Dynamixel servo driver
- [bb_ik_fabrik](https://github.com/beam-bots/bb_ik_fabrik) - FABRIK inverse kinematics
