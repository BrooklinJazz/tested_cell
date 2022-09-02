defmodule TestedCell do
  use Kino.JS, assets_path: "lib/assets"
  use Kino.JS.Live
  use Kino.SmartCell, name: "Tested Cell"
  @max_attempts 3

  @impl true
  def init(attrs, ctx) do
    assertions = attrs["assertions"] || ""
    solution = attrs["solution"] || ""
    default_source = attrs["default_source"] || ""
    title = attrs["title"] || "Exercise"

    {:ok,
     assign(ctx,
       assertions: assertions,
       solution: solution,
       title: title,
       attempts: 0,
       display_editors: false
     ),
     editor: [
       attribute: "code",
       language: "elixir",
       default_source: default_source,
       placement: :bottom
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
       title: ctx.assigns.title,
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

  def handle_event("update_title", %{"title" => title}, ctx) do
    broadcast_event(ctx, "update_title", %{"title" => title})
    {:noreply, assign(ctx, title: title)}
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
    # attempts start at 1, so we subtract 1
    if ctx.assigns.attempts - 1 >= @max_attempts do
      broadcast_event(ctx, "display_solution", %{solution: ctx.assigns.solution})
    end

    {:noreply, assign(ctx, attempts: ctx.assigns.attempts + 1)}
  end

  @impl true
  def handle_info({:display_editors, display}, ctx) do
    broadcast_event(ctx, "display_editors", %{display: display})

    {:noreply, ctx}
  end

  # persist the assertions and solution
  @impl true
  def to_attrs(ctx) do
    %{
      "assertions" => ctx.assigns.assertions,
      "solution" => ctx.assigns.solution,
      "title" => ctx.assigns.title,
      "attempts" => ctx.assigns.attempts
    }
  end

  @impl true
  def to_source(attrs) do
    """
    ExUnit.start(auto_run: false)

    defmodule Assertion do
      use ExUnit.Case

      test "#{attrs["title"]}" do
        try do
          Process.flag(:trap_exit, true)
          #{attrs["code"]}
          #{attrs["assertions"]}
        catch
          error ->
            flunk(\"\"\"
              Your solution threw the following error:

              \#\{inspect(error)\}
            \"\"\")

          :exit, {error, {GenServer, message_type, [_pid, message, _timeout]}} ->
              flunk(\"\"\"
                GenServer crashed with the following error:

                \#\{inspect(error)\}

                When it recieved: \#\{inspect(message)\} \#\{message_type\}

                Likely you need to define the corresponding handler for \#\{inspect(message)\}.

                Ensure you defined a handle_call/3, handle_info/2, or handle_cast/2 or appropriate handler function.

                  def handle_call(:message, _from, state) do
                    ...
                  end

                Also ensure you call GenServer.call/2, GenServer.cast/2, or otherwise send the message correctly.

                  GenServer.call(pid, :message)
            \"\"\")
          :exit, error ->
            flunk(\"\"\"
              Unhandled exit with the following error:

              \#\{inspect(error)\}
            \"\"\")
        after
          # all warnings and errors are printed to the previous Kino Frame
          # to avoid cluttering the test results display.
          Process.sleep(10)
          Kino.render(Kino.Markdown.new("### Test Results \n<hr/>"))
        end
      end
    end

    ExUnit.run()

    # Make variables and modules defined in the test available.
    # Also allows for exploration using the output of the cell.
    # Unfortunately, this results in duplication of warnings.
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
