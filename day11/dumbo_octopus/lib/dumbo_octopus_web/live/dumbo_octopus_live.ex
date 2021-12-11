defmodule DumboOctopusWeb.DumboOctopusLive do
  use DumboOctopusWeb, :live_view

  alias DumboOctopus.Simulation

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        input_data: "",
        step: 0,
        octopi: [],
        flashes: 0
      )

    {:ok, socket}
  end

  def handle_event("update-input", %{"puzzle-input" => input}, socket) do
    step = socket.assigns[:step]

    socket = update_sim_in_socket(socket, input, step)

    {:noreply, socket}
  end

  def handle_event("update-step", %{"step" => step}, socket) do
    input = socket.assigns[:input_data]

    step =
      case Integer.parse(step) do
        :error -> 0
        {step, _} -> step
      end

    socket = update_sim_in_socket(socket, input, step)

    {:noreply, socket}
  end

  defp update_sim_in_socket(socket, input_data, step) do
    {sim, flashes} =
      input_data
      |> Simulation.parse_input()
      |> Simulation.step_with_count(step)

    assign(socket,
      input_data: input_data,
      step: step,
      octopi: Simulation.octopi_values(sim),
      flashes: flashes
    )
  end

  def octopi_params(value) do
    value = if value == 0, do: 10, else: value || 0

    style = "opacity: #{10 * value}%"

    style = if value == 10, do: "#{style};text-shadow: 0 0 1em white;", else: style

    [title: value, style: style]
  end
end
