defmodule BB.Example.WX200.Command.DisableTorque do
  @moduledoc """
  Command handler to disable holding torque on all Robotis servos.

  This command writes `torque_enable: false` to all servos registered
  with the Dynamixel controller, allowing them to be moved freely by hand.

  ## Usage

      commands do
        command :disable_torque do
          handler BB.Example.WX200.Command.DisableTorque
          allowed_states [:idle]
        end
      end

  Then execute:

      {:ok, task} = BB.Example.WX200.Robot.disable_torque()
      {:ok, :torque_disabled} = Task.await(task)

  """
  @behaviour BB.Command

  @controller :dynamixel

  @impl true
  def handle_command(_goal, context) do
    robot = context.robot_module

    with {:ok, servo_ids} <- BB.Process.call(robot, @controller, :list_servos),
         :ok <- disable_all_servos(robot, servo_ids) do
      {:ok, :torque_disabled}
    end
  end

  defp disable_all_servos(robot, servo_ids) do
    results =
      Enum.map(servo_ids, fn servo_id ->
        BB.Process.call(robot, @controller, {:write, servo_id, :torque_enable, false})
      end)

    case Enum.find(results, &match?({:error, _}, &1)) do
      nil -> :ok
      error -> error
    end
  end
end
