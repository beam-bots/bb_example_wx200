# SPDX-FileCopyrightText: 2026 James Harton
#
# SPDX-License-Identifier: Apache-2.0

defmodule BB.Example.WX200.Command.Home do
  @moduledoc """
  Command handler to move all joints to their neutral (zero) positions.

  This command sends position 0 to all moveable joints, returning the robot
  to its home configuration. It waits for every actuator to accept its target,
  so a joint that refuses - a disarmed robot, a servo that has gone - fails the
  command rather than leaving it claiming success.

  ## Usage

      commands do
        command :home do
          handler BB.Example.WX200.Command.Home
          allowed_states [:idle]
        end
      end

  Then execute:

      {:ok, cmd} = BB.Example.WX200.Robot.home()
      {:ok, :homed} = BB.Command.await(cmd)

  """
  use BB.Command

  alias BB.Robot.Joint

  @impl BB.Command
  def handle_command(_goal, context, state) do
    positions =
      context.robot.joints
      |> Enum.filter(fn {_name, joint} -> Joint.movable?(joint) end)
      |> Map.new(fn {name, _joint} -> {name, 0.0} end)

    {:stop, :normal, %{state | result: home_result(context, positions)}}
  end

  @impl BB.Command
  def result(%{result: {:error, _} = error}), do: error
  def result(%{result: result}), do: {:ok, result}

  defp home_result(context, positions) do
    case BB.Motion.send_positions(context, positions) do
      :ok -> :homed
      {:error, _} = error -> error
    end
  end
end
