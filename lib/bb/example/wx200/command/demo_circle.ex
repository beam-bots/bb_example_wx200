defmodule BB.Example.WX200.Command.DemoCircle do
  @moduledoc """
  Demo command that traces a circle using FABRIK IK.

  First moves to a safe starting position, then traces a small circle
  in the XZ plane (vertical plane in front of the robot).

  ## Goal Parameters

  Optional:
  - `radius` - Circle radius in metres (default: `0.03`)
  - `points` - Number of points around the circle (default: `16`)
  - `delay` - Delay between points in milliseconds (default: `150`)

  ## Usage

      {:ok, task} = BB.Example.WX200.Robot.demo_circle()
      {:ok, :complete} = Task.await(task, 30_000)
  """
  @behaviour BB.Command

  alias BB.IK.FABRIK.Motion
  alias BB.Math.Vec3

  # Safe starting position - comfortably within workspace
  # X forward, Y=0 (centred), Z at reasonable height
  @start_x 0.25
  @start_y 0.0
  @start_z 0.20

  @default_radius 0.03
  @default_points 16
  @default_delay 150

  @impl true
  def handle_command(goal, context) do
    radius = Map.get(goal, :radius, @default_radius)
    points = Map.get(goal, :points, @default_points)
    delay = Map.get(goal, :delay, @default_delay)

    start_position = Vec3.new(@start_x, @start_y, @start_z)

    # First move to the starting position
    case Motion.move_to(context, :ee_link, start_position, delivery: :direct) do
      {:ok, _meta} ->
        Process.sleep(500)

        # Generate circle points in XZ plane (vertical, forward-back motion)
        targets = generate_circle_points(@start_x, @start_y, @start_z, radius, points)

        case execute_path(context, targets, delay) do
          :ok ->
            # Return to start position
            Motion.move_to(context, :ee_link, start_position, delivery: :direct)
            {:ok, :complete}

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason, _meta} ->
        {:error, {:failed_to_reach_start, reason}}
    end
  end

  defp generate_circle_points(cx, cy, cz, radius, num_points) do
    # Circle in XZ plane - Y stays constant
    for i <- 0..num_points do
      angle = 2 * :math.pi() * i / num_points
      x = cx + radius * :math.cos(angle)
      z = cz + radius * :math.sin(angle)
      Vec3.new(x, cy, z)
    end
  end

  defp execute_path(context, targets, delay) do
    Enum.reduce_while(targets, :ok, fn target, :ok ->
      case Motion.move_to(context, :ee_link, target, delivery: :direct) do
        {:ok, _meta} ->
          Process.sleep(delay)
          {:cont, :ok}

        {:error, reason, _meta} ->
          {:halt, {:error, {:ik_failed, target, reason}}}
      end
    end)
  end
end
