defmodule TestedCell do
  use Kino.JS, assets_path: "lib/assets"
  use Kino.JS.Live
  use Kino.SmartCell, name: "Tested Cell"

  @impl true
  def init(attrs, ctx) do
    assertions = attrs["assertions"] || ""
    solution = attrs["solution"] || ""
    default_source = attrs["default_source"] || ""

    {:ok,
     assign(ctx,
       assertions: assertions,
       solution: solution,
       attempts: 0,
       display_editors: TestedCell.Control.editors_enabled?()
     ),
     editor: [
       attribute: "code",
       language: "elixir",
       default_source: default_source,
       placement: :top
     ]}
  end

  # Run when the TestedCell is evaluated
  @impl true
  def scan_eval_result(server, _eval_result) do
    send(server, :attempt)
  end

  @impl true
  def handle_connect(ctx) do
    {:ok,
     %{
       assertions: ctx.assigns.assertions,
       solution: ctx.assigns.solution,
       solution_html: solution_to_html(ctx.assigns.solution),
       attempts: ctx.assigns.attempts,
       display_editors: ctx.assigns.display_editors
     }, ctx}
  end

  @impl true
  def handle_event("update_assertions", %{"assertions" => assertions}, ctx) do
    broadcast_event(ctx, "update_assertions", %{"assertions" => assertions})
    {:noreply, assign(ctx, assertions: assertions)}
  end

  @impl true
  def handle_event("update_solution", %{"solution" => solution}, ctx) do
    solution_html = solution_to_html(solution)

    broadcast_event(ctx, "update_solution", %{
      "solution" => solution,
      "solution_html" => solution_html
    })

    {:noreply, assign(ctx, solution: solution)}
  end

  @impl true
  def handle_info(:attempt, ctx) do
    ExUnit.start(auto_run: false)

    {%{failures: failures}, _} =
      """
      defmodule Attempt do
        use ExUnit.Case

        @tag capture_log: false
        test "check attempt" do
          #{ctx.assigns["code"]}
          #{ctx.assigns["assertions"]}
        end
      end

      ExUnit.run() |> IO.inspect(label: "TESTS")
      """
      |> Code.eval_string()

    failed = failures >= 0
    # attempts start at 1, so we subtract 1
    if ctx.assigns.attempts - 1 >= TestedCell.Control.max_attempts() do
      broadcast_event(ctx, "display_solution", %{solution: ctx.assigns.solution})
    end

    if failed do
      {:noreply, assign(ctx, attempts: ctx.assigns.attempts + 1)}
    else
      {:noreply, ctx}
    end
  end

  # persist the assertions and solution
  @impl true
  def to_attrs(ctx) do
    %{
      "assertions" => ctx.assigns.assertions,
      "solution" => ctx.assigns.solution
    }
  end

  @impl true
  def to_source(attrs) do
    """
    ExUnit.start(auto_run: false)
    defmodule Assertion do
      use ExUnit.Case

      test "" do
        #{attrs["code"]}
        #{attrs["assertions"]}
      end
    end

    ExUnit.run()

    # Make variables and modules defined in the test available.
    # Also allows for exploration using the output of the cell.
    #{attrs["code"]}
    """
  end

  defp solution_to_html(solution) do
    solution
    |> String.trim()
    |> Makeup.highlight()
    |> String.replace("\n", "\n<span class=\"line-number\"></span>")
    |> String.replace("<code>", "<code><span class=\"line-number\"></span>")
  end
end
