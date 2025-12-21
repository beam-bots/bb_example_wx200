defmodule BB.Example.WX200.Command.Home do
  @moduledoc """
  Command handler to move all joints to their neutral (zero) positions.

  This command sends position 0 to all moveable joints, returning the robot
  to its home configuration.

  ## Usage

      commands do
        command :home do
          handler BB.Example.WX200.Command.Home
          allowed_states [:idle]
        end
      end

  Then execute:

      {:ok, task} = BB.Example.WX200.Robot.home()
      {:ok, :homed} = Task.await(task)

  """
  @behaviour BB.Command

  alias BB.Robot.Joint

  @impl true
  def handle_command(_goal, context) do
    positions =
      context.robot.joints
      |> Enum.filter(fn {_name, joint} -> Joint.movable?(joint) end)
      |> Map.new(fn {name, _joint} -> {name, 0.0} end)

    BB.Motion.send_positions(context, positions, delivery: :direct)

    {:ok, :homed}
  end
end
